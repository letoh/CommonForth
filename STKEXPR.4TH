// Stack Parameter and Local Variable Expressions for Common Forth

// Note ! 
//   While using Stack Expression, the word 'EXIT' will cause the code
//   flow analysis failed, so compiler might complain that the stack
//   is not balanced but in fact it is balance.

// Stack parameter and Local variables           08/08/'92 successfully work
// ( all in data stack, return stack not involved )

                // Algorithm Developped by : Luke Lee
                // Implemented by          : Luke Lee
                // Version                 : 2.2
                // Last update             : 04/27/'96

                // Version 1.0 start date  : 8/4/'92
                //             finish date : 8/8/'92

	// * Modification history I rememberred.
        // 08/09/'92 : Modify DOES>
        // 08/13/'92 : Fix DOES> bug
        // 09/04/'92 : Optimize code for 0 0 LEFT ð DROP ð LODSD
        // 09/05/'92 : Modify ARG@ and LEFT for more readable 
        //             FOR ... NEXT loop . R@ = #I and use AFT ... THEN .
        // 09/14/'92 : Modify $COMPILER1 for double precision integers.
        // 12/04/'92 : Modify constant 1024 into CONSTANT tmpCodeOffset .
        // 01/07/'93 : Modify bug in LEFT while size >= 9 .
        // 02/14/'93 : Modify head-structure relative words : .ATTRIBUTE ....
        // 02/23/'93 : Modify DOES> to allow one CREATE and multiple DOES> .
        // 04/21/'93 : Rename vocabulary Parms&LocalVars into STACK-EXPRESSION.
        // 07/03/'93 : 1. \ modified
        //             2. Modify IF ... ELSE ... ENDIF structure
        //              Ex.  : TEST (| I1 I2 FLAG -- O |)
        //                       I1 I2 FLAG IF
        //                           >> O        ( I2 >> O )
        //                       ELSE
        //                           DROP >> O   ( I1 >> O, I2 DROPed )
        //                       ENDIF
        //                       .... ;
        //               should results an error, since ELSE appears, the
        //               execution flow may either go through IF part or
        //               ELSE part, so if it goes through ELSE part, 
        //               the stack status should be the same as IF part.
        // 07/20/'93 : Redefines 'OF' and 'ENDCASE' .
        // 07/22/'93 : Modify 'EXIT'.
        // 04/20/'94 : Redefines 'ENDOF' for fixing bug in CASE ... ENDCASE
        //             structure.
        // 04/22/'94 : Eliminates 'OF', 'ENDCASE', 'ENDOF' and adds 'COMPILE'
        //             for fixing CASE ... ENDCASE bug while using StkExpr .
        // 04/23/'94 : Add '=>' for value or local variables assignments.
        // 05/22/'94 : Modify ';' for 'DOES>', if DOES> is used, there should
        //             be a test on 'StkExprUsed?'
        // 09/20/'94 : Add 'call,' .
	// 10/09/'94 : Rename '\' into '//' and 'COMPILE' into '\'.
	// 10/16/'94 : Modify data stack pointer from ESI to EBP .
	// 11/03/'94 : Rename '(...)' pair into '((...))' pair.
	// 12/02/'94 : Modify DOES> for CF0.4TH 's new DOES>.
        // 05/02/'95 : Modify EXIT for TRACER.4TH .
        // 08/14/'95 : Modify DOES> for FLOAT.4TH's FCONSTANT .
	// 08/21/'95 : Reorder the word set. Make '?NoARG@' and '?NoLEFT' 
	//	       calls '(|ABORT|)'. Modify PUSHTOS and POPTOS .
	// 08/25/'95 : Apply 'reset-list mechanism' for error handling .
	// 09/26/'95 : Rename 'call,' to 'compile,' .
	// 10/12/'95 : Move 'stkexpr-checker' to STACK-EXPRESSION vocabulary .
	// 10/14/'95 : Fix bug in ']', it does not turn STATE ON .
	// 01/28/'96 : Fix bug while handling error in (|ABORT|) .
	// 03/13/'96 : Only add comments for WHILE ... [ ELSE ] ... THEN .
	// 03/19/'96 : Modify all control structures for stack balancing
	//	       check. Also modify CF0.4TH for supporting StkExpr.
	// 03/20/'96 : Better warning messages. Treat stack-balancing check
	//	       as a warning since EXIT might be used.	
	// 04/08/'96 : Make ?StkExprUnderflow results an (|ABORT|) .
        // 04/27/'96 : Use OriginalCompiler to store original compiler.

