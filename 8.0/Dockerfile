## Dockerfile for a haskell environment
FROM       debian:jessie
MAINTAINER Chris Biscardi <chris@christopherbiscardi.com>

## ensure locale is set during build
ENV LANG            C.UTF-8

RUN echo 'deb http://ppa.launchpad.net/hvr/ghc/ubuntu trusty main' > /etc/apt/sources.list.d/ghc.list && \
    # hvr keys
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F6F88286 && \
    apt-get update && \
    apt-get install -y --no-install-recommends cabal-install-1.24 ghc-8.0.2 happy-1.19.5 alex-3.1.7 \
            zlib1g-dev libtinfo-dev libsqlite3-0 libsqlite3-dev ca-certificates g++ git wget && \
    wget -qO- https://get.haskellstack.org/ | sh && \
    rm -rf /var/lib/apt/lists/*

ENV PATH /root/.cabal/bin:/root/.local/bin:/opt/cabal/1.24/bin:/opt/ghc/8.0.2/bin:/opt/happy/1.19.5/bin:/opt/alex/3.1.7/bin:$PATH

## run ghci by default unless a command is specified
CMD ["ghci"]
