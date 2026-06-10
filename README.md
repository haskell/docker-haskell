![haskell logo](https://github.com/haskell/docker-haskell/blob/master/logo.png?raw=true)

[![Validate Debian](https://github.com/haskell/docker-haskell/actions/workflows/debian.yml/badge.svg)](https://github.com/haskell/docker-haskell/actions/workflows/debian.yml)
[![Hadolint](https://github.com/haskell/docker-haskell/actions/workflows/lint.yml/badge.svg)](https://github.com/haskell/docker-haskell/actions/workflows/lint.yml)
[![Dockerfile Generator](https://github.com/haskell/docker-haskell/actions/workflows/generator.yml/badge.svg)](https://github.com/haskell/docker-haskell/actions/workflows/generator.yml)

---

# Haskell Docker Official Images

This is the Git repository for the Docker [Official Image](https://github.com/docker-library/official-images#what-are-official-images) for [`haskell`](https://hub.docker.com/_/haskell/).
For usage examples and image tags, see the [Docker Hub page](https://hub.docker.com/_/haskell/).

## Image Details

### Included Tools

- [Glasgow Haskell Compiler (GHC)](https://www.haskell.org/ghc/)
- [Cabal](https://cabal.readthedocs.io/en/stable/) CLI
- [Haskell Stack](https://docs.haskellstack.org/en/stable/) CLI

### Operating System Support

| Operating System | Support | Supported Versions | Support Variants |
|------------------|---------|--------------------|------------------|
| Debian           | Yes     | bookworm, bullseye, buster (legacy, hand-maintained) | standard, slim |
| Alpine           | [Planned](https://github.com/haskell/docker-haskell/issues/22) | last 2 releases | N/A |
| Windows          | [Planned](https://github.com/haskell/docker-haskell/issues/3) | ltsc2022 | windowsservercore, nanoserver |

Currently maintained GHC lines: **9.6, 9.8, 9.10, 9.12, 9.14** (matches the CI matrix).
Older lines (9.0, 9.2, 9.4) are kept for legacy use and do not receive routine
Cabal/Stack updates.

### Processor Architecture Support

- amd64
- arm64 (aarch64)

### Installation Method

Stack and cabal-install are downloaded as upstream release archives and installed into `/usr/local/bin`.
GHC is installed from upstream bindists into `/opt/ghc/<version>`.

Each installation step verifies:

- the release signature (PGP)
- the archive checksum (`sha256`)

The image `PATH` includes:

- `/root/.cabal/bin`
- `/root/.local/bin`
- `/opt/ghc/${GHC}/bin`

### Verification Method

Verification follows the Docker Official Images [preferred process](https://github.com/docker-library/official-images#image-build):

- verify the release signer via PGP key validation
- verify archive checksums

### Version Support Policy

#### GHC

These images will support GHC minor versions (e.g., 9.2) that are either actively being maintained 
(new patch releases will come out) or are still popular. Once both of these are no longer true, 
support can be dropped. Users can still pull these images, however, they will not be listed on the docker hub 
page and will no longer be updated with new Cabal and Stack versions.

Only the latest patch release in each actively maintained minor line receives routine updates.

#### Cabal + Stack

For actively supported GHC versions, Cabal and Stack should be updated when new versions are released.

## Maintenance

### Generating Dockerfiles

Most Dockerfiles are generated from `template/Dockerfile.ncl` using Nickel data
files, validated against the contract in `template/schema.ncl`. The repository
ships two entry points:

- `./generate.sh <data-file.ncl> <output-file>` — bash wrapper that runs
  `nickel export` for a single data file. Used ad-hoc.
- `./generate_dockerfiles.nu` — nushell script that regenerates every
  data-driven Dockerfile in one pass. This is what CI runs (see
  `Dockerfile generator` workflow).

Regenerate a single Dockerfile from the repository root with the bash helper:

```bash
./generate.sh 9.14/bookworm.ncl 9.14/bookworm/Dockerfile
```

You can also run Nickel directly (note the `Schema` validation, matching the
helper scripts):

```bash
nickel export --format text -o 9.14/bookworm/Dockerfile - <<'EOF'
let render = import "template/Dockerfile.ncl" in
let {Schema} = import "template/schema.ncl" in
let config = import "9.14/bookworm.ncl" in
render (config | Schema)
EOF
```

To regenerate every data-driven Dockerfile at once:

```bash
nu ./generate_dockerfiles.nu
```

The `nu` entry point accepts a single optional `--pattern` (`-p`) flag, a
regex matched against the full data-file path. Use it to limit a run to a
single GHC line, a single variant, or a single file. Some examples:

```bash
nu ./generate_dockerfiles.nu                            # every data-driven Dockerfile
nu ./generate_dockerfiles.nu --pattern '14'          # only 9.14 variants
nu ./generate_dockerfiles.nu --pattern 'bookworm$' # every bookworm variant
nu ./generate_dockerfiles.nu --pattern '10/buster'   # exactly one file
```

The pattern is a Nushell/PCRE regex; the `\.` escapes are required. Anchor
patterns with `^`/`$` where you need exact matches (for example `'^9\.14/'`
matches only the 9.14 directory and not a hypothetical `9.140/`). Lines
without `.ncl` data (9.0, 9.2) and hand-maintained Dockerfiles (9.4–9.8
buster, 9.10 buster/slim-buster) are skipped regardless of the filter, since
they have no source data file to match.

Run `nu ./generate_dockerfiles.nu --help` for the full doc comments.

General layout:

- `template/Dockerfile.ncl` is the rendered template
- `template/schema.ncl` is the Nickel contract applied to each data file
- `<GHC line>/<variant>.ncl` (for example `9.14/bookworm.ncl`) contains distro-specific values
- `<GHC line>/_globals.ncl` contains shared values (for example Stack and cabal-install versions)
- some lines also use shared fragments like `<GHC line>/_ghc.ncl` and `<GHC line>/_cabal-install*.ncl`
- `<GHC line>/<variant>/Dockerfile` is the generated output

Note: not every Dockerfile is generated from `.ncl` data. GHC `9.0` and `9.2`
have no `.ncl` data files at all — their Dockerfiles are hand-maintained and
the generator skips them. GHC `9.4`/`9.6`/`9.8` only have `.ncl` data for
bullseye and slim-bullseye; the buster and slim-buster Dockerfiles in those
lines are also hand-maintained. GHC `9.10` has `.ncl` data for bookworm,
bullseye, slim-bookworm, and slim-bullseye; the `9.10/buster/Dockerfile` and
`9.10/slim-buster/Dockerfile` are hand-maintained and not regenerated by
`generate_dockerfiles.nu`.

### Building and Running Locally

```bash
docker build -t haskell-local 9.14/bookworm
docker run -it haskell-local bash
```

### Updating the Images

This is a two-step process:

1. Update this repository (`haskell/docker-haskell`).
2. Update the [official-images library file](https://github.com/docker-library/official-images/blob/master/library/haskell) to reference the new commit.

#### 1. Update Dockerfiles in this repository

When GHC, cabal-install, or Stack releases a new version:

1. Update versions, checksums, and release keys in the relevant Nickel files.
2. Regenerate affected Dockerfiles.
3. Build and smoke-test locally.
4. Open a PR and make sure CI passes.

##### GHC

1. Bump the GHC version in relevant `.ncl` files (for example `9.12.4` -> `9.12.5`).
2. Download checksums from `https://downloads.haskell.org/~ghc/<version>/SHA256SUMS`.
3. Update the `x86_64` and `aarch64` checksums for each affected distro/bindist.
4. If a bindist is missing for a target distro, add or update an override URL (see existing `overrides.ghc.aarch64.url` usage).
5. Update the release key if the releaser changed.

Known GHC releasers:

- [Ben Gamari](https://keyserver.ubuntu.com/pks/lookup?search=ben%40well-typed.com&fingerprint=on&op=index)
- [Zubin Duggal](https://keyserver.ubuntu.com/pks/lookup?search=zubin%40well-typed.com&fingerprint=on&op=index)
- [Bryan Richter](https://keyserver.ubuntu.com/pks/lookup?search=bryan%40haskell.foundation&fingerprint=on&op=index)

##### cabal-install

1. Bump the cabal-install version in relevant `_globals.ncl` files.
2. Download checksums from `https://downloads.haskell.org/~cabal/cabal-install-<version>/SHA256SUMS`.
3. Update checksums for the expected bindists (for example `x86_64-linux-deb10`, `aarch64-linux-deb10`,
   `x86_64-linux-deb11`, `aarch64-linux-deb11`, `x86_64-linux-deb12`, `aarch64-linux-deb12`,
   as needed by the affected lines).
4. Update the release key if the releaser changed.

Known cabal-install releasers:

- [Mikolaj Konarski](https://keyserver.ubuntu.com/pks/lookup?search=mikolaj.konarski%40gmail.com&fingerprint=on&op=index)
- [Hecate](https://keyserver.ubuntu.com/pks/lookup?search=hecate%40glitchbra.in&fingerprint=on&op=index)

##### Stack

1. Bump the Stack version in relevant `_globals.ncl` files.
2. Download checksums from the Stack release assets (for example `stack-<version>-linux-x86_64.tar.gz.sha256` 
   and `stack-<version>-linux-aarch64.tar.gz.sha256`).
3. Update both architecture checksums.

The Stack signing key is documented at <https://docs.haskellstack.org/en/stable/SIGNING_KEY/> and is typically stable.

#### 2. Release new versions through official-images

Images are built and released by Docker Official Images. The haskell entry is maintained in:

- <https://github.com/docker-library/official-images/blob/master/library/haskell>

Typical release steps:

1. Identify which GHC lines are affected.
2. Update `GitCommit` to the new commit in this repository.
3. Update `Tags` when needed.
4. Open a PR in `docker-library/official-images` with a clear summary.
5. After merge, Docker's build system publishes updated images.

More details: <https://github.com/docker-library/faq#an-images-source-changed-in-git-now-what>

### Update Docker Hub Docs

Docker Hub docs for this image live in:

- <https://github.com/docker-library/docs/tree/master/haskell>

### Image Tests

#### Functionality Tests

This repository's CI (`Validate Debian`) builds images and runs the upstream official-images tests.
The `build-smoke-test` job builds every maintained GHC line (9.6, 9.8, 9.10, 9.12, 9.14) on
bullseye and additionally bookworm for the 9.12 and 9.14 lines. The `arm64-tests` job builds
bullseye for every maintained line and bookworm for 9.10/9.12/9.14 (slim variants are excluded
on arm64).

#### Dockerfile Linting

Dockerfiles are linted with [`hadolint`](https://github.com/hadolint/hadolint) via GitHub Actions.
Global exceptions are configured in [`.hadolint.yaml`](.hadolint.yaml).
