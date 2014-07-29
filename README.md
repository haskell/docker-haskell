# docker-haskell: haskell in a container

`docker-haskell` is a docker container shipping a minimal haskell toolchain

## Contents

The default configuration of `docker-haskell` provides the following:

| package         | version    |
|-----------------|------------|
| `alex`          | `3.1.3`    |
| `cabal-install` | `1.20.0.3` |
| `happy`         | `1.19.4`   |
| `ghc`           | `7.8.3`    |

## Overview

`docker-haskell` can be used in the following ways:

*   **As a haskell development environment**

     _run `alex`, `cabal`, `ghc`, or `happy` directly_

*   **As a container in which to run haskell apps**

    _compile/run haskell app locally; access via ssh_

*   **As a base image for other containers**

    _`docker-agda`, `docker-idris`, `docker-purescript`, `docker-<your-haskell-app>` etc._

## Requirements

You will need the following:

*   access to a docker host
*   docker client installed on your workstation

See the [docker installation](https://docs.docker.com/installation/) page for details.

#### tl;dr

*   Mac OS X

        brew cask install virtualbox && brew install boot2docker docker

      NOTE: follow the [directions](https://github.com/boot2docker/boot2docker#how-to-use) at [boot2docker/boot2docker](https://github.com/boot2docker/boot2docker)

*   Ubuntu

        apt-get install docker.io

      NOTE: you might want to [rename docker.io to docker](http://pastebin.com/raw.php?i=hm3y4vJy)

## Quickstart

*   download the container, start ghci, and attach to an interactive session:

        docker run -it --rm=true --name='ghci' darinmorrison/haskell bash -lc 'ghci'

*   download the container, start sshd, detach and keep the container running:

        docker run -dP --name='ghc-sshd' darinmorrison/haskell /sbin/my_init --enable-insecure-key

      NOTE: see [here](https://github.com/phusion/baseimage-docker#login-to-the-container-or-running-a-command-inside-it-via-ssh) for details on how to log in to the container via ssh

Another possibility is [darinmorrison/vagrant-haskell](https://github.com/darinmorrison/vagrant-haskell) which is based on this container but in some ways provides a more convenient interface. If you are running OS X and need NFS-style shared folders (rather than using `scp` or `sftp`) this will probably be the better approach. Vagrant is unnecessary on Linux—[mount volumes](https://docs.docker.com/userguide/dockervolumes) and use [nsenter](https://github.com/jpetazzo/nsenter) instead of NFS and ssh.

## Upgrading

You can upgrade to the latest image with an explicit pull:

    docker pull darinmorrison/haskell:latest

## Customization

For the time being, see [phusion/baseimage-docker](https://github.com/phusion/baseimage-docker) for further details.
