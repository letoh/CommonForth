// 
//  Infix grammar sample with LL(k) Compiler .
//
				// 09/21/'95  Written by  : Luke Lee
				//            Version     : 2.6
				//            	   update : 09/26/'95
				//            	   update : 01/07/'96
				//                 update : 01/28/'96
                                //            Last update : 09/19/'96

// 01/28/'96 : Rename TRANSLATE-BLOCK into TRANSLATE .
// 09/19/'96 : Use '<( ... )>' to represent infix syntax.

NEEDS LL(k)GEN.4TH

GRAMMAR INFIX

INFIX ALSO DEFINITIONS

FALSE VALUE ShowInfix? INVISIBLE

CREATE LineBuffer  512 ALLOT

: #append  ( A$ -- )
      // Concat current token to LineBuffer with a trailing space 
      [ NODEBUG @ NOT ] #IF
	." #appending " DUP COUNT TYPE CR
      #ENDIF
	DUP C@ IF  LineBuffer SWAP COUNT $+ "  " $+   ENDIF
	DROP ; 1 0 #PARMS

: #appendthis ( -- )  ThisToken #append ; 0 0 #PARMS

: #returnthis ( -- )  $$1 @ $$$ ! ; 0 0 #PARMS

//
//  Terminal defining 
//

CR .( Defining Terminals ... ) CR

STR" )>"  T: ")>"  ;T   // 09/19/'96
STR" +"   T: '+'   ;T
STR" -"   T: '-'   ;T
STR" *"   T: '*'   ;T
STR" /"   T: '/'   ;T
STR" ("   T: '('   ;T
STR" )"   T: ')'   ;T
STR" ="   T: '='   ;T
STR" <"   T: '<'   ;T
STR" >"   T: '>'   ;T
STR" <>"  T: "<>"  ;T
STR" <="  T: "<="  ;T
STR" >="  T: ">="  ;T
STR" **"  T: "**"  ;T
STR" F+"  T: "F+"  ;T
STR" F-"  T: "F-"  ;T
STR" F*"  T: "F*"  ;T
STR" F/"  T: "F/"  ;T
STR" F**" T: "F**" ;T
STR" NOT" T: "NOT" ;T
STR" AND" T: "AND" ;T
STR" OR"  T: "OR"  ;T
STR" XOR" T: "XOR" ;T
STR" MOD" T: "MOD" ;T
STR" ABS" T: "ABS" ;T
STR" FABS" T: "FABS" ;T

//
//  Grammar defining
//
.( Defining Grammar ... ) CR

SYMBOLS: <primary> <logical_op> <relational_op> <adding_op> <multiplying_op> 
SYMBOLS: <abs_op> <exponational_op> <uniary_op> <factor> <term> 
SYMBOLS: <simple_expr> <relation> <expression>

.( Production rule 1) CR
P: <primary> -> '(' <expression> ')'
	     -> GetToken
	     	DUP C@ 0<> 		ANDTHEN
		DUP $" )" $= NOT  	ANDTHEN
	        #appendthis TRUE 	THEN-AND
		NIP
	     ;P

.( Production rule 2) CR
P: <logical_op> -> "AND" { #returnthis }
		-> "OR"  { #returnthis }
		-> "XOR" { #returnthis }
		;P

.( Production rule 3) CR
P: <relational_op> -> '='   { #returnthis }
		   -> "<>"  { #returnthis }
		   -> '<'   { #returnthis }
		   -> "<="  { #returnthis }
		   -> '>'   { #returnthis }
		   -> ">="  { #returnthis }
		   ;P

.( Production rule 4) CR
P: <adding_op> -> '+'  { #returnthis }
	       -> '-'  { #returnthis }
	       -> "F+" { #returnthis }
	       -> "F-" { #returnthis }
	       ;P

.( Production rule 5) CR
P: <multiplying_op> -> '*'   { #returnthis }
		    -> '/'   { #returnthis }
		    -> "F*"  { #returnthis }
		    -> "F/"  { #returnthis }
		    -> "MOD" { #returnthis }
		    ;P

.( Production rule 6) CR
P: <abs_op> -> "ABS"   { #returnthis }
	    -> "FABS"  { #returnthis }
	    ;P

.( Production rule 7) CR
P: <uniary_op> -> '+' { NULL$ $$$ ! }
	       -> '-' { $" NEGATE" $$$ !  }
	       ;P

// <expo_op> -> **
//	     -> F**
// <factor> -> [ <uniary adding op> ] <primary> [ <expo op> <primary> ]
//          -> [ <uniary adding op> ] ABS <primary>
//          -> NOT <primary>

.( Production rule 8) CR
P: <exponational_op> -> "**"  <primary> { $$1 @ #append }
		     -> "F**" <primary> { $$1 @ #append }
		     ;P

.( Production rule 9) CR
// NOTE : If you don't put the "NOT" operation as the first production rule
//	  , it will be treated as <primary> and cause an error
P: <factor> -> "NOT" <primary> { $$1 @ #append }
	    -> [[ <uniary_op> ]] <abs_op> <primary> 
	        { $$2 @ #append $$1 @ #append }
	    -> [[ <uniary_op> ]] <primary> [[ <exponational_op> ]]
	       	{ $$1 @ #append }
	    ;P

.( Production rule 10) CR
P: <term> -> <factor> {{ <multiplying_op> <factor> { -$$2 @ #append } }}
	  ;P

.( Production rule 11) CR
P: <simple_expr> -> <term> {{ <adding_op> <term> { -$$2 @ #append } }}
		 ;P

.( Production rule 12) CR
P: <relation> -> <simple_expr> 
		 {{ <relational_op> <simple_expr> { -$$2 @ #append } }}
	      ;P

.( Production rule 13) CR
P: <expression> -> <relation> {{ <logical_op> <relation> { -$$2 @ #append } }}
		;P

.( Production rule 14) CR
GOAL: <infix_expr_rest> -> <expression> ")>"    // the rest of infix expression
			-> ")>"
			;GOAL

FORTH DEFINITIONS

: **    ( a b -- a^b )
	FOR 1 AFT OVER * THEN NEXT NIP ; 2 1 #PARMS

: <(    ( -- )
	0 LineBuffer !
	<infix_expr_rest> IF
	   ShowInfix? IF
	      CR ." LineBuffer : " CR LineBuffer COUNT TYPE CR 
	   ENDIF
	   LineBuffer COUNT TRANSLATE ?DUP IF THROW ENDIF
	ELSE
	   ." * Infix syntax error. " CR ABORT
	ENDIF ; IMMEDIATE

: .INFIX   ShowInfix?  NOT TO ShowInfix?  ;	// toggle displaying

ONLY FORTH ALSO DEFINITIONS

