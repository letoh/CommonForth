// Short-Cut Boolean Evaluation Control Structure
//                                    08/04/'93  Designed by : Luke Lee
//                                               Version     : 2.1
//						 Last update : 09/26/'95

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
: (RESLOVE-CUT) (( A -- ))
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
        0 ?DO  (RESLOVE-CUT)  LOOP  ; IMMEDIATE

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
        0 SWAP ?DO  (RESLOVE-CUT)  LOOP  ; IMMEDIATE

: :     \ REANDTHEN \ REORELSE	
	:       ; 0 0 #PARMS

ONLY FORTH ALSO DEFINITIONS

COMMENT: ------------------ Test program -----------------------

: .ANDTHEN      ." ANDTHEN" ;
: .ORELSE       ." ORELSE" ;
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

CR .( ----- Testing ANDTHEN ----- ) CR
1 . TEST1 CR 2 . TEST2 CR 3 . TEST3 CR 4 . TEST4 CR 
.( ----- Testing ORELSE -----) CR
1 . TEST5 CR 2 . TEST6 CR 3 . TEST7 CR 4 . TEST8 CR 
.( ----- Mixing Testing -----) CR
TEST9

FORGET .ANDTHEN

COMMENT;
