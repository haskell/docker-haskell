# docker-haskell: haskell in a container

`docker-haskell` is a minimal Ubuntu-based docker container.

## docker Registry

`docker-haskell` is available as an image on the docker registry at [darinmorrison/haskell](https://index.docker.io/u/darinmorrison/haskell/).

## Use Cases

`docker-haskell` can be used in the following ways:

*   **As a haskell development environment**

     _run `alex`, `cabal`, `ghc`, or `happy` directly_

*   **As a container in which to run haskell apps**

    _compile/run haskell app locally; access via ssh_

*   **As a base image for other containers**

    _`docker-agda`, `docker-idris`, `docker-purescript`, `docker-<your-haskell-app>` etc._

## FAQ

For the time being, see [phusion/baseimage-docker](https://github.com/phusion/baseimage-docker) for configuration details, including [how to access the container via ssh](https://github.com/phusion/baseimage-docker#login-to-the-container-via-ssh).
