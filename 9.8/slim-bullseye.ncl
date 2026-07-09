let globals = import "_globals.ncl"
in
globals
& {
  distro = {
    codename = "bullseye",
    abbr = "deb11",
    image = "debian:bullseye-slim",
    digest = "sha256:f18adf4e1d04b1d8ba48025b8e35003f4c748ddd3dd8e875fe4e7d9a9c0dec84",
  },
  ghc = import "_ghc.ncl",
  cabal_install = import "_cabal-install.ncl",
}
