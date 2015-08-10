// Miscellaneous high level words for Common Forth

                                        // Written by : Luke Lee
                                        // Last update : 01/23/'97

// ---------------------------------------------------------------------------

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//                    I M P O R T A N T     N O T E S
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//  Note that if you are trying to add some compiling words ( such as ASCII )
//  into this HI.4TH and wish it would be compatiable with Stack Expression,
//  you MUST insert it after Stack Expression is loaded. 
//     That is, you should add your own compiling words after the line : 
//  'FLOAD StkExpr.4TH' .
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

// --------------------------------------------------------------------------
// Modification history I rememberred (too many to record them all) :
//   [8/20/'92] : Add DEFERS and modifies DEFER .
//   [9/05/'92] : Add alias #I of R@, and modify the bug in ALIAS
//                ( the I/O #PARMS must be the same too ) .
//   [1/3/'93]  : Add CASE ... OF ... ENDOF .. ENDCASE
//                ERASE
//                DO , ?DO , LOOP and LEAVE
//   [2/23/'93] : Modify the CASE ... ENDCASE structure to be compatiable
//                with standard structure.
//       .
//       .       ( not recorded )
//       .
//   [8/4/'93]  : Include SHORTCUT.4TH for short cut boolean evaluation.
//   [8/19/'93] : Modify bugs in TRIM-VOC , Search-Entry and WORDS .
//   [4/17/'94] : Add >HEAD
//   [4/22/'94] : Load CASE.4TH after STKEXPR.4TH for CASE ... ENDCASE
//   [4/23/'94] : VALUE words are now in stack-expression
//                KEYBUF.4TH are now implemented and included here.
//   [4/26/'94] : New FLOAD and $FLOAD for create filenames in vocabulary
//                FILES .
//   [5/6/'94]  : Include NEEDS .
//   [5/14/'94] : Multasker .
//   [5/15/'94] : modify > < <= ... into MACROs
//   [11/20/'94] : add 'PATCH' .
//   [12/02/'94] : add 'CREATOR?' for CF0.4TH's DOES> modification
//	.
//	.	( not recorded )
//	.
//   [01/04/'96] : Modify COMMENT: ... ;COMMENT for running away comments.
//   [01/16/'96] : Modify ASSERT.4TH for running away assertion.
//   ...
//   [03/10/'96] : Optimize ARRAY: for different case DOES> .
//   [03/19/'96] : Move 2SWAP into CF0.4TH .
//   [07/14/'96] : Modify HERROR$ for DPMI error messages.
//   [11/15/'96] : Move disassembler CODE>HEAD here.
//   [01/04/'97] : Add COMMENT-PAIR: words set.
//   [01/20/'97] : Modify [ COMPILE exit ] to [ exit, ]
//   [01/21''97] : Add [ DEFERRED ], ex: 
//                 DEFER DFR    ['] NOOP IS DFR
//                 DEFERRED DFR     
//                      ['] WORDS IS DFR   DFR
//                 IS DFR
//   [01/23/'97] : Modify [ CREATOR? ] for more robust checking.
// --------------------------------------------------------------------------

WARNING OFF
DECIMAL

CR
.( ----------------------  Loading high level words  -----------------------)

// ***********     Structure defining words and Head Structure  ************

CR .( Loading data structure defining words : STRUCT.4TH ...)
FLOAD STRUCT.4TH 

FLOAD HEAD.4TH

// ********************       System memory map        *********************

FLOAD MEMMAP.4TH        // system memory map

.( ... ok)

// ***************         Some commonly used words        *****************

: valid-addr?   ( a -- T/F )
        BASE-ADDRESS     BASE-ADDRESS |WORK-SPACE |FORTH-VOCTABLE
        WITHIN ; 1 1 #PARMS

