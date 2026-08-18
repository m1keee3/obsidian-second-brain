#!/usr/bin/env bash
# Fast, CWD-independent launcher for the obsidian-second-brain MCP server.
#
# Why this exists: `uv run --with "mcp<1.7"` resolves relative to the current
# working directory. Launched from a session inside a repo whose parent has a
# `pyproject.toml` workspace with no `requires-python` (e.g. ~/arcadia), uv walks
# up, adopts that workspace, and defaults to the system Python 3.9 — but mcp<1.7
# needs Python >=3.10, so resolution fails ("No solution found") and the MCP
# server never connects (-32000). Search then silently degrades to grep. A cold
# uv cache adds a slow PyPI resolve on top, which can also time out.
#
# A prebuilt local venv sidesteps ALL of it: a fixed >=3.10 interpreter with mcp
# already installed — no workspace discovery, no resolver, no network. Startup is
# instant and identical from any directory.
#
# Falls back to uv (self-bootstrapping) if the venv is missing, so a fresh
# machine still works before the venv exists.
# Recreate the venv:
#   uv venv "$ROOT/.mcp-venv"
#   uv pip install --python "$ROOT/.mcp-venv/bin/python" "mcp<1.7"
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
SRV="$ROOT/integrations/obsidian-mcp-server/server.py"
VENV_PY="$ROOT/.mcp-venv/bin/python"
if [ -x "$VENV_PY" ]; then
  exec "$VENV_PY" "$SRV"
else
  exec uv run --no-project --with "mcp<1.7" python "$SRV"
fi
