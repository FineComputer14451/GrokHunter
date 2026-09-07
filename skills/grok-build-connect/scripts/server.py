#!/usr/bin/env python3
"""GrokHunter Grok Build Connect — HTTP MCP bridging Grok Bot to the grok CLI.

Works on Termux and desktop (Linux/macOS). Binds 127.0.0.1 by default;
put Cloudflare/ngrok in front. Requires Authorization: Bearer <token>.
"""
from __future__ import annotations

import os
import re
import secrets
import shutil
import subprocess
import sys
from pathlib import Path

HOST = os.environ.get("GROK_BUILD_CONNECT_HOST", "127.0.0.1")
PORT = int(os.environ.get("GROK_BUILD_CONNECT_PORT", "8766"))
TOKEN = os.environ.get("GROK_BUILD_CONNECT_TOKEN", "").strip()
HOME = Path(os.environ.get("HOME", str(Path.home()))).resolve()
EXTRA_ROOTS = [
    Path(p).resolve()
    for p in os.environ.get("GROK_BUILD_CONNECT_ROOTS", "").split(":")
    if p.strip()
]
MAX_BYTES = int(os.environ.get("GROK_BUILD_CONNECT_MAX_BYTES", str(256 * 1024)))
ASK_TIMEOUT = int(os.environ.get("GROK_BUILD_CONNECT_ASK_TIMEOUT", "180"))
ASK_MAX_CHARS = int(os.environ.get("GROK_BUILD_CONNECT_ASK_MAX_CHARS", "8000"))
CWD_DEFAULT = Path(os.environ.get("GROK_BUILD_CONNECT_CWD", str(HOME))).expanduser().resolve()

# Optional override for grok binary
GROK_BIN = os.environ.get("GROK_BUILD_CONNECT_GROK", "").strip()


def _grok() -> str:
    if GROK_BIN:
        return GROK_BIN
    found = shutil.which("grok")
    if not found:
        raise FileNotFoundError(
            "grok CLI not found on PATH. Install Grok Build, then re-run start.sh."
        )
    return found


def _roots() -> list[Path]:
    roots = [HOME, CWD_DEFAULT, *EXTRA_ROOTS]
    prefix = os.environ.get("PREFIX")
    if prefix:
        roots.append(Path(prefix).resolve())
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
        raw = CWD_DEFAULT / raw
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
            "GROK_BUILD_CONNECT_TOKEN missing or too short (min 24 chars).\n"
            'Generate: python3 -c "import secrets; print(secrets.token_urlsafe(32))"',
            file=sys.stderr,
        )
        sys.exit(2)


def _run(argv: list[str], timeout: int | None = None, cwd: Path | None = None) -> str:
    try:
        proc = subprocess.run(
            argv,
            capture_output=True,
            text=True,
            timeout=timeout or 90,
            cwd=str(cwd or CWD_DEFAULT),
            env={**os.environ, "TERM": os.environ.get("TERM", "xterm-256color"), "CI": "1"},
        )
    except FileNotFoundError as e:
        return f"not found: {e}"
    except subprocess.TimeoutExpired:
        return f"timeout after {timeout or 90}s"
    out = (proc.stdout or "") + (("\n" + proc.stderr) if proc.stderr else "")
    raw = out.encode("utf-8", errors="replace")
    if len(raw) > MAX_BYTES:
        out = raw[:MAX_BYTES].decode("utf-8", errors="replace") + "\n…[truncated]"
    return f"exit {proc.returncode}\n{out}".rstrip()


def main() -> None:
    _check_token()
    try:
        from mcp.server.fastmcp import FastMCP
        from mcp.server.transport_security import TransportSecuritySettings
        from starlette.middleware.base import BaseHTTPMiddleware
        from starlette.requests import Request
        from starlette.responses import JSONResponse
        from starlette.routing import Route
        import uvicorn
    except ImportError as e:
        print("Missing deps. Run: pip install -r requirements.txt\n" + str(e), file=sys.stderr)
        sys.exit(1)

    # Cloudflare quick tunnels send Host: *.trycloudflare.com (see termux-connect fix).
    transport_security = TransportSecuritySettings(enable_dns_rebinding_protection=False)
    extra_hosts = [
        h.strip()
        for h in os.environ.get("GROK_BUILD_CONNECT_ALLOWED_HOSTS", "").split(",")
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
        "grokhunter-grok-build-connect",
        instructions=(
            "Scoped tools for the local Grok Build (`grok`) CLI on Termux or desktop. "
            "Prefer grok_version / grok_plugin_list / grok_ask. Paths are jailed to HOME."
        ),
        host=HOST,
        port=PORT,
        streamable_http_path="/mcp",
        stateless_http=True,
        transport_security=transport_security,
    )

    @mcp.tool()
    def grok_version() -> str:
        """Return `grok --version` and resolved binary path."""
        g = _grok()
        return f"binary={g}\n" + _run([g, "--version"], timeout=30)

    @mcp.tool()
    def grok_plugin_list() -> str:
        """List installed Grok Build plugins (`grok plugin list`)."""
        return _run([_grok(), "plugin", "list"], timeout=60)

    @mcp.tool()
    def grok_mcp_list() -> str:
        """List MCP servers configured in Grok Build (`grok mcp list`)."""
        return _run([_grok(), "mcp", "list"], timeout=60)

    @mcp.tool()
    def grok_mcp_doctor() -> str:
        """Diagnose Grok Build MCP config (`grok mcp doctor`)."""
        return _run([_grok(), "mcp", "doctor"], timeout=90)

    @mcp.tool()
    def grok_ask(prompt: str, model: str = "", cwd: str = "") -> str:
        """Single-turn headless `grok -p` (prints response and exits). Caps prompt length."""
        p = (prompt or "").strip()
        if not p:
            return "empty prompt"
        if len(p) > ASK_MAX_CHARS:
            return f"prompt too long (max {ASK_MAX_CHARS} chars)"
        work = _jail(cwd) if cwd.strip() else CWD_DEFAULT
        if not work.is_dir():
            return f"cwd not a directory: {work}"
        argv = [_grok(), "-p", p, "--output-format", "text"]
        if model.strip():
            argv.extend(["-m", model.strip()])
        return _run(argv, timeout=ASK_TIMEOUT, cwd=work)

    @mcp.tool()
    def list_dir(path: str = ".") -> str:
        """List a directory under the jail (HOME / PREFIX / configured cwd)."""
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

    class BearerAuth(BaseHTTPMiddleware):
        async def dispatch(self, request: Request, call_next):
            if request.url.path in {"/healthz", "/"}:
                return await call_next(request)
            auth = request.headers.get("authorization", "")
            expected = f"Bearer {TOKEN}"
            if not secrets.compare_digest(auth, expected):
                return JSONResponse({"error": "unauthorized"}, status_code=401)
            return await call_next(request)

    async def healthz(request: Request):
        grok_ok = False
        try:
            _grok()
            grok_ok = True
        except Exception:
            grok_ok = False
        return JSONResponse(
            {
                "ok": True,
                "service": "grokhunter-grok-build-connect",
                "grok_on_path": grok_ok,
                "port": PORT,
            }
        )

    app = mcp.streamable_http_app()
    app.add_middleware(BearerAuth)
    app.routes.insert(0, Route("/healthz", healthz, methods=["GET"]))

    print(
        f"grok-build-connect listening on http://{HOST}:{PORT}/mcp "
        f"(cwd={CWD_DEFAULT}, jail={_roots()})",
        flush=True,
    )
    uvicorn.run(app, host=HOST, port=PORT, log_level="info")


if __name__ == "__main__":
    main()
