#!/usr/bin/env python3
"""Grok Build TUI status line for the GrokHunter lab.

Reads Grok's JSON payload on stdin. Prints one compact row. Never reads
secrets.env, never prints session ids or unknown keys, never hits the network.
"""
from __future__ import annotations

import json
import os
import re
import subprocess
import sys
import time
from pathlib import Path

SEP = " │ "
TIMER_SEP = " · "
ANSI_RE = re.compile(r"\x1b\[[0-9;]*m")
OURS_CACHE_PREFIX = "grokhunter-statusline-"
GIT_TTL_SEC = 5
MODEL_MAX = 16
COST_HIDE_BELOW = 0.005
CTX_WARN_DEFAULT = 80


def _vis_len(text: str) -> int:
    return len(ANSI_RE.sub("", text))


def _color(code: str, text: str) -> str:
    if os.environ.get("NO_COLOR"):
        return text
    return f"\033[{code}m{text}\033[0m"


def _basename(path: str | None) -> str | None:
    if not path or not isinstance(path, str):
        return None
    name = Path(path.rstrip("/")).name
    return name or None


def _short_model(data: dict) -> str:
    model = data.get("model") if isinstance(data.get("model"), dict) else {}
    name = model.get("display_name") or model.get("id") or ""
    if not isinstance(name, str):
        name = ""
    name = name.strip()
    if not name:
        return "?"
    if len(name) > MODEL_MAX:
        return name[: MODEL_MAX - 1] + "…"
    return name


def _ctx_seg(data: dict) -> str | None:
    cw = data.get("context_window") if isinstance(data.get("context_window"), dict) else {}
    pct = cw.get("used_percentage")
    try:
        n = int(pct)
    except (TypeError, ValueError):
        return None
    n = max(0, min(100, n))
    text = f"{n}%"
    try:
        warn_at = int(cw.get("auto_compact_threshold_percent"))
    except (TypeError, ValueError):
        warn_at = CTX_WARN_DEFAULT
    if n >= warn_at:
        return _color("33", text)
    return text


def _cost_seg(data: dict) -> str | None:
    cost = data.get("cost") if isinstance(data.get("cost"), dict) else {}
    raw = cost.get("total_cost_usd")
    try:
        n = float(raw)
    except (TypeError, ValueError):
        return None
    if n < COST_HIDE_BELOW:
        return None
    return f"${n:.2f}"


def _cwd_seg(data: dict) -> str | None:
    ws = data.get("workspace") if isinstance(data.get("workspace"), dict) else {}
    path = ws.get("current_dir") if isinstance(ws.get("current_dir"), str) else None
    if not path:
        path = data.get("cwd") if isinstance(data.get("cwd"), str) else None
    return _basename(path)


def _now_ms() -> int:
    env = os.environ.get("GROK_STATUSLINE_NOW_MS")
    if env:
        try:
            return int(env)
        except ValueError:
            pass
    return int(time.time() * 1000)


def _timer_seg(data: dict) -> str | None:
    turn = data.get("turn") if isinstance(data.get("turn"), dict) else {}
    started = turn.get("started_at_ms")
    try:
        started_i = int(started)
    except (TypeError, ValueError):
        return None
    elapsed = (_now_ms() - started_i) // 1000
    if elapsed < 0:
        return None
    if elapsed < 60:
        return f"{elapsed}s"
    if elapsed < 3600:
        return f"{elapsed // 60}m"
    return f"{elapsed // 3600}h"


def _git_cache_path(session_id: str) -> Path:
    base = os.environ.get("GROK_STATUSLINE_CACHE") or os.environ.get("TMPDIR") or "/tmp"
    safe = re.sub(r"[^A-Za-z0-9._-]", "_", session_id)[:40] or "none"
    return Path(base) / f"{OURS_CACHE_PREFIX}{safe}"


