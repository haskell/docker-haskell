let v = import "versions.ncl" in

let rendered = m%"
#!/usr/bin/env bash
set -euo pipefail

# Haskell Toolchain devcontainer feature
# Versions are pinned by versions.ncl (imported from 9.14/bookworm.ncl + globals).

GHC_VERSION="${GHCVERSION:-"%{v.ghc_version}"}"
CABAL_VERSION="${CABALVERSION:-"%{v.cabal_version}"}"
HLS_VERSION="%{v.hls_version}"
GHCUP_VERSION="%{v.ghcup_version}"
STACK_VERSION="%{v.stack_version}"

INCLUDE_STACK="${INSTALLSTACK:-"true"}"
INCLUDE_HLS="${INSTALLHLS:-"true"}"
INSTALL_STACK_GHCUP_HOOK="${INSTALLSTACKGHCUPHOOK:-"true"}"
ADJUST_BASHRC="${ADJUSTBASH:-"true"}"
INSTALL_LINTERS="${INSTALLLINTERS:-"true"}"
GLOBAL_PACKAGES="${GLOBALPACKAGES:-""}"
GLOBAL_LIBRARIES="${GLOBALLIBRARIES:-""}"

ORMOLU_VERSION="%{v.linters.ormolu}"
FOURMOLU_VERSION="%{v.linters.fourmolu}"

# --- Resolve install user (mirrors devcontainers-extra/features/src/haskell) ---
if [ "$(id -u)" -ne 0 ]; then
  echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.' >&2
  exit 1
fi

if [ -n "${_REMOTE_USER:-}" ] && [ "$_REMOTE_USER" != "root" ]; then
  INSTALL_AS="$_REMOTE_USER"
  NEED_SUDO=1
else
  INSTALL_AS="root"
  NEED_SUDO=0
  export HOME=/root
fi

