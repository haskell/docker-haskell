FROM haskell:7.8-onbuild

RUN cabal build
RUN mkdir log
# Default Command for Container
CMD ["dist/build/snap-example/snap-example"]