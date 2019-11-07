{-# LANGUAGE DeriveGeneric #-}
-- | Script to generate dockerfiles. Obviously using Haskell.
--
-- TBW usage
module Main (main) where

import Control.Monad (forM_)
import Data.Char (toLower)
import Data.List (intercalate)
import GHC.Generics (Generic)
import System.FilePath ((</>), takeDirectory)
import System.Directory (createDirectoryIfMissing)

import Zinza

params :: [(FilePath, Params)]
params =
    [ mk dist ver slim
    | dist <- [Stretch ..]
    , slim <- [True, False]
    , ver  <- [ Version [8,8,1]
              , Version [8,6,5]
              , Version [8,4,4]
              ]
    ]
  where
    mk :: Distribution -> Version -> Bool -> (FilePath, Params)
    mk dist gv slim = (,) fp Params
        { pDistribution = dist
        , pGhcVersion   = gv
        , pSlim         = slim
        -- See stack-shasum.sh
        , pStackVersion = Version [2,1,3]
        , pStackSha256  = "c724b207831fe5f06b087bac7e01d33e61a1c9cad6be0468f9c117d383ec5673"
        }
      where
        dir = dispVersion (majorVersion gv) </> dispDistribution dist

        fp | slim      = dir </> "slim" </> "Dockerfile"
           | otherwise = dir </> "Dockerfile"

main :: IO ()
main = do
    template <- parseAndCompileTemplateIO "Dockerfile.template"
    forM_ params $ \(fp, p) -> do
        contents <- template p
        createDirectoryIfMissing True (takeDirectory fp)
        writeFile fp contents

-------------------------------------------------------------------------------
-- Data types
-------------------------------------------------------------------------------

newtype Version = Version [Int]
  deriving (Show)

dispVersion :: Version -> String
dispVersion (Version vs) = intercalate "." (map show vs)

majorVersion :: Version -> Version
majorVersion v@(Version [])      = v
majorVersion v@(Version [_])     = v
majorVersion v@(Version (x:y:_)) = Version [x,y]

instance Zinza Version where
    toType _ = TyString Nothing
    toValue  = VString . dispVersion

data Distribution = Stretch | Buster
  deriving (Show, Enum, Bounded)

dispDistribution :: Distribution -> String
dispDistribution = map toLower . show

instance Zinza Distribution where
    toType _ = TyString Nothing
    toValue  = VString . dispDistribution

data Params = Params
    { pDistribution :: Distribution
    , pGhcVersion   :: Version
    , pSlim         :: Bool
    , pStackVersion :: Version
    , pStackSha256  :: String
    }
  deriving (Show, Generic)

instance Zinza Params where
    toType  = genericToTypeSFP
    toValue = genericToValueSFP
