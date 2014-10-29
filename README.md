## What is Haskell?

![image](https://github.com/darinmorrison/docker-haskell/blob/docker-library/logo.png?raw=true)

Haskell is an advanced purely-functional programming language. An open-source
product of more than twenty years of cutting-edge research, it allows rapid
development of robust, concise, correct software. With strong support for
integration with other languages, built-in concurrency and parallelism,
debuggers, profilers, rich libraries and an active community, Haskell makes it
easier to produce flexible, maintainable, high-quality software.

The Glorious Glasgow Haskell Compilation System (GHC) is a state-of-the-art,
open source, compiler and interactive environment for the functional language
Haskell.  GHC includes an optimising compiler (`ghc`), an interactive
environment (`ghci`), and a convenient script runner (`runghc`).

> [haskell.org](http://www.haskell.org)

> [Glasgow Haskell Compiler](http://www.haskell.org/ghc)

The default configuration of this image provides the following packages:

| package         | version    |
|-----------------|------------|
| `alex`          | `3.1.3`    |
| `cabal-install` | `1.20.0.3` |
| `happy`         | `1.19.4`   |
| `ghc`           | `7.8.3`    |

## How to use this image

Directly run `ghci`.

    $ docker run -it --rm haskell:7.8
    GHCi, version 7.8.3: http://www.haskell.org/ghc/  :? for help
    Loading package ghc-prim ... linking ... done.
    Loading package integer-gmp ... linking ... done.
    Loading package base ... linking ... done.
    Prelude>

Dockerize an application on Hackage with a Dockerfile that inherits from the
base image.

    FROM haskell:7.8
    RUN cabal update && cabal install MazesOfMonad
    VOLUME /root/.MazesOfMonad
    ENTRYPOINT ["/root/.cabal/bin/mazesofmonad"]

Develop and ship your Haskell application with a Dockerfile that utilizes the
build cache for quick iteration.

    FROM haskell:7.8

    RUN cabal update

    # Add .cabal file
    ADD ./server/snap-example.cabal /opt/server/snap-example.cabal

    # Docker will cache this command as a layer, freeing us up to
    # modify source code without re-installing dependencies
    RUN cd /opt/server && cabal install --only-dependencies -j4

    # Add and Install Application Code
    ADD ./server /opt/server
    RUN cd /opt/server && cabal install

    # Add installed cabal executables to PATH
    ENV PATH /root/.cabal/bin:$PATH

    # Default Command for Container
    WORKDIR /opt/server
    CMD ["snap-example"]

This example can be reviewed in more depth at
https://github.com/darinmorrison/docker-haskell/tree/docker-library/examples/7.8.3/snap
