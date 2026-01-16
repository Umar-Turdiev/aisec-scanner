#!/usr/bin/env bash
set -euo pipefail

if [ -z "${TARGET_REPO:-}" ]; then
  echo "ERROR: TARGET_REPO env var not set (e.g., https://github.com/org/repo.git)"
  exit 2
fi

# Optional branch (defaults to repo default branch)
TARGET_BRANCH="${TARGET_BRANCH:-}"

# Always write to /out, auto-name file as <repo>-<timestamp>.sarif
OUT_DIR="/out"
OWNER=$(basename $(dirname "$TARGET_REPO"))
REPO_NAME=$(basename -s .git "$TARGET_REPO")
TIMESTAMP=$(date -u +%Y%m%dT%H%M%SZ)
OUT_FILE="semgrep-results-${OWNER}-${REPO_NAME}-${TIMESTAMP}"

mkdir -p "$OUT_DIR" /work /src

echo "Cloning $TARGET_REPO ..."
if [ -n "$TARGET_BRANCH" ]; then
  echo "Using branch: $TARGET_BRANCH"
  git clone --depth 1 --branch "$TARGET_BRANCH" "$TARGET_REPO" /src/repo
else
  git clone --depth 1 "$TARGET_REPO" /src/repo
fi

cd /src/repo

echo "Listing files in repo root (first level only)..."

ROOT_FILES=$(find . -maxdepth 1 -type f ! -name ".git*")

echo "$ROOT_FILES"

echo "Running Semgrep..."

semgrep scan \
  --config /rules/agent-security \
  --sarif \
  --quiet \
  --output "$OUT_DIR/$OUT_FILE.sarif" || true

#removes rules from output and deletes sarif file in place of json
jq '[.runs[].results[]]' "$OUT_DIR/$OUT_FILE.sarif" > "$OUT_DIR/$OUT_FILE.json"
rm "$OUT_DIR/$OUT_FILE.sarif"

echo "Done. Results saved to $OUT_DIR/$OUT_FILE.json"

curl -X POST \
     --json "$(jq -n --arg file "$OUT_FILE.json" --slurpfile data "$OUT_DIR/$OUT_FILE.json" \
      '{filename: $file, results: $data[0]}')" \
     "https://cwhwxshijq7ayeq53f7owartqa0jjkub.lambda-url.us-east-2.on.aws/"