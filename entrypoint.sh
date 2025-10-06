#!/usr/bin/env bash
set -euo pipefail

if [ -z "${TARGET_REPO:-}" ]; then
  echo "ERROR: TARGET_REPO env var not set (e.g., https://github.com/org/repo.git)"
  exit 2
fi

mkdir -p /out /work /src
echo "Cloning $TARGET_REPO ..."
git clone --depth 1 "$TARGET_REPO" /work/repo

# Semgrep's Docker image expects code under /src; mirror the repo there.
rm -rf /src/repo || true
cp -R /work/repo /src/repo

cd /src/repo
echo "Running Semgrep..."
semgrep scan \
  --config auto \
  --config /rules/agent-security \
  --sarif \
  --output /out/semgrep.sarif || true

echo "Done. Results at /out/semgrep.sarif"
