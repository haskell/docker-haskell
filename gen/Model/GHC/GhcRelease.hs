module Model.GHC.GhcReleaser where

data GhcRelease = GhcRelease {
  _version :: Version,
  _os :: OperatingSystem,
  _osVersion :: OperatingSystemVersion,
}
