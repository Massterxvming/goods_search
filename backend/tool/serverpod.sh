#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
sdk_bin="$project_root/.fvm/flutter_sdk/bin"

if [[ ! -x "$sdk_bin/dart" ]]; then
  echo 'Flutter SDK is missing. Run fvm install in the project root first.' >&2
  exit 1
fi

# Use the project SDK for the CLI and any Dart subprocesses it starts.
export PATH="$sdk_bin:$PATH"
cd "$project_root/backend/goods_search_server"
exec "$sdk_bin/dart" pub global run serverpod_cli:serverpod_cli "$@"
