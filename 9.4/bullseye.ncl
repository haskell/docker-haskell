let globals = import "_globals.ncl"
in
globals
& {
  distro = {
    codename = "bullseye",
    abbr = "deb11",
    image = "debian:bullseye",
    digest = "sha256:aeec37aebc55ca5cc6fcfb8d5f6ae2fd43d5017ad849e6e2fdb5325d61e144db",
  },
  ghc = import "_ghc.ncl",
  cabal_install = import "_cabal-install.ncl",
}
