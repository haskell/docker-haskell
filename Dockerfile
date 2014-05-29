## Dockerfile for a haskell environment
## https://github.com/darinmorrison/docker-haskell
FROM       phusion/baseimage:0.9.10
MAINTAINER Darin Morrison <darinmorrison+docker@gmail.com>

## set the correct environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV HOME            /root
ENV LC_ALL          en_US.UTF-8
ENV LANG            en_US.UTF-8
ENV LANGUAGE        en_US.UTF-8

## start the init system (e.g., for sshd)
# CMD ["/sbin/my_init"]

## support apt-cacher-ng
# RUN echo 'Acquire::http { Proxy "http://<hostname>:3142"; };' >> /etc/apt/apt.conf.d/01proxy

## support apt-get mirror method
# RUN echo 'deb mirror://mirrors.ubuntu.com/mirrors.txt trusty           main restricted universe multiverse' >> /etc/apt/sources.list\
#  && echo 'deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-updates   main restricted universe multiverse' >> /etc/apt/sources.list\
#  && echo 'deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-backports main restricted universe multiverse' >> /etc/apt/sources.list\
#  && echo 'deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-security  main restricted universe multiverse' >> /etc/apt/sources.list

## add ppa for ubuntu trusty haskell packages
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F6F88286\
 && echo 'deb     http://ppa.launchpad.net/hvr/ghc/ubuntu trusty main' >> /etc/apt/sources.list.d/haskell.list\
 && echo 'deb-src http://ppa.launchpad.net/hvr/ghc/ubuntu trusty main' >> /etc/apt/sources.list.d/haskell.list

## install ubuntu trusty haskell packages
RUN apt-get update\
 && apt-get install -y --no-install-recommends alex-3.1.3 cabal-install-1.20 ghc-7.8.2 happy-1.19.3

RUN echo 'PATH=/opt/alex/3.1.3/bin:/opt/cabal/1.20/bin:/opt/ghc/7.8.2/bin:/opt/happy/1.19.3/bin:${PATH}' > /etc/profile.d/haskell.sh

RUN apt-get clean\
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
