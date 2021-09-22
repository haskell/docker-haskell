FROM debian:stretch

ENV LANG C.UTF-8

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        dirmngr \
        g++ \
        git \
        gnupg \
        libsqlite3-dev \
        libtinfo-dev \
        libgmp-dev \
        make \
        netbase \
        openssh-client \
        xz-utils \
        zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

ARG GHCUP_VERSION=0.1.17
ARG GPG_KEY=7784930957807690A66EBDBE3786C5262ECB4A3F

# install ghcup
RUN gpg --batch --keyserver keys.openpgp.org --recv-keys $GPG_KEY && \
    curl -sSfL -O https://downloads.haskell.org/~ghcup/$GHCUP_VERSION/x86_64-linux-ghcup-$GHCUP_VERSION && \
    curl -sSfL -O https://downloads.haskell.org/~ghcup/$GHCUP_VERSION/SHA256SUMS && \
    curl -sSfL -O https://downloads.haskell.org/~ghcup/$GHCUP_VERSION/SHA256SUMS.sig && \
    gpg --verify SHA256SUMS.sig SHA256SUMS && \
    sha256sum -c --ignore-missing SHA256SUMS && \
    mv x86_64-linux-ghcup-$GHCUP_VERSION /usr/bin/ghcup && \
    chmod +x /usr/bin/ghcup && \
    rm -rf SHA256SUMS SHA256SUMS.sig

ARG GHC=9.0.1
ARG CABAL_INSTALL=3.6.0.0
ARG STACK=2.7.3

# install haskell toolchain
RUN export GHCUP_CURL_OPTS="--silent" && \
	ghcup config set gpg-setting GPGStrict && \
	ghcup --verbose install ghc   --isolate=/usr     --force ${GHC} && \
	ghcup --verbose install cabal --isolate=/usr/bin --force ${CABAL_INSTALL} && \
	ghcup --verbose install stack --isolate=/usr/bin --force ${STACK} && \
	find "/usr/lib/ghc-${GHC}/" \( -name "*_p.a" -o -name "*.p_hi" \) -type f -delete && \
	rm -r "/usr/share/doc/ghc-${GHC}" && \
	rm -rf /tmp/ghcup*

ENV PATH /root/.cabal/bin:/root/.local/bin:$PATH

CMD ["ghci"]
