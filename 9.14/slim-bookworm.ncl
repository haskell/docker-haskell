let globals = import "_globals.ncl"
in
globals
& {
  distro = {
    codename = "bookworm",
    abbr = "deb12",
    image = "debian:bookworm-slim",
    digest = "sha256:0104b334637a5f19aa9c983a91b54c89887c0984081f2068983107a6f6c21eeb",
  },
  ghc = {
    version = "9.14.1",
    release_key = "88B57FCF7DB53B4DB3BFA4B1588764FBE22D19C4",
    assets = {
      aarch64 = { sha256sum = "6aa27a377451851c851eefdd869e8f5a9217b02ce66c6ca9b418b72efee28427" },
      x86_64 = { sha256sum = "60f7ab75f28df892729fbaff3a54f58ee3ad7e731929f1b2f3eb0208f73de841" },
    },
  },
  cabal_install = {
    assets = {
      aarch64 = { sha256sum = "41d8fc43de1c652c00d85799d0273f8b6600bc71603126bc651ca4e3917a1b84" },
      x86_64 = { sha256sum = "209987f6abdd1119f6b2674a0d1012857a783464774708cb4f3fd9e156ea7bea" },
    },
  },
}
