let globals = import "_globals.ncl"
in
globals
& {
  distro = {
    codename = "bullseye",
    abbr = "deb11",
    image = "debian:bullseye-slim",
  },
  ghc = import "_ghc.ncl",
  cabal_install = import "_cabal-install.ncl",
}
