module Main where

import System.IO
import System.IO.Error
import qualified Data.Text as Text
import Text.Ginger

main :: IO ()
main = do
   _ <- runGingerT (makeContextM scopeLookup (putStr . Text.unpack . htmlSource)) tpl
   pure ()

loadFile :: FilePath -> IO String
loadFile fn = openFile fn ReadMode >>= hGetContents

loadFileMay :: FilePath -> IO (Maybe String)
loadFileMay fn =
    tryIOError (loadFile fn) >>=
        \case
            Right contents ->
                return (Just contents)
            Left err -> do
                print err -- remove this line if you want to fail silently
                return Nothing

{
    ghc: {
        releasers: [{
            name: ben.gamari,
            pgpKey: asdfasdf3423423432
        }
        releases: [{
            version: 8.10.7,
            sha256: asdfasdfasdf124124,
            releasedBy: ben.gamari
        },
        {
            version: 9.0.2,
            sha256: asdfasdfasdf124124,
            releasedBy: ben.gamari
        }
        ]
    },
    stack: {
        version: 2.7.5,
        pgpKey: asdfsadfds234234,
        releases: [{
            osType: linux,
            arch: amd64,
            sha256: adsfasdf12123,

        },
        {
            osType: windows,
            arch: amd64,
            sha256: adsfasdf12123
        }
        ]
    },
    cabal: {
        version: 3.6.2.0,
        pgpKey: asdfsadfds234234,
        releases: [{
            os: debian,
            osVersion: buster,
            arch: amd64,
            sha256: adsfasdf12123,
        },
        ]
    }
    operatingSystemsVariants: [
        {
            name: debian,
            variants: [standard, slim],
            versions: [buster]

        },
        {
            name: alpine,
            versions: [3.14, 3.15]
        },
        {
            name: windows,
            variants: [windowsservercore, nanoserver]
            versions: [1809, ltsc2022]
        }
    ]
}
