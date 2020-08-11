FROM debian:stretch

RUN apt-get update && \
    apt-get install -y --no-install-recommends gnupg ca-certificates dirmngr && \
    rm -rf /var/lib/apt/lists/*

ARG GHC=8.10.2
ARG DEBIAN_KEY=427CB69AAC9D00F2A43CAF1CBA3CBA3FFE22B574
ARG CABAL_INSTALL=3.2
ARG STACK=2.3.3
ARG STACK_KEY=C5705533DA4F78D8664B5DC0575159689BEFB442
ARG STACK_RELEASE_KEY=2C6A674E85EE3FB896AFC9B965101FF31C5C154D

RUN export GNUPGHOME="$(mktemp -d)" && \
    gpg --batch --keyserver keyserver.ubuntu.com --recv-keys ${DEBIAN_KEY} && \
    gpg --batch --armor --export ${DEBIAN_KEY} > /etc/apt/trusted.gpg.d/haskell.org.gpg.asc && \
    gpgconf --kill all && \
    echo 'deb http://downloads.haskell.org/debian stretch main' > /etc/apt/sources.list.d/ghc.list && \
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
    rm -rf "$GNUPGHOME" /var/lib/apt/lists/*

RUN export GNUPGHOME="$(mktemp -d)" && \
    gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys ${STACK_KEY} && \
    gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys ${STACK_RELEASE_KEY} && \
    curl -fSL https://github.com/commercialhaskell/stack/releases/download/v${STACK}/stack-${STACK}-linux-x86_64.tar.gz -o stack.tar.gz && \
    curl -fSL https://github.com/commercialhaskell/stack/releases/download/v${STACK}/stack-${STACK}-linux-x86_64.tar.gz.asc -o stack.tar.gz.asc && \
    gpg --batch --trusted-key 0x575159689BEFB442 --verify stack.tar.gz.asc stack.tar.gz && \
    tar -xf stack.tar.gz -C /usr/local/bin --strip-components=1 && \
    /usr/local/bin/stack config set system-ghc --global true && \
    /usr/local/bin/stack config set install-ghc --global false && \
    rm -rf "$GNUPGHOME" /var/lib/apt/lists/* /stack.tar.gz.asc /stack.tar.gz

ENV PATH /root/.cabal/bin:/root/.local/bin:/opt/cabal/${CABAL_INSTALL}/bin:/opt/ghc/${GHC}/bin:$PATH

CMD ["ghci"]
