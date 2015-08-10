// Conditional Compilation for Common Forth

        // Written by     : Luke Lee
        // Version        : 1.3
        // Update history : 05/04/'95 .. 05/06/'95 finished v1.0
	//		    01/04/'96 .. fix bug in #UNDEFINE
	//		    01/28/'96 .. Modify #EXISTED, retrieve out 
        //                               another word EXISTED? ;
        //                  05/09/'96 .. Fix bug in PUSH'EVAL and POP'EVAL
        //                               that make 'EVAL-STACK underflows 
        //                               and overwrites RESET-#IF-SYSTEM's
        //                               >HEAD pointer .

COMMENT:
    1. #UNDEFINE : modify a symbol's name to make it un-searchable.
    2. #IF  ...  #ELSE  ...  #ENDIF
    3. #DEFINED  :  defined in CONTEXT ?
    4. #NOTDEFINED : not defined in CONTEXT ?
    5. #EXISTED  :  exist in any vocabulary ?
    6. There is no '#DEFINE' since colon DEFINitions are defining words.

    Examples 
      EX1 :  
        : SYMBOL1 ;
        #DEFINED SYMBOL1   #DEFINED SYMBOL2  AND  #IF
             .( SYMBOL1 and SYMBOL2 Both exists )
        #ELSE
             .( Either SYMBOL1 or SYMBOL2 not defined )
        #ENDIF
        #UNDEFINE SYMBOL1
      EX2 :
        : Speed-Oriented-Word
          [ 386? ] #IF
             386-CODES
          #ELSE [ 486? ] #IF
             486-OPTIMIZED-CODES
          #ENDIF #ENDIF  ;
COMMENT;

ONLY FORTH ALSO DEFINITIONS

HIDDEN ALSO DEFINITIONS

CREATE ChkExistName |HEAD| ALLOT
BINARY
01010101 CONSTANT #MAGIC#DEFINE#
DECIMAL

FORTH DEFINITIONS

// The following 2 word will be patched later
: #ELSE        (( T/F#IF -- T/F#IF ))   NOOP    ; 1 1 #PARMS IMMEDIATE
: #ENDIF        (( T/F#IF -- ))         NOOP    ; 1 0 #PARMS IMMEDIATE

: #UNDEFINE    (( -- )) // Make this head an garbage.
        ' >NAME COUNT FOR
            DUP C@               // Make searching fail by XOR 01010101(2)
            #MAGIC#DEFINE# XOR OVER C!
            1+    
        NEXT DROP ; 0 0 #PARMS IMMEDIATE
        
: #DEFINED      (( -- T/F )) // if it is defined in CONTEXTs 
        TOKEN FIND NIP 0<>  ; 0 1 #PARMS IMMEDIATE

: #NOTDEFINED	(( -- T/F ))
	\ #DEFINED NOT ; 0 1 #PARMS IMMEDIATE

: EXISTED?	(( name len -- ca/0 ))
	ChkExistName |HEAD| 0 FILL
	DUP ChkExistName C! ChkExistName 1+ SWAP MOVE
	ChkExistName DUP 1+ HASH VOC-LINK @
        BEGIN (( stradr key vlink ))
            >R R@ @ (FIND) 0=  		// str_adr ca ha=0 | str_adr key F=0
            WHILE (( stradr key ))
                R> CELL+ @ DUP 0=
        UNTIL (( stradr key 0 ))
                NIP  (( stradr 0 ))
	    ELSE  (( stradr ca ))
	     	RDROP
            THEN  
	NIP ; 2 1 #PARMS

: #EXISTED      (( -- T/F )) // if it is defined in any vocabulary
        TOKEN COUNT EXISTED? 0<> ; 0 1 #PARMS IMMEDIATE

HIDDEN DEFINITIONS

$1F000000 CONSTANT #IF-MARK
$00FFFFFF CONSTANT #CondMask
0         VALUE    SkipNest#IF

0 CONSTANT 'EVAL-STACK-BOTTOM   // value modified later

CREATE 'EVAL-STACK-TOP    64 CELLS HERE OVER 0 FILL ALLOT    
HERE => 'EVAL-STACK-BOTTOM      0 , 0 ,  // 05/09/'96

'EVAL-STACK-BOTTOM VALUE 'EVALSTK^      // stack pointer

