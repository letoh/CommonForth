// FIBONACCI sequence demonstration

CREATE FIBs
   50 CELL* ALLOT

: [] (( BASE INDEX -- ADDR ))
   CELL* + ; 2 1 #PARMS

: FIBONACCI (| N -- F |) RECURSIVE
    N 0 = IF
      0 >> F
    ELSE N 1 = IF
      1 >> F
    ELSE 
      N 2 - FIBONACCI   N 1- FIBONACCI  +   >> F
    ENDIF ENDIF ;

: FIB (| N -- |)
   N 46 > IF
      CR ." * Input integer too large ( > 46 ) !" CR 
   ELSE
      CR ." * Non recursive : FIBONACCI(" N 0 .R ." ) = "
      0 FIBs !
      1 FIBs CELL+ !
      N 1+ 2 ?DO
         FIBs #I 2 - [] @   FIBs #I 1- [] @    +    FIBs #I []  !
      LOOP
      FIBs N [] @ .
      CR ." * Recursive : FIBONACCI(" N 0 .R ." ) = "
      N FIBONACCI .
   ENDIF ;

// 10/21/'95

: .FIBSEQ	(( -- )) // display Fibonacci sequence
      CR 0 DUP 16 U.R 1 DUP 16 U.R
      BEGIN
	 TUCK + DUP 16 U.R
         2DUP U>
      UNTIL 2DROP CR ;
