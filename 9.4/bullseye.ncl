let globals = import "_globals.ncl"
in
globals
& {
  distro = {
    codename = "bullseye",
    abbr = "deb11",
    image = "debian:bullseye",
    digest = "sha256:e7100042ddfd3c1fb9d4a5bf15acbdb1058d7bb3340142916d3413a5c001fc89",
  },
  ghc = import "_ghc.ncl",
  cabal_install = import "_cabal-install.ncl",
}
