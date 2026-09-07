#!/usr/bin/env python3
"""GrokHunter Termux Connect — scoped HTTP MCP for Grok Bot.

Binds to 127.0.0.1 by default. Put Cloudflare/ngrok in front.
Requires Authorization: Bearer <token>.
"""
from __future__ import annotations

import os
import re
import secrets
import shlex
import subprocess
import sys
from pathlib import Path

# --- config ---
HOST = os.environ.get("TERMUX_CONNECT_HOST", "127.0.0.1")
PORT = int(os.environ.get("TERMUX_CONNECT_PORT", "8765"))
TOKEN = os.environ.get("TERMUX_CONNECT_TOKEN", "").strip()
HOME = Path(os.environ.get("HOME", str(Path.home()))).resolve()
# Extra allowed roots (colon-separated), e.g. Termux PREFIX
EXTRA_ROOTS = [
    Path(p).resolve()
    for p in os.environ.get("TERMUX_CONNECT_ROOTS", "").split(":")
    if p.strip()
]
MAX_BYTES = int(os.environ.get("TERMUX_CONNECT_MAX_BYTES", str(256 * 1024)))
SHELL_TIMEOUT = int(os.environ.get("TERMUX_CONNECT_SHELL_TIMEOUT", "60"))
# If set, shell is disabled and only doctor/status/file tools work
SHELL_MODE = os.environ.get("TERMUX_CONNECT_SHELL", "allowlist").strip().lower()
# allowlist: only these command prefixes
ALLOW_PREFIXES = [
    "grokhunter ",
    "grok ",
    "which ",
    "command -v ",
    "uname ",
    "df ",
    "pwd",
    "ls ",
    "ls\t",
    "echo ",
    "cat ",
    "head ",
    "tail ",
    "test ",
    "true",
    "false",
    "id",
    "whoami",
    "date",
    "env | ",
    "printenv ",
]

DENY_RE = re.compile(
    r"(^|[;&|`$\n])\s*(rm\s|dd\s|mkfs|reboot|shutdown|su\b|sudo\b|curl\s|wget\s|"
    r"python\s+-c|perl\s+-e|base64\s+-d|nc\s|ncat\s|chmod\s+[0-7]*[2367]|chown\s)",
    re.I,
)


def _roots() -> list[Path]:
    roots = [HOME, *EXTRA_ROOTS]
    prefix = os.environ.get("PREFIX")
    if prefix:
        roots.append(Path(prefix).resolve())
    # de-dupe
    out: list[Path] = []
    seen = set()
    for r in roots:
        s = str(r)
        if s not in seen:
            seen.add(s)
            out.append(r)
    return out


def _jail(path: str) -> Path:
    raw = Path(path).expanduser()
    if not raw.is_absolute():
        raw = HOME / raw
    resolved = raw.resolve()
    for root in _roots():
        try:
            resolved.relative_to(root)
            return resolved
        except ValueError:
            continue
    raise PermissionError(f"path outside jail: {path}")


def _check_token() -> None:
    if not TOKEN or len(TOKEN) < 24:
        print(
            "TERMUX_CONNECT_TOKEN missing or too short (min 24 chars).\n"
            "Generate: python3 -c \"import secrets; print(secrets.token_urlsafe(32))\"",
            file=sys.stderr,
        )
        sys.exit(2)


def _shell_ok(cmd: str) -> None:
    if SHELL_MODE in ("off", "0", "false", "no"):
        raise PermissionError("shell disabled (TERMUX_CONNECT_SHELL=off)")
    c = cmd.strip()
    if not c:
        raise ValueError("empty command")
    if "\n" in c or "\r" in c:
        raise PermissionError("multiline shell blocked")
    if DENY_RE.search(c):
        raise PermissionError("command matched deny pattern")
    if SHELL_MODE == "open":
        return
    # allowlist
    ok = False
    for p in ALLOW_PREFIXES:
        if c == p.strip() or c.startswith(p):
            ok = True
            break
    if not ok:
        raise PermissionError(
            "command not on allowlist; set TERMUX_CONNECT_SHELL=open only if you accept the risk"
        )


