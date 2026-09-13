#!/usr/bin/env bash
set -e

echo "Checking no-stack install..."
# shellcheck source=/dev/null
source ~/.bashrc 2>/dev/null || true
export PATH="$HOME/.local/share/ghcup/bin:$HOME/.cabal/bin:$PATH"

ghc --version
cabal --version
haskell-language-server-wrapper --version

if command -v stack >/dev/null 2>&1; then
  echo "FAIL: stack should not be installed"
  exit 1
fi

echo "stack correctly absent."