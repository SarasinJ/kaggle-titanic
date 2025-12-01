#!/usr/bin/env bash
set -euo pipefail

# Resolve repository root relative to this script location.
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$PROJECT_ROOT/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "load_dotenv.sh: no .env file found at $ENV_FILE; skipping." >&2
  exit 0
fi

# Export every variable defined in the .env file into the current environment.
set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a
