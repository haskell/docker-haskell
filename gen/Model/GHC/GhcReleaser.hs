module Model.GHC.GHCReleaser where

data GhcReleaser = GhcReleaser {
  _name :: String,
  _pgpKey :: PGPKey
}
