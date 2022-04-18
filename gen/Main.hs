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
