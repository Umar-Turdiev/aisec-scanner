#!/usr/bin/env bash
set -euo pipefail

if [ -z "${TARGET_REPO:-}" ]; then
  echo "ERROR: TARGET_REPO env var not set (e.g., https://github.com/org/repo.git)"
  exit 2
fi

OUT_DIR=${OUT_DIR:-/out}
OUT_FILE=${OUT_FILE:-semgrep-$(date -u +%Y%m%dT%H%M%SZ).sarif}

mkdir -p "$OUT_DIR" /work /src
echo "Cloning $TARGET_REPO ..."
git clone --depth 1 "$TARGET_REPO" /src/repo

cd /src/repo
echo "Running Semgrep..."
semgrep scan \
  --config /rules/agent-security \
  --sarif \
  --quiet \
  --output /out/semgrep.sarif || true

echo "Done. Results at $OUT_DIR/$OUT_FILE"
