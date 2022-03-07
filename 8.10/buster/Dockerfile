FROM debian:buster

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
        libsqlite3-dev \
        libtinfo-dev \
        make \
        netbase \
        openssh-client \
        xz-utils \
        zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

ARG CABAL_INSTALL=3.6.2.0
ARG CABAL_INSTALL_RELEASE_KEY=A970DF3AC3B9709706D74544B3D9F94B8DCAE210

RUN set -eux; \
    cd /tmp; \
    ARCH="$(dpkg-architecture --query DEB_BUILD_GNU_CPU)"; \
    CABAL_INSTALL_TAR="cabal-install-$CABAL_INSTALL-$ARCH-linux-deb10.tar.xz"; \
    CABAL_INSTALL_URL="https://downloads.haskell.org/~cabal/cabal-install-$CABAL_INSTALL/$CABAL_INSTALL_TAR"; \
    CABAL_INSTALL_SHA256SUMS_URL="https://downloads.haskell.org/~cabal/cabal-install-$CABAL_INSTALL/SHA256SUMS"; \
    # sha256 from https://downloads.haskell.org/~cabal/cabal-install-$CABAL_INSTALL/SHA256SUMS
    case "$ARCH" in \
        'aarch64') \
            CABAL_INSTALL_SHA256='d9acee67d4308bc5c22d27bee034d388cc4192a25deff9e7e491e2396572b030'; \
            ;; \
        'x86_64') \
            CABAL_INSTALL_SHA256='4759b56e9257e02f29fa374a6b25d6cb2f9d80c7e3a55d4f678a8e570925641c'; \
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
    # confirm we are verying SHA256SUMS that matches the release + sha256
    grep "$CABAL_INSTALL_SHA256  $CABAL_INSTALL_TAR" SHA256SUMS; \
    gpgconf --kill all; \
    \
    tar -xf cabal-install.tar.gz -C /usr/local/bin; \
    \
    rm -rf /tmp/*; \
    \
    cabal --version

# GHC 8.10 requires LLVM version 9 - 12 on aarch64
ARG LLVM_VERSION=12
ARG LLVM_KEY=6084F3CF814B57C1CF12EFD515CF4D18AF4F7421

RUN set -eux; \
    if [ "$(dpkg-architecture --query DEB_BUILD_GNU_CPU)" = "aarch64" ]; then \
        GNUPGHOME="$(mktemp -d)"; export GNUPGHOME; \
        mkdir -p /usr/local/share/keyrings/; \
        gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$LLVM_KEY"; \
        gpg --batch --armor --export "$LLVM_KEY" > /usr/local/share/keyrings/apt.llvm.org.gpg.asc; \
        echo "deb [ signed-by=/usr/local/share/keyrings/apt.llvm.org.gpg.asc ] http://apt.llvm.org/buster/ llvm-toolchain-buster-$LLVM_VERSION main" > /etc/apt/sources.list.d/llvm.list; \
        apt-get update; \
        apt-get install -y --no-install-recommends llvm-$LLVM_VERSION; \
        gpgconf --kill all; \
        rm -rf "$GNUPGHOME" /var/lib/apt/lists/*; \
    fi

ARG GHC=8.10.7
ARG GHC_RELEASE_KEY=88B57FCF7DB53B4DB3BFA4B1588764FBE22D19C4

RUN set -eux; \
    cd /tmp; \
    ARCH="$(dpkg-architecture --query DEB_BUILD_GNU_CPU)"; \
    GHC_URL="https://downloads.haskell.org/~ghc/$GHC/ghc-$GHC-$ARCH-deb10-linux.tar.xz"; \
    # sha256 from https://downloads.haskell.org/~ghc/$GHC/SHA256SUMS
    case "$ARCH" in \
        'aarch64') \
            GHC_SHA256='fad2417f9b295233bf8ade79c0e6140896359e87be46cb61cd1d35863d9d0e55'; \
            ;; \
        'x86_64') \
            GHC_SHA256='a13719bca87a0d3ac0c7d4157a4e60887009a7f1a8dbe95c4759ec413e086d30'; \
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
    cd "ghc-$GHC"; \
    ./configure --prefix "/opt/ghc/$GHC"; \
    make install; \
    # remove some docs
    rm -rf "/opt/ghc/$GHC/share/"; \
    \
    rm -rf /tmp/*; \
    \
    "/opt/ghc/$GHC/bin/ghc" --version

ARG STACK=2.7.5
ARG STACK_RELEASE_KEY=C5705533DA4F78D8664B5DC0575159689BEFB442

RUN set -eux; \
    cd /tmp; \
    ARCH="$(dpkg-architecture --query DEB_BUILD_GNU_CPU)"; \
    INSTALL_STACK="true"; \
    STACK_URL="https://github.com/commercialhaskell/stack/releases/download/v${STACK}/stack-${STACK}-linux-$ARCH.tar.gz"; \
    # sha256 from https://github.com/commercialhaskell/stack/releases/download/v${STACK}/stack-${STACK}-linux-$ARCH.tar.gz.sha256
    case "$ARCH" in \
        'aarch64') \
            # Stack does not officially support ARM64, nor do the binaries that exist work.
            # Hitting https://github.com/commercialhaskell/stack/issues/2103#issuecomment-972329065 when trying to use
            # stack-2.7.1-linux-aarch64.tar.gz
            INSTALL_STACK="false"; \
            ;; \
        'x86_64') \
            STACK_SHA256='9bcd165358d4dcafd2b33320d4fe98ce72faaf62300cc9b0fb86a27eb670da50'; \
            ;; \
        *) echo >&2 "error: unsupported architecture '$ARCH'" ; exit 1 ;; \
    esac; \
    if [ "$INSTALL_STACK" = "true" ]; then \
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
        stack --version; \
    fi

ENV PATH /root/.cabal/bin:/root/.local/bin:/opt/ghc/${GHC}/bin:$PATH

CMD ["ghci"]
