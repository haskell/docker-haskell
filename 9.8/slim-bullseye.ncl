let globals = import "_globals.ncl"
in
globals
& {
  distro = {
    codename = "bullseye",
    abbr = "deb11",
    image = "debian:bullseye-slim",
    digest = "sha256:cd1bc32f233a49f1b82149c9edb8ef34fb1e6c45f37211445c51a97603468604",
  },
  ghc = import "_ghc.ncl",
  cabal_install = import "_cabal-install.ncl",
}
