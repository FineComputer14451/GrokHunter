#!/usr/bin/env python3
"""Validate GrokHunter .grok-plugin/marketplace.json local sources."""
from __future__ import annotations
import json, re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / '.grok-plugin' / 'marketplace.json'
NAME_RE = re.compile(r'^[a-z0-9]+(?:-[a-z0-9]+)*$')

def main():
    cat = json.loads(CATALOG.read_text())
    assert 'plugins' in cat and isinstance(cat['plugins'], list)
    names = []
    for e in cat['plugins']:
        name = e.get('name')
        if not isinstance(name, str) or not NAME_RE.match(name):
            raise SystemExit(f'bad name: {name!r}')
        if name in names:
            raise SystemExit(f'duplicate name: {name}')
        names.append(name)
        src = e.get('source')
        if not isinstance(src, dict) or 'path' not in src:
            raise SystemExit(f'{name}: expected local source.path')
        path = src['path']
        if path.startswith('/') or '..' in path:
            raise SystemExit(f'{name}: unsafe path {path}')
        root = (ROOT / path).resolve()
        if not root.is_dir():
            raise SystemExit(f'{name}: missing {path}')
        man = root / '.grok-plugin' / 'plugin.json'
        if not man.is_file():
            raise SystemExit(f'{name}: missing .grok-plugin/plugin.json')
        json.loads(man.read_text())
        if not (root / 'README.md').is_file():
            raise SystemExit(f'{name}: missing README.md')
    print(f'OK — {len(names)} plugins')

if __name__ == '__main__':
    main()
