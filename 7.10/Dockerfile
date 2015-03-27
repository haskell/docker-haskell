## Dockerfile for a haskell environment
FROM       debian:jessie
MAINTAINER Chris Biscardi <chris@christopherbiscardi.com>

## custom apt-get install options
ENV OPTS_APT        -y --no-install-recommends

## ensure locale is set during build
ENV LANG            C.UTF-8

RUN apt-get update && \
    apt-get install ${OPTS_APT} software-properties-common && \
    add-apt-repository -y ppa:hvr/ghc && \
    sed -i s/jessie/trusty/g /etc/apt/sources.list.d/hvr-ghc-jessie.list

RUN apt-get update && \
    apt-get install ${OPTS_APT} cabal-install-1.22 ghc-7.10.1 happy-1.19.4 alex-3.1.3

ENV PATH /root/.cabal/bin:/opt/cabal/1.22/bin:/opt/ghc/7.10.1/bin:/opt/happy/1.19.4/bin:/opt/alex/3.1.3/bin:$PATH

## install additional libs typically needed by hackage packages
#RUN apt-get update && \
#    apt-get install ${OPTS_APT} zlib1g-dev libtinfo-dev

## run ghci by default unless a command is specified
CMD ["ghci"]