: RESET-#IF-SYSTEM     'EVAL-STACK-BOTTOM => 'EVALSTK^ 
                       0 => SkipNest#IF ; 
: ?RESET-#IF-SYSTEM DUP IF RESET-#IF-SYSTEM ENDIF ;

: ?ABORT-COND"  (( T/F -- ))
        COMPILE ?RESET-#IF-SYSTEM  \ ABORT" ; IMMEDIATE

: PUSH'EVAL     (( -- ))
        'EVALSTK^ CELL- 
        DUP 'EVAL-STACK-TOP < ABORT" PUSH:This should never happen !"
        DUP 'EVAL-STACK-TOP = ?ABORT-COND" 'EVAL stack overflow"
        => 'EVALSTK^ 
        'EVAL @ 'EVALSTK^ !  
        ; 0 0 #PARMS

: POP'EVAL      (( -- ))
        'EVALSTK^ 'EVAL-STACK-BOTTOM > ABORT" POP:This should never happen !"
        'EVALSTK^ 'EVAL-STACK-BOTTOM = ?ABORT-COND" 'EVAL stack underflow"
        'EVALSTK^ @ 'EVAL !
        'EVALSTK^ CELL+ => 'EVALSTK^
        ; 0 0 #PARMS

: SetInterp     INTERPRETER 'EVAL ! RESET-#IF-SYSTEM ; 0 0 #PARMS

VOCABULARY (VALID-WORDS)
(VALID-WORDS) DEFINITIONS

: #IF   (( -- )) 
        SkipNest#IF 1+ => SkipNest#IF ; 1 0 #PARMS

: #ELSE (( -- ) T/F#IF -- ) 
        SkipNest#IF 0= IF 
            POP'EVAL \ #ELSE // execute '#ELSE' in FORTH vocabulary
        ENDIF ; 

: #ENDIF (( -- ) T/F#IF -- ) 
        SkipNest#IF 0= IF
            POP'EVAL \ #ENDIF // execute '#ENDIF' in FORTH vocabulary
        ELSE
            SkipNest#IF 1- => SkipNest#IF
        ENDIF ;

// Import from FORTH vocabulary for comments :

' COMMENT:   ALIAS   COMMENT:
' ((         ALIAS   ((      
' //         ALIAS   //      

ONLY FORTH ALSO HIDDEN ALSO DEFINITIONS

: #SkipSource  (( A -- ) T/F#IF A -- )
        // Search only (VALID-WORDS) vocabulary and executes them
        DUP 1+ HASH  ['] (VALID-WORDS) >BODY @  (FIND)
        0<> IF // ( T/F#IF ) A ca
            NIP EXECUTE // Execute (VALID-WORDS) only
        ELSE   // A key
            2DROP // ignore them if it is not in (VALID-WORDS)
        ENDIF ; 

: Chk#Cond      (( T/F#IF str len -- ))
        DEPTH 3 < IF 
           CR 2DUP TYPE ."  error : No condition for " TYPE 
           CR SetInterp ABORT
        ENDIF
        ROT 
        #CondMask NOT AND #IF-MARK <> IF 
            CR TYPE ."  : Not matched #IF...#ELSE...#ENDIF" 
            CR SetInterp ABORT 
        ENDIF 2DROP ; 3 0 #PARMS

: (#ELSE)        (( T/F#IF -- T/F#IF ))
        DUP >R " #ELSE" Chk#Cond R>
        DUP #CondMask AND 0<> IF
            PUSH'EVAL
            ['] #SkipSource 'EVAL !
        ENDIF ; 1 1 #PARMS
        
: (#ENDIF)        (( T/F#IF -- ))
        " #ENDIF" Chk#Cond ; 1 0 #PARMS

FORTH DEFINITIONS

' (#ELSE)  PATCH #ELSE
' (#ENDIF) PATCH #ENDIF

: #IF          (( T/F -- T/F#IF ))
        DEPTH 0= IF 
            CR ." * #IF : No condition for #IF" CR SetInterp ABORT
        ENDIF
        DUP NOT IF
            PUSH'EVAL
            ['] #SkipSource 'EVAL !
        ENDIF 
        #CondMask AND #IF-MARK OR ; 1 1 #PARMS IMMEDIATE

ONLY FORTH ALSO DEFINITIONS

