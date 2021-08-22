FROM debian:stretch AS builder

ENV LANG C.UTF-8

# to install ghcup + ghc, cabal and stack
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        gcc \
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

# install ghcup
ARG GHCUP_VERSION=0.1.16.2
RUN curl --proto '=https' --tlsv1.2 -sSf https://downloads.haskell.org/~ghcup/$GHCUP_VERSION/x86_64-linux-ghcup-$GHCUP_VERSION > /usr/bin/ghcup && \
    chmod +x /usr/bin/ghcup

# install cabal
ARG CABAL_VERSION=3.4.0.0
RUN ghcup install cabal -i /usr/local/bin $CABAL_VERSION

# install stack
ARG STACK_VERSION=2.7.3
RUN ghcup install stack -i /usr/local/bin $STACK_VERSION

# install GHC into /opt/ghc + remove profiling support
ARG GHC_VERSION=9.0.1
RUN ghcup install ghc -i /opt/ghc $GHC_VERSION && \
  find /opt/ghc/lib -name "*.p_hi" -type f -delete && \
  find /opt/ghc/lib -name "*_p.a" -type f -delete

FROM debian:stretch

ENV LANG C.UTF-8

# common haskell + stack dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        g++ \
        gcc \
        git \
        gnupg \
        libc6-dev \
        libffi-dev \
        libgmp-dev \
        libtinfo-dev \
        make \
        netbase \
        xz-utils \
        zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /opt/ghc/bin /opt/ghc/bin
COPY --from=builder /opt/ghc/lib /opt/ghc/lib

# stack should use global ghc
RUN /usr/local/bin/stack config set system-ghc --global true && \
    /usr/local/bin/stack config set install-ghc --global false

# ensure any user gets GHC on the path
RUN echo 'export PATH="/opt/ghc/bin:$PATH"' >> /etc/profile.d/ghc_path.sh && \
	chmod +x /etc/profile.d/ghc_path.sh

ENV PATH /root/.cabal/bin:/root/.local/bin:/opt/ghc/bin:$PATH

CMD ["ghci"]
