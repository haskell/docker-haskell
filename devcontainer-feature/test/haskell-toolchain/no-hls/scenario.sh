#!/usr/bin/env bash
set -e

echo "Checking no-hls install..."
# shellcheck source=/dev/null
source ~/.bashrc 2>/dev/null || true
export PATH="$HOME/.local/share/ghcup/bin:$HOME/.cabal/bin:$PATH"

ghc --version
cabal --version
stack --version

if command -v haskell-language-server-wrapper >/dev/null 2>&1; then
  echo "FAIL: HLS should not be installed"
  exit 1
fi

echo "HLS correctly absent."