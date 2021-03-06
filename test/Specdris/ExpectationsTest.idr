module Specdris.ExpectationsTest

import Specdris.Data.SpecAction
import Specdris.Data.SpecResult
import Specdris.Data.SpecState

import Specdris.Core
import Specdris.Expectations

import Specdris.TestUtil

%access private
%default total

it : (description : String) -> SpecResult -> SpecAction
it descr spec = It descr (pure spec)

showTestCase : String -> String
showTestCase test = "expectation_" ++ test

noAround : IO SpecResult -> IO SpecResult
noAround spec = spec

testPending : IO ()
testPending
  = do state1 <- evaluate noAround $ it (showTestCase "pending") $ pending
       state2 <- evaluate noAround $ it (showTestCase "pendingWith") $ pendingWith "test"

       testAndPrint "pending" state1 (MkState 1 0 1) (==)
       testAndPrint "pendingWith" state2 (MkState 1 0 1) (==)

testEqual : IO ()
testEqual
  = do state1 <- evaluate noAround $ it (showTestCase "shouldBe") $ 1 `shouldBe` 1
       state2 <- evaluate noAround $ it (showTestCase "===") $ 1 === 2
       
       testAndPrint "equal" state1 (MkState 1 0 0) (==)
       testAndPrint "===" state2 (MkState 1 1 0) (==)

testUnequal : IO ()
testUnequal
  = do state1 <- evaluate noAround $ it (showTestCase "shouldNotBe") $ 1 `shouldNotBe` 2
       state2 <- evaluate noAround $ it (showTestCase "/==") $ 1 /== 1
  
       testAndPrint "unequal" state1 (MkState 1 0 0) (==)
       testAndPrint "/==" state2 (MkState 1 1 0) (==)

testSatisfy : IO ()
testSatisfy
  = do state1 <- evaluate noAround $ it (showTestCase "sat") $ 1 `shouldSatisfy` (> 0)
       state2 <- evaluate noAround $ it (showTestCase "!sat") $ 1 `shouldSatisfy` (> 1)
        
       testAndPrint "satisfy" state1 (MkState 1 0 0) (==)
       testAndPrint "satisfy" state2 (MkState 1 1 0) (==)

export
specSuite : IO ()
specSuite = do putStrLn "\n  expectations:"
               testPending
               testEqual
               testUnequal
               testSatisfy
