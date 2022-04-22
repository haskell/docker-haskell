module Model.GHCInfo where

data GhcInfo = GhcInfo {
    _releasers :: [GHCReleaser],
    _ghcReleases :: [GHCRelease]
}
