## Dockerfile for a haskell environment
## https://github.com/darinmorrison/docker-haskell
FROM       phusion/baseimage:0.9.12
MAINTAINER Darin Morrison <darinmorrison+docker@gmail.com>

## disable prompts from apt
ENV DEBIAN_FRONTEND noninteractive

## custom apt-get install options
ENV OPTS_APT        -y --force-yes --no-install-recommends

## ensure locale is set during build
ENV LC_ALL          en_US.UTF-8
ENV LANG            en_US.UTF-8
ENV LANGUAGE        en_US.UTF-8

## ensure locale is set during init
RUN echo           'en_US.UTF-8' >  '/etc/container_environment/LC_ALL'\
 && echo           'en_US.UTF-8' >  '/etc/container_environment/LANG'\
 && echo           'en_US.UTF-8' >  '/etc/container_environment/LANGUAGE'

## ensure locale is set for new logins
RUN echo    'LC_ALL=en_US.UTF-8' >> '/etc/default/locale'\
 && echo      'LANG=en_US.UTF-8' >> '/etc/default/locale'\
 && echo  'LANGUAGE=en_US.UTF-8' >> '/etc/default/locale'

## add ppa for ubuntu trusty haskell packages
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F6F88286\
 && echo 'deb     http://ppa.launchpad.net/hvr/ghc/ubuntu trusty main' >> /etc/apt/sources.list.d/haskell.list\
 && echo 'deb-src http://ppa.launchpad.net/hvr/ghc/ubuntu trusty main' >> /etc/apt/sources.list.d/haskell.list

## support apt-get mirror method
# RUN sed -i '1ideb mirror://mirrors.ubuntu.com/mirrors.txt trusty-security  main restricted universe multiverse' /etc/apt/sources.list\
#  && sed -i '1ideb mirror://mirrors.ubuntu.com/mirrors.txt trusty-backports main restricted universe multiverse' /etc/apt/sources.list\
#  && sed -i '1ideb mirror://mirrors.ubuntu.com/mirrors.txt trusty-updates   main restricted universe multiverse' /etc/apt/sources.list\
#  && sed -i '1ideb mirror://mirrors.ubuntu.com/mirrors.txt trusty           main restricted universe multiverse' /etc/apt/sources.list

## install ghc dependencies
RUN apt-get update\
 && apt-get install ${OPTS_APT}\
      gcc\
      libc6\
      libc6-dev\
      libgmp10\
      libgmp-dev\
      libncursesw5\
      libtinfo5

## install llvm for the ghc backend
RUN apt-get update\
 && apt-get install ${OPTS_APT} llvm

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

## set the VERSION vars and PATH for login shells
RUN\
  ( exec >> /etc/profile.d/haskell.sh\
 && echo "VERSION_ALEX=${VERSION_ALEX}"\
 && echo "VERSION_CABAL=${VERSION_CABAL}"\
 && echo "VERSION_HAPPY=${VERSION_HAPPY}"\
 && echo "VERSION_GHC=${VERSION_GHC}"\
 && echo 'PATH=/opt/ghc/${VERSION_GHC}/bin:${PATH}'\
 && echo 'PATH=/opt/happy/${VERSION_HAPPY}/bin:${PATH}'\
 && echo 'PATH=/opt/cabal/${VERSION_CABAL}/bin:${PATH}'\
 && echo 'PATH=/opt/alex/${VERSION_ALEX}/bin:${PATH}'\
  )

## run ghci by default unless a command is specified
CMD ["bash", "-cl", "ghci"]
