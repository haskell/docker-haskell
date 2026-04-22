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
    version = "9.12.4",
    release_key = "88B57FCF7DB53B4DB3BFA4B1588764FBE22D19C4",
    assets = {
      aarch64 = {
        sha256sum = "e0e2b536e56f08ee9b6eb9c2c4fe43f8d289257afb786ea8f5538c5c7b252f2f",
        url = "https://downloads.haskell.org/~ghc/9.12.4/ghc-9.12.4-aarch64-deb10-linux.tar.xz",
      },
      x86_64 = { sha256sum = "3699fc558231c81836f632f09e36e01381141d7df42ab26a0db6b1b7d0c74f30" },
    },
  },
  cabal_install = {
    assets = {
      aarch64 = { sha256sum = "5e8c47a055d5b744741039a7061ee43ec7d080d1251784e7a4cd836403e42523" },
      x86_64 = { sha256sum = "41b85bb25fa654e4b79169014b9142fe696ff35e002e043caa0e52d65204ba8a" },
    },
  },
}