: CODE>HEAD ( ca -- ha|0 ) // Convert code address into head address if success,
                           // otherwise return 0.
        DUP DUP valid-addr?
        IF >HEAD DUP valid-addr?
           IF 2DUP |REFERENCE @ =
              IF
                 NIP EXIT
              ENDIF
           ENDIF
        ENDIF 2DROP FALSE ; 1 1 #PARMS

0  CONSTANT NULL
0  CONSTANT NIL

: BINARY  2 BASE ! ; 0 0 #PARMS

: EXIT  (( -- ))
        STATE @ IF  exit,  ENDIF ; 0 0 #PARMS IMMEDIATE

: TUCK  (( n1 n2 -- n2 n1 n2 ))
        SWAP OVER ; MACRO 2 3 #PARMS

: ALIAS         (( ca -- ))
        CREATE
          LAST @ 2DUP |REFERENCE ! // set reference field
          OVER >HEAD |USER-DEFINED @ OVER |USER-DEFINED !
          OVER >HEAD |ATTRIBUTE @ OVER |ATTRIBUTE ! // set attr...out-parms
          SWAP |SIZE @ SWAP |SIZE ! ; 1 0 #PARMS

' R@     DUP    ALIAS  #I ALIAS I

: ERASE 0 FILL ; 2 0 #PARMS

: CMOVE>        (( from to count -- ))
	FOR 
	   R@ + 1- SWAP R@ + 1- SWAP
	   AFT
	      OVER C@ OVER C! 1- SWAP 1- SWAP
	   THEN
	NEXT 2DROP ; 3 0 #PARMS

: MOVE          (( from to count -- ))
        -ROT 2DUP U< IF
           ROT CMOVE>
        ELSE
           ROT CMOVE
        ENDIF ; 3 0 #PARMS

: BEEP          (( -- ))	
	7 BIOSEMIT ; 0 0 #PARMS

: (VOC-FIND)    (( stradr voc-table -- ca ha | stradr F ))
        OVER 1+ HASH SWAP (FIND)        // stradr ca ha | stradr key F
        DUP IF
           ROT DROP
        ELSE
           NIP
        ENDIF ; 2 2 #PARMS INVISIBLE

// *******************          Vocabulary words           *****************

CR .( Loading Vocabulary Definitions : VOCAB.4TH ...)
FLOAD VOCAB.4TH
.( ... ok)

VOCABULARY HIDDEN
HIDDEN ALSO DEFINITIONS

// ***********************         Defer words          ********************

: CRASH         (( -- ))
        ."  Uninitialized vector !" CR ABORT ; 0 0 #PARMS

FORTH DEFINITIONS

: CREATOR?	( creator created -- T/F )      // 01/23/'97 modified
        DUP ['] call [ ' call >HEAD |SIZE @ 1- ] LITERAL COMP 0= IF
	   1+ DUP @ + (( CELL+  CELL- )) @  =
        ELSE
           2DROP FALSE
        ENDIF ; 2 1 #PARMS

: DEFER         ( -- )
        CREATE
	  $FF $FF #PARMS
          ['] CRASH ,
        DOES>
           @EXECUTE  ; 0 0 #PARMS        

: 'DEFER        ( -- ca ) 
        // Tick for defer words, check whether it is defined by DEFER.
        ' ['] DEFER OVER CREATOR? NOT IF
           ."  Can't defers a non-deferred word " >HEAD .ID ."  ." CR ABORT
        ENDIF ; 0 1 #PARMS INVISIBLE
                              
: DEFERS        ( -- ) ( TIB:  <NAME> -- )
        'DEFER
        >BODY @ compile,
        ; 0 0 #PARMS IMMEDIATE COMPILEONLY

: >DEFERRED     ( defer_ca -- deferred_ca )     >BODY @ ; 1 1 #PARMS

: DEFERRED      ( -- ca )
        STATE @ IF
           'DEFER >BODY \ LITERAL  COMPILE @
        ELSE
           'DEFER >DEFERRED
        ENDIF ; IMMEDIATE 0 1 #PARMS

