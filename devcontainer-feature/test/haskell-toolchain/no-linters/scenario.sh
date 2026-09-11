#!/usr/bin/env bash
set -e

echo "Checking no-linters install..."
# shellcheck source=/dev/null
source ~/.bashrc 2>/dev/null || true
export PATH="$HOME/.local/share/ghcup/bin:$HOME/.cabal/bin:$PATH"

ghc --version
cabal --version
stack --version
haskell-language-server-wrapper --version

for tool in ormolu fourmolu; do
  if command -v "$tool" >/dev/null 2>&1; then
    echo "FAIL: $tool should not be installed"
    exit 1
  fi
done

echo "All formatters correctly absent."