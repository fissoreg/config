#!/bin/zsh
# <resource>-subagent gateway, uvx-style: spawned on demand by the calling
# agent as a stdio MCP server child process. No daemon to babysit - the caller
# starts it with its session and it dies with it. The model server (e.g. Ollama)
# is what keeps the local model warm across calls, not this process.
set -euo pipefail

GATEWAY_DIR="${GATEWAY_DIR:-$HOME/gateways/email-subagent}"
cd "$GATEWAY_DIR" || {
  echo "email-subagent: GATEWAY_DIR does not exist: $GATEWAY_DIR" >&2
  echo "Set GATEWAY_DIR, or copy this launcher next to your gateway checkout." >&2
  exit 1
}

# Optional: point at a specific local model / resource-server config here.
# export EMAIL_AGENT_MODEL="YOUR_PROVIDER/YOUR_LOCAL_MODEL"

exec npx tsx src/stdio.ts
