FROM debian:bullseye-slim

ENV LANG C.UTF-8

# common haskell + stack dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        dpkg-dev \
        git \
        gcc \
        gnupg \
        g++ \
        libc6-dev \
        libffi-dev \
        libgmp-dev \
        libnuma-dev \
        libtinfo-dev \
        make \
        netbase \
        xz-utils \
        zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

ARG STACK=3.1.1
ARG STACK_RELEASE_KEY=C5705533DA4F78D8664B5DC0575159689BEFB442

RUN set -eux; \
    cd /tmp; \
    ARCH="$(dpkg-architecture --query DEB_BUILD_GNU_CPU)"; \
    STACK_URL="https://github.com/commercialhaskell/stack/releases/download/v${STACK}/stack-${STACK}-linux-$ARCH.tar.gz"; \
    # sha256 from https://github.com/commercialhaskell/stack/releases/download/v${STACK}/stack-${STACK}-linux-$ARCH.tar.gz.sha256
    case "$ARCH" in \
        'aarch64') \
            STACK_SHA256='033cb75bad3a5299b522c99e8056915bd081879f5df312e6d44d7511fc567455'; \
            ;; \
        'x86_64') \
            STACK_SHA256='d096125ea3d987a55d17f7d4f8599ee2fd96bd2d0f033566e28ddfe248f730f9'; \
            ;; \
        *) echo >&2 "error: unsupported architecture '$ARCH'" ; exit 1 ;; \
    esac; \
    curl -sSL "$STACK_URL" -o stack.tar.gz; \
    echo "$STACK_SHA256 stack.tar.gz" | sha256sum --strict --check; \
    \
    curl -sSL "$STACK_URL.asc" -o stack.tar.gz.asc; \
    GNUPGHOME="$(mktemp -d)"; export GNUPGHOME; \
    gpg --batch --keyserver keyserver.ubuntu.com --receive-keys "$STACK_RELEASE_KEY"; \
    gpg --batch --verify stack.tar.gz.asc stack.tar.gz; \
    gpgconf --kill all; \
    \
    tar -xf stack.tar.gz -C /usr/local/bin --strip-components=1 "stack-$STACK-linux-$ARCH/stack"; \
    stack config set system-ghc --global true; \
    stack config set install-ghc --global false; \
    \
    rm -rf /tmp/*; \
    \
    stack --version;

ARG CABAL_INSTALL=3.10.3.0
ARG CABAL_INSTALL_RELEASE_KEY=EAF2A9A722C0C96F2B431CA511AAD8CEDEE0CAEF

RUN set -eux; \
    cd /tmp; \
    ARCH="$(dpkg-architecture --query DEB_BUILD_GNU_CPU)"; \
    CABAL_INSTALL_TAR="cabal-install-$CABAL_INSTALL-$ARCH-linux-deb11.tar.xz"; \
    CABAL_INSTALL_URL="https://downloads.haskell.org/~cabal/cabal-install-$CABAL_INSTALL/$CABAL_INSTALL_TAR"; \
    CABAL_INSTALL_SHA256SUMS_URL="https://downloads.haskell.org/~cabal/cabal-install-$CABAL_INSTALL/SHA256SUMS"; \
    # sha256 from https://downloads.haskell.org/~cabal/cabal-install-$CABAL_INSTALL/SHA256SUMS
    case "$ARCH" in \
        'aarch64') \
            CABAL_INSTALL_SHA256='e0b6604d3596c5e5b7236e79ff4f5aa8af337792bf69ac4a90634c761f1b9ed5'; \
            ;; \
        'x86_64') \
            CABAL_INSTALL_SHA256='12d018bdd07efed470f278f22d94b33655c4fcbc44d28d97b5ebb7944d5607c5'; \
            ;; \
        *) echo >&2 "error: unsupported architecture '$ARCH'"; exit 1 ;; \
    esac; \
    curl -fSL "$CABAL_INSTALL_URL" -o cabal-install.tar.gz; \
    echo "$CABAL_INSTALL_SHA256 cabal-install.tar.gz" | sha256sum --strict --check; \
    \
    curl -sSLO "$CABAL_INSTALL_SHA256SUMS_URL"; \
    curl -sSLO "$CABAL_INSTALL_SHA256SUMS_URL.sig"; \
    GNUPGHOME="$(mktemp -d)"; export GNUPGHOME; \
    gpg --batch --keyserver keyserver.ubuntu.com --receive-keys "$CABAL_INSTALL_RELEASE_KEY"; \
    gpg --batch --verify SHA256SUMS.sig SHA256SUMS; \
    # confirm we are verifying SHA256SUMS that matches the release + sha256
    grep "$CABAL_INSTALL_SHA256  $CABAL_INSTALL_TAR" SHA256SUMS; \
    gpgconf --kill all; \
    \
    tar -xf cabal-install.tar.gz -C /usr/local/bin; \
    \
    rm -rf /tmp/*; \
    \
    cabal --version

ARG GHC=9.10.1
ARG GHC_RELEASE_KEY=FFEB7CE81E16A36B3E2DED6F2DE04D4E97DB64AD

RUN set -eux; \
    cd /tmp; \
    ARCH="$(dpkg-architecture --query DEB_BUILD_GNU_CPU)"; \
    GHC_URL="https://downloads.haskell.org/~ghc/$GHC/ghc-$GHC-$ARCH-deb11-linux.tar.xz"; \
    # sha256 from https://downloads.haskell.org/~ghc/$GHC/SHA256SUMS
    case "$ARCH" in \
        'aarch64') \
            GHC_SHA256='1db449c445d34779d4deaba22341576f7b512a05b6c2b5cb64f3846d1509714e'; \
            ;; \
        'x86_64') \
            GHC_SHA256='78975575b8125ecf1f50f78b1016b14ea6e87abbf1fc39797af469d029c5d737'; \
            ;; \
        *) echo >&2 "error: unsupported architecture '$ARCH'" ; exit 1 ;; \
    esac; \
    curl -sSL "$GHC_URL" -o ghc.tar.xz; \
    echo "$GHC_SHA256 ghc.tar.xz" | sha256sum --strict --check; \
    \
    GNUPGHOME="$(mktemp -d)"; export GNUPGHOME; \
    curl -sSL "$GHC_URL.sig" -o ghc.tar.xz.sig; \
    gpg --batch --keyserver keyserver.ubuntu.com --receive-keys "$GHC_RELEASE_KEY"; \
    gpg --batch --verify ghc.tar.xz.sig ghc.tar.xz; \
    gpgconf --kill all; \
    \
    tar xf ghc.tar.xz; \
    cd "ghc-$GHC-$ARCH-unknown-linux"; \
    ./configure --prefix "/opt/ghc/$GHC"; \
    make install; \
    \
    rm -rf /tmp/*; \
    \
    "/opt/ghc/$GHC/bin/ghc" --version

ENV PATH /root/.cabal/bin:/root/.local/bin:/opt/ghc/${GHC}/bin:$PATH

CMD ["ghci"]
