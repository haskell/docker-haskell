# docker-haskell: haskell in a container

`docker-haskell` is a docker container shipping a minimal haskell toolchain

---

### NOTE: [docker-library](https://github.com/darinmorrison/docker-haskell/tree/docker-library) will soon replace this branch

---

**Table of Contents**

*   [Overview](#overview)
    *   [Use Cases](#use_cases)
    *   [Container Contents](#container_contents)
*   [Usage](#usage)
    *   [Getting Started](#getting_started)
        *   [Running via Vagrant](#running_via_vagrant)
    *   [Installing Docker](#installing_docker)
    *   [Upgrading the Container](#upgrading_the_container)
*   [Customization](#customization)

-----------------------------------------

## Overview

<a name="use_cases"></a>
### Use Cases

`docker-haskell` can be used in the following ways:

*   **As a haskell development environment**

     _run `alex`, `cabal`, `ghc`, or `happy` directly_

*   **As a container in which to run haskell apps**

    _compile/run haskell app locally; access via ssh_

*   **As a base image for other containers**

    _`docker-agda`, `docker-idris`, `docker-purescript`, `docker-<your-haskell-app>` etc._

<a name="container_contents"></a>
### Container Contents

The default configuration of `docker-haskell` provides the following:

| package         | version    |
|-----------------|------------|
| `alex`          | `3.1.3`    |
| `cabal-install` | `1.20.0.3` |
| `happy`         | `1.19.4`   |
| `ghc`           | `7.8.3`    |

## Usage

<a name="getting_started"></a>
### Getting Started

<span style='font-size: small;'>_See [Installing Docker](https://github.com/darinmorrison/docker-haskell#requirements) if you don't already have `docker` configured on your workstation._</span>

*   **pull the container, start a ghci session, and attach interactively**:

        docker run -itP --rm=true --name='ghci' darinmorrison/haskell

*   **pull the container, start sshd, and detach to the backround**:

        docker run -dP --name='ghc-sshd' darinmorrison/haskell /sbin/my_init --enable-insecure-key

      NOTE: see [here](https://github.com/phusion/baseimage-docker#login-to-the-container-or-running-a-command-inside-it-via-ssh) for details on how to log in to the container via ssh

<a name="running_via_vagrant"></a>
#### Running via Vagrant

`docker-haskell` can also be run through a [Vagrant](http://www.vagrantup.com/) wrapper such as the one at [darinmorrison/vagrant-haskell](https://github.com/darinmorrison/vagrant-haskell) which uses a lightweight Linux distribution and the Vagrant docker provider.

If you are running OS X, using `docker-haskell` as a portable development environment, and need NFS-style shared folders, the Vagrant wrapper will likely provide a more convenient workflow¹.

If you are running Linux the Vagrant wrapper isn't necessary—just [mount volumes](https://docs.docker.com/userguide/dockervolumes) and use [nsenter](https://github.com/jpetazzo/nsenter) instead of using NFS and ssh.

¹ <span style='font-size: small;'>_This will no longer be necessary once volumes are mountable from an OS X host._</span>

<a name="installing_docker"></a>
### Installing Docker

You will need the following:

*   access to a docker host
*   the docker client installed on your workstation

See the [docker installation](https://docs.docker.com/installation/) page for details.

#### tl;dr

*   Mac OS X

        brew install caskroom/cask/brew-cask boot2docker && !#:0 cask !#:1 virtualbox && (!#:3 init; !#:3 up)

      NOTE: set `DOCKER_HOST=:2375` or use `docker -H :2375`; see [directions](https://github.com/boot2docker/boot2docker#how-to-use)

*   Ubuntu

        curl -sSL https://get.docker.io/ubuntu/ | sudo sh

<a name="upgrading_the_container"></a>
### Upgrading the Container

You can upgrade to the latest image with an explicit pull:

    docker pull darinmorrison/haskell:latest

### Customization

For the time being, see [phusion/baseimage-docker](https://github.com/phusion/baseimage-docker) for further details.
