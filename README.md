# docker-haskell: haskell in a container

`docker-haskell` is a minimal Ubuntu-based docker container.

## Overview

`docker-haskell` can be used in the following ways:

*   **As a haskell development environment**

     _run `alex`, `cabal`, `ghc`, or `happy` directly_

*   **As a container in which to run haskell apps**

    _compile/run haskell app locally; access via ssh_

*   **As a base image for other containers**

    _`docker-agda`, `docker-idris`, `docker-purescript`, `docker-<your-haskell-app>` etc._

## How do I use this?

You can download `docker-haskell` via the docker index at [darinmorrison/haskell](https://index.docker.io/u/darinmorrison/haskell/) or build the `Dockerfile` directly. If you aren't familiar with how that works, see the docker tutorial: https://www.docker.io/gettingstarted.

Another possibility is [darinmorrison/vagrant-haskell](https://github.com/darinmorrison/vagrant-haskell) which is based on this container but in some ways provides a more convenient interface.

## FAQ

For the time being, see [phusion/baseimage-docker](https://github.com/phusion/baseimage-docker) for further details, including [how to access the container via ssh](https://github.com/phusion/baseimage-docker#login-to-the-container-via-ssh).
