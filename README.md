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

#### Update Dockerfiles

When a new version of Cabal, Stack or GHC is released the images need to be updated. This involves:

1. Update to the new version in the Dockerfile.
2. Update the PGP key, if the person doing the release has changed.
3. Updating the sha256 to the new version of the tool, for all supported processor architectures.
4. For GHC: Updating the github actions to test the new version.

See an [example](https://github.com/haskell/docker-haskell/pull/83/files) of a GHC update.

#### Release New Versions

Images are built and released by the central docker official images system. Specifically haskell is maintained in this [file](https://github.com/docker-library/official-images/blob/master/library/haskell). See the [docs](https://github.com/docker-library/official-images#instruction-format) on this format.

1. Determine which docker haskell image GHC versions have been impacted by the unreleased changes.
2. Update the `GitCommit` in the [`haskell`](https://github.com/docker-library/official-images/blob/master/library/haskell) file.
3. Update the `Tags` if these have changed.
3. Create a PR, including info on what has changed. The official images people will review the actual Dockerfile changes as they want official images to maintain a high level of quality.
4. Once merged, their build system will run and the image updates will eventually be released.

This [doc](https://github.com/docker-library/faq#an-images-source-changed-in-git-now-what) described the process in more detail.

### Update Docker Hub Docs

The [docker hub haskell docs](https://github.com/docker-library/docs/tree/master/haskell) live in a separate repo.

### Image Tests

#### Functionality Tests

The [image tests](https://github.com/docker-library/official-images/tree/master/test/tests) live in the official-images repo. They are run against amd64 and aarch64 in this repo. When updating [`haskell`](https://github.com/docker-library/official-images/blob/master/library/haskell) in the official images repo they are only run against amd64.

#### Dockerfile Linting

This is done via [`hadolint`](https://github.com/hadolint/hadolint). We should not be afraid to ignore hadolint rules globally if required as it is not really designed for the official images which have some nuances.
