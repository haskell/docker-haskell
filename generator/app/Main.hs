{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

-- | An example Ginger CLI application.
--
-- Takes two optional arguments; the first one is a template file, the second
-- one a file containing some context data in JSON format.
module Main where

import qualified Data.Aeson as JSON
import qualified Data.ByteString as BS
import qualified Data.ByteString.UTF8 as UTF8
import Data.HashMap.Strict (HashMap)
import qualified Data.HashMap.Strict as HashMap
import Data.Text (Text)
import qualified Data.Text as Text
import qualified Data.Yaml as YAML hiding (decodeFile)
import qualified Data.Yaml.Include as YAML (decodeFile)
import Options (DataSource (..), Options (..), TemplateSource (..), parseOptions)
import System.Environment (getArgs)
import System.Exit
import System.IO
import System.IO.Error
import Text.Ginger

main :: IO ()
main = do
  args <- getArgs
  options <- parseOptions args
  case options of
    RunOptions tpl dat ->
      run tpl dat

loadData :: DataSource -> IO (Maybe (HashMap Text JSON.Value))
loadData (DataFromFile fn) = YAML.decodeFile fn
loadData DataFromStdin = decodeStdin
loadData (DataLiteral str) = decodeString str

loadTemplate :: TemplateSource -> IO (Template SourcePos)
loadTemplate tplSrc = do
  let resolve = loadFileMay
  (tpl, src) <- case tplSrc of
    TemplateFromFile fn -> (,) <$> parseGingerFile resolve fn <*> return Nothing
    TemplateFromStdin -> getContents >>= \s -> (,) <$> parseGinger resolve Nothing s <*> return (Just s)

  case tpl of
    Left err -> do
      tplSource <-
        case src of
          Just s ->
            return (Just s)
          Nothing -> do
            let s = sourceName <$> peSourcePosition err
            case s of
              Nothing -> return Nothing
              Just sn -> Just <$> loadFile sn
      printParserError tplSource err
      exitFailure
    Right t -> do
      return t

run :: TemplateSource -> DataSource -> IO ()
run tplSrc dataSrc = do
  scope <- loadData dataSrc
  let contextLookup :: Text -> Run p IO Text (GVal (Run p IO Text))
      contextLookup key = return $ toGVal (scope >>= HashMap.lookup key)
  let context =
        makeContextTextExM
          contextLookup
          (putStr . Text.unpack)
          (hPutStrLn stderr . show)

  tpl <- loadTemplate tplSrc
  runGingerT context tpl >>= either (hPutStrLn stderr . show) showOutput
  where
    showOutput value
      | isNull value = return ()
      | otherwise = putStrLn . show $ value

printParserError :: Maybe String -> ParserError -> IO ()
printParserError srcMay = putStrLn . formatParserError srcMay

displayParserError :: String -> ParserError -> IO ()
displayParserError src pe = do
  case peSourcePosition pe of
    Just pos -> do
      let ln = Prelude.take 1 . Prelude.drop (sourceLine pos - 1) . Prelude.lines $ src
      case ln of
        [] -> return ()
        x : _ -> do
          putStrLn x
          putStrLn $ Prelude.replicate (sourceColumn pos - 1) ' ' ++ "^"
    _ -> return ()

loadFile :: FilePath -> IO String
loadFile fn = openFile fn ReadMode >>= hGetContents

loadFileMay :: FilePath -> IO (Maybe String)
loadFileMay fn =
  tryIOError (loadFile fn) >>= \case
    Right contents -> return (Just contents)
    Left err -> do
      print err
      return Nothing

decodeString :: (JSON.FromJSON v) => String -> IO (Maybe v)
decodeString = return . YAML.decode . UTF8.fromString

decodeStdin :: (JSON.FromJSON v) => IO (Maybe v)
decodeStdin = YAML.decode <$> BS.getContents

gAsStr :: GVal m -> String
gAsStr = Text.unpack . asText

strToGVal :: String -> GVal m
strToGVal = toGVal . Text.pack
