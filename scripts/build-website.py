#!/usr/bin/env python3
"""Stitch GrokHunter static pages and write website/site.json.

No npm. Safe to run on a phone (Python 3) or in GitHub Actions.
Fragments live in website/_src/. Generated HTML is committed so
`python3 -m http.server -d website` works without the stitch.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WEB = ROOT / "website"
SRC = WEB / "_src"

SKIP_AGENT_MD = {"README.md", "HANDOFF-TEMPLATES.md", "REFERENCES.md"}
PAGES = (
    {
        "slug": "index",
        "file": "index.html",
        "body": "index.body.html",
        "title": "GrokHunter {version} — AI coding lab on unrooted Android",
        "description": (
            "Kali NetHunter Rootless × Grok Build 1.0.5 — AI coding lab for "
            "unrooted Android. Grok 4.6, agents, personas, roles, Aider, XFCE desktop."
        ),
    },
    {
        "slug": "install",
        "file": "install.html",
        "body": "install.body.html",
        "title": "Install GrokHunter {version} — rootless overlay",
        "description": "Install or refresh GrokHunter on unrooted Android. Overlay-only, XFCE, Grok Build.",
    },
    {
        "slug": "cli",
        "file": "cli.html",
        "body": "cli.body.html",
        "title": "GrokHunter CLI — Grok TUI vs lab TUI",
        "description": "grokhunter commands. Bare grokhunter opens Grok Build. grokhunter tui is the lab menu.",
    },
    {
        "slug": "desktop",
        "file": "desktop.html",
        "body": "desktop.body.html",
        "title": "GrokHunter desktop — XFCE on Termux:X11",
        "description": "nh-x11, grokhunter menu (XFCE submenu), binds, and phone-real X11 notes. Not the lab TUI.",
    },
    {
        "slug": "agents",
        "file": "agents.html",
        "body": "agents.body.html",
        "title": "GrokHunter Coding Team — agents, personas, roles",
        "description": "Coding Team loop and lab specialists for GrokHunter on unrooted Android.",
    },
    {
        "slug": "faq",
        "file": "faq.html",
        "body": "faq.body.html",
        "title": "GrokHunter FAQ — rootless lab",
        "description": "FAQ, architecture, and credits for the GrokHunter rootless coding lab.",
    },
    {
        "slug": "404",
        "file": "404.html",
        "body": "404.body.html",
        "title": "GrokHunter — page not found",
        "description": "That page is not on the GrokHunter site.",
    },
)


def count_catalog() -> dict[str, int]:
    agents = sum(
        1
        for p in (ROOT / "agents").glob("*.md")
        if p.name not in SKIP_AGENT_MD
    )
    personas = sum(1 for _ in (ROOT / "personas").glob("*.toml"))
    roles = sum(1 for _ in (ROOT / "roles").glob("*.toml"))
    skills = sum(1 for p in (ROOT / "skills").iterdir() if p.is_dir())
    return {
        "agents": agents,
        "personas": personas,
        "roles": roles,
        "skills": skills,
    }


def tokens(version: str, counts: dict[str, int]) -> dict[str, str]:
    return {
        "VERSION": version,
        "MIN_GROK": "1.0.5",
        "AGENTS": str(counts["agents"]),
        "PERSONAS": str(counts["personas"]),
        "ROLES": str(counts["roles"]),
        "SKILLS": str(counts["skills"]),
    }


def subst(text: str, table: dict[str, str]) -> str:
    for key, val in table.items():
        text = text.replace("{{" + key + "}}", val)
    return text


def stitch(page: dict, table: dict[str, str]) -> str:
    head = (SRC / "head.html").read_text()
    header = (SRC / "header.html").read_text()
    body = (SRC / page["body"]).read_text()
    footer = (SRC / "footer.html").read_text()
    local = dict(table)
    local["TITLE"] = page["title"].format(version=table["VERSION"])
    local["DESCRIPTION"] = page["description"]
    local["PAGE"] = "" if page["file"] == "index.html" else page["file"]
    local["SLUG"] = page["slug"]
    html = head + header + body + footer
    html = subst(html, local)
    if "{{" in html:
        leftover = [tok for tok in html.split("{{")[1:]]
        raise SystemExit(f"unreplaced token in {page['file']}: {leftover[:3]}")
    return html


def write_site_json(version: str, counts: dict[str, int]) -> None:
    data = {
        "version": version,
        "min_grok": "1.0.5",
        "overlay_cache": "2026.2.25",
        "agents": counts["agents"],
        "personas": counts["personas"],
        "roles": counts["roles"],
        "skills": counts["skills"],
        "pages": [p["file"] for p in PAGES],
        "tui": {
            "bare": "Grok Build fullscreen TUI (grok-nethunter)",
            "tui": "Lab operations menu (alias: lab)",
            "menu": "Kali/XFCE Applications submenu",
        },
    }
    path = WEB / "site.json"
    path.write_text(json.dumps(data, indent=2) + "\n")
    print(f"wrote {path.relative_to(ROOT)}")


def main() -> int:
    if not SRC.is_dir():
        print(f"missing {SRC}", file=sys.stderr)
        return 1
    version = (ROOT / "VERSION").read_text().strip()
    counts = count_catalog()
    table = tokens(version, counts)
    write_site_json(version, counts)
    for page in PAGES:
        out = WEB / page["file"]
        out.write_text(stitch(page, table))
        print(f"wrote {out.relative_to(ROOT)}")
    print(
        f"catalog agents={counts['agents']} personas={counts['personas']} "
        f"roles={counts['roles']} skills={counts['skills']}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
