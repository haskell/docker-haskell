## Dockerfile for a haskell environment
FROM       debian:jessie
MAINTAINER Chris Biscardi <chris@christopherbiscardi.com>

## custom apt-get install options
ENV OPTS_APT        -y --no-install-recommends

## ensure locale is set during build
ENV LANG            C.UTF-8

RUN echo 'deb http://ppa.launchpad.net/hvr/ghc/ubuntu trusty main' > /etc/apt/sources.list.d/ghc.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F6F88286 && \
    apt-get update && \
    apt-get install ${OPTS_APT} cabal-install-1.20 ghc-7.8.4 happy-1.19.4 alex-3.1.3 zlib1g-dev libtinfo-dev libsqlite3-0 libsqlite3-dev && \
    rm -rf /var/lib/apt/lists/*

ENV PATH /root/.cabal/bin:/opt/cabal/1.20/bin:/opt/ghc/7.8.4/bin:/opt/happy/1.19.4/bin:/opt/alex/3.1.3/bin:$PATH

## run ghci by default unless a command is specified
CMD ["ghci"]
