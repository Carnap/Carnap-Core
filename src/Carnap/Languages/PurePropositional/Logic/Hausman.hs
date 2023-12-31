{-#LANGUAGE FlexibleContexts, FlexibleInstances, MultiParamTypeClasses #-}
module Carnap.Languages.PurePropositional.Logic.Hausman
    ( parseHausmanSL, HausmanSL,  hausmanSLCalc) where

import Data.Map as M (lookup, Map)
import Text.Parsec
import Carnap.Core.Data.Types (Form)
import Carnap.Languages.PurePropositional.Syntax
import Carnap.Languages.PurePropositional.Parser
import Carnap.Calculi.Util
import Carnap.Calculi.NaturalDeduction.Syntax
import Carnap.Calculi.NaturalDeduction.Parser
import Carnap.Calculi.NaturalDeduction.Checker
import Carnap.Languages.ClassicalSequent.Syntax
import Carnap.Languages.ClassicalSequent.Parser
import Carnap.Languages.PurePropositional.Logic.Rules

{-| A system for propositional logic resembling the sentential logic system
from Hausman' Logic and Philosophy
-}

data HausmanSL = MP | Conj | MT | HS | DS1 | DS2 | Add | CD | Simp1 | Simp2
               | DN1 | DN2  | Contra1 | Contra2 | DeM1 | DeM2 | DeM3 | DeM4
               | Impl1 | Impl2 | Exp1 | Exp2 | Comm1 | Comm2 
               | Taut1 | Taut2 | Taut3 | Taut4 | Assoc1 | Assoc2 | Assoc3 | Assoc4
               | Equiv1 | Equiv2 | Equiv3 | Equiv4 | Dist1 | Dist2 | Dist3 | Dist4
               | CP1 | CP2 | IP1 | IP2
               | AP | Pr (Maybe [(ClassicalSequentOver PurePropLexicon (Sequent (Form Bool)))])
               deriving (Eq)

instance Show HausmanSL where
    show MP = "MP"
    show Conj = "Conj"
    show MT = "MT"
    show HS = "HS"
    show DS1 = "DS"
    show DS2 = "DS"
    show Add = "Add"
    show CD = "CD"
    show Simp1 = "Simp"
    show Simp2 = "Simp"
    show DN1 = "DN"
    show DN2 = "DN"
    show Contra1 = "Contra"
    show Contra2 = "Contra"
    show DeM1 = "DeM"
    show DeM2 = "DeM"
    show DeM3 = "DeM"
    show DeM4 = "DeM"
    show Impl1 = "Impl"
    show Impl2 = "Impl"
    show Exp1 = "Exp"
    show Exp2 = "Exp"
    show Comm1 = "Comm"
    show Comm2 = "Comm"
    show Taut1 = "Taut"
    show Taut2 = "Taut"
    show Taut3 = "Taut"
    show Taut4 = "Taut"
    show Assoc1 = "Assoc"
    show Assoc2 = "Assoc"
    show Assoc3 = "Assoc"
    show Assoc4 = "Assoc"
    show Equiv1 = "Equiv"
    show Equiv2 = "Equiv"
    show Equiv3 = "Equiv"
    show Equiv4 = "Equiv"
    show Dist1 = "Dist"
    show Dist2 = "Dist"
    show Dist3 = "Dist"
    show Dist4 = "Dist"
    show CP1 = "CP"
    show CP2 = "CP"
    show IP1 = "IP"
    show IP2 = "IP"
    show AP    = "AP"
    show (Pr _)  = "p"

instance Inference HausmanSL PurePropLexicon (Form Bool) where
    ruleOf MP   = modusPonens
    ruleOf Conj = adjunction
    ruleOf MT   = modusTollens
    ruleOf HS   = hypotheticalSyllogism
    ruleOf DS1  = modusTollendoPonensVariations !! 0 
    ruleOf DS2  = modusTollendoPonensVariations !! 1
    ruleOf Add  = additionVariations !! 1 --book only uses this form
    ruleOf CD   = constructiveDilemma
    ruleOf Simp1 = simplificationVariations !! 0
    ruleOf Simp2 = simplificationVariations !! 1
    ruleOf DN1 = doubleNegation !! 0
    ruleOf DN2 = doubleNegation !! 1
    ruleOf Contra1 = contraposition !! 0
    ruleOf Contra2 = contraposition !! 1
    ruleOf DeM1 = deMorgansLaws !! 0
    ruleOf DeM2 = deMorgansLaws !! 1
    ruleOf DeM3 = deMorgansLaws !! 2
    ruleOf DeM4 = deMorgansLaws !! 3
    ruleOf Impl1 = materialConditional !! 0
    ruleOf Impl2 = materialConditional !! 1
    ruleOf Exp1 = exportation !! 0
    ruleOf Exp2 = exportation !! 1
    ruleOf Comm1 = andCommutativity !! 0
    ruleOf Comm2 = orCommutativity !! 0
    ruleOf Taut1 = andIdempotence !! 0
    ruleOf Taut2 = andIdempotence !! 1
    ruleOf Taut3 = orIdempotence !! 0
    ruleOf Taut4 = orIdempotence !! 1
    ruleOf Assoc1 = andAssociativity !! 0
    ruleOf Assoc2 = andAssociativity !! 1
    ruleOf Assoc3 = orAssociativity !! 0
    ruleOf Assoc4 = orAssociativity !! 1
    ruleOf Equiv1 = biconditionalExchange !! 0
    ruleOf Equiv2 = biconditionalExchange !! 0
    ruleOf Equiv3 = biconditionalCases !! 0
    ruleOf Equiv4 = biconditionalCases !! 1
    ruleOf Dist1 = distribution !! 0
    ruleOf Dist2 = distribution !! 1
    ruleOf Dist3 = distribution !! 4
    ruleOf Dist4 = distribution !! 5
    ruleOf CP1 = conditionalProofVariations !! 0
    ruleOf CP2 = conditionalProofVariations !! 1
    ruleOf IP1 = explictNonConstructiveConjunctionReductioVariations !! 0
    ruleOf IP2 = explictNonConstructiveConjunctionReductioVariations !! 1
    ruleOf AP         = axiom
    ruleOf (Pr _)     = axiom

    indirectInference x
        | x `elem` [CP1, CP2] = Just PolyProof
        | x `elem` [IP1, IP2] = Just assumptiveProof
        | otherwise = Nothing

    isAssumption AP = True
    isAssumption _ = False

    restriction (Pr prems) = Just (premConstraint prems)
    restriction _ = Nothing

parseHausmanSL :: RuntimeDeductionConfig PurePropLexicon (Form Bool) -> Parsec String u [HausmanSL]
parseHausmanSL rtc = do r <- choice (map (try . string) [ "MP", "Conj", "MT", "HS", "DS", "Add", "CD", "Simp"
                                                        , "DN", "Contra", "DeM", "Impl", "Exp", "Comm", "Taut", "Assoc"
                                                        , "Equiv", "Dist", "CP", "IP", "AP","p"
                                                        ])
                        case r of
                           "MP" -> return [MP]
                           "Conj" -> return [Conj]
                           "MT" -> return [MT]
                           "HS" -> return [HS]
                           "DS" -> return [DS1, DS2]
                           "Add" -> return [Add] 
                           "CD" -> return [CD]
                           "Simp" -> return [Simp1, Simp2]
                           "DN" -> return [DN1, DN2]
                           "Contra" -> return [Contra1, Contra2]
                           "DeM" -> return [DeM1, DeM2, DeM3, DeM4]
                           "Impl" -> return [Impl1, Impl2]
                           "Exp" -> return [Exp1, Exp2]
                           "Comm" -> return [Comm1, Comm2]
                           "Taut" -> return [Taut1, Taut2, Taut3, Taut4]
                           "Assoc" -> return [Assoc1, Assoc2, Assoc3, Assoc4]
                           "Equiv" -> return [Equiv1, Equiv2, Equiv3, Equiv4]
                           "Dist" -> return [Dist1, Dist2, Dist3, Dist4]
                           "CP" -> return [CP1,CP2]
                           "IP" -> return [IP1, IP2]
                           "AP" -> return [AP]
                           "p" -> return [Pr (problemPremises rtc)]

parseHausmanSLProof :: RuntimeDeductionConfig PurePropLexicon (Form Bool) -> String -> [DeductionLine HausmanSL PurePropLexicon (Form Bool)]
parseHausmanSLProof rtc = toCommentedDeductionFitch (parseHausmanSL rtc) (purePropFormulaParser hausmanOpts)

hausmanSLNotation :: String -> String 
hausmanSLNotation x = case runParser altParser 0 "" x of
                        Left e -> show e
                        Right s -> s
    where altParser = do s <- handleCon <|> try handleQuant <|> try handleAtom <|> handleLParen <|> handleRParen <|> fallback
                         rest <- (eof >> return "") <|> altParser
                         return $ s ++ rest
          handleCon = (char '∧' >> return "∙") <|> (char '¬' >> return "~") <|> (char '→' >> return "⊃") <|> (char '↔' >> return "≡")
          handleQuant = do q <- oneOf "∀∃"
                           v <- anyChar
                           return $ "(" ++ (if q == '∃' then "∃" else "") ++ [v] ++ ")"
          handleLParen = do char '('
                            n <- getState 
                            putState (n + 1)
                            return $ ["(","{","["] !! (n `mod` 3) 
          handleRParen = do char ')'
                            n <- getState 
                            putState (n - 1)
                            return $ [")","}","]"] !! ((n - 1) `mod` 3)
          handleAtom = do c <- oneOf "ABCDEFGHIJKLMNOPQRSTUVWXYZ" <* char '('
                          args <- oneOf "abcdefghijklmnopqrstuvwxyz" `sepBy` char ','
                          char ')'
                          return $ c:args
          fallback = do c <- anyChar 
                        return [c]

hausmanSLCalc = mkNDCalc 
    { ndRenderer = NoRender
    , ndParseProof = parseHausmanSLProof
    , ndProcessLine = hoProcessLineFitch
    , ndProcessLineMemo = Just hoProcessLineFitchMemo
    , ndParseSeq = parseSeqOver (purePropFormulaParser hausmanOpts)
    , ndParseForm = purePropFormulaParser hausmanOpts
    , ndNotation = hausmanSLNotation
    }
