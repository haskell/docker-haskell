#! /bin/sh

set -eux;

cd /tmp;
ARCH="$(dpkg-architecture --query DEB_BUILD_GNU_CPU)";
STACK_URL="https://github.com/commercialhaskell/stack/releases/download/v${STACK}/stack-${STACK}-linux-$ARCH.tar.gz";
# sha256 from https://github.com/commercialhaskell/stack/releases/download/v${STACK}/stack-${STACK}-linux-$ARCH.tar.gz.sha256
case "$ARCH" in
    'aarch64')
        STACK_SHA256='0581cebe880b8ed47556ee73d8bbb9d602b5b82e38f89f6aa53acaec37e7760d';
        ;;
    'x86_64')
        STACK_SHA256='0581cebe880b8ed47556ee73d8bbb9d602b5b82e38f89f6aa53acaec37e7760d';
        ;;
    *) echo >&2 "error: unsupported architecture '$ARCH'" ; exit 1 ;;
esac;
curl -sSL "$STACK_URL" -o stack.tar.gz;
echo "$STACK_SHA256 stack.tar.gz" | sha256sum --strict --check;

curl -sSL "$STACK_URL.asc" -o stack.tar.gz.asc;
GNUPGHOME="$(mktemp -d)"; export GNUPGHOME;
gpg --batch --keyserver keyserver.ubuntu.com --receive-keys "$STACK_RELEASE_KEY";
gpg --batch --verify stack.tar.gz.asc stack.tar.gz;
gpgconf --kill all;

tar -xf stack.tar.gz -C /usr/local/bin --strip-components=1 "stack-$STACK-linux-$ARCH/stack";
stack config set system-ghc --global true;
stack config set install-ghc --global false;

rm -rf /tmp/*;

stack --version;
