# AI SEC Scanner

Containerized Semgrep scanner for public repos. Runs on local Docker or ECS Fargate.

## What it does

Scans a Git repository with Semgrep. Emits SARIF. Prints logs to stdout.

## Key features

Uses your custom rules in `/rules/agent-security`. Produces `/out/semgrep.sarif`. Accepts `TARGET_REPO`.

## Quick start

```bash
git clone https://github.com/umar-turdiev/aisec-scanner.git
cd aisec-scanner
docker build -t aisec-scanner:latest .
```

## Example local run

```bash
mkdir -p out
docker run --rm \
  -e TARGET_REPO=https://github.com/psf/requests.git \
  -v "$(pwd)/out:/out" \
  aisec-scanner
```

Logs stream in the console. SARIF lands at `./out/semgrep.sarif`.

## Rules layout

```
/rules/
  agent-security/
    AGENT001.yaml
    AGENT002.yaml
```

Each rule targets AI-agent risks. Keep rule IDs stable.

## Semgrep invocation

The image calls Semgrep similar to:

```bash
semgrep scan \
  --config /rules/agent-security \
  --metrics=off \
  --timeout 240 \
  --sarif --output /out/semgrep.sarif
```

Run docker container with semgrep repository

docker build -t test .
docker run --rm -e TARGET_REPO="https://github.com/semgrep/semgrep" -v "$(pwd)/out:/out" test