// Syntax :

// Example 1. Two input parameters, one output parameter
//   : f (| in1 in2 -- out |) ... ;

// Example 2. Two input parameters, no outputs
//   : f (| in1 in2 -- |) ... ;

// Example 3. No inputs, two output parameters
//   : f (| -- out1 out2 |) ... ;

// Example 4. Three inputs, two locals and 2 outputs
// : f (| in1 in2 in3 | local1 local2 -- out1 out2 |)
//       in1 in2 + >> local1
//       local1 in3 * >> out1
//       ... ;

// Note:   With | present but no local variables defined, the syntax is still
//         valid. Ex.   : f (| in1 in2 | -- out |) ... ;

// Example 5     CREATE .. DOES> ...
//       Note : The parameters between ':' to 'DOES>' are unknown for
//              codes between 'DOES>' to ';' .
//  Ex 5.1
// : f (| in1 -- |)
//       CREATE 
//         in1 ,
//       DOES> (| pfa -- |)  // There MUST have at least one parameter
//         pfa @ . ;         // representing PFA  
//
//  Ex 5.2
// : TEST (| in1 -- |)
//       CREATE
//        in1 ,
//       DOES> (| a b c pfa -- |)
//        pfa @ . c . b . a . ;
// 4 TEST newword ok
// 1 2 3 newword 4 3 2 1 ok

VARIABLE BUG-WARNING  TRUE BUG-WARNING !

: PUSHTOS       (( -- ))
	COMPILE DUP ; 0 0 #PARMS

: POPTOS	(( -- ))
	COMPILE DROP ; 0 0 #PARMS

VOCABULARY STACK-EXPRESSION
STACK-EXPRESSION ALSO DEFINITIONS

DEFER   (|var-type|)
DEFER   (FORGET-HP) 1 0 #PARMS

VARIABLE (|<--?-->|)    // incoming parameters + local variables
VARIABLE (|SP|)         0 (|SP|) !      // local stack pointer
VARIABLE first?         TRUE first? !
VARIABLE 1st-tmp-symbol
VARIABLE #in
VARIABLE #out
VARIABLE StkExprUsed
VARIABLE OriginalCompiler

VARIABLE DOES?          FALSE DOES? !
VARIABLE DOES>#IN
VARIABLE DOES>#OUT

55 K CONSTANT tmpCodeOffset   // Fibonacci( 10 ) = 55
2 BASE !
01      CONSTANT        (|R|)           // read only variables
10      CONSTANT        (|W|)           // write only variables
11      CONSTANT        (|R/W|)         // read/write variables
DECIMAL

' STACK-EXPRESSION CONSTANT stack-parameter // a distinct value for type-checking

: StkExprUsed? StkExprUsed @ ; 0 1 #PARMS

: 1st-tmp-symbol?       (( -- ))
        first? @ IF LAST @ 1st-tmp-symbol ! FALSE first? ! ENDIF ; 0 0 #PARMS

: FORGET-PARMS  (( -- ))
        first? @ NOT IF
                HERE 1st-tmp-symbol @ (FORGET-HP) CP !
                TRUE first? !  0 (|SP|) !
        ENDIF ; 0 0 #PARMS

2VARIABLE (|CleanError|)

: (|ABORT|)     (( -- ))
        FORGET-PARMS
	StkExprUsed OFF		// 01/28/'96 added. Bug fixed.
        LAST @ |HEAD| + DUP HP ! LAST ! // Fail defining word, adjust HP back
	(|CleanError|) POP-RESETTER
        OriginalCompiler @ ?DUP IF  'COMPILER !  ENDIF
        OriginalCompiler OFF
        ABORT ; 0 0 #PARMS

: ?NoARG@ (( offset size T/F -- offset size ))
        IF ."  Invalid argument for ARG@ : " SWAP . . ."  ." CR ABORT ENDIF 
	; 3 2 #PARMS

: ?NoLEFT (( offset size T/F -- offset size ))
        IF ."  Invalid argument for LEFT : " SWAP . . ."  ." CR ABORT ENDIF
	; 3 2 #PARMS

: ?exceed$7F (( n -- n ))	// 32 * 4 = 128 = $80 > $7F = -1 in short integer
	DUP 32 >= IF ." Argument exceed 32 cells ." ABORT ENDIF ; 1 1 #PARMS

