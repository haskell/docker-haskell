## Dockerfile for a haskell environment
## https://github.com/darinmorrison/docker-haskell
FROM       debian:unstable
MAINTAINER Darin Morrison <darinmorrison+docker@gmail.com>

## disable prompts from apt
ENV DEBIAN_FRONTEND noninteractive

## custom apt-get install options
ENV OPTS_APT        -y --force-yes --no-install-recommends

## ensure locale is set during build
ENV LC_ALL          C.UTF-8
ENV LANG            C.UTF-8
ENV LANGUAGE        C.UTF-8

## ensure locale is set for new logins
RUN echo    'LC_ALL=C.UTF-8' >> '/etc/default/locale'\
 && echo      'LANG=C.UTF-8' >> '/etc/default/locale'\
 && echo  'LANGUAGE=C.UTF-8' >> '/etc/default/locale'

## add ppa for ubuntu trusty haskell packages
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F6F88286\
 && echo 'deb     http://ppa.launchpad.net/hvr/ghc/ubuntu trusty main' >> /etc/apt/sources.list.d/haskell.list\
 && echo 'deb-src http://ppa.launchpad.net/hvr/ghc/ubuntu trusty main' >> /etc/apt/sources.list.d/haskell.list

## haskell package versions; can be overriden via context hacks
ENV VERSION_ALEX   3.1.3
ENV VERSION_CABAL  1.20
ENV VERSION_HAPPY  1.19.4

## install minimal set of haskell packages
RUN apt-get update\
 && apt-get install ${OPTS_APT}\
      alex-"${VERSION_ALEX}"\
      cabal-install-"${VERSION_CABAL}"\
      happy-"${VERSION_HAPPY}"

## haskell package versions; can be overriden via context hacks
ENV VERSION_GHC    7.8.3

## install ghc
RUN apt-get update\
 && apt-get install ${OPTS_APT}\
      ghc-"${VERSION_GHC}"

## link the binaries into /usr/local/bin
RUN find /opt -maxdepth 3 -name bin -type d\
  -exec sh -c\
    'cd {} && ls .\
      | egrep -v ^.*\-[.[:digit:]]+$\
      | xargs -I % ln -s `pwd`/% /usr/local/bin/%' \;

## run ghci by default unless a command is specified
CMD ["ghci"]
