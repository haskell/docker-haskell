module Model.GhcInfo where

data GhcInfo = GhcInfo {
    _ghcReleasers :: [GhcReleaser],
    _ghcReleases :: [GhcRelease]
}
