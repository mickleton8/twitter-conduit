{-# LANGUAGE OverloadedStrings #-}
module Main where

import qualified Data.Conduit as C
import qualified Data.Conduit.List as CL
import qualified Data.Map as M
import Control.Monad
import Control.Monad.Trans
import System.Environment
import System.IO

import Web.Twitter
import Common

main :: IO ()
main = withCF $ do
  [screenName] <- liftIO getArgs
  let sn = QScreenName screenName
  folids <- C.runResourceT $ do
    followersIds sn C.$$ CL.consume
  friids <- C.runResourceT $ do
    friendsIds sn C.$$ CL.consume

  let folmap = M.fromList $ map (flip (,) True) folids
      os = filter (\uid -> M.notMember uid folmap) friids
      bo = filter (\usr -> M.member usr folmap) friids

  liftIO $ putStrLn "one sided:"
  liftIO $ print os

  liftIO $ putStrLn "both following:"
  liftIO $ print bo
