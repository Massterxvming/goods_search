#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
service_dir="$project_root/backend/agent_service"
node_version="$(cat "$service_dir/.nvmrc")"
node_binary=""

# Prefer the installed project version without changing the global Node setup.
for candidate in \
  "${AGENT_NODE_BIN:-}" \
  "${NVM_DIR:-$HOME/.nvm}/versions/node/v$node_version/bin/node" \
  "$(command -v node || true)" \
  /opt/homebrew/bin/node \
  /usr/local/bin/node; do
  if [[ -x "$candidate" ]] && \
    [[ "$("$candidate" -p 'const [major, minor] = process.versions.node.split(".").map(Number); major > 22 || (major === 22 && minor >= 19)')" == true ]]; then
    node_binary="$candidate"
    break
  fi
done

if [[ -z "$node_binary" ]]; then
  echo 'Node 22.19+ is required. Install it or set AGENT_NODE_BIN to its node executable.' >&2
  exit 1
fi

export PATH="$(dirname -- "$node_binary"):$PATH"
cd "$service_dir"
if [[ ! -f .env ]]; then
  (umask 077; cp .env.example .env)
fi
if [[ $# -eq 0 ]]; then
  set -- start
fi
exec npm "$@"
