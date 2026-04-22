let globals = import "_globals.ncl"
in
globals
& {
  distro = {
    codename = "bullseye",
    abbr = "deb11",
    image = "debian:bullseye-slim",
  },
  ghc = {
    version = "9.14.1",
    release_key = "88B57FCF7DB53B4DB3BFA4B1588764FBE22D19C4",
    assets = {
      aarch64 = {
        sha256sum = "526c352cceddbf6c580e17ade7e782e3b21b4182d328b2d454c9f13ca7c08992",
        url = "https://downloads.haskell.org/~ghc/9.14.1/ghc-9.14.1-aarch64-deb10-linux.tar.xz",
      },
      x86_64 = { sha256sum = "98f42ba5b44e50d680434b9d3c7ad51b257678899cf7f806a0c85cf63b6d1095" },
    },
  },
  cabal_install = {
    assets = {
      aarch64 = { sha256sum = "6c5b74781d64266fa060099502d33b1f8297f269a5f71eda871b7db7fb3bf8e4" },
      x86_64 = { sha256sum = "0af41eac80718dc4396340cffa2dbf525e777ec3e877f689718a9ef5aedcb6ab" },
    },
  },
}