: ARG@ (( offset size -- ))       
        // A generalized PICK, but it does not need run-time arguments 
        // for PICKing elements, the offset and size is determined at
        // compiling time.
    2DUP - -1 < ?NoARG@
    2DUP $FF >= SWAP $FF > OR ?NoARG@
    OVER $FF = IF // reserve space on stack, the values in reserved spaces 
                  // are undefined
       SWAP DROP DUP 0<> IF
	  ?exceed$7F
	  $89 C, $45 C, $FC C,	// { EBP CELL- } EAX  MOV
	  $8D C, $6D C, CELL* NEGATE C,		// EBP { EBP CELL* - }	   LEA
       ELSE     // $FF 0 ARG@ ... do nothing
          DROP
       ENDIF
    ELSE OVER 0= IF
       2DROP PUSHTOS // PUSHTOS is enough
    ELSE // size = 1 implemented only
       DUP 1 <> ?NoARG@ DROP
       ?exceed$7F	
       PUSHTOS 
       $8B C, $45 C, CELL* C,	// EAX { EBP CELL* + } MOV
    ENDIF ENDIF 
; 2 0 #PARMS

: LEFT  (( offset size -- ))
    2DUP - -1 < ?NoLEFT
    DUP 0= IF // DROP cells
      DROP ?DUP 0= IF  // 0 0 LEFT = DROP 
        POPTOS
      ELSE
	?exceed$7F
	$8B C, $45 C, DUP CELL* C,	// EAX	{ EBP DUP CELL* + }	MOV
	$8D C, $6D C, 1+ CELL* C,	// EBP	{ EBP 1+ CELL* + }	LEA
      ENDIF 
    ELSE DUP 1 = IF // just adjust data stack pointer, since EAX is TOS
      DROP ?exceed$7F $8D C, $6D C, CELL* C,	// EBP { EBP CELL* + }	LEA
    ELSE
      2DUP 2 - FOR // ofs siz ofs
        $8B C, $95 C, #I CELL* ,                // MOV EDX, [EBP+4*x]
        $89 C, $95 C, 1- DUP CELL* ,            // MOV [EBP+4*y], EDX
      NEXT DROP // ofs siz
      $8D C, $AD C, - 1+ CELL* ,      // LEA EBP,[EBP+(offset-size+1)*4]
    ENDIF ENDIF
; 2 0 #PARMS

: .StkExprWarning	(( -- ))
	CR ." ** Stack Expression Warning : " CR ; 0 0 #PARMS
: .StkExprError		(( -- ))
	CR ." ** Stack Expression Error : " CR ; 0 0 #PARMS

: ?suspectable-bug1     (( pfa T/F -- pfa ))
        BUG-WARNING @ AND IF
          .StkExprWarning  ."  Variable " 
          DUP BODY> >HEAD .ID
          ."  not initialized yet . "
        ENDIF ; 2 1 #PARMS

: ?suspectable-bug2     (( pfa T/F -- pfa ))
        BUG-WARNING @ AND IF
          .StkExprWarning  ."  Input variable "
          DUP BODY> >HEAD .ID
          ."  modified . "
        ENDIF ; 2 1 #PARMS

: ?suspectable-bug3     (( T/F -- ))
	BUG-WARNING @ AND IF
	   .StkExprWarning	
	   ."  Stack might not balance in this control structure, " 
	   ." if you are using EXIT " CR
	   ." in this word, check again and ignore this message ."
        ENDIF ; 1 0 #PARMS

: ?BUG!         (( T/F -- ))
        IF .StkExprError ."  Stack use does not match parameter experssion "
           ." --- " (|SP|) @ . ." extra cell(s)." CR
           (|ABORT|)
        ENDIF ; 1 0 #PARMS

: (|create|)    (( -- ))  // Parameter creation time routines .
        1st-tmp-symbol? 
        stack-parameter LAST @ |USER-DEFINED !
        (|<--?-->|) DUP @ 1+ DUP ROT ! , IMMEDIATE COMPILEONLY ; 0 0 #PARMS

: (|does|)      (( pfa )) // What do parameters do ?
                        // Local variables behaves the same .
        DUP CELL+ @ (|W|) = ?suspectable-bug1
        @ (|<--?-->|) @ SWAP - (|SP|) @ + 1 ARG@
        1 (|SP|) +!     ; 1 0 #PARMS

