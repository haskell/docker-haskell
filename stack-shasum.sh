#!/bin/sh
# Get stack, verify using GPG, calculate tarball sha256sum

# Get keys
#
# gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys C5705533DA4F78D8664B5DC0575159689BEFB442
# gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys 2C6A674E85EE3FB896AFC9B965101FF31C5C154D
#

STACKVER=2.1.3

curl -fSL https://github.com/commercialhaskell/stack/releases/download/v${STACKVER}/stack-${STACKVER}-linux-x86_64.tar.gz -o stack.tar.gz && \
curl -fSL https://github.com/commercialhaskell/stack/releases/download/v${STACKVER}/stack-${STACKVER}-linux-x86_64.tar.gz.asc -o stack.tar.gz.asc && \

gpg --batch --trusted-key 0x575159689BEFB442 --verify stack.tar.gz.asc stack.tar.gz

sha256sum stack.tar.gz
 