def _git_dirty(repo: str | None, session_id: str) -> bool:
    if os.environ.get("GROK_STATUSLINE_NO_GIT"):
        return False
    if not repo or not isinstance(repo, str):
        return False
    cache = _git_cache_path(session_id)
    try:
        age = time.time() - cache.stat().st_mtime
        if age <= GIT_TTL_SEC:
            return cache.read_text(encoding="utf-8").strip() == "1"
    except OSError:
        pass
    dirty = False
    try:
        proc = subprocess.run(
            ["git", "-C", repo, "rev-parse", "--is-inside-work-tree"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            timeout=1,
            check=False,
        )
        if proc.returncode == 0:
            diff = subprocess.run(
                ["git", "-C", repo, "diff", "--quiet"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                timeout=1,
                check=False,
            )
            staged = subprocess.run(
                ["git", "-C", repo, "diff", "--cached", "--quiet"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                timeout=1,
                check=False,
            )
            dirty = diff.returncode != 0 or staged.returncode != 0
    except (OSError, subprocess.TimeoutExpired):
        dirty = False
    try:
        cache.parent.mkdir(parents=True, exist_ok=True)
        cache.write_text("1" if dirty else "0", encoding="utf-8")
    except OSError:
        pass
    return dirty


def _branch_seg(data: dict) -> str | None:
    ws = data.get("workspace") if isinstance(data.get("workspace"), dict) else {}
    branch = ws.get("branch")
    if not isinstance(branch, str) or not branch.strip():
        return None
    branch = branch.strip()
    repo = ws.get("current_dir") if isinstance(ws.get("current_dir"), str) else None
    session_id = data.get("session_id") if isinstance(data.get("session_id"), str) else "none"
    if _git_dirty(repo, session_id):
        return f"{branch}*"
    return branch


def _join(parts: list[str], timer: str | None) -> str:
    line = SEP.join(p for p in parts if p)
    if timer:
        return f"{line}{TIMER_SEP}{timer}" if line else timer
    return line


def _fit(items: list[tuple[str, str]], timer: str | None, cols: int) -> str:
    order = ["cwd", "model", "ctx", "cost", "branch"]
    by = dict(items)
    present = [k for k in order if k in by]
    drop_order = ["branch", "cost", "cwd"]
    timers: list[str | None] = [timer, None]
    for t in timers:
        work = list(present)
        for drop in [None] + drop_order:
            if drop is not None and drop in work:
                work.remove(drop)
            line = _join([by[k] for k in work], t)
            if _vis_len(line) <= cols:
                return line
        # shrink model if it is the leftover overflow
        if "model" in by and _vis_len(_join([by[k] for k in work], t)) > cols:
            raw = ANSI_RE.sub("", by["model"])
            for n in range(len(raw), 0, -1):
                by["model"] = raw[:n]
                line = _join([by[k] for k in work], t)
                if _vis_len(line) <= cols:
                    return line
    line = _join([by[k] for k in present if k in ("model", "ctx")], None)
    return line or "?"


def _columns() -> int:
    raw = os.environ.get("COLUMNS") or "80"
    try:
        n = int(raw)
    except ValueError:
        n = 80
    return n if n > 0 else 80


def render(data: dict) -> str:
    items: list[tuple[str, str]] = []
    cwd = _cwd_seg(data)
    if cwd:
        items.append(("cwd", cwd))
    items.append(("model", _short_model(data)))
    ctx = _ctx_seg(data)
    if ctx:
        items.append(("ctx", ctx))
    cost = _cost_seg(data)
    if cost:
        items.append(("cost", cost))
    branch = _branch_seg(data)
    if branch:
        items.append(("branch", branch))
    return _fit(items, _timer_seg(data), _columns()) or "?"


def main() -> int:
    raw = sys.stdin.read()
    try:
        data = json.loads(raw) if raw.strip() else {}
        if not isinstance(data, dict):
            data = {}
    except json.JSONDecodeError:
        data = {}
    sys.stdout.write(render(data) + "\n")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except BrokenPipeError:
        raise SystemExit(0)