: -->f(x)       (( -- ))  // input parameters
        CREATE
           1 #in +! (|create|) (|R|) ,
        DOES>
           (|does|) ; 0 0 #PARMS

: f(x)-->       (( -- ))  // output parameters
        CREATE
           1 #out +! (|create|) (|W|) ,
        DOES>
           (|does|) ; 0 0 #PARMS

: f(locals)     (( -- ))  // local variables
        CREATE
           (|create|) (|W|) ,
        DOES>
           (|does|) ; 0 0 #PARMS

: unknown?      (( c -- c ))
        DUP $FF = IF
          .StkExprError 
	  ."  Cannot use words with unknown number of parameters !" 
	  CR (|ABORT|)
        ENDIF ; 1 1 #PARMS

: +-(|SP|)      (( ha -- ))
        DUP |OUT-PARMS C@ unknown? 
        SWAP |IN-PARMS C@ unknown?   -   (|SP|) +!       ; 1 0 #PARMS

: ?StkExprUnderflow	(( T/F -- ))
	IF .StkExprError 
	   ."  Local stack underflow during compilation ! " 
	   ." You might 'DROP' too much." CR (|ABORT|)
	ENDIF ; 1 0 #PARMS

: StkExpr$COMPILE     (( A -- ))        // Higher level compiler
	(|SP|) @ 0< ?StkExprUnderflow
        FIND DUP IF
          DUP |ATTRIBUTE H@ IMMED AND IMMED <> IF
            +-(|SP|) compile,
          ELSE
            DROP EXECUTE        // immediate word
          ENDIF
        ELSE DROP
          'NUMBER @EXECUTE IF
             DOUBLE? IF
                SWAP \ LITERAL \ LITERAL 2 (|SP|) +!
             ELSE
                \ LITERAL 1 (|SP|) +!
             ENDIF
          ELSE
             SPACE COUNT TYPE ."  <-- What?" CR (|ABORT|)
          ENDIF
        ENDIF 
	(|SP|) @ 0< ?StkExprUnderflow	; 1 0 #PARMS

: stkexpr-checker       (( ha -- ))
        StkExprUsed? IF +-(|SP|) ELSE DROP ENDIF ; 1 0 #PARMS

: balance?	(( lsp0 -- lsp0 ))
        StkExprUsed? IF
	    DUP (|SP|) @ <>  ?suspectable-bug3
	ENDIF ; 1 1 #PARMS

: (|SP|)@	COMPILE (|SP|) COMPILE @ ; IMMEDIATE COMPILEONLY
: (|SP|)!	COMPILE (|SP|) COMPILE ! ; IMMEDIATE COMPILEONLY

FORTH DEFINITIONS

: \          StkExprUsed? IF
                >IN @ ' >HEAD +-(|SP|) >IN !
             ENDIF
             \ \
             ; IMMEDIATE COMPILEONLY 0 0 #PARMS

: DEFERS     StkExprUsed? IF
		>IN @ ' >HEAD +-(|SP|) >IN !
	     ENDIF
	     \ DEFERS
	     ; IMMEDIATE COMPILEONLY 0 0 #PARMS

: COMPILE    (( -- ))
             >IN @ ' >HEAD \ LITERAL >IN !
             COMPILE stkexpr-checker
             \ COMPILE
             ; IMMEDIATE COMPILEONLY 0 0 #PARMS

: compile,   (( ca -- ))
             StkExprUsed? IF
                DUP >HEAD +-(|SP|)
             ENDIF
             compile, ; 1 0 #PARMS

// Redefine all control structures, all control structure needs stack-balance
// checking.

: FOR	(( -- lsp a ))
	COMPILE >R (|SP|)@  HERE	; 0 2 #PARMS IMMEDIATE COMPILEONLY

: NEXT  (( lsp a -- ))
	COMPILE next rel, 
	balance? (|SP|)!  		; 2 0 #PARMS IMMEDIATE COMPILEONLY

: BEGIN (( -- lsp a ))
	(|SP|)@  HERE  			; 0 2 #PARMS IMMEDIATE COMPILEONLY

: UNTIL (( lsp a -- ))
	COMPILE ?BRANCH rel, 
	balance? (|SP|)!  		; 2 0 #PARMS IMMEDIATE COMPILEONLY

: AGAIN (( lsp a -- ))
	COMPILE BRANCH rel,
	balance? (|SP|)!  		; 2 0 #PARMS IMMEDIATE COMPILEONLY

