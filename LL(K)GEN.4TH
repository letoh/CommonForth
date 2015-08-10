// LL(K) Grammar Compiler
			//  Copyright (C) Luke Lee, since 1995
			//  09/19..09/21/'95  Written by  : Luke Lee
			// 		      Version     : 2.5
			// 		      Last update : 09/26/'95

//
// This is a LL(k) Grammar Compiler, with 'k' lookahead symbols.
//
//   This compiler does not check the validity of your input grammar, 
// it might generate error messages, or might not. Like left-recursion 
// problem won't be detected by this grammar compiler, you have to write
// your grammar correctly.
//
//   The real k value is depend on your buffering method. The default
// compiling buffer is TIB, system default is 4096(+256 safety) bytes
// while FLOADing, however, in interpreting mode you can have only one
// line for inputing, that is normally 80 characters. Since the system
// default buffer is at the same size but symbols always have different
// length, so the real 'k' is not a fix value but changes all the time.
//

// ////////////////////////////////////////////	//
//   Grammar Compiler for Scanner and Parser	//
// ////////////////////////////////////////////	//

VOCABULARY LL(k)Gen
LL(k)Gen ALSO DEFINITIONS

64 CONSTANT MaxTokenLength

FORTH DEFINITIONS

: STR"	(( -- A ))	// define string literal
	HERE  $,"  ;

: $COPY	 (( c$ a -- ))	
     // Copy counted string from c$ to a, assume no overlapping.
     // if c$ is zero-lengthed, a will be overwrited with one zero-byte.
	OVER C@ 1+ CMOVE ; 2 0 #PARMS

// Three interface for scanner : ThisToken  GetToken  ^IN

// current token buffer, a counted string :
CREATE ThisToken MaxTokenLength CELL+ ALLOT 

LL(k)Gen DEFINITIONS

: (GetToken)    (( -- A$ ))
	TOKEN DUP ThisToken $COPY ; 0 1 #PARMS

FORTH DEFINITIONS

DEFER ^IN	(( -- A ) where A is a pointer/variable )
DEFER GetToken	(( -- cA$ ) where cA$ is a counted string )
  // There is no need for unget routine, since I assume inputs are handled
  // by ^IN .

' (GetToken)  IS  GetToken	// default GetToken handler
' >IN	      IS  ^IN		// default ^IN handler

0 CONSTANT StringType	// default semantic type

LL(k)Gen DEFINITIONS

STRUCT: SemanticFrame
    STRUCT: SemanticRecord
  	WORD: |Content
	WORD: |Type	// the type of |Content field
    ;STRUCT
    WORD: |lastFrame^	// semantic frame of previous production
    WORD: |last^IN 	// original ^IN of previous production
;STRUCT

//
// Semantic stack :  
//
//   |Frame |Record |Record | ... |Frame |Record |Record | ... 
//
// Each production rule builds an SemanticFrame on entry, and left a
// SemanticRecord on leaving.
//

CREATE SemanticStack	64 K ALLOT	// a large stack for semantic type
HERE CONSTANT EndSemanticStack		// bottom line
SemanticStack VALUE Frame^	// Semantic stack frame pointer
SemanticStack VALUE Stack^	// Semantic stack pointer

NODEBUG @ #IF

: SemanticStackCheck ; IMMEDIATE

#ELSE

: SemanticStackCheck
	Frame^ SemanticStack <  ORELSE
	Stack^ SemanticStack <  ELSE-OR
	ABORT" * LL(k)Gen : Semantic stack underflow "
	Frame^ EndSemanticStack >=  ORELSE
	Stack^ EndSemanticStack >=  ELSE-OR 
	ABORT" * LL(k)Gen : Semantic stack overflow "   ; 0 0 #PARMS

#ENDIF

: <clear_frame>  (( -- ))
	Frame^ SIZEOF SemanticFrame LITERAL +  to  Stack^
	Frame^ |last^IN @  ^IN  !
	NULL$   Frame^ |Content   !
	StringType  Frame^ |Type  !	; 0 0 #PARMS

