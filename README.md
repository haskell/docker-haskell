![image](https://github.com/haskell/docker-haskell/blob/master/logo.png?raw=true)

| Build | Status | Badges | (per-arch) |
|:-:|:-:|:-:|:-:|
| [![amd64 build status badge](https://img.shields.io/jenkins/s/https/doi-janky.infosiftr.net/job/multiarch/job/amd64/job/haskell.svg?label=amd64)](https://doi-janky.infosiftr.net/job/multiarch/job/amd64/job/haskell/) | [![aarch64v8 build status badge](https://img.shields.io/jenkins/s/https/doi-janky.infosiftr.net/job/multiarch/job/aarch64v8/job/haskell.svg?label=aarch64v8)](https://doi-janky.infosiftr.net/job/multiarch/job/aarch64v8/job/haskell/) | [![put-shared build status badge](https://img.shields.io/jenkins/s/https/doi-janky.infosiftr.net/job/put-shared/job/light/job/haskell.svg?label=put-shared)](https://doi-janky.infosiftr.net/job/put-shared/job/light/job/haskell/) |

---

# Haskell Docker Official Images

This is the Git repo of the [Docker "Official Image"](https://github.com/docker-library/official-images#what-are-official-images) for [`haskell`](https://hub.docker.com/_/haskell/). See [the Docker Hub page](https://hub.docker.com/_/haskell/) for the full readme on how to use this Docker image.

## Image Details

### Included Tools

* [Glasgow Haskell Compiler (GHC)](https://www.haskell.org/ghc/).
* [Cabal](https://cabal.readthedocs.io/en/stable/) the CLI tool.
* [Haskell Stack](https://docs.haskellstack.org/en/stable) the CLI tool.

### Operating System Support

| Operating System | Support | Supported Versions | Support Variants              |
|------------------|---------|--------------------|-------------------------------|
| Debian           | Yes     | buster             | standard, slim                |
| Alpine           | [Planned](https://github.com/haskell/docker-haskell/issues/22) | Last 2 releases    | N/A                           |
| Windows          | [Planned](https://github.com/haskell/docker-haskell/issues/3) | ltsc2022           | windowsservercore, nanoserver |

### Processor Architecture Support

* amd64
* aarch64 ([does not include Stack](https://github.com/haskell/docker-haskell/issues/59))

### Installation Method

#### Cabal + Stack

Cabal and Stack release binaries for various platforms. These are downloaded and made available eg. copied into `/usr/local/bin`.

#### GHC

GHC releases an archive which includes scripts to install GHC. Once downloaded GHC is installed via:

* `./configure ` (we pass in additional paramters to the configure step)
* `make install`

The installed binaries are made availabe on the `PATH`.

### Verification Method

Verification is done following the ['preferred' method for docker official images](https://github.com/docker-library/official-images#image-build). This means we:

* Verify the release is published by the expected person via PGP key verification.
* Verify the sha256 of the release is as expected.

### Version Support Policy

#### GHC

GHC minor versions (eg. 9.2) that are either actively being maintained (new patch releases will come out) or are still popular will be supported by these images. Once both of these are no longer true, support can be dropped. Users can still pull these images, however they will not be listed on the docker hub page and will no longer be updated with new Cabal and Stack versions.

Additionally, only the latest patch version of each major version of GHC will recieve further updates.

#### Cabal + Stack

For actively supported GHC versions, Cabal and Stack should be updated when new versions are relesaed.

## Maintenance

### Building + Running Locally

You can build and run the images locally with something like:

```bash
$ docker build -t haskell-local 9.2/buster && docker run -it haskell-local bash
```

### Updating The Images

This invovles a 2 step process.

1. Update the images in the docker-haskell repository.
2. Update the [official images repo](https://github.com/docker-library/official-images/blob/master/library/haskell) to use the new git commit sha.

#### 1. Update Dockerfiles

When a new version of Cabal, Stack or GHC is released the images need to be updated. In general this involves:

1. Update to the new version in the Dockerfile.
2. Updating the sha256 to the new version of the tool, for all supported processor architectures.
3. Update the PGP key, if the person doing the release has changed.

##### GHC

1. Replace the old and new GHC version globally eg. `9.4.3` becomes `9.4.4`. This will update both Dockerfiles **and the github actions**.
2. Obtain the new sha256 for the new GHC binary distribution via https://downloads.haskell.org/~ghc/9.4.4/SHA256SUMS . Look for the sha for the `.tar.xz` supported versions (currently `x86_64-deb10` + `aarch64-deb10`).
3. Replace globally the old sha256 for these with the new one obtained in step 2.
4. Update the PGP key if the person doing the release has changed. You can build the image locally at this point to see if it works or not. If it fails you need to update the PGP key. You need to find the key from the person doing the release on the ubuntu keyserver. See below for known releasers.

* [Ben Gamari](https://keyserver.ubuntu.com/pks/lookup?search=ben%40well-typed.com&fingerprint=on&op=index)
* [Zubin Duggal](https://keyserver.ubuntu.com/pks/lookup?search=zubin%40well-typed.com&fingerprint=on&op=index)
* [Bryan Richter](https://keyserver.ubuntu.com/pks/lookup?search=bryan%40haskell.foundation&fingerprint=on&op=index)

An [example](https://github.com/haskell/docker-haskell/commit/d25abd175c94517494f55e74c2a908cb2caa8552)

##### Cabal

1. Replace the old and new cabal version globally eg. `3.6.2.0` becomes `3.8.1.0`.
2. Obtain the new sha256 for the new cabal binary distribution via https://downloads.haskell.org/~cabal/cabal-install-3.8.1.0/SHA256SUMS . Look for the sha for the `.tar.xz` supported versions (currently `x86_64-linux-deb10` + `aarch64-linux-deb10`).
3. Replace globally the old sha256 for these with the new one obtained in step 2.
4. Update the PGP key if the person doing the release has changed. You can build the image locally at this point to see if it works or not. If it fails you need to update the PGP key. You need to find the key from the person doing the release on the ubuntu keyserver. See below for known releasers.

* [Mikolaj Konarski](https://keyserver.ubuntu.com/pks/lookup?search=mikolaj.konarski%40gmail.com&fingerprint=on&op=index)

An [example](https://github.com/haskell/docker-haskell/commit/73cf1f7f950cd34bf7cc9691067b0e7761016c1a)

##### Stack

1. Replace the old and new stack version globally eg. `2.9.1` becomes `2.9.3`.
2. Obtain the new sha256 for the new stack binary distribution via https://github.com/commercialhaskell/stack/releases/tag/v2.9.3 . Look for `stack-2.9.3-linux-x86_64.tar.gz.sha256` + `stack-2.9.3-linux-aarch64.tar.gz.sha256` files in the assets list.
3. Replace globally the old sha256 for these with the new one obtained in step 2.
4. The [stack PGP key](https://docs.haskellstack.org/en/stable/SIGNING_KEY/) does not change so can be left as is.

An [example](https://github.com/haskell/docker-haskell/commit/321f4b6dd77e2caee2caa947b50779fb47c26959) (this also enabled aarch64 for stack, so has a bit more noise but you get the idea).

#### 2. Release New Versions

Images are built and released by the central docker official images system. Specifically haskell is maintained in this [file](https://github.com/docker-library/official-images/blob/master/library/haskell). See the [docs](https://github.com/docker-library/official-images#instruction-format) on this format.

1. Determine which docker haskell image GHC versions have been impacted by the unreleased changes (stack + cabal bumps impacts all versions, GHC just impacts specific versions).
2. Update the `GitCommit` in the [`haskell`](https://github.com/docker-library/official-images/blob/master/library/haskell) file.
3. Update the `Tags` if these have changed.
3. Create a PR, including info on what has changed. The official images people will review the actual Dockerfile changes as they want official images to maintain a high level of quality.
4. Once merged, their build system will run and the image updates will eventually be released.

This [doc](https://github.com/docker-library/faq#an-images-source-changed-in-git-now-what) describes the process in more detail.

### Update Docker Hub Docs

The [docker hub haskell docs](https://github.com/docker-library/docs/tree/master/haskell) live in a separate repo.

### Image Tests

#### Functionality Tests

The [image tests](https://github.com/docker-library/official-images/tree/master/test/tests) live in the official-images repo. They are run against amd64 and aarch64 in this repo. When updating [`haskell`](https://github.com/docker-library/official-images/blob/master/library/haskell) in the official images repo they are only run against amd64.

#### Dockerfile Linting

This is done via [`hadolint`](https://github.com/hadolint/hadolint). We should not be afraid to ignore hadolint rules globally if required as it is not really designed for the official images which have some nuances.