: IF    (( -- lsp A ))
	COMPILE ?BRANCH 
	(|SP|)@ HERE 0 rel,  		; 0 2 #PARMS IMMEDIATE COMPILEONLY

: AHEAD (( -- lsp A ))
	COMPILE BRANCH 
	(|SP|)@ HERE 0 rel,  		; 0 2 #PARMS IMMEDIATE COMPILEONLY

: REPEAT (( lsp1 A lsp0 a0 -- ))
	\ AGAIN HERE SWAP +!  (|SP|)!	; 4 0 #PARMS IMMEDIATE COMPILEONLY

: ENDIF (( lsp A -- ))
	HERE SWAP +!  balance? (|SP|)!  ; 2 0 #PARMS IMMEDIATE COMPILEONLY

: AFT   (( lsp a -- lsp a lsp A ))
	2DROP \ AHEAD \ BEGIN 2SWAP  	; 2 4 #PARMS IMMEDIATE COMPILEONLY

: ELSE  (( lsp0 A0 -- lsp1 A ))
	\ AHEAD	2SWAP	// lsp a lsp0 a0
	HERE SWAP +! (|SP|)!  		; 2 2 #PARMS IMMEDIATE COMPILEONLY

: WHILE (( lsp0 a0 -- lsp1 A lsp0 a0 ))
	\ IF 2SWAP 			; 2 4 #PARMS IMMEDIATE COMPILEONLY

' ENDIF	ALIAS THEN

: ABORT" (( -- ; <string> ))
	COMPILE abort" $,"		; 0 0 #PARMS IMMEDIATE COMPILEONLY

: $"    (( -- ; <string> ))
	COMPILE $"| $," 		; 0 0 #PARMS IMMEDIATE COMPILEONLY

: Z$"   (( -- ; <string> ))
	COMPILE Z$"| $," 0 C, 		; 0 0 #PARMS IMMEDIATE COMPILEONLY

: "     (( -- ))
	COMPILE "|  $," 		; 0 0 #PARMS IMMEDIATE COMPILEONLY

: LITERAL   (( w -- )) // Compile tos to code dictionary as an integer literal.
	COMPILE (LIT) , ; 1 0 #PARMS IMMEDIATE COMPILEONLY

: [']   (( -- )) ' \ LITERAL ; 0 0 #PARMS IMMEDIATE COMPILEONLY

: IS	\ IS  STATE @ IF  -1 (|SP|) +!  ENDIF ; IMMEDIATE 1 0 #PARMS

: EXIT  // 07/22/'93
        STATE @ IF
            StkExprUsed? IF
                (|SP|) @ 0<> ?BUG!
                (|<--?-->|) @ 1- #out @ LEFT
            ENDIF
            \ EXIT      // <-- modified for TRACER.4TH on 05/02/'95
        ENDIF ; IMMEDIATE 0 0 #PARMS

: >>    (( -- ))
        ' DUP >HEAD |USER-DEFINED @ stack-parameter <> IF
          ."  Cannot assign ( >> ) value to " >HEAD .ID ." ." CR (|ABORT|)
        ENDIF
        -1 (|SP|) +! >BODY DUP @ (|<--?-->|) @ SWAP - (|SP|) @ + CELL*
        $89 C, $85 C, ,         // MOV [EBP+4*...], EAX
	POPTOS
        DUP CELL+ @ (|R|) = ?suspectable-bug2
        CELL+ (|R/W|) SWAP ! // modify variable attribute to read/write-able
        ; IMMEDIATE COMPILEONLY 0 0 #PARMS

: |)    (( LAST@ CP@ -- ))
        CP ! LAST !
        #in @ #out @ #PARMS
        $FF (|<--?-->|) @ #in @ - ARG@
        'EVAL @  OriginalCompiler  !
        ['] StkExpr$COMPILE  'COMPILER  !
        ]  ; COMPILEONLY 2 0 #PARMS

