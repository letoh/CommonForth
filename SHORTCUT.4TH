// Short-Cut Boolean Evaluation Control Structure
//                                    08/04/'93  Designed by : Luke Lee
//                                               Version     : 2.5
//						 Last update : 01/19/'97

//  The idea came from ADA/CS language ( a subset of ADA ),
//  the 'and then' and 'or else' for short cut boolean evaluation .

//  Syntax :
//
//     1. Full boolean evaluation :
//          A B >   C D <   AND  E F =  AND
//        Short cut boolean evaluation :
//          A B >  ANDTHEN  C D <   ANDTHEN   E F =  THEN-AND
//
//     2. Full boolean evaluation :
//          A B >   C D <   OR  E F =   OR
//        Short cut boolean evaluation :
//          A B >  ORELSE   C D <   ORELSE    E F =  ELSE-OR
//
//     3. Mixing two structure :
//         Full boolean evaluation :
//           A B AND C AND D AND   E F OR G OR    AND
//         Short cut boolean evaluation :
//           A ANDTHEN B ANDTHEN C ANDTHEN D ANDTHEN
//               E ORELSE F ORELSE G ELSE-OR
//           THEN-AND
//
//  New Syntax :                                        01/18/'97 
//   This syntax is designed for nesting short-cut boolean evaluations.
//      1. ANY{
//               <word list>  ( -- T/F1 )
//            ORELSE
//               <word list>  ( -- T/F2 )
//            ORELSE
//               <word list>  ( -- T/F3 )
//         }ANY?         ( -- T/F1 OR T/F2 OR T/F3 )
//      2. ALL{
//               <word list>  ( -- T/F1 )
//            ANDTHEN
//               <word list>  ( -- T/F2 )
//            ANDTHEN
//               <word list>  ( -- T/F3 )
//         }ALL?         ( -- T/F1 AND T/F2 AND T/F3 )

FORTH DEFINITIONS

// for compilers who are going to compile some shortcut boolean evaluations

VARIABLE ANDTHENED?	// renamed from ANDTHEN-STARTED    09/26/'95
VARIABLE ORELSEED?

HIDDEN ALSO DEFINITIONS

: (MARK-CUT)    (( -- ))
                HERE 0 rel, COMPILE DROP
                ; 0 0 #PARMS COMPILEONLY
: (ANDTHEN)     (( -- A ))
                COMPILE JT=0 (MARK-CUT)
                ; 0 1 #PARMS COMPILEONLY
: (ORELSE)      (( -- A ))
                COMPILE JT<>0 (MARK-CUT)
                ; 0 1 #PARMS COMPILEONLY
: (RESOLVE-CUT) (( A -- ))
                HERE SWAP +! ; 1 0 #PARMS COMPILEONLY

: ?MISSING-ANDTHEN (( -- ))		// 09/20/'95
	ANDTHENED? @ NOT ABORT"  Missing ANDTHEN " ; 0 0 #PARMS

: ?MISSING-ORELSE  (( -- ))		// 09/20/'95
	ORELSEED? @ NOT ABORT"  Missing ORELSE " ; 0 0 #PARMS

