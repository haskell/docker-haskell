#!/usr/bin/env bash
set -e

# The devcontainer test harness runs test.sh as root. The feature may have
# installed under _REMOTE_USER's home (devcontainer/Codespaces) or under /root
# (plain Dockerfile RUN). Detect which by checking where ghcup env lives.
if [ -n "${_REMOTE_USER:-}" ] && [ "$_REMOTE_USER" != "root" ] && [ -f "${_REMOTE_USER_HOME:-/home/$_REMOTE_USER}/.local/share/ghcup/env" ]; then
  REMOTE_HOME="${_REMOTE_USER_HOME:-/home/$_REMOTE_USER}"
else
  REMOTE_HOME="/root"
fi

# shellcheck source=/dev/null
source "$REMOTE_HOME/.bashrc" 2>/dev/null || true
if [ -f "$REMOTE_HOME/.local/share/ghcup/env" ]; then
  # shellcheck source=/dev/null
  source "$REMOTE_HOME/.local/share/ghcup/env"
fi
export PATH="$REMOTE_HOME/.local/bin:$REMOTE_HOME/.cabal/bin:$PATH"

echo "Checking Haskell toolchain (using $REMOTE_HOME)..."
ghc --version
cabal --version
stack --version
haskell-language-server-wrapper --version
ormolu --version
fourmolu --version
echo "All tools present."