: <enter_production>	(( -- )) // allocate new semantic stack frame
	Stack^  DUP SIZEOF SemanticFrame LITERAL +  to  Stack^  // alloc
	Frame^  OVER |lastFrame^  !
	to  Frame^
	^IN @   Frame^ |last^IN   !
	NULL$   Frame^ |Content   !
	StringType  Frame^ |Type  !
	SemanticStackCheck	; 0 0 #PARMS

: restoreFrame^	(( -- ))
	Frame^ |lastFrame^   DUP @  to  Frame^
	to Stack^   ; 0 0 #PARMS

// Note that zero-string should occupy a zero valued byte .

: <?leave_production>   (( T/F -- T/F )) 
     // dealloc semantic stack and return the result of current production
	DUP IF	// pattern matched, left the result.
	    restoreFrame^
	ELSE    // pattern not match, left a null result.
	    Frame^ |last^IN @   ^IN    !	// for symbol lookahead
	    NULL$  Frame^ |Content     !	// return NULL
	    restoreFrame^
	ENDIF
	SemanticStackCheck  ; 1 1 #PARMS

: ResetSemanticStack	(( -- ))  // reset semantic stack
	SemanticStack DUP to Frame^ to Stack^  ; 0 0 #PARMS

FORTH DEFINITIONS

: push_token	(( a -- ))
     // the token string to be pushed cannot be temporary, it must be
     // allocated first or statically allocated .
	Stack^ |Content !
	StringType Stack^ |Type  !
	Stack^ SIZEOF SemanticRecord LITERAL + to Stack^
	SemanticStackCheck	; 1 0 #PARMS

' Frame^ ALIAS $$$

: $$	(( n -- ^semantic_record ))
      // n : n>0 -- counted from first record forward
      //     n<0 -- counted from current record backward
      //     n=0 -- result semantic record of current production 
	DUP 0> IF
	    SIZEOF SemanticRecord LITERAL *	// positive value
 	    Frame^ + [ SIZEOF SemanticFrame OFFSET |lastFrame^ - ] LITERAL +
	    ASSERT{ DUP Stack^ <
		  }?ASSERT" * $$ : Semantic not defined"
	ELSE DUP 0< IF
	    SIZEOF SemanticRecord LITERAL *	// negative value
	    Stack^ +
	    ASSERT{ DUP Frame^ SIZEOF SemanticFrame LITERAL + >= 
		  }?ASSERT" * $$ : Cannot access previous production semantic"
	ELSE
	    DROP Frame^	// 0 $$ == $$$
	ENDIF ENDIF ; 1 1 #PARMS

: $$1  1 $$ ;	: $$2  2 $$ ;	: $$3  3 $$ ;	: $$4  4 $$ ;	: $$5  5 $$ ;
: -$$1 -1 $$ ;	: -$$2 -2 $$ ;	: -$$3 -3 $$ ;	: -$$4 -4 $$ ;	: -$$5 -5 $$ ;

: $$6  6 $$ ; INVISIBLE	: $$7  7 $$ ; INVISIBLE	: $$8  8 $$ ; INVISIBLE
: $$9  9 $$ ; INVISIBLE : $$A $A $$ ; INVISIBLE	: $$B $B $$ ; INVISIBLE
: $$C $C $$ ; INVISIBLE	: $$D $D $$ ; INVISIBLE	: $$E $E $$ ; INVISIBLE
: $$F $F $$ ; INVISIBLE

LL(k)Gen DEFINITIONS

: TokenMatch?	(( A$ -- T/F ))
      // peek at current token, if it doesn't match, don't fetch it out.
	>R ^IN @  GetToken  R@  $= DUP IF  
	   NIP R@  
	ELSE  
	   SWAP ^IN ! NULL$
	ENDIF push_token RDROP ; 1 1 #PARMS INVISIBLE

: NotDefinedProduction (( -- ))
	CR ." * This production have not been defined yet." ABORT ;

FORTH DEFINITIONS

// ------------------------ //
//  LL(k) Grammar Compiler  //
// ------------------------ //

: TERMINAL:	(( STRtok -- ))	// Terminals
	CREATE	IMMEDIATE
		\ ]  \ LITERAL  COMPILE TokenMatch?

	DOES>	\ LITERAL  COMPILE EXECUTE	// directly jump
	     	\ ANDTHEN ; 1 0 #PARMS