: |     (( -- ))
        ['] f(locals) IS (|var-type|) ; COMPILEONLY 0 0 #PARMS

: --    (( -- ))
        ['] f(x)--> IS (|var-type|) ; COMPILEONLY 0 0 #PARMS

STACK-EXPRESSION DEFINITIONS

' |  >NAME COUNT DROP CONSTANT "|"
' -- >NAME COUNT DROP CONSTANT "--"
' |) >NAME COUNT DROP CONSTANT "|)"

DEFER (|delimiter?|)
DEFER (|syntax?|)       // syntax check not implemented yet

: inparms       (( A -- T/F T/F ))
        "--" OVER COUNT COMP 0 =
        "|" ROT COUNT COMP 0 = OVER OR ; 1 2 #PARMS

: localparms    (( A -- F T/F ))
        FALSE "--" ROT COUNT COMP 0 = ; 1 2 #PARMS

: outparms      (( A -- F T/F ))
        FALSE "|)" ROT COUNT COMP 0 = ; 1 2 #PARMS

: scan-parms    (( -- T/F ))
        BEGIN
          >IN @ TOKEN (|delimiter?|)
        NOT WHILE
          DROP >IN ! (|var-type|)
        REPEAT SWAP DROP ; 0 1 #PARMS

: SCAN-PARMS    (( -- ))
        ['] inparms IS (|delimiter?|)
        scan-parms
        NOT IF
          ['] localparms IS (|delimiter?|)
          | scan-parms DROP
        ENDIF
        ['] outparms IS (|delimiter?|)
        -- scan-parms DROP
        |) ; 0 0 #PARMS

: LEAVE-SCOPE? (( -- ))
        StkExprUsed? IF
            FALSE StkExprUsed !
            (|SP|) @ 0<> ?BUG!
            (|<--?-->|) @ 1- #out @ LEFT
            FORGET-PARMS
            OriginalCompiler @  'COMPILER  !   OriginalCompiler OFF
	    (|CleanError|)  POP-RESETTER
        ENDIF ; 0 0 #PARMS

: %!>   (( VALUE -- ))
     // Runtime routine of !>
        R> DUP 5 + >R
        1+ @ R@ + >BODY ! ; 1 0 #PARMS

FORTH DEFINITIONS

' CONSTANT ALIAS VALUE

: !>    (( v -- ))
        STATE @ IF
           COMPILE %!>  ' compile,  -1 (|SP|) +!  // value will make (|SP|)++
        ELSE
           ' >BODY !
        ENDIF ; IMMEDIATE 1 0 #PARMS

: =>	(( v -- ))
        >IN @ ' SWAP >IN !
        >HEAD |USER-DEFINED @ stack-parameter = IF
            \ >>
        ELSE
            \ !>
        ENDIF ; IMMEDIATE 1 0 #PARMS

' => DUP DUP ALIAS =: ALIAS to ALIAS TO

: (|    (( -- LAST@ CP@ ))
	['] (|ABORT|) (|CleanError|) PUSH-RESETTER
        0 DUP (|<--?-->|) ! (|SP|) !    TRUE DUP StkExprUsed ! first? !
        0 DUP #in ! #out !      LAST @ HERE
        DUP tmpCodeOffset + CP !
        ['] -->f(x) IS (|var-type|)
        SCAN-PARMS ; COMPILEONLY IMMEDIATE 0 2 #PARMS

: :     (( -- ))
        FALSE DOES? ! !CSP CURRENT @ CONTEXT ! : ; 0 0 #PARMS

: DOES> (( -- ))
        LEAVE-SCOPE?
        StkExprUsed? IF         // 08/14/'95 add IF due to FCONSTANT
            COMPILE (LIT) HERE DOES>#IN  ! 0 ,  
            COMPILE (LIT) HERE DOES>#OUT ! 1 ,
            COMPILE #PARMS
        ENDIF
	\ DOES>
	StkExprUsed? IF
            DOES? @ NOT 
	    IF // Already DOES>-ed ? For one CREATE and multiple DOES>
                HP @ |HEAD| - DUP LAST ! HP ! 0 1 #PARMS // temporary dummy header
            ENDIF
	ENDIF
        TRUE DOES? !  ; IMMEDIATE COMPILEONLY 0 0 #PARMS

: ;     (( -- ))
        LEAVE-SCOPE?
        DOES? @ IF
           StkExprUsed? IF      // 5/22/'94
               LAST @ DUP |IN-PARMS C@ 1- DOES>#IN @ !
               |OUT-PARMS C@ DOES>#OUT @ !
               |HEAD| DUP HP +! LAST +!
           ENDIF
	   FALSE DOES? !
        ENDIF
        ?CSP \ ;        ; IMMEDIATE COMPILEONLY 0 0 #PARMS

: .#PARMS       (( <name> -- ))
        ' >HEAD DUP |IN-PARMS C@ . |OUT-PARMS C@ . ; 0 0 #PARMS


