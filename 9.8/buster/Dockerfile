FROM buildpack-deps:buster

ENV LANG C.UTF-8

# additional haskell specific deps
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libnuma-dev \
        libtinfo-dev && \
    rm -rf /var/lib/apt/lists/*

ARG STACK=2.15.1
ARG STACK_RELEASE_KEY=C5705533DA4F78D8664B5DC0575159689BEFB442

RUN set -eux; \
    cd /tmp; \
    ARCH="$(dpkg-architecture --query DEB_BUILD_GNU_CPU)"; \
    STACK_URL="https://github.com/commercialhaskell/stack/releases/download/v${STACK}/stack-${STACK}-linux-$ARCH.tar.gz"; \
    # sha256 from https://github.com/commercialhaskell/stack/releases/download/v${STACK}/stack-${STACK}-linux-$ARCH.tar.gz.sha256
    case "$ARCH" in \
        'aarch64') \
            STACK_SHA256='450126245044aa37ea8ba33f70c3c5bad331a3b4d3138f7b7ad0dee2a4ca1613'; \
            ;; \
        'x86_64') \
            STACK_SHA256='3e8d85c4c9d24905498edc8c0ec0b4fa207093d9817f281d842c203f33ad9f5e'; \
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

ARG CABAL_INSTALL=3.10.2.0
ARG CABAL_INSTALL_RELEASE_KEY=EAF2A9A722C0C96F2B431CA511AAD8CEDEE0CAEF

RUN set -eux; \
    cd /tmp; \
    ARCH="$(dpkg-architecture --query DEB_BUILD_GNU_CPU)"; \
    CABAL_INSTALL_TAR="cabal-install-$CABAL_INSTALL-$ARCH-linux-deb10.tar.xz"; \
    CABAL_INSTALL_URL="https://downloads.haskell.org/~cabal/cabal-install-$CABAL_INSTALL/$CABAL_INSTALL_TAR"; \
    CABAL_INSTALL_SHA256SUMS_URL="https://downloads.haskell.org/~cabal/cabal-install-$CABAL_INSTALL/SHA256SUMS"; \
    # sha256 from https://downloads.haskell.org/~cabal/cabal-install-$CABAL_INSTALL/SHA256SUMS
    case "$ARCH" in \
        'aarch64') \
            CABAL_INSTALL_SHA256='004ed4a7ca890fadee23f58f9cb606c066236a43e16b34be2532b177b231b06d'; \
            ;; \
        'x86_64') \
            CABAL_INSTALL_SHA256='bdeb27c008b09c3b86f8a2768018d62a1aee02565304d123fda87ed432549418'; \
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

ARG GHC=9.8.1
ARG GHC_RELEASE_KEY=FFEB7CE81E16A36B3E2DED6F2DE04D4E97DB64AD

RUN set -eux; \
    cd /tmp; \
    ARCH="$(dpkg-architecture --query DEB_BUILD_GNU_CPU)"; \
    GHC_URL="https://downloads.haskell.org/~ghc/$GHC/ghc-$GHC-$ARCH-deb10-linux.tar.xz"; \
    # sha256 from https://downloads.haskell.org/~ghc/$GHC/SHA256SUMS
    case "$ARCH" in \
        'aarch64') \
            GHC_SHA256='aab7af72614f8bf9ca624407aa4dbc69bc009c2b4cc1a0f3c062008db81bdb95'; \
            ;; \
        'x86_64') \
            GHC_SHA256='d498657ca00514bc4620b591f74b93f9a3b64e5282e5c4e2876a734c130f1fbf'; \
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
