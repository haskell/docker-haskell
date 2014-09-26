## Dockerfile for a haskell environment
FROM       debian:stable
MAINTAINER Darin Morrison <darinmorrison+docker@gmail.com>

## disable prompts from apt
ENV DEBIAN_FRONTEND noninteractive

## custom apt-get install options
ENV OPTS_APT        -y --force-yes --no-install-recommends

## ensure locale is set during build
ENV LC_ALL          C.UTF-8
ENV LANG            C.UTF-8
ENV LANGUAGE        C.UTF-8

## ensure locale is set for new logins
RUN echo    'LC_ALL=C.UTF-8' >> '/etc/default/locale'\
 && echo      'LANG=C.UTF-8' >> '/etc/default/locale'\
 && echo  'LANGUAGE=C.UTF-8' >> '/etc/default/locale'

## configure apt to use the haskell repository
ADD http://deb.haskell.org/deb.haskell.org.gpg-key /tmp/deb.haskell.org.gpg-key
RUN apt-key add /tmp/deb.haskell.org.gpg-key\
 && echo 'deb     http://deb.haskell.org/stable/ ./' >> /etc/apt/sources.list.d/haskell.list\
 && echo 'deb-src http://deb.haskell.org/stable/ ./' >> /etc/apt/sources.list.d/haskell.list

## set ghc upstream package versions and ghc deb revisions
ENV VERSION_GHC    7.8.3
ENV DEB_REV_GHC    -1

## install ghc
RUN apt-get update\
 && apt-get install ${OPTS_APT}\
      ghc-7.8.3="${VERSION_GHC}""${DEB_REV_GHC}"

## set upstream package versions for remaining haskell packages
ENV VERSION_ALEX   3.1.3
ENV VERSION_CABAL  1.20.0.3
ENV VERSION_HAPPY  1.19.4

## set deb revisions for remaining haskell packages
ENV DEB_REV_ALEX   -1
ENV DEB_REV_CABAL  -1
ENV DEB_REV_HAPPY  -1

## install minimal set of haskell packages
RUN apt-get update\
 && apt-get install ${OPTS_APT}\
      alex="${VERSION_ALEX}""${DEB_REV_ALEX}"\
      cabal-install-1.20="${VERSION_CABAL}""${DEB_REV_CABAL}"\
      happy="${VERSION_HAPPY}""${DEB_REV_HAPPY}"


## link binaries into /usr/local/bin
RUN find /opt -maxdepth 3 -name bin -type d\
  -exec sh -c\
    'cd {} && ls .\
      | egrep -v ^.*\-[.[:digit:]]+$\
      | xargs -I % ln -s `pwd`/% /usr/local/bin/%' \;

## run ghci by default unless a command is specified
CMD ["ghci"]
