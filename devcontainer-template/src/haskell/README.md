# Haskell (cabal)

A minimal Haskell project using [cabal-install](https://cabal.readthedocs.io/),
with the full toolchain (GHC, cabal, Stack, HLS, ormolu, fourmolu) installed via
the [`haskell-toolchain` devcontainer feature](../src/haskell-toolchain).

## What's included

- **GHC 9.14.1** (LTS) + **HLS 2.14.0.0** via ghcup
- **cabal-install 3.16.1.0** + **Stack 3.11.1**
- **Formatters**: ormolu, fourmolu
- **VS Code extensions**: `haskell.haskell`, `haskell-lang-server`
- **Format on save**: fourmolu

## Getting started

1. Use this template to create a new repository.
2. Open in a devcontainer (VS Code: `Reopen in Container`, or GitHub Codespaces).
3. The `postCreateCommand` runs `cabal update && cabal build` automatically.
4. Run the project: `cabal run helloworld`

## Project structure

```
.
├── .devcontainer/
│   └── devcontainer.json      # feature config + VS Code customizations
├── .vscode/
│   ├── extensions.json        # recommended extensions
│   └── settings.json          # HLS + formatter settings
├── src/
│   └── Main.hs                # putStrLn "Hello, Haskell!"
├── helloworld.cabal           # cabal package spec
└── .gitignore
```

## Customizing the GHC version

Edit `.devcontainer/devcontainer.json` and change the `version` option:

```jsonc
"features": {
  "ghcr.io/haskell/docker-haskell/devcontainer-features/haskell-toolchain:1.0.0": {
    "version": "9.12"  // or "9.10", "9.8", "latest", "recommended"
  }
}
```

## Adding linters (hlint, stylish-haskell)

The curated formatter set (ormolu, fourmolu) is compatible with GHC 9.14.1.
`hlint` and `stylish-haskell` are not included because their latest Hackage
releases don't support `base-4.22` (shipped with GHC 9.14). See the
[feature README](../src/haskell-toolchain/README.md#why-only-ormolu-and-fourmolu)
for details.