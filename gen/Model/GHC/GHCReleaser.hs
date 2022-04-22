module Model.GHC.GHCReleaser where

data GHCReleaser = GHCReleaser {
  _name :: String,
  _pgpKey :: PGPKey
}
