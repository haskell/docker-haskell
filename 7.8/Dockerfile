## Dockerfile for a haskell environment
FROM       debian:wheezy
MAINTAINER Darin Morrison <darinmorrison+docker@gmail.com>

## disable prompts from apt
ENV DEBIAN_FRONTEND noninteractive

## custom apt-get install options
ENV OPTS_APT        -y --no-install-recommends

## ensure locale is set during build
ENV LC_ALL          C.UTF-8
ENV LANG            C.UTF-8
ENV LANGUAGE        C.UTF-8

## configure apt to use the haskell repository
ADD http://deb.haskell.org/deb.haskell.org.gpg-key /tmp/deb.haskell.org.gpg-key
RUN apt-key add /tmp/deb.haskell.org.gpg-key\
 && echo 'deb     http://deb.haskell.org/stable/ ./' >> /etc/apt/sources.list.d/haskell.list\
 && echo 'deb-src http://deb.haskell.org/stable/ ./' >> /etc/apt/sources.list.d/haskell.list

## set ghc upstream package versions and ghc deb revisions
ENV MAJOR_GHC       7.8
ENV MINOR_GHC       .3
ENV DEB_REV_GHC     -1

## install ghc
RUN apt-get update\
 && apt-get install ${OPTS_APT}\
      ghc-7.8.3="${MAJOR_GHC}""${MINOR_GHC}""${DEB_REV_GHC}"

## set upstream package versions (major-level) for remaining haskell packages
ENV MAJOR_ALEX      3.1
ENV MAJOR_CABAL     1.20
ENV MAJOR_HAPPY     1.19

## set upstream package versions (minor-level) for remaining haskell packages
ENV MINOR_ALEX      .3
ENV MINOR_CABAL     .0.3
ENV MINOR_HAPPY     .4

## set deb revisions for remaining haskell packages
ENV DEB_REV_ALEX    -1
ENV DEB_REV_CABAL   -1
ENV DEB_REV_HAPPY   -1

## install minimal set of haskell packages
RUN apt-get update\
 && apt-get install ${OPTS_APT}\
      alex="${MAJOR_ALEX}""${MINOR_ALEX}""${DEB_REV_ALEX}"\
      cabal-install-"${MAJOR_CABAL}"="${MAJOR_CABAL}""${MINOR_CABAL}""${DEB_REV_CABAL}"\
      happy="${MAJOR_HAPPY}""${MINOR_HAPPY}""${DEB_REV_HAPPY}"

## install additional libs typically needed by hackage packages
RUN apt-get update\
 && apt-get install ${OPTS_APT} zlib1g-dev

## set PATH for tools not installed to /usr/{bin,/local/bin}
ENV PATH            /opt/cabal/$MAJOR_CABAL/bin:$PATH
ENV PATH            /opt/ghc/$MAJOR_GHC$MINOR_GHC/bin:$PATH

## run ghci by default unless a command is specified
CMD ["ghci"]
