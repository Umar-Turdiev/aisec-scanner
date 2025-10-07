#!/usr/bin/env bash
set -euo pipefail

if [ -z "${TARGET_REPO:-}" ]; then
  echo "ERROR: TARGET_REPO env var not set (e.g., https://github.com/org/repo.git)"
  exit 2
fi

# Always write to /out, auto-name file as <repo>-<timestamp>.sarif
OUT_DIR="/out"
REPO_NAME=$(basename -s .git "$TARGET_REPO")
TIMESTAMP=$(date -u +%Y%m%dT%H%M%SZ)
OUT_FILE="${REPO_NAME}-${TIMESTAMP}.sarif"

mkdir -p "$OUT_DIR" /work /src

echo "Cloning $TARGET_REPO ..."
git clone --depth 1 "$TARGET_REPO" /src/repo

cd /src/repo
echo "Running Semgrep..."

semgrep scan \
  --config /rules/agent-security \
  --sarif \
  --quiet \
  --output "$OUT_DIR/$OUT_FILE" || true

#removes rules from output and deletes sarif file in place of json
jq '[.runs[].results[]]' "$OUT_DIR/$OUT_FILE" > "$OUT_DIR/$OUT_FILE.json"
rm "$OUT_DIR/$OUT_FILE"

echo "Done. Results saved to $OUT_DIR/$OUT_FILE.json"
