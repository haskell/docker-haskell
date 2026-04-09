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
| Debian           | Yes     | bookworm, bullseye (legacy buster directories still exist for older GHC lines) | standard, slim |
| Alpine           | [Planned](https://github.com/haskell/docker-haskell/issues/22) | last 2 releases | N/A |
| Windows          | [Planned](https://github.com/haskell/docker-haskell/issues/3) | ltsc2022 | windowsservercore, nanoserver |

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

Dockerfiles are generated from `template/Dockerfile.jinja` using YAML data files.

Build the generator (one-time or after generator changes):

```bash
cd generator
stack build
```

Regenerate a Dockerfile from the repository root with the helper script:

```bash
./generate.sh 9.14/bookworm.yaml 9.14/bookworm/Dockerfile
```

You can also run the generator directly:

```bash
cd generator
stack run -- -t ../template/Dockerfile.jinja --data-file ../9.14/bookworm.yaml > ../9.14/bookworm/Dockerfile
```

General layout:

- `<GHC line>/<variant>.yaml` (for example `9.14/bookworm.yaml`) contains distro-specific values
- `<GHC line>/_globals.yaml` contains shared values (for example Stack and cabal-install versions)
- some lines also use shared fragments like `<GHC line>/_ghc.yaml` and `<GHC line>/_cabal-install*.yaml`
- `<GHC line>/<variant>/Dockerfile` is the generated output

The generator can print a few `RuntimeError` messages related to missing override keys; these are usually harmless.

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

1. Update versions, checksums, and release keys in the relevant YAML files.
2. Regenerate affected Dockerfiles.
3. Build and smoke-test locally.
4. Open a PR and make sure CI passes.

##### GHC

1. Bump the GHC version in relevant YAML files (for example `9.12.4` -> `9.12.5`).
2. Download checksums from `https://downloads.haskell.org/~ghc/<version>/SHA256SUMS`.
3. Update the `x86_64` and `aarch64` checksums for each affected distro/bindist.
4. If a bindist is missing for a target distro, add or update an override URL (see existing `overrides.ghc.aarch64.url` usage).
5. Update the release key if the releaser changed.

Known GHC releasers:

- [Ben Gamari](https://keyserver.ubuntu.com/pks/lookup?search=ben%40well-typed.com&fingerprint=on&op=index)
- [Zubin Duggal](https://keyserver.ubuntu.com/pks/lookup?search=zubin%40well-typed.com&fingerprint=on&op=index)
- [Bryan Richter](https://keyserver.ubuntu.com/pks/lookup?search=bryan%40haskell.foundation&fingerprint=on&op=index)

##### cabal-install

1. Bump the cabal-install version in relevant `_globals.yaml` files.
2. Download checksums from `https://downloads.haskell.org/~cabal/cabal-install-<version>/SHA256SUMS`.
3. Update checksums for the expected bindists (for example `x86_64-linux-deb11`, `aarch64-linux-deb11`, 
   `x86_64-linux-deb12`, `aarch64-linux-deb12`, as needed by the affected lines).
4. Update the release key if the releaser changed.

Known cabal-install releasers:

- [Mikolaj Konarski](https://keyserver.ubuntu.com/pks/lookup?search=mikolaj.konarski%40gmail.com&fingerprint=on&op=index)
- [Hecate](https://keyserver.ubuntu.com/pks/lookup?search=hecate%40glitchbra.in&fingerprint=on&op=index)

##### Stack

1. Bump the Stack version in relevant `_globals.yaml` files.
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
The CI matrix currently covers maintained Debian variants, with both amd64 and arm64 validation.

#### Dockerfile Linting

Dockerfiles are linted with [`hadolint`](https://github.com/hadolint/hadolint) via GitHub Actions.
Global exceptions are configured in [`.hadolint.yaml`](.hadolint.yaml).
