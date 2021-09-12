FROM debian:stretch

ENV LANG C.UTF-8

# common haskell + stack dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        dirmngr \
        git \
        gcc \
        gnupg \
        g++ \
        libc6-dev \
        libffi-dev \
        libgmp-dev \
        libsqlite3-dev \
        libtinfo-dev \
        make \
        netbase \
        openssh-client \
        xz-utils \
        zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

ARG CABAL_INSTALL=3.6.0.0
ARG CABAL_INSTALL_RELEASE_KEY=A970DF3AC3B9709706D74544B3D9F94B8DCAE210
# get from https://downloads.haskell.org/~cabal/cabal-install-$CABAL_INSTALL/SHA256SUMS
ARG CABAL_INSTALL_RELEASE_SHA256=BFCB7350966DAFE95051B5FC9FCB989C5708AB9E78191E71FC04647061668A11

RUN cd /tmp && \
    export GNUPGHOME="$(mktemp -d)" && \
    gpg --batch --keyserver keyserver.ubuntu.com --recv-keys ${CABAL_INSTALL_RELEASE_KEY} && \
    curl -fSLO https://downloads.haskell.org/~cabal/cabal-install-$CABAL_INSTALL/SHA256SUMS && \
    curl -fSLO https://downloads.haskell.org/~cabal/cabal-install-$CABAL_INSTALL/SHA256SUMS.sig && \
    gpg --batch --trusted-key B3D9F94B8DCAE210 --verify SHA256SUMS.sig SHA256SUMS && \
    curl -fSL https://downloads.haskell.org/~cabal/cabal-install-$CABAL_INSTALL/cabal-install-$CABAL_INSTALL-x86_64-linux.tar.xz -o cabal-install.tar.gz && \
    echo "$CABAL_INSTALL_RELEASE_SHA256 cabal-install.tar.gz" | sha256sum --strict --check && \
    tar -xf cabal-install.tar.gz -C /usr/local/bin && \
    rm -rf "$GNUPGHOME" /var/lib/apt/lists/* /tmp/*

ARG GHC=9.0.1
ARG GHC_RELEASE_KEY=FFEB7CE81E16A36B3E2DED6F2DE04D4E97DB64AD
# get from https://downloads.haskell.org/~ghc/$GHC/SHA256SUMS
ARG GHC_RELEASE_SHA256=4CA6252492F59FE589029FADCA4B6F922D6A9F0FF39D19A2BD9886FDE4E183D5

RUN cd /tmp && \
  export GNUPGHOME="$(mktemp -d)" && \
  curl -sSL https://downloads.haskell.org/~ghc/$GHC/ghc-$GHC-x86_64-deb9-linux.tar.xz -o ghc.tar.xz && \
  curl -sSL https://downloads.haskell.org/~ghc/$GHC/ghc-$GHC-x86_64-deb9-linux.tar.xz.sig -o ghc.tar.xz.sig && \
  gpg --batch --keyserver keyserver.ubuntu.com --receive-keys ${GHC_RELEASE_KEY} && \
  gpg --batch --trusted-key 2DE04D4E97DB64AD --verify ghc.tar.xz.sig ghc.tar.xz && \
  echo "$GHC_RELEASE_SHA256 ghc.tar.xz" | sha256sum --strict --check && \
  tar xf ghc.tar.xz && \
  cd ghc-$GHC && \
  ./configure --prefix /opt/ghc/$GHC && \
  make install && \
  find /opt/ghc/$GHC/ \( -name "*_p.a" -o -name "*.p_hi" \) -type f -delete && \
  rm -rf /opt/ghc/$GHC/share/ && \
  rm -rf "$GNUPGHOME" /tmp/*

ARG STACK=2.7.3
ARG STACK_RELEASE_KEY=C5705533DA4F78D8664B5DC0575159689BEFB442
# get from https://github.com/commercialhaskell/stack/releases/download/v${STACK}/stack-${STACK}-linux-x86_64.tar.gz.sha256
ARG STACK_RELEASE_SHA256=A6C090555FA1C64AA61C29AA4449765A51D79E870CF759CDE192937CD614E72B

RUN cd /tmp && \
    export GNUPGHOME="$(mktemp -d)" && \
    gpg --batch --keyserver keyserver.ubuntu.com --recv-keys ${STACK_RELEASE_KEY} && \
    curl -fSL https://github.com/commercialhaskell/stack/releases/download/v${STACK}/stack-${STACK}-linux-x86_64.tar.gz -o stack.tar.gz && \
    curl -fSL https://github.com/commercialhaskell/stack/releases/download/v${STACK}/stack-${STACK}-linux-x86_64.tar.gz.asc -o stack.tar.gz.asc && \
    gpg --batch --trusted-key 575159689BEFB442 --verify stack.tar.gz.asc stack.tar.gz && \
    echo "$STACK_RELEASE_SHA256 stack.tar.gz" | sha256sum --strict --check && \
    tar -xf stack.tar.gz -C /usr/local/bin --strip-components=1 stack-$STACK-linux-x86_64/stack && \
    /usr/local/bin/stack config set system-ghc --global true && \
    /usr/local/bin/stack config set install-ghc --global false && \
    rm -rf "$GNUPGHOME" /var/lib/apt/lists/* /tmp/*

ENV PATH /root/.cabal/bin:/root/.local/bin:/opt/ghc/${GHC}/bin:$PATH

CMD ["ghci"]