: ;TERMINAL	(( -- ))	// End Token Definition
	COMPILE exit \ [  ; IMMEDIATE

' TERMINAL:  ALIAS  T:
' ;TERMINAL  ALIAS  ;T

// Usage :
// P: <xxx> -> ...
// 	    -> LAMBDA
//	    ;P		
: LAMBDA  (( T -- T ))	COMPILE TRUE ; IMMEDIATE

: SYMBOL:  (( -- )) // Non Terminals, intermediate symbol
	CREATE  IMMEDIATE
		['] NotDefinedProduction ,

	DOES>   \ LITERAL COMPILE @EXECUTE	// indirectly jump
		\ ANDTHEN ; 0 0 #PARMS

: SYMBOLS:  (( -- ))
	BEGIN
	   >IN @ BL WORD C@ 0<> 
	WHILE
	   >IN ! SYMBOL:
	REPEAT DROP ; 0 0 #PARMS

' SYMBOL: ALIAS S:

: {	; IMMEDIATE  // Action routine, just for good looking .
: }	; IMMEDIATE

//
// Syntax like [[ LAMBDA ]] is illegal. There must be at least one symbol 
// inside '[[' and ']]' , either terminal or non-terminal will do.
// Of course I can make it leagal, but for users who use such a syntax 
// tend to use syntax like {{ LAMBDA }} which is a infinite loop.
//

: [[	(( -- ANDTHENED?@ ... ))    // Begin optional item production
	ANDTHENED? @
	DUP IF  \ REANDTHEN  ENDIF  ; IMMEDIATE

: ]]	(( ANDTHENED?@ ... -- ))    // End optional item
	COMPILE TRUE \ THEN-AND
	COMPILE DROP
	IF  \ ANDTHENED  ENDIF	; IMMEDIATE

: {{	(( -- BEGIN ANDTHENED?@ ... ))    // Begin optional list production
	\ BEGIN \ [[  ; IMMEDIATE

: }}	(( BEGIN ANDTHENED?@ ... -- ))    // End optional list
	COMPILE TRUE \ THEN-AND
	IF  \ ANDTHENED  ENDIF
	COMPILE NOT \ UNTIL	; IMMEDIATE

: ValidSymbol>	(( -- ca ) ca is the code addr of a non-terminal symbol)
	TOKEN  FIND IF
	    ['] SYMBOL: OVER CREATOR? NOT IF
	       CR >HEAD .ID ."  : not defined by SYMBOL: ." CR ABORT
	    ENDIF
	ELSE
	    CR COUNT TYPE ."  : not defined non-terminal symbol." CR ABORT
	ENDIF ; 0 1 #PARMS INVISIBLE

: PRODUCTION:	(( -- ))	// Define a production
	ValidSymbol> >BODY HERE SWAP !
	\ ] COMPILE <enter_production>
	COMPILE FALSE ; // for the first " -> "

: ->	(( -- ))	// production rule define
	ANDTHENED? @ IF  COMPILE TRUE \ THEN-AND  ENDIF
	\ ORELSE  COMPILE <clear_frame>	  ; IMMEDIATE

: ;PRODUCTION	(( -- ))	// End production definition
	ANDTHENED? @ IF  COMPILE TRUE \ THEN-AND  ENDIF
	\ ELSE-OR COMPILE <?leave_production>
	COMPILE exit    \ [  ; IMMEDIATE

' PRODUCTION: ALIAS P:
' ;PRODUCTION ALIAS ;P

: GOAL:	  (( -- )) // define system goal, system goal cannot be predefined
		   // by SYMBOL: , and should not be recursively called.
	\ : COMPILE ResetSemanticStack
	COMPILE <enter_production> COMPILE FALSE ; 0 0 #PARMS

: ;GOAL	  (( -- ))
	COMPILE TRUE
	ANDTHENED? @ IF  \ THEN-AND  ENDIF
	\ ELSE-OR COMPILE <?leave_production>
	COMPILE ResetSemanticStack  \ ;   ; IMMEDIATE

ONLY FORTH ALSO DEFINITIONS

' VOCABULARY ALIAS GRAMMAR

