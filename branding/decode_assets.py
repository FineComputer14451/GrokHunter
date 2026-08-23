#!/usr/bin/env python3
"""Decode branding/assets*.b64.json into real PNG/JPEG files."""
import base64, json, sys
from pathlib import Path

root = Path(__file__).resolve().parent.parent
brand = root / "branding"
files = sorted(brand.glob("assets*.b64.json"))
if not files:
    print("no assets*.b64.json — skip")
    sys.exit(0)
for blob_path in files:
    blobs = json.loads(blob_path.read_text())
    for rel, b64 in blobs.items():
        out = root / rel
        out.parent.mkdir(parents=True, exist_ok=True)
        data = base64.b64decode(b64)
        out.write_bytes(data)
        print(f"decoded {rel} ({len(data)} bytes)")
