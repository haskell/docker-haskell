#!/usr/bin/env bash
set -e

echo "Checking escape-hatch (globalPackages=ormolu, curated formatters off)..."
# shellcheck source=/dev/null
source ~/.bashrc 2>/dev/null || true
export PATH="$HOME/.local/share/ghcup/bin:$HOME/.cabal/bin:$PATH"

ghc --version
cabal --version
ormolu --version

if command -v fourmolu >/dev/null 2>&1; then
  echo "FAIL: fourmolu should not be installed (curated formatters off)"
  exit 1
fi

echo "Escape hatch works: ormolu present via globalPackages, fourmolu absent."