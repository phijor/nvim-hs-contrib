{-# LANGUAGE LambdaCase #-}
{- |
Module      :  Neovim.User.Input
Description :  Utility functions to retrieve user input
Copyright   :  (c) Sebastian Witte
License     :  Apache-2.0

Maintainer  :  woozletoff@gmail.com
Stability   :  experimental
Portability :  GHC

-}
module Neovim.User.Input
    where

import Neovim
import Neovim.User.Choice

import System.Directory


-- | Helper function that calls the @input()@ function of neovim.
input :: String -- ^ Message to display
      -> Maybe String -- ^ Input fiiled in
      -> Maybe String -- ^ Completion mode
      -> Neovim env (Either NeovimException Object)
input message mPrefilled mCompletion = vim_call_function "input" $
    (message <> " ")
    +: maybe "" id mPrefilled
    +: maybe [] (+: []) mCompletion


-- | Prompt the user to specify a directory.
--
-- If the directory does not exist, ask the usere whether it should be created.
askForDirectory :: String -- ^ Message to put in front
                -> Maybe FilePath -- ^ Prefilled text
                -> Neovim env FilePath
askForDirectory message mPrefilled = do
    fp <- errOnInvalidResult $ input message mPrefilled (Just "dir")

    efp <- errOnInvalidResult $
            vim_call_function "expand" $ (fp :: FilePath) +: []

    whenM (not <$> liftIO (doesDirectoryExist efp)) $
        whenM (yesOrNo (efp ++ " does not exist, create it?")) $
            liftIO $ createDirectoryIfMissing True efp

    return efp


askForString :: String -- ^ message to put in front
             -> Maybe String -- ^ Prefilled text
             -> Neovim env String
askForString message mPrefilled =
    errOnInvalidResult $ input message mPrefilled Nothing
