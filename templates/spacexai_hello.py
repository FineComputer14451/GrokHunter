#!/usr/bin/env python3
"""Minimal SpaceXAI (xAI) client — OpenAI-compatible Responses API.

  pip install openai
  export XAI_API_KEY=xai-...   # or source ~/.grok/secrets.env
  python3 templates/spacexai_hello.py

Docs: https://docs.x.ai/developers/quickstart
Models: https://docs.x.ai/developers/models
"""
from __future__ import annotations

import os
import sys

try:
    from openai import OpenAI
except ImportError:
    print("Install the OpenAI SDK:  pip install openai", file=sys.stderr)
    sys.exit(1)

api_key = os.environ.get("XAI_API_KEY")
if not api_key:
    print("Set XAI_API_KEY (e.g. source ~/.grok/secrets.env)", file=sys.stderr)
    sys.exit(1)

client = OpenAI(api_key=api_key, base_url="https://api.x.ai/v1")
model = os.environ.get("SPACEXAI_MODEL", "grok-4.6")
prompt = " ".join(sys.argv[1:]) if len(sys.argv) > 1 else "Say hello from GrokHunter in one short sentence."

resp = client.responses.create(model=model, input=prompt)
print(resp.output_text)
