FROM debian:buster

RUN apt-get update && \
    apt-get install -y --no-install-recommends gnupg ca-certificates dirmngr && \
    rm -rf /var/lib/apt/lists/*

ARG GHC=8.10.1
ARG CABAL_INSTALL=3.2

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 427CB69AAC9D00F2A43CAF1CBA3CBA3FFE22B574 && \
    echo 'deb http://downloads.haskell.org/debian buster main' > /etc/apt/sources.list.d/ghc.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        cabal-install-${CABAL_INSTALL} \
        curl \
        g++ \
        ghc-${GHC} \
        git \
        libsqlite3-dev \
        libtinfo-dev \
        make \
        netbase \
        openssh-client \
        xz-utils \
        zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

ENV PATH /root/.cabal/bin:/opt/cabal/${CABAL_INSTALL}/bin:/opt/ghc/${GHC}/bin:$PATH

CMD ["ghci"]
