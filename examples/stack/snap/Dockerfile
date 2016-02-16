FROM haskell:7.10.3

WORKDIR /opt/server

ADD stack.yaml /opt/server/stack.yaml

# Add just the .cabal file to capture dependencies
ADD ./snap-example.cabal /opt/server/snap-example.cabal

# Docker will cache this command as a layer, freeing us up to
# modify source code without re-installing dependencies
# (unless the .cabal file changes!)
RUN stack build --only-dependencies

# Add and Install Application Code
COPY . /opt/server
RUN stack build

CMD ["stack", "exec", "snap-example"]
