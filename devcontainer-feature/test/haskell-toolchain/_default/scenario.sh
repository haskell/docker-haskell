#!/usr/bin/env bash
set -e

echo "Checking default install (all tools)..."
# shellcheck source=/dev/null
source ~/.bashrc 2>/dev/null || true
export PATH="$HOME/.local/share/ghcup/bin:$HOME/.cabal/bin:$PATH"

ghc --version
cabal --version
stack --version
haskell-language-server-wrapper --version
ormolu --version
fourmolu --version

echo "All default tools present."