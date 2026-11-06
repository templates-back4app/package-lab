#!/usr/bin/env bash
# What `npm install` is allowed to do before you have read anything.
set -uo pipefail
cd "$(dirname "$0")"
WORK=$(mktemp -d); trap 'rm -rf "$WORK"' EXIT
cp -r evil-package "$WORK/pkg"
mkdir -p "$WORK/app" && printf '{"name":"victim","private":true,"version":"1.0.0"}\n' > "$WORK/app/package.json"

probe() {
  local flags="$1" label="$2"
  rm -f "$WORK/proof.txt"
  # an environment like the one a build or a laptop actually has
  docker run --rm -v "$WORK":/w -w /w/app \
    -e PROVIDER_API_KEY=sk-lab-0000-not-a-real-key \
    -e DATABASE_PASSWORD=not-a-real-password \
    -e GITHUB_TOKEN=ghp-not-a-real-token \
    node:22-alpine sh -c "
    rm -f /tmp/package-lab-proof.txt
    npm install $flags --silent --no-audit --no-fund ../pkg >/dev/null 2>&1
    cp /tmp/package-lab-proof.txt /w/proof.txt 2>/dev/null || true
    rm -rf node_modules package-lock.json
  " >/dev/null 2>&1
  if [ -s "$WORK/proof.txt" ]; then
    printf '      %-34s%s\n' "$label" "it ran"
    sed 's/^/        /' "$WORK/proof.txt"
  else
    printf '      %-34s%s\n' "$label" "it did not run"
  fi
}

echo ""
probe ""                 "npm install"
probe "--ignore-scripts" "npm install --ignore-scripts"
echo ""