def main() -> None:
    _check_token()
    try:
        from mcp.server.fastmcp import FastMCP
        from starlette.middleware.base import BaseHTTPMiddleware
        from starlette.requests import Request
        from starlette.responses import JSONResponse
        import uvicorn
    except ImportError as e:
        print(
            "Missing deps. Run: pip install -r requirements.txt\n" + str(e),
            file=sys.stderr,
        )
        sys.exit(1)

    # FastMCP defaults DNS-rebinding Host allowlist to 127.0.0.1/localhost only.
    # Cloudflare quick tunnels send Host: *.trycloudflare.com → 421 Invalid Host.
    # Bind stays loopback; Bearer auth remains the access gate.
    from mcp.server.transport_security import TransportSecuritySettings

    transport_security = TransportSecuritySettings(
        enable_dns_rebinding_protection=False,
    )
    extra_hosts = [
        h.strip()
        for h in os.environ.get("TERMUX_CONNECT_ALLOWED_HOSTS", "").split(",")
        if h.strip()
    ]
    if extra_hosts:
        transport_security = TransportSecuritySettings(
            enable_dns_rebinding_protection=True,
            allowed_hosts=[
                f"{HOST}:{PORT}",
                HOST,
                "localhost",
                f"localhost:{PORT}",
                "127.0.0.1:*",
                "localhost:*",
                *extra_hosts,
            ],
        )

    mcp = FastMCP(
        "grokhunter-termux-connect",
        instructions=(
            "Scoped tools for GrokHunter on Termux. Paths are jailed to HOME/PREFIX. "
            "Shell is allowlisted by default. Prefer grokhunter_doctor / grokhunter_status."
        ),
        host=HOST,
        port=PORT,
        streamable_http_path="/mcp",
        stateless_http=True,
        transport_security=transport_security,
    )

    @mcp.tool()
    def grokhunter_status() -> str:
        """Run `grokhunter status` on the phone (preferred health check)."""
        return _run(["grokhunter", "status"])

    @mcp.tool()
    def grokhunter_doctor() -> str:
        """Run `grokhunter doctor` on the phone."""
        return _run(["grokhunter", "doctor"])

    @mcp.tool()
    def list_dir(path: str = ".") -> str:
        """List a directory under the jail (HOME / PREFIX)."""
        target = _jail(path)
        if not target.is_dir():
            return f"not a directory: {target}"
        lines = []
        for child in sorted(target.iterdir(), key=lambda p: p.name.lower())[:500]:
            kind = "d" if child.is_dir() else "f"
            lines.append(f"{kind}\t{child.name}")
        return "\n".join(lines) or "(empty)"

    @mcp.tool()
    def read_file(path: str, max_bytes: int = 65536) -> str:
        """Read a text file under the jail (capped)."""
        target = _jail(path)
        if not target.is_file():
            return f"not a file: {target}"
        n = min(max(1, max_bytes), MAX_BYTES)
        data = target.read_bytes()[: n + 1]
        truncated = len(data) > n
        text = data[:n].decode("utf-8", errors="replace")
        if truncated:
            text += "\n…[truncated]"
        return text

    @mcp.tool()
    def write_file(path: str, content: str, mode: str = "overwrite") -> str:
        """Write a text file under the jail. mode=overwrite|append. Blocks paths with secrets.env name unless TERMUX_CONNECT_ALLOW_SECRETS=1."""
        target = _jail(path)
        if target.name in {"secrets.env", ".env"} and os.environ.get("TERMUX_CONNECT_ALLOW_SECRETS") != "1":
            raise PermissionError("refusing to write secrets.env / .env")
        target.parent.mkdir(parents=True, exist_ok=True)
        data = content.encode("utf-8")
        if len(data) > MAX_BYTES:
            raise ValueError(f"content exceeds {MAX_BYTES} bytes")
        if mode == "append":
            with target.open("ab") as f:
                f.write(data)
        else:
            target.write_bytes(data)
        return f"wrote {len(data)} bytes → {target}"

    @mcp.tool()
    def shell(command: str) -> str:
        """Run an allowlisted shell command (default). Prefer grokhunter_* tools."""
        _shell_ok(command)
        return _run(["bash", "-lc", command])

    def _run(argv: list[str]) -> str:
        try:
            proc = subprocess.run(
                argv,
                capture_output=True,
                text=True,
                timeout=SHELL_TIMEOUT,
                cwd=str(HOME),
                env={**os.environ, "TERM": os.environ.get("TERM", "xterm-256color")},
            )
        except FileNotFoundError as e:
            return f"not found: {e}"
        except subprocess.TimeoutExpired:
            return f"timeout after {SHELL_TIMEOUT}s"
        out = (proc.stdout or "") + (("\n" + proc.stderr) if proc.stderr else "")
        if len(out.encode("utf-8", errors="replace")) > MAX_BYTES:
            out = out.encode("utf-8", errors="replace")[:MAX_BYTES].decode("utf-8", errors="replace") + "\n…[truncated]"
        return f"exit {proc.returncode}\n{out}".rstrip()

    class BearerAuth(BaseHTTPMiddleware):
        async def dispatch(self, request: Request, call_next):
            if request.url.path in {"/healthz", "/"}:
                return await call_next(request)
            auth = request.headers.get("authorization", "")
            expected = f"Bearer {TOKEN}"
            # constant-time compare
            if not secrets.compare_digest(auth, expected):
                return JSONResponse({"error": "unauthorized"}, status_code=401)
            return await call_next(request)

    async def healthz(request: Request):
        return JSONResponse({"ok": True, "service": "grokhunter-termux-connect"})

    app = mcp.streamable_http_app()
    app.add_middleware(BearerAuth)
    # health route
    from starlette.routing import Route

    app.routes.insert(0, Route("/healthz", healthz, methods=["GET"]))

    print(
        f"termux-connect listening on http://{HOST}:{PORT}/mcp "
        f"(shell={SHELL_MODE}, jail={_roots()})",
        flush=True,
    )
    uvicorn.run(app, host=HOST, port=PORT, log_level="info")


if __name__ == "__main__":
    main()