: ?EXPECT-THEN-AND (( #count -- #count ))
        DUP 0> ABORT"  THEN-AND expected " ; 1 1 #PARMS

: ?EXPECT-ELSE-OR  (( #count -- #count ))
        DUP 0< ABORT"  ELSE-OR expected " ; 1 1 #PARMS

FORTH DEFINITIONS

// restart ANDTHEN and restart ORELSE  . 09/22/'95 , 09/26/'95
: REANDTHEN  (( -- )) ANDTHENED? OFF ; 0 0 #PARMS IMMEDIATE
: ANDTHENED  (( -- )) ANDTHENED? ON  ; 0 0 #PARMS IMMEDIATE
: REORELSE   (( -- )) ORELSEED?  OFF ; 0 0 #PARMS IMMEDIATE
: ORELSEED   (( -- )) ORELSEED?  ON  ; 0 0 #PARMS IMMEDIATE

: ANDTHEN  // (( -- A +#count )) or (( A +#count -- A A' +#count ))
        ANDTHENED? @ IF
            (ANDTHEN) SWAP 1+
        ELSE
            \ ANDTHENED	(ANDTHEN) 1
        ENDIF  ; IMMEDIATE

: THEN-AND // (( A0 A1 A2 ... +#count -- ))
	?MISSING-ANDTHEN
        ?EXPECT-ELSE-OR         // prevent misuse of THEN-AND
        \ REANDTHEN
        0 ?DO  (RESOLVE-CUT)  LOOP  ; IMMEDIATE

: ORELSE  // (( -- A #count )) or (( A #count -- A A' #count ))
        ORELSEED? @ IF
            (ORELSE)  SWAP 1-
        ELSE
            \ ORELSEED  (ORELSE) -1
        ENDIF  ; IMMEDIATE

: ELSE-OR  // (( A0 A1 A2 ... -#count -- ))
	?MISSING-ORELSE
        ?EXPECT-THEN-AND        // prevent misuse of ELSE-OR
        \ REORELSE
        0 SWAP ?DO  (RESOLVE-CUT)  LOOP  ; IMMEDIATE

// The following are added at [01/19/'97]
// Assume that the first page [ 0..Pagesize ] bytes machine's 4G virtual address
// and the last page [ ($FFFFFFFF-Pagesize)..$FFFFFFFF ] are un-accessable.

: ALL{  ( -- andthened? )
        OPTIMIZE @ NOT IF  COMPILE nop  ENDIF   // as a marker
        ANDTHENED? @    \ REANDTHEN     ; 0 1 #PARMS IMMEDIATE

: }ALL? ( andthened? A0 A1 A2 ... +#count  -- )
        ANDTHENED? @ IF  \ THEN-AND  ENDIF  ANDTHENED? ! ; IMMEDIATE
' ALL{  ALIAS ALL
' }ALL? ALIAS ALL?

: ANY{  ( -- orelseed? )        // since -1 is used as TRUE
        OPTIMIZE @ NOT IF  COMPILE nop  ENDIF   // as a marker
        ORELSEED? @     \ REORELSE      ; 0 1 #PARMS IMMEDIATE

: }ANY? ( orelseed? A0 A1 A2 ... -#count -- )
        ORELSEED? @ IF  \ ELSE-OR  ENDIF  ORELSEED? !  ; IMMEDIATE
' ANY{   ALIAS ANY
' }ANY?  ALIAS ANY?

: :     \ REANDTHEN \ REORELSE	
	:       ; 0 0 #PARMS

ONLY FORTH ALSO DEFINITIONS

COMMENT: ------------------ Test program -----------------------

: .ANDTHEN      ." ANDTHEN " ;
: .ORELSE       ." ORELSE " ;
: ANDTHEN       COMPILE .ANDTHEN \ ANDTHEN ; IMMEDIATE
: ORELSE        COMPILE .ORELSE  \ ORELSE ; IMMEDIATE

: .T/F  (( T/F -- ))
        IF ."  TRUE " ELSE ."  FALSE " ENDIF ;
: =.T/F (( T/F -- ))
        ." =" .T/F ;

: .THEN-AND     ."  THEN-AND " ;
: .ELSE-OR      ."  ELSE-OR " ;
: THEN-AND      \ THEN-AND COMPILE .THEN-AND ; IMMEDIATE
: ELSE-OR       \ ELSE-OR  COMPILE .ELSE-OR ; IMMEDIATE

: .ALL{         ." ALL{ " ;
: .}ALL?        ." }ALL? " ;
: ALL{          \ ALL{  COMPILE .ALL{  ; IMMEDIATE
: }ALL?         \ }ALL? COMPILE .}ALL? ; IMMEDIATE
: .ANY{         ." ANY{ " ;
: .}ANY?        ." }ANY? " ;
: ANY{          \ ANY{  COMPILE .ANY{  ; IMMEDIATE
: }ANY?         \ }ANY? COMPILE .}ANY? ; IMMEDIATE

: TT   TRUE  DUP .T/F ;
: FF   FALSE DUP .T/F ;

: TEST1
        TT ANDTHEN TT ANDTHEN TT ANDTHEN FF ANDTHEN TT THEN-AND =.T/F ;
: TEST2
        TT ANDTHEN FF ANDTHEN TT ANDTHEN FF THEN-AND =.T/F ;
: TEST3
        FF ANDTHEN TT ANDTHEN TT ANDTHEN TT THEN-AND =.T/F ;
: TEST4 
        TT ANDTHEN TT ANDTHEN TT ANDTHEN TT ANDTHEN TT THEN-AND =.T/F ;
: TEST5
        FF ORELSE FF ORELSE FF ORELSE TT ORELSE TT ELSE-OR =.T/F ;
: TEST6
        FF ORELSE TT ORELSE TT ORELSE FF ELSE-OR =.T/F ;
: TEST7
        TT ORELSE FF ORELSE FF ORELSE FF ELSE-OR =.T/F ;
: TEST8
        FF ORELSE FF ORELSE FF ORELSE FF ORELSE FF ELSE-OR =.T/F ;

: TEST9
        TT ANDTHEN TT ANDTHEN TT ANDTHEN
        FF ORELSE FF ORELSE TT ORELSE FF ELSE-OR  ANDTHEN FF THEN-AND =.T/F ;

: TEST10
        ALL{
             TT ANDTHEN 
             TT ANDTHEN CR
             ANY{
                 FF ORELSE
                 FF ORELSE
                 TT ORELSE
                 TT ORELSE
                 TT ORELSE
                 TT
             }ANY?      CR
             ANDTHEN
             FF
             ANDTHEN
             TT
             ANDTHEN
             FF
        }ALL?   =.T/F ;
: TEST11
        ALL{
                TT ANDTHEN
                TT ANDTHEN CR
                ALL{
                        TT ANDTHEN
                        TT ANDTHEN
                        TT
                }ALL?   CR
                ANDTHEN
                FF
        }ALL?   =.T/F ;

CR .( ----- Testing ANDTHEN ----- ) CR
1 . TEST1 CR 2 . TEST2 CR 3 . TEST3 CR 4 . TEST4 CR 
.( ----- Testing ORELSE -----) CR
1 . TEST5 CR 2 . TEST6 CR 3 . TEST7 CR 4 . TEST8 CR 
.( ----- Mixing Testing -----) CR
TEST9 CR
.( ----- Other testings -----) CR
.( TEST10 : ) TEST10 CR
.( TEST11 : ) TEST11 CR

FORGET .ANDTHEN

COMMENT;

