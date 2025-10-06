# Simple: start from official Semgrep image
FROM semgrep/semgrep:latest

# Copy your custom rules into the image
COPY rules /rules
# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Workdir for cloning targets
WORKDIR /work

# Default entrypoint: repo URL is passed as $TARGET_REPO, results go to /out/semgrep.sarif
ENTRYPOINT ["/entrypoint.sh"]
