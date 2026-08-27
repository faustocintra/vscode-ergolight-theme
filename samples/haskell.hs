{-# LANGUAGE DeriveGeneric #-}

module Main where

import Data.Map qualified as Map
import GHC.Generics (Generic)

data Status = Draft | Paid | Shipped
  deriving (Eq, Show, Generic)

newtype OrderId = OrderId Int
  deriving (Eq, Show)

class Renderable a where
  render :: a -> String

instance Renderable Status where
  render status =
    case status of
      Draft -> "draft"
      Paid -> "paid"
      Shipped -> "shipped"

main :: IO ()
main = do
  let orders = Map.fromList [(OrderId 1, Paid)]
  print (fmap render orders)

