let globals = import "_globals.ncl"
in
globals
& {
  distro = {
    codename = "bookworm",
    abbr = "deb12",
    image = "debian:bookworm",
  },
  ghc = {
    version = "9.10.3",
    release_key = "88B57FCF7DB53B4DB3BFA4B1588764FBE22D19C4",
    assets = {
      aarch64 = {
        sha256sum = "052789dfe7f6fba6dc3822de0da272e8a5bd358c37adae17d8e82cff39bc1008",
        url = "https://downloads.haskell.org/~ghc/9.10.3/ghc-9.10.3-aarch64-deb11-linux.tar.xz",
      },
      x86_64 = { sha256sum = "1ac63f04eac0ad551d45cbde38f27e0e3f43ceefd98833fae1fa3f2dbd042367" },
    },
  },
  cabal_install = {
    assets = {
      aarch64 = { sha256sum = "f763fb2af2bc1ff174b7361a7d51109a585954f87a0e14f86d144f3bce28f7a9" },
      x86_64 = { sha256sum = "73a463306c771e18ca22c0a9469176ffab0138ec5925adb5364ef47174e1adc5" },
    },
  },
}
