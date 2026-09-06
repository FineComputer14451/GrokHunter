#!/usr/bin/env python3
"""Regenerate .grok-plugin/plugin-index.json for local GrokHunter marketplace plugins."""
from __future__ import annotations
import json, re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / '.grok-plugin' / 'marketplace.json'
INDEX = ROOT / '.grok-plugin' / 'plugin-index.json'

def parse_fm(path: Path) -> dict:
    text = path.read_text(encoding='utf-8', errors='replace')[:65536]
    if not text.startswith('---'):
        return {}
    lines = text.splitlines()
    fields, i = {}, 1
    while i < len(lines):
        line = lines[i]
        if line.strip() in ('---', '...'):
            break
        m = re.match(r'^([A-Za-z0-9_-]+):\s*(.*)$', line)
        if not m:
            i += 1
            continue
        key, value = m.group(1), m.group(2).strip()
        if re.match(r'^[|>][+-]?$', value):
            block, j = [], i + 1
            while j < len(lines) and (lines[j].startswith((' ', '\t')) or not lines[j].strip()):
                if lines[j].strip():
                    block.append(lines[j].strip())
                j += 1
            value, i = ' '.join(block), j
        else:
            if len(value) >= 2 and value[0] == value[-1] and value[0] in '"\'':
                value = value[1:-1]
            i += 1
        fields[key] = value
    return fields

def scan(root: Path):
    skills, commands, agents = [], [], []
    sd = root / 'skills'
    if sd.is_dir():
        for sk in sorted(sd.iterdir()):
            sm = sk / 'SKILL.md'
            if sm.exists():
                fm = parse_fm(sm)
                skills.append({'name': fm.get('name', sk.name), 'description': (fm.get('description') or '')[:120]})
    cd = root / 'commands'
    if cd.is_dir():
        for cf in sorted(cd.glob('*.md')):
            fm = parse_fm(cf)
            commands.append({'name': fm.get('name', cf.stem), 'description': (fm.get('description') or '')[:120]})
    ad = root / 'agents'
    if ad.is_dir():
        for af in sorted(ad.glob('*.md')):
            fm = parse_fm(af)
            agents.append({'name': fm.get('name', af.stem), 'description': (fm.get('description') or '')[:120]})
    return skills, commands, agents

def main():
    catalog = json.loads(CATALOG.read_text())
    out = {'plugins': []}
    for entry in catalog['plugins']:
        src = entry['source']
        path = src['path'] if isinstance(src, dict) else src
        root = (ROOT / path).resolve()
        if not root.is_dir():
            raise SystemExit(f"missing plugin dir: {path}")
        man = json.loads((root / '.grok-plugin' / 'plugin.json').read_text())
        skills, commands, agents = scan(root)
        out['plugins'].append({
            'name': entry['name'],
            'version': man.get('version'),
            'skills': skills,
            'commands': commands,
            'agents': agents,
            'mcpServers': [],
            'hooks': [],
            'lspServers': [],
        })
    text = json.dumps(out, indent=2, sort_keys=True) + '\n'
    if '--check' in sys.argv:
        if INDEX.read_text() != text:
            raise SystemExit('plugin-index.json is stale; run without --check')
        print('OK')
        return
    INDEX.write_text(text)
    print(f'wrote {INDEX} ({len(out["plugins"])} plugins)')

if __name__ == '__main__':
    main()
