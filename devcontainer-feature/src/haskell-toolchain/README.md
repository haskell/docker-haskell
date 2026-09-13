# Haskell Toolchain (ghcup)

Installs the Haskell toolchain via [ghcup](https://www.haskell.org/ghcup/):
GHC, cabal-install, Stack, the Haskell Language Server, and a curated set of
formatters (`ormolu`, `fourmolu`).

Tool versions are **pinned** in [`versions.ncl`](versions.ncl), which imports
from the `9.14/bookworm.ncl` data file in this same repository. This keeps the
feature in lockstep with the official `haskell` Docker images — bumping a
version in one place updates both.

## Example usage

```jsonc
"features": {
  "ghcr.io/haskell/docker-haskell/devcontainer-features/haskell-toolchain:1.0.0": {
    "version": "9.14"
  }
}
```

## Options

| Option | Type | Default | Description |
|---|---|---|---|
| `version` | string | `9.14` | GHC version (ghcup shorthand: `9.14`, `recommended`, `latest`, …). |
| `installStack` | boolean | `true` | Install Stack. |
| `installHLS` | boolean | `true` | Install the Haskell Language Server. |
| `installStackGHCupHook` | boolean | `true` | Force Stack to use ghcup-installed GHC (no separate Stack GHC downloads). |
| `adjustBash` | boolean | `true` | Prepend ghcup to `PATH` in `~/.bashrc`. |
| `installLinters` | boolean | `true` | Install curated formatters (`ormolu`, `fourmolu`). |
| `globalPackages` | string | `""` | Extra `cabal install` packages (space-separated, unpinned). Escape hatch. |
| `globalLibraries` | string | `""` | Extra `cabal install --lib` libraries (space-separated, unpinned). Escape hatch. |

## Pinned versions (v1.0.0)

| Tool | Version | Source |
|---|---|---|
| GHC | 9.14.1 | `9.14/bookworm.ncl` |
| cabal-install | 3.16.1.0 | `9.14/_globals.ncl` |
| Stack | 3.11.1 | `9.14/_globals.ncl` |
| HLS | 2.14.0.0 | `versions.ncl` (LTS pair with GHC 9.14.1) |
| ghcup | 0.2.6.2 | `versions.ncl` |
| ormolu | 0.8.2.0 | `versions.ncl` |
| fourmolu | 0.20.0.0 | `versions.ncl` |

## Why only ormolu and fourmolu?

`hlint`, `stylish-haskell`, and `cabal-fmt` are **not** included in the curated
set because their latest Hackage releases constrain `ghc < 9.13` or
`base < 4.22`, making them incompatible with GHC 9.14.1 (which ships
`base-4.22.0.0`). They depend on `ghc-lib-parser 9.12.x`, which has not been
updated for GHC 9.14's `base` at the time of writing.

When upstream releases versions compatible with GHC 9.14, they will be added
back to the curated set. Until then, users can attempt to install them via the
`globalPackages` escape hatch with `--allow-newer`:

```jsonc
"features": {
  "ghcr.io/haskell/docker-haskell/devcontainer-features/haskell-toolchain:1.0.0": {
    "installLinters": false,
    "globalPackages": "hlint stylish-haskell cabal-fmt"
  }
}
```

(Note: `globalPackages` does not pass `--allow-newer`; users needing it should
install manually in a `postCreateCommand`.)

## Supported base images

Debian and Ubuntu only in v1.0.0. Alpine support is tracked by
[issue #22](https://github.com/haskell/docker-haskell/issues/22) and will land
in lockstep with the Alpine base images.

## Regenerating `install.sh`

`install.sh` is **generated** from `install.sh.tpl.ncl` via Nickel. Do not edit
the `.sh` file directly; edit the template and re-render:

```bash
cd devcontainer-feature/src/haskell-toolchain
nickel export --format text <<'Nickel' > install.sh
let tpl = import "install.sh.tpl.ncl" in
tpl.install_sh
Nickel
chmod +x install.sh
```

The `feature-publish.yml` workflow re-renders automatically on tag.

## Install-user behavior

Mirrors [`devcontainers-extra/features/src/haskell`](https://github.com/devcontainers-extra/features/tree/main/src/haskell):

- When `_REMOTE_USER` is set (devcontainer / Codespaces build context),
  ghcup is installed as that user via `sudo -iu "$_REMOTE_USER"`.
- When `_REMOTE_USER` is unset and the script runs as root (plain Dockerfile
  `RUN`), ghcup is installed under `/root`.
- Non-root invocation without `_REMOTE_USER` hard-fails.

`GHCUP_USE_XDG_DIRS=1` is set in both paths.