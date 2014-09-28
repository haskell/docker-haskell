## Dockerfile for a haskell environment with cabal-install onbuild triggers
FROM       haskell:7.8.3
MAINTAINER Darin Morrison <darinmorrison+docker@gmail.com>

## create and enter app directory
RUN mkdir -p /haskell/src/app
WORKDIR /haskell/src/app

ONBUILD COPY . /haskell/src/app
ONBUILD RUN cabal update && cabal install --only-dependencies
