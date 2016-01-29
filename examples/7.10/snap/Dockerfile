FROM haskell:7.10

WORKDIR /opt/server

RUN cabal update

# Add just the .cabal file to capture dependencies
COPY ./snap-example.cabal /opt/server/snap-example.cabal

# Docker will cache this command as a layer, freeing us up to
# modify source code without re-installing dependencies
# (unless the .cabal file changes!)
RUN cabal install --only-dependencies -j4

# Add and Install Application Code
COPY . /opt/server
RUN cabal install

CMD ["snap-example"]