: IS            ( ca -- )
        STATE @ IF
          ' >BODY \ LITERAL COMPILE !
        ELSE
          ' >BODY !
        ENDIF ; IMMEDIATE 1 0 #PARMS

// *****************        COMMENT: and ;COMMENT         *******************
// Note : 
//   ';COMMENT' must be placed as the first word of that line, otherwise
//   it won't make any effect
//      Ex.
//   COMMENT:
//      THIS IS A COMMENT
//      HERE  ;COMMENT  HAS NO EFFECT
//	COMMENT: HERE HAS NO EFFECT EITHER
//      THIS IS ANOTHER COMMENT
//   ;COMMENT  // HERE ;COMMENT WORKS

VARIABLE CommentSaved'EVAL	' NOOP  CommentSaved'EVAL  !
2VARIABLE CommentResetter

: ResetComments	(( -- ))
	['] NOOP  CommentSaved'EVAL  !
	CommentResetter POP-RESETTER ; 0 0 #PARMS

FORTH DEFINITIONS

: ;COMMENT	(( -- ))
        TRUE ABORT"  Not commenting" ; 0 0 #PARMS IMMEDIATE

: COMMENT;	(( -- )) // just for compatiability
	\ ;COMMENT ; 0 0 #PARMS IMMEDIATE INVISIBLE

HIDDEN DEFINITIONS

DEFER CommentPairing?  ( a -- T/F )  1 1 #PARMS
: FailCommentPairing   ( a -- T/F )  DROP FALSE ; 1 1 #PARMS
' FailCommentPairing IS CommentPairing?

: EndComments	( -- )
	CommentSaved'EVAL @ 'EVAL !
	ResetComments  ; 0 0 #PARMS

: $SKIP-COMMENTS   ( A -- )
	DUP  ['] ;COMMENT >NAME  $= 
        OVER ['] COMMENT; >NAME  $= OR
        OVER CommentPairing?        OR  NIP
        IF
	   EndComments
        ELSE
           \ //
        ENDIF ; 1 0 #PARMS

: CommentsRunAway?	(( -- ))
	CommentSaved'EVAL @ ['] NOOP <> IF
	   EndComments
	   CR ." * Error : Run away comments , COMMENT: without ;COMMENT ." CR
	   ABORT
	ENDIF ; 0 0 #PARMS

FORTH DEFINITIONS

: COMMENT:      (( -- ))
	['] ResetComments CommentResetter PUSH-RESETTER
        'EVAL @ CommentSaved'EVAL !
        ['] $SKIP-COMMENTS 'EVAL !
        \ //  		; IMMEDIATE 0 0 #PARMS

: COMMENTS-PAIR: ( -- ) 
                     ( TIB: <comment-begin> <comment-end> -- ) // 01/04/'97
        >IN @  TOKEN C@ 0<> TOKEN C@ 0<> AND SWAP  >IN !
        NOT IF  CR ." * Error : Comments not paired." CR ABORT  ENDIF
        ['] COMMENT: ALIAS
        CREATE
           HERE    //  DUP aaaa $=  SWAP DEFERS CommentPairing?   OR  EXIT
           COMPILE DUP   LAST @ |NAME-LENGTH \ LITERAL   COMPILE $=
           COMPILE SWAP  
           ['] CommentPairing? >BODY @  call,  // DEFERS CommentPairing?
           COMPILE OR   exit,
           IS  CommentPairing?
        DOES>
           \ ;COMMENT ; 0 0 #PARMS

// *********************       Floaded file names        *******************

HIDDEN DEFINITIONS

DEFER  ENDOF$FLOAD   0 0 #PARMS
' CommentsRunAway? IS ENDOF$FLOAD

FORTH DEFINITIONS

VOCABULARY FILES

ALSO FILES DEFINITIONS
: HI.4TH ; : STRUCT.4TH ; : HEAD.4TH ; : MEMMAP.4TH ; : VOCAB.4TH ;
PREVIOUS DEFINITIONS

VARIABLE FILENAMES
FILENAMES ON

: $>UPPER	(( str len -- ))
	FOR AFT 
	    DUP C@  [ CHAR a ] LITERAL [ CHAR z ] LITERAL BETWEEN
	    IF 
	       [ CHAR A CHAR a - ] LITERAL OVER +!  // no underflow possible
	    ENDIF 
	    1+
	THEN NEXT DROP ; 2 0 #PARMS 	

: $>LOWER	(( str len -- ))
	FOR AFT 
	    DUP C@  [ CHAR A ] LITERAL [ CHAR Z ] LITERAL BETWEEN
	    IF 
	       [ CHAR a CHAR A - ] LITERAL OVER +!  // no overflow possible
	    ENDIF
	    1+
	THEN NEXT DROP ; 2 0 #PARMS 	

: $FLOAD        (( str len -- ))
        FILENAMES @ IF
          CURRENT @ -ROT ALSO FILES DEFINITIONS
	  RP@ DUP 2SWAP ROT OVER - 
	  NEGATE ALIGNED NEGATE RP!	// allocate temporary space on RStack
	  TUCK RP@ SWAP CMOVE
          RP@ SWAP 2DUP $>UPPER
	  2DUP "HEADER OVERT $C3 C,
	  PREVIOUS 2SWAP SWAP CURRENT ! >R
	  $FLOAD R> RP!			// free RStack by 'len' bytes
        ELSE
          $FLOAD
	ENDIF
	ENDOF$FLOAD ; 2 0 #PARMS INVISIBLE

: FLOAD         (( -- ; <string> ))
        RP@ TOKEN COUNT 
	RP@ OVER - 8 -	// save space for PACK$ 's trailing zeros.
	NEGATE ALIGNED NEGATE RP!	// allocate string space on RStack
	RP@ PACK$ SWAP >R
	COUNT $FLOAD
	R> RP! (( free RStack )) ; 0 0 #PARMS

: NEEDS         (( -- ; <string> ))
        RP@ TOKEN COUNT TUCK RP@ OVER - 8 -
	NEGATE ALIGNED NEGATE RP!
	RP@ PACK$ 1+ SWAP $>UPPER
	>R 
        RP@ CELL+  ['] FILES >BODY @  (VOC-FIND) IF
           DROP
        ELSE
           COUNT $FLOAD
        ENDIF
	R> RP! ; 0 0 #PARMS

// ***********************    Multasking facilities     **********************

CR .( Loading multasking facilities MULTASK.4TH ...)
FLOAD MULTASK.4TH
.( ... ok)

// *********************     Program tracing tool       ********************

CR .( Loading Program Tracing Tool : TRACER.4TH ...)
FLOAD TRACER.4TH
.( ... ok)

// ***************          Stack expression words         *****************

CR .( Loading Stack Expression : StkExpr.4TH ...)
FLOAD StkExpr.4TH
.( ... ok)

// *********************      New compiling words      *********************

: $"    ( -- ; <string> )       // 01/12/'97
        STATE @ IF
           \ $"
        ELSE                    
           HERE $,"
        ENDIF   ; IMMEDIATE  // A state-smart word which stack effect are not 
                             // the same in compiling time or in interpreting 
                             // time . So no '#PARMS' could be defined.

: Z$"   ( -- ; <string> )       // 01/12/'97
        STATE @ IF
           \ Z$"
        ELSE
	   HERE $," 0 C,
        ENDIF   ; IMMEDIATE

: "     ( -- ; <string> )       // 01/12/'97
        STATE @ IF
	   \ "  
        ELSE
           HERE $," COUNT
        ENDIF   ; IMMEDIATE

: ASCII         (( -- ))
        CHAR STATE @ IF \ LITERAL ENDIF ; IMMEDIATE 0 0 #PARMS

BUG-WARNING OFF

// *************      CASE ... OF ... ENDOF ... ENDCASE     ****************

CR .( Loading CASE.4TH ...)
FLOAD CASE.4TH
.( ... ok)

FORTH DEFINITIONS

// **********************     System image saving    ************************

: HERROR$       (( err-code -- str len ))
        CASE
	   $01 OF " Invalid mode"	     ENDOF
           $02 OF " File not found"          ENDOF
           $03 OF " Path not found"          ENDOF
           $04 OF " Not enough file handles" ENDOF
           $05 OF " Access denied"           ENDOF
           $06 OF " Invalid handle"          ENDOF
           $0C OF " Invalid access code"     ENDOF
           // DPMI error codes : 07/14/'96 added
           $8001 OF " Unsupported function"        ENDOF
           $8002 OF " Invalid state"               ENDOF
           $8003 OF " System integrity"            ENDOF
           $8004 OF " Dead lock"                   ENDOF
           $8005 OF " Request cancelled"           ENDOF
           $8010 OF " Resource Unavailable"        ENDOF
           $8011 OF " Descriptor unavailable"      ENDOF
           $8012 OF " Linear memory unavailable"   ENDOF
           $8013 OF " Physical memory unavailable" ENDOF
           $8014 OF " Backing store unavailable"   ENDOF
           $8015 OF " Callback unavailable"        ENDOF
           $8016 OF " Handle unavailable"          ENDOF
           $8017 OF " Lock count exceeded"         ENDOF
           $8018 OF " Resource owned exclusively"  ENDOF
           $8019 OF " Resource owned shared"       ENDOF
           $8021 OF " Invalid value"               ENDOF
           $8022 OF " Invalid selector"            ENDOF
           $8023 OF " Invalid handle"              ENDOF
           $8024 OF " Invalid callback"            ENDOF
           $8025 OF " Invalid linear address"      ENDOF
           $8026 OF " Invalid request"             ENDOF
        ENDCASE ; 1 2 #PARMS

CR .( Loading FSAVE.4TH ...)
FLOAD FSAVE.4TH
.( ... ok)

// ***************        Miscellaneous alias words       ******************

FORTH DEFINITIONS

' CELL*         ALIAS CELLS
' OVERT         ALIAS REVEAL
' CP            ALIAS DP
' @EXECUTE      ALIAS PERFORM
' @             ALIAS HEAD>
' IF            ALIAS ?{
' ELSE          ALIAS }{
' ENDIF         ALIAS }?

// ********************       FORGET and WORDS       ************************

STACK-EXPRESSION ALSO HIDDEN DEFINITIONS

VARIABLE TOTAL-WORDS    // for WORDS
VARIABLE FENCE          // for (FORGET)

: HashTable?    (( ha -- T/F ))
    // check whether the head is a vocabulary hash table
        >R FALSE VOC-LINK @ BEGIN
          DUP @ R@ = IF
            SWAP DROP TRUE DUP -ROT
          ELSE
            CELL+ @ DUP 0 =
          ENDIF
        UNTIL RDROP DROP ; 1 1 #PARMS

: Vocabulary? (( ha -- T/F ))
    // check whether the head belongs to a vocabulary
        DUP HEAD> >BODY @ |HASHTABLE| + = ; 1 1 #PARMS

: Search-Thread  (( ha hashtab ^link -- last-^link T/F ))
        SWAP >R                         (( ha ^link ;R: hashtab ))
        BEGIN
            SWAP OVER
            @ DUP 0= IF  RDROP NIP EXIT  ENDIF
            R@ +                        (( ^link ha ha' ;R: hashtab ))
        2DUP <> WHILE
            |LINK ROT DROP
        REPEAT                          (( ^link ha ha' ;R: hashtab ))
        RDROP 2DROP TRUE  ; 3 2 #PARMS

: TRIM-ENTRY    (( ha -- ha ))
        // trim a head off
        DUP |NAME-STRING HASH CELL*                                 (( ha off ))
        VOC-LINK @                                            (( ha off vbody ))
        BEGIN
           >R 2DUP OVER SWAP R@ @ SWAP OVER +       (( ha off ha ha tab ^link ))
           Search-Thread IF                                (( ha off ha ^link ))
              SWAP |LINK @ SWAP ! FALSE   // skip this entry
           ELSE
              2DROP TRUE
           ENDIF        (( ha off T/F ))
        WHILE
           R> CELL+ @                                         (( ha off vbody ))
           DUP 0=  ABORT"  Vocabulary corrupted"  // head not found
        REPEAT
        DROP RDROP  ; 1 1 #PARMS

: TRIM-VOC  (( ha -- ha )) // ha = head of vocabulary, trim off this vocabulary
        DUP @ >BODY DUP CELL+ @ VOC-LINK !
        // no need to check CURRENT since a vocabulary can't possibily inside
        // itself, except FORTH which can never be trimed.
        @ CONTEXT BEGIN
            2DUP @ = IF
               DUP CELL+ OVER OVER CURRENT SWAP - CMOVE
            ELSE
               CELL+
            ENDIF
        DUP @ 0= UNTIL 2DROP
        CONTEXT CELL+ @ 0= IF  CONTEXT @ CONTEXT CELL+ !  ENDIF ; 1 1 #PARMS

: TRIM-HEADS    (( ha -- )) // Trim off all words later than this word
        >R HP @ BEGIN   (( ha' | ha ))
           DUP HashTable? IF
             |HASHTABLE| + TRIM-VOC
           ELSE DUP Vocabulary? IF
             TRIM-VOC
           ENDIF ENDIF
           TRIM-ENTRY
           DUP |HEAD| + SWAP R@ =
        UNTIL HP ! RDROP ; 1 0 #PARMS

: invalid-ha?   (( ha -- ha T/F ))
        DUP HEAD> >HEAD OVER <> ; 1 2 #PARMS

: ((FORGET))    (( ha -- )) 
        // perform forgetting
        DUP HEAD> CELL-
        SWAP TRIM-HEADS
        CP ! ; 1 0 #PARMS

: (FORGET)      (( ha -- ))
        DUP HEAD> FENCE @ < ABORT" Below Fence "
        invalid-ha? ABORT" Invalid address to forget"
        ((FORGET)) HP @ LAST ! ; 1 0 #PARMS

' (FORGET) IS (FORGET-HP)

VARIABLE AllWords?

FORTH DEFINITIONS

: (WORDS)	(( -- ))
     CR ." [ Vocabulary : " CONTEXT @ HASHTABLE>BODY BODY> >HEAD .ID ."  ]"
     CR 0 TOTAL-WORDS !
     HP @ BEGIN                                           (( ha ))
        DUP DUP |NAME-STRING HASH CELL*                   (( ha ha off ))
        CONTEXT @ SWAP OVER +                             (( ha ha tab ^link ))
        Search-Thread NIP  IF
	   DUP |ATTRIBUTE H@ INVIS-MASK AND 0=   AllWords? @  OR
	   IF  // invisible
              DUP |NAME-LENGTH DUP C@ AT? DROP + 80 >= IF CR ENDIF
              COUNT TYPE TAB 1 TOTAL-WORDS +!      // display context[0] words
	   ENDIF	
        ENDIF
        |HEAD| +
        DUP HashTable? IF |HASHTABLE| + ENDIF
        PAUSE
     DUP HP0 = NUF? OR UNTIL DROP
     CR ." [ Total " BASE @ DECIMAL TOTAL-WORDS @ . BASE !
     ." words displayed ]" CR ; 0 0 #PARMS INVISIBLE


: WORDS         (( -- ))
	AllWords? OFF (WORDS)  ; 0 0 #PARMS
	
: ALLWORDS	(( -- ))
	AllWords? ON (WORDS)  ; 0 0 #PARMS

: FORGET        (( -- ))  // 08/18/'93 modified, works only on CURRENT
        TOKEN  CURRENT @ (VOC-FIND) DUP IF
            NIP (FORGET)
        ELSE
            DROP SPACE ASCII " EMIT COUNT TYPE ASCII " EMIT
            ."  is not in CURRENT vocabulary. " CR ABORT
        ENDIF  ; 0 0 #PARMS

: UNLOAD	(( -- )TIB: <filename> )	// 1/3/'95, 11/29/'95
        RP@ TOKEN COUNT TUCK RP@ OVER - 8 -
	NEGATE ALIGNED NEGATE RP!
	RP@ PACK$ 1+ SWAP $>UPPER
	>R
        RP@ CELL+  ['] FILES >BODY @  (VOC-FIND) DUP IF
	    DUP (FORGET)
	ENDIF
	2DROP
	R> RP! ; 0 0 #PARMS

: RELOAD	(( -- )TIB: <filename> ) // 1/3/'95
	>IN @ UNLOAD >IN !  NEEDS ; 0 0 #PARMS

// *****************     Special stack operation words     ******************

COMMENT:
  GCD with recurse :

: GCD-AUX  (| M N -- G |) RECURSIVE       // tail recursive
        M N MOD >> G
        G 0<> ?{ N G GCD-AUX }{ N }?  >> G ;

: GCD (| M N -- G |)
        M N < ?{ M >> G   N >> M   G >> N }?
        M N GCD-AUX >> G ;
COMMENT;

HIDDEN DEFINITIONS

: GCD (| M N -- G |)
        M N < ?{ M >> G   N >> M   G >> N }?
        BEGIN
           M N MOD >> G
        G 0<> WHILE
           N >> M   G >> N
        REPEAT
        N >> G ;

: ?No<==> (| P1 P2 T/F -- |)
        T/F IF
          ."  Invalid argument for <==> : " P1 . P2 . ."  ." CR ABORT
        ENDIF ;

FORTH DEFINITIONS

: <==> (| OFFSET SIZE | G TOTAL ^CELL DIFF -- |)        // EXCHANGE
        // a generalized ROLL, but it does not need run-time argument for
        // ROLLing, the offset and size for rolling is determined
        // at compiling time .
    OFFSET SIZE OFFSET $FF > SIZE $FF > OR SIZE OFFSET > OR ?No<==>
    SIZE 0<> ?{ // size = 0, do nothing
        OFFSET 1+ >> TOTAL
        TOTAL SIZE GCD >> G
        TOTAL SIZE - >> DIFF   DIFF 1- >> ^CELL
        TOTAL G / 1- FOR AFT
            ^CELL 0 = ?{
               $87 C, $45 C, $00 C,   // XCHG EAX,[EBP]
            }{
               $87 C, $85 C, ^CELL CELL* ,      // XCHG EAX, [EBP+^CELL*4]
            }?
            ^CELL DIFF + TOTAL MOD >> ^CELL
        THEN NEXT
        G 1- FOR AFT
             $8B C, $95 C, #I CELL* ,   // MOV  EDX, [EBP+(I-1)*4]
             OFFSET SIZE - #I 1+ + >> ^CELL
             TOTAL G / 1- FOR AFT
                 $87 C, $95 C, ^CELL CELL* , // XCHG EDX, [EBP+^CELL*4]
                 ^CELL DIFF + TOTAL MOD >> ^CELL
             THEN NEXT
             $89 C, $95 C, #I CELL* ,   // MOV  [EBP+(I-1)*4], EDX
        THEN NEXT
    }? ;

// : 2SWAP         ((| a b c d -- C D A B |)
//         // pretty looking but inefficient
//                a >> A   b >> B   c >> C   d >> D ;

: 2OVER         (( a b c d -- a b c d a b ))
        [ 3 1 ARG@ 3 1 ARG@ ] ; 4 6 #PARMS

: 2ROT          (( a b c d e f -- c d e f a b ))
        [ 5 4 <==> ] ; 6 6 #PARMS

: TEST:         (( -- ))
        >IN @ BL WORD FIND DUP IF // duplicate words will be eliminated
           DUP (FORGET)
        ENDIF
        2DROP >IN ! : ; 0 0 #PARMS

: ARRAY:        (( cell_size #cells -- )TIB: <name> -- )
        CREATE 1 1 #PARMS
           OVER , OVER * DUP  LAST @ |SIZE  !
	   HERE OVER ERASE  ALLOT
	   CASE // special case
	       1  OF  DOES> + CELL+  EXIT		   ENDOF
	       2  OF  DOES> SWAP 2* + CELL+  EXIT	   ENDOF
	       4  OF  DOES> SWAP CELL* + CELL+ EXIT	   ENDOF
  	       8  OF  DOES> SWAP CELL* 2* + CELL+ EXIT	   ENDOF
	      16  OF  DOES> SWAP CELL* CELL* + CELL+ EXIT  ENDOF
	     256  OF  DOES> SWAP 256* + CELL+ EXIT	   ENDOF
	   ENDCASE
        DOES>  (( index -- addr ))
	   TUCK @ * + CELL+ EXIT  ; 2 0 #PARMS

: <PATCH>       ( adr old-adr -- )        // patch old-adr to 'JMP adr'
	$E9 OVER C!	// laydown 'JMP'
	1+ DUP CELL+ ROT SWAP - SWAP !  ; 2 0 #PARMS INVISIBLE

: (PATCH)	( ca old-ca -- ) // modified for patching C functions
	DUP CODE>HEAD DUP 0<> IF
           |SIZE  5 SWAP !  // size became 5, the rest codes became garbage.
        ELSE
           DROP
        ENDIF
        <PATCH> ; 2 0 #PARMS INVISIBLE

: PATCH		(( ca -- )TIB: <target-name> )
        // redirect <target-name>'s code into 'ca'
	' DUP >HEAD |SIZE  @
	5 < ABORT" Target word's code size is too small (<5), can't PATCH"
	STATE @ IF
	   \ LITERAL COMPILE (PATCH)
	ELSE
	   (PATCH)
	ENDIF ; 1 0 #PARMS IMMEDIATE

// New control structure : the #REPEATS:                <New idea>
// Ex1: 
//      : TEST  10 #REPEATS: 1 2 + . ;  <enter>
//      TEST  <enter>
//      3 3 3 3 3 3 3 3 3 3 3 ok
// Ex2:
//      : TEST  #REPEATS: 2 + DUP . ; <enter>
//      10 5 TEST   <enter>
//      12 14 16 18 20 ok
//      . <enter> 
//      20 ok

: #REPEATS: (( n -- ))
     // execute the codes between '#REPEATS:' and ';' N times.
        R> SWAP
        FOR AFT
           DUP >R EXECUTE R>
        THEN NEXT DROP ; COMPILEONLY

// ********************         DO-LOOP words         ***********************
CR .( Loading DOLOOP.4TH ...)
FLOAD DOLOOP.4TH
.( ... ok)

// ***************      Short-cut boolean evaluation        *****************
CR .( Loading short-cut boolean evaluation : SHORTCUT.4TH ...)
FLOAD SHORTCUT.4TH
.( ... ok)

// **********************    Conditional Compilation    *********************

CR .( Loading conditional compilation words #IF.4TH ...)
FLOAD #IF.4TH
.( ... ok)

CR .( Loading assertion defining tool ASSERT.4TH ...)
FLOAD ASSERT.4TH
.( ... ok)

HIDDEN ALSO 

HERE FENCE !

// ****************        Command history recording        ****************
CR .( Loading line editor KEYBUF.4TH ...)
FLOAD KEYBUF.4TH
.( ... ok)

ONLY FORTH ALSO DEFINITIONS

WARNING ON              // for duplicate names
BUG-WARNING ON          // for stack expression

CR
.( -------------------  Finish loading high level words --------------------)