# --- System dependencies (Debian/Ubuntu only in v1.0.0; Alpine tracked by issue #22) ---
rm -rf /var/lib/apt/lists/*
apt-get update -y
if [ "${NEED_SUDO}" = "1" ]; then
  apt-get install -y --no-install-recommends sudo
fi
apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  build-essential \
  libffi-dev \
  libgmp-dev \
  libncurses-dev \
  libtinfo-dev \
  xz-utils \
  zlib1g-dev \
  git
rm -rf /var/lib/apt/lists/*

# --- Bootstrap ghcup + install tools as the install user ---
# When running as root without _REMOTE_USER, execute directly (no sudo needed).
# When _REMOTE_USER is set (devcontainer/Codespaces), run via sudo -iu so that
# ghcup installs into the remote user's home directory with XDG dirs.
# The unquoted heredoc lets the outer shell expand the pinned values;
# \$-escapes protect what must expand inside.
if [ "${NEED_SUDO}" = "1" ]; then
  sudo -iu "${INSTALL_AS}" <<INSTALL_EOF
set -euo pipefail

export GHCUP_USE_XDG_DIRS=1

export BOOTSTRAP_HASKELL_NONINTERACTIVE=1
export BOOTSTRAP_HASKELL_GHC_VERSION='${GHC_VERSION}'
export BOOTSTRAP_HASKELL_CABAL_VERSION='${CABAL_VERSION}'
export BOOTSTRAP_HASKELL_DOWNLOADER='curl'
export BOOTSTRAP_HASKELL_INSTALL_HLS='false'
export BOOTSTRAP_HASKELL_ADJUST_BASHRC='${ADJUST_BASHRC}'

if [ '${INCLUDE_STACK}' = 'false' ]; then
  export BOOTSTRAP_HASKELL_INSTALL_NO_STACK='true'
fi
if [ '${INSTALL_STACK_GHCUP_HOOK}' = 'false' ]; then
  export BOOTSTRAP_HASKELL_INSTALL_NO_STACK_HOOK='true'
fi

curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

. "\${HOME}/.local/share/ghcup/env"

# Pin ghcup itself to the exact version from versions.ncl.
ghcup upgrade --ghcup-version '${GHCUP_VERSION}' || true

if [ '${INCLUDE_HLS}' = 'true' ]; then
  ghcup install hls '${HLS_VERSION}'
fi

# Pin stack to the exact version from versions.ncl.
if [ '${INCLUDE_STACK}' = 'true' ]; then
  ghcup install stack '${STACK_VERSION}'
fi

if [ '${INCLUDE_STACK}' = 'true' ] && [ '${INSTALL_STACK_GHCUP_HOOK}' = 'true' ]; then
  if command -v stack >/dev/null 2>&1; then
    stack config set system-ghc --global true >/dev/null 2>&1 || \
      echo 'Warning: failed to configure Stack to use ghcup-installed GHC.' >&2
  fi
fi

if [ '${INSTALL_LINTERS}' = 'true' ]; then
  cabal update
  cabal install -j\$(nproc) --semaphore \
    ormolu-'${ORMOLU_VERSION}' \
    fourmolu-'${FOURMOLU_VERSION}' \
    --overwrite-policy=always
fi

if [ -n '${GLOBAL_PACKAGES}' ]; then
  echo '${GLOBAL_PACKAGES}' | xargs cabal install
fi

if [ -n '${GLOBAL_LIBRARIES}' ]; then
  echo '${GLOBAL_LIBRARIES}' | xargs cabal install --lib
fi

rm -rf ~/.ghcup/tmp || true
INSTALL_EOF
else
  # Running as root directly — no sudo needed.
  bash <<INSTALL_EOF
set -euo pipefail

export GHCUP_USE_XDG_DIRS=1

export BOOTSTRAP_HASKELL_NONINTERACTIVE=1
export BOOTSTRAP_HASKELL_GHC_VERSION='${GHC_VERSION}'
export BOOTSTRAP_HASKELL_CABAL_VERSION='${CABAL_VERSION}'
export BOOTSTRAP_HASKELL_DOWNLOADER='curl'
export BOOTSTRAP_HASKELL_INSTALL_HLS='false'
export BOOTSTRAP_HASKELL_ADJUST_BASHRC='${ADJUST_BASHRC}'

if [ '${INCLUDE_STACK}' = 'false' ]; then
  export BOOTSTRAP_HASKELL_INSTALL_NO_STACK='true'
fi
if [ '${INSTALL_STACK_GHCUP_HOOK}' = 'false' ]; then
  export BOOTSTRAP_HASKELL_INSTALL_NO_STACK_HOOK='true'
fi

curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

. "\${HOME}/.local/share/ghcup/env"

ghcup upgrade --ghcup-version '${GHCUP_VERSION}' || true

if [ '${INCLUDE_HLS}' = 'true' ]; then
  ghcup install hls '${HLS_VERSION}'
fi

if [ '${INCLUDE_STACK}' = 'true' ]; then
  ghcup install stack '${STACK_VERSION}'
fi

if [ '${INCLUDE_STACK}' = 'true' ] && [ '${INSTALL_STACK_GHCUP_HOOK}' = 'true' ]; then
  if command -v stack >/dev/null 2>&1; then
    stack config set system-ghc --global true >/dev/null 2>&1 || \
      echo 'Warning: failed to configure Stack to use ghcup-installed GHC.' >&2
  fi
fi

if [ '${INSTALL_LINTERS}' = 'true' ]; then
  cabal update
  cabal install -j\$(nproc) --semaphore \
    ormolu-'${ORMOLU_VERSION}' \
    fourmolu-'${FOURMOLU_VERSION}' \
    --overwrite-policy=always
fi

if [ -n '${GLOBAL_PACKAGES}' ]; then
  echo '${GLOBAL_PACKAGES}' | xargs cabal install
fi

if [ -n '${GLOBAL_LIBRARIES}' ]; then
  echo '${GLOBAL_LIBRARIES}' | xargs cabal install --lib
fi

rm -rf ~/.ghcup/tmp || true
INSTALL_EOF
fi

apt-get clean || true
rm -rf /var/lib/apt/lists/* || true

echo "Haskell toolchain installed: GHC ${GHC_VERSION}, cabal ${CABAL_VERSION}, HLS ${HLS_VERSION}"
"% in

{ install_sh = rendered }