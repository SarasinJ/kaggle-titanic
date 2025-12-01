#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

if ! command -v kaggle >/dev/null 2>&1; then
  echo "kaggle CLI not found in PATH. Run inside 'pixi shell'." >&2
  exit 1
fi

slug="${1:-}"

if [[ -z "$slug" ]]; then
  echo "Discovering latest Kaggle Playground competition..."
  slug=$(kaggle competitions list --category playground --sort-by recentlyCreated | awk 'NR==3 {print $1}' | awk -F/ '{print $NF}')
fi

if [[ -z "$slug" || "$slug" == "ref" ]]; then
  echo "Unable to resolve a playground competition slug." >&2
  exit 1
fi

echo "Using slug: $slug"

COMP_ROOT="competitions/playground/$slug"
DATA_ROOT="data/playground/$slug"

mkdir -p "$COMP_ROOT/notebooks" "$COMP_ROOT/notes" "$DATA_ROOT/raw" "$DATA_ROOT/processed"

NOTE_FILE="$COMP_ROOT/notes/README.md"
if [[ ! -f "$NOTE_FILE" ]]; then
  cat > "$NOTE_FILE" <<'EOF'
# Playground Notes

Use this space to track objectives, experiments, and reflections for this playground episode.
EOF
fi

ZIP_PATH="$DATA_ROOT/raw/${slug}.zip"
if [[ -f "$ZIP_PATH" ]]; then
  echo "Archive already exists at $ZIP_PATH; reusing."
else
  echo "Downloading competition data..."
  if ! kaggle competitions download -c "$slug" -p "$DATA_ROOT/raw"; then
    echo "Kaggle download failed. Confirm that your kaggle.json credentials are configured and that you've accepted the competition rules." >&2
    exit 1
  fi
fi

if [[ ! -f "$ZIP_PATH" ]]; then
  echo "Expected archive $ZIP_PATH not found after download." >&2
  exit 1
fi

echo "Extracting archive..."
unzip -o "$ZIP_PATH" -d "$DATA_ROOT/raw" >/dev/null

echo "Scaffolding complete under $COMP_ROOT and data under $DATA_ROOT."
