// Assertion statements for debugging support .

                        // Written by  : Luke Lee
                        // Version     : 1.6
                        // Last Update : 03/18/'96

 //  05/05/'95..05/08/'95   Finish. v1.0 
 //  v1.5 01/16/'96  Apply ENDOF$FLOAD and Resetter mechanism.
 //  v1.6 03/18/'96  Modify bug which I forgot to POP-RESETTER in 
 //		     'EndEvalNoAssert' and 'EndAssertion'

COMMENT:
    The assertion statements should be used only for 'reading and testing'
    data but not to influence the target code while loaded with 'NODEBUG ON'.

    Assertion should be short and clear, so NO NESTING assertion is allowed.

    Syntax :

	ASSERT{ 
	   Index  UpperLimit  LowerLimit  BETWEEN // logical expression inside
	}?ASSERT" Index out of arrary boundary."

;COMMENT

ONLY FORTH ALSO DEFINITIONS

VARIABLE NODEBUG	NODEBUG ON

: DEBUGGING?	(( -- T/F ))	NODEBUG @ NOT ; 0 1 #PARMS

DEFER }?ASSERT"	IMMEDIATE COMPILEONLY

HIDDEN ALSO DEFINITIONS

2VARIABLE AssertionResetter

: EndEvalNoAssert	(( -- ))
	ASCII " WORD DROP   // ignore assertion message string
	COMPILER  'EVAL  !
	AssertionResetter POP-RESETTER
	; 0 0 #PARMS

: EvalNoAssert	(( A -- ))      // drop words till [ }?ASSERT" ] is reached.
	>R
        R@ $" //" $= IF
	   \ //
	ELSE R@ $" ((" $= IF
	   \ ((
	ELSE R@ ['] }?ASSERT" >NAME $= IF
	   EndEvalNoAssert
	ENDIF ENDIF ENDIF
	RDROP ; 1 0 #PARMS

: Invalid-}?ASSERT"	(( -- ))
	// while EvalNoAssert , it will process }?ASSERT" itself, in such
	// situations, executing }?ASSERT" is an error.
	CR ." * Invalid place of }?ASSERT" 
	ASCII " EMIT SPACE ASCII . EMIT CR ABORT ; 0 0 #PARMS

' Invalid-}?ASSERT" IS }?ASSERT"

: SkipAssertion	   (( -- ))
	['] EvalNoAssert  'EVAL !
	['] Invalid-}?ASSERT" IS }?ASSERT" // }?ASSERT" should not be executed
	; 0 0 #PARMS

: EndAssertion  (( -- ))
	COMPILE NOT  \ ABORT"	// RUNTIME : assertion wrong, abort 
	['] Invalid-}?ASSERT" IS }?ASSERT" // un-matched ASSERT{ ... }?ASSERT"
	AssertionResetter POP-RESETTER
	; 0 0 #PARMS

: ParseAssertion   (( -- ))
	['] EndAssertion  IS	}?ASSERT"	; 0 0 #PARMS

: ResetAsserter   (( -- ))  // can't execute [ ASSERT{ ] without [ }?ASSERT" ]
	['] }?ASSERT" >BODY @ ['] EndAssertion = IF // NODEBUG is OFF
	   COMPILER 'EVAL !
	ENDIF
	['] Invalid-}?ASSERT" IS }?ASSERT"
	AssertionResetter POP-RESETTER ; 0 0 #PARMS
					    
: RunAwayAssertion?	(( -- ))
	DEFERS ENDOF$FLOAD
	['] }?ASSERT" >BODY @  ['] EndAssertion =	// NODEBUG OFF
	'EVAL @ ['] EvalNoAssert =  OR			// NODEBUG ON
	IF
	   ResetAsserter
	   CR ." * Error : Run away assertion, ASSERT{ without }?ASSERT" 
	   ASCII " EMIT ASCII . EMIT CR  ABORT
	ENDIF ; 0 0 #PARMS

' RunAwayAssertion? IS ENDOF$FLOAD

FORTH DEFINITIONS

: ASSERT{	(( -- ))
	['] ResetAsserter AssertionResetter PUSH-RESETTER
	DEBUGGING? NOT IF
	   SkipAssertion
	ELSE  // Debugging
	   ParseAssertion
	ENDIF  ; 0 0 #PARMS IMMEDIATE COMPILEONLY

ONLY FORTH ALSO DEFINITIONS

