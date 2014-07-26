## Dockerfile for a haskell environment
## https://github.com/darinmorrison/docker-haskell
FROM       phusion/baseimage:0.9.12
MAINTAINER Darin Morrison <darinmorrison+docker@gmail.com>

## disable prompts from apt
ENV DEBIAN_FRONTEND noninteractive

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

## start the init system (e.g., for sshd)
# CMD ["/sbin/my_init"]

## support apt-cacher-ng
# RUN echo 'Acquire::http { Proxy "http://<hostname>:3142"; };' >> /etc/apt/apt.conf.d/01proxy

## add ppa for ubuntu trusty haskell packages
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F6F88286\
 && echo 'deb     http://ppa.launchpad.net/hvr/ghc/ubuntu trusty main' >> /etc/apt/sources.list.d/haskell.list\
 && echo 'deb-src http://ppa.launchpad.net/hvr/ghc/ubuntu trusty main' >> /etc/apt/sources.list.d/haskell.list

## update the package database
RUN apt-get update

## install llvm for the ghc backend
RUN apt-get install -y --no-install-recommends llvm

## haskell package versions; can be overriden via context hacks
ENV VERSION_ALEX   3.1.3
ENV VERSION_CABAL  1.20
ENV VERSION_GHC    7.8.3
ENV VERSION_HAPPY  1.19.3

## install minimal set of haskell packages
RUN apt-get install -y --no-install-recommends\
      alex-"${VERSION_ALEX}"\
      cabal-install-"${VERSION_CABAL}"\
      ghc-"${VERSION_GHC}"\
      happy-"${VERSION_HAPPY}"

## set the PATH for login shells
RUN echo 'PATH=/opt/happy/${VERSION_HAPPY}/bin:${PATH}' >> /etc/profile.d/haskell.sh\
 && echo 'PATH=/opt/ghc/${VERSION_GHC}/bin:${PATH}'     >> /etc/profile.d/haskell.sh\
 && echo 'PATH=/opt/cabal/${VERSION_CABAL}/bin:${PATH}' >> /etc/profile.d/haskell.sh\
 && echo 'PATH=/opt/alex/${VERSION_ALEX}/bin:${PATH}'   >> /etc/profile.d/haskell.sh

## cleanup
RUN apt-get clean\
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
