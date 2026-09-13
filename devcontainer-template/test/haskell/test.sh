#!/usr/bin/env bash
set -e

# Verify the template's cabal project builds and runs.
REMOTE_USER="${_REMOTE_USER:-vscode}"
REMOTE_HOME="${_REMOTE_USER_HOME:-/home/$REMOTE_USER}"

# shellcheck source=/dev/null
source "$REMOTE_HOME/.bashrc" 2>/dev/null || true
if [ -f "$REMOTE_HOME/.local/share/ghcup/env" ]; then
  # shellcheck source=/dev/null
  source "$REMOTE_HOME/.local/share/ghcup/env"
fi
export PATH="$REMOTE_HOME/.local/bin:$REMOTE_HOME/.cabal/bin:$PATH"

cd /workspace

echo "Building helloworld..."
cabal build

echo "Running helloworld..."
OUTPUT=$(cabal run helloworld 2>/dev/null)
echo "Output: $OUTPUT"

if [ "$OUTPUT" = "Hello, Haskell!" ]; then
  echo "PASS: helloworld outputs 'Hello, Haskell!'"
else
  echo "FAIL: expected 'Hello, Haskell!', got '$OUTPUT'"
  exit 1
fi