#!/usr/bin/env python3
"""Decode branding/assets*.b64.json and optional *.b64 sidecars into raster files."""
import base64, json, sys
from pathlib import Path

root = Path(__file__).resolve().parent.parent
brand = root / "branding"

# Pack format
for blob_path in sorted(brand.glob("assets*.b64.json")):
    blobs = json.loads(blob_path.read_text())
    for rel, b64 in blobs.items():
        out = root / rel
        out.parent.mkdir(parents=True, exist_ok=True)
        data = base64.b64decode(b64)
        out.write_bytes(data)
        print(f"decoded {rel} ({len(data)} bytes)")

# Sidecar format: path/to/file.ext.b64 -> path/to/file.ext
for side in sorted(brand.rglob("*.b64")):
    if side.name.startswith("assets"):
        continue
    if not side.name.endswith(".b64"):
        continue
    out = side.with_suffix("")
    data = base64.b64decode(side.read_text().strip())
    out.write_bytes(data)
    print(f"decoded sidecar {out.relative_to(root)} ({len(data)} bytes)")
