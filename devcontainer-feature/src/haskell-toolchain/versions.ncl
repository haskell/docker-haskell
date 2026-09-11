let bookworm = import "../../../9.14/bookworm.ncl" in
let globals = bookworm in
{
  ghc_version = globals.ghc.version,
  cabal_version = globals.cabal_install.version,
  stack_version = globals.stack.version,
  hls_version = "2.14.0.0",
  ghcup_version = "0.2.6.2",
  linters = {
    ormolu = "0.8.2.0",
    fourmolu = "0.20.0.0",
  },
}