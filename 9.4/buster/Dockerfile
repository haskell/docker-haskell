FROM buildpack-deps:buster

ENV LANG C.UTF-8

# additional haskell specific deps
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libnuma-dev \
        libtinfo-dev && \
    rm -rf /var/lib/apt/lists/*

ARG STACK=2.11.1
ARG STACK_RELEASE_KEY=C5705533DA4F78D8664B5DC0575159689BEFB442

RUN set -eux; \
    cd /tmp; \
    ARCH="$(dpkg-architecture --query DEB_BUILD_GNU_CPU)"; \
    STACK_URL="https://github.com/commercialhaskell/stack/releases/download/v${STACK}/stack-${STACK}-linux-$ARCH.tar.gz"; \
    # sha256 from https://github.com/commercialhaskell/stack/releases/download/v${STACK}/stack-${STACK}-linux-$ARCH.tar.gz.sha256
    case "$ARCH" in \
        'aarch64') \
            STACK_SHA256='c7733d07ed78d6f4d82e0ebf6d260eb693c6c9df2208003d60caba69766f9c15'; \
            ;; \
        'x86_64') \
            STACK_SHA256='408a120e824ed6e6b24c548a2ff6f210fcb0eed246f204a280ed4c75af0517e7'; \
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

ARG CABAL_INSTALL=3.8.1.0
ARG CABAL_INSTALL_RELEASE_KEY=E9EC5616017C3EE26B33468CCE1ED8AE0B011D8C

RUN set -eux; \
    cd /tmp; \
    ARCH="$(dpkg-architecture --query DEB_BUILD_GNU_CPU)"; \
    CABAL_INSTALL_TAR="cabal-install-$CABAL_INSTALL-$ARCH-linux-deb10.tar.xz"; \
    CABAL_INSTALL_URL="https://downloads.haskell.org/~cabal/cabal-install-$CABAL_INSTALL/$CABAL_INSTALL_TAR"; \
    CABAL_INSTALL_SHA256SUMS_URL="https://downloads.haskell.org/~cabal/cabal-install-$CABAL_INSTALL/SHA256SUMS"; \
    # sha256 from https://downloads.haskell.org/~cabal/cabal-install-$CABAL_INSTALL/SHA256SUMS
    case "$ARCH" in \
        'aarch64') \
            CABAL_INSTALL_SHA256='c7fa9029f2f829432dd9dcf764e58605fbb7431db79234feb3e46684a9b37214'; \
            ;; \
        'x86_64') \
            CABAL_INSTALL_SHA256='c71a1a46fd42d235bb86be968660815c24950e5da2d1ff4640da025ab520424b'; \
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

ARG GHC=9.4.6
ARG GHC_RELEASE_KEY=88b57fcf7db53b4db3bfa4b1588764fbe22d19c4

RUN set -eux; \
    cd /tmp; \
    ARCH="$(dpkg-architecture --query DEB_BUILD_GNU_CPU)"; \
    GHC_URL="https://downloads.haskell.org/~ghc/$GHC/ghc-$GHC-$ARCH-deb10-linux.tar.xz"; \
    # sha256 from https://downloads.haskell.org/~ghc/$GHC/SHA256SUMS
    case "$ARCH" in \
        'aarch64') \
            GHC_SHA256='b27e4e4d760216457c20fdce3ec419e1bac905608e6577c2c2fa15f4a3779370'; \
            ;; \
        'x86_64') \
            GHC_SHA256='6061c20ff4e154e81944dfc9f37afff5aaa05ce51ad25db3425ff85bb85a92a3'; \
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
