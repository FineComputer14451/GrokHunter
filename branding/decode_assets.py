#!/usr/bin/env python3
"""Decode branding/assets*.b64.json and optional *.b64 sidecars into raster files."""
import base64
import binascii
import json
import sys
from pathlib import Path

root = Path(__file__).resolve().parent.parent
brand = root / "branding"


def b64decode_padded(s: str) -> bytes:
    """Decode base64 with automatic padding and whitespace cleanup."""
    cleaned = "".join(s.split())  # drop whitespace/newlines
    pad = (-len(cleaned)) % 4
    if pad:
        cleaned += "=" * pad
    return base64.b64decode(cleaned, validate=False)


def decode_one(label: str, b64: str, out: Path) -> bool:
    """Write decoded bytes to out. Returns True on success."""
    try:
        data = b64decode_padded(b64)
    except (binascii.Error, ValueError) as e:
        print(f"  · skipped (bad base64): {label} — {e}", file=sys.stderr)
        return False
    if not data:
        print(f"  · skipped (empty): {label}", file=sys.stderr)
        return False
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_bytes(data)
    print(f"decoded {label} ({len(data)} bytes)")
    return True


# Pack format: assets*.b64.json → { "relative/path": "<base64>" }
for blob_path in sorted(brand.glob("assets*.b64.json")):
    blobs = json.loads(blob_path.read_text())
    for rel, b64 in blobs.items():
        decode_one(rel, b64, root / rel)

# Sidecar format: path/to/file.ext.b64 → path/to/file.ext
for side in sorted(brand.rglob("*.b64")):
    if side.name.startswith("assets"):
        continue
    if not side.name.endswith(".b64"):
        continue
    out = side.with_suffix("")  # strip trailing .b64
    label = str(out.relative_to(root))
    decode_one(label, side.read_text(), out)
