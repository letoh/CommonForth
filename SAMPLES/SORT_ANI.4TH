// Multasking EXAMPLEs

NEEDS 387FLOAT.4TH
NEEDS GRAPHICS.4TH

GRAPHICS ALSO FORTH DEFINITIONS

// Problem 28 :

GRAPHICS-MODE

VARIABLE CurrDateTime

: ShowTime  (| -- |)
	GraphicsMode? IF
	   MULTI?  SINGLE AT?  GGetTextColor 
	   54 0 AT G_WHITE G_BLUE GSetTextColor
	   time( NULL ) to CurrDateTime
	   ctime( CurrDateTime ) 25 TYPE
	   GSetTextColor  AT  IF  MULTI  ENDIF
	ENDIF ;

BACKGROUND: TEXTCLOCK
	BEGIN
	   16 TICKS  ShowTime
	AGAIN ; 

TEXTCLOCK WAKE

// //////////////////////////////////////////////////////////////////////////
// Sorting Animation Again

30 VALUE DELAYCOUNT

GMaxY 40 -   CONSTANT YRange
GSizeX 2/ 1- CONSTANT XRange

0 	  VALUE QX0	0 VALUE QY0
XRange 1+ VALUE SX0	0 VALUE SY0

// General Routines  -------------------------------------------------
: DELAY  (| -- |)  DELAYCOUNT FOR PAUSE NEXT ;

: WipeEntry     (( x y x0 y0 -- ))
        DELAY
	2SWAP YRange SWAP - SWAP 1+ SWAP 
	ROT + -ROT + SWAP G_BLACK GDrawCPoint ; 4 0 #PARMS

: DrawEntry     (( x y x0 y0 -- ))
	2SWAP YRange SWAP - SWAP 1+ SWAP
	ROT + -ROT + SWAP G_YELLOW GDrawCPoint ; 4 0 #PARMS

: DrawAxis      (| x0 y0 -- |)
        x0 0 x0 YRange G_WHITE GDrawCLine
	x0  YRange 1+  x0 XRange +  YRange 1+  G_WHITE GDrawCLine ;
// Sortions : -------------------------------------------------------
// ////////////// //
// 1. Quick Sort  //
// ////////////// //

CELL GSizeX  ARRAY:  []QSortEntry
0 VALUE QStartTime
0 VALUE QEndTime

: QWipe (( index -- )) 
	DUP []QSortEntry @ QX0 QY0 WipeEntry ; 1 0 #PARMS
: QDraw (( index -- ))
	DUP []QSortEntry @ QX0 QY0 DrawEntry ; 1 0 #PARMS
: QExchange     (( i j -- ))
        2DUP QWipe QWipe
        2DUP []QSortEntry SWAP []QSortEntry 2DUP @ SWAP @ ROT ! SWAP !
        QDraw QDraw ; 2 0 #PARMS

: (QuickSort)   (| left right | i j pivot -- |)   RECURSIVE
        right left > IF
           right []QSortEntry @  to  pivot
           left 1- to i     right to j
           BEGIN
              BEGIN   i 1+ to i    i []QSortEntry @  pivot  >=   UNTIL
              BEGIN   j 1- to j    j []QSortEntry @  pivot  <=   UNTIL
           i j < WHILE
              i j QExchange PAUSE
           REPEAT
           i right QExchange PAUSE
           left   i 1-   (QuickSort)
           i 1+   right  (QuickSort)
        ENDIF ;

: QCheckResult  (( left right -- ))
        SWAP ?DO
            #I []QSortEntry @  #I 1+ []QSortEntry @  >
            IF CR ." ** Quick Sort failed " CR ABORT ENDIF
        LOOP ; 2 0 #PARMS

: QuickSort     (| left right -- |)
        left right (QuickSort)
        left right QCheckResult ;

: QSortInit     (| -- |)
        QX0 QY0 DrawAxis
        XRange 0 ?DO
           rand( ); YRange MOD     #I []QSortEntry   !    #I QDraw
        LOOP ;

// /////////////////////// //
// 2. Straight Radix Sort  //
// /////////////////////// //

CELL GSizeX  ARRAY:  []SSortEntry
CELL GSizeX  ARRAY:  []SSortBuffer
0 VALUE SStartTime
0 VALUE SEndTime

: SWipe (( index -- ))    
	DUP []SSortEntry @ SX0 SY0 WipeEntry ; 1 0 #PARMS
: SDraw (( index -- ))    
	DUP []SSortEntry @ SX0 SY0 DrawEntry ; 1 0 #PARMS

: SSortInit     (| -- |)
        SX0 SY0 DrawAxis
        XRange 0 ?DO
           rand( ); YRange MOD     #I []SSortEntry   !    #I SDraw
        LOOP ;

: SSortInit2	(| unsorted -- |)
	SX0 SY0 DrawAxis
	unsorted  0 []SSortEntry  SIZEOF []SSortEntry LITERAL  MOVE
	XRange 0 ?DO  #I SDraw  LOOP ;

: SCheckResult  (( left right -- ))
        SWAP ?DO
            #I []SSortEntry @  #I 1+ []SSortEntry @  >
            IF CR ." ** Straight Radix Sort failed " CR ABORT ENDIF
        LOOP ; 2 0 #PARMS

: POWER2   (( n -- 2^n ))       1 SWAP 0 ?DO 2* LOOP ;
// ///////////////////////////////////////////// //
 6  CONSTANT  mm       mm POWER2  CONSTANT  MM
// ///////////////////////////////////////////// //
CELL MM ARRAY: []count

: bits  (( key start bitnum -- x ))
     // mask out 'key', from 'start', 'bitnum' bits
        FOR -1 AFT 2* THEN NEXT NOT -ROT
        FOR AFT 2/ THEN NEXT  AND  ; 3 1 #PARMS

: (StraightRadixSort)     (| #items | pass index -- |)
        [ CELL 8 * mm / 1- ] LITERAL 0 ?DO
            #I to pass
            MM FOR AFT  #I []count OFF  THEN NEXT
           // Distribution counting
            #items 1+  0  DO
               #I []SSortEntry @   pass mm *   mm   bits
               []count  1 SWAP +!
            LOOP
            MM 1 DO   #I 1- []count @    #I []count   +!   LOOP
            #items FOR
                  #I []SSortEntry @   pass mm *   mm  bits  []count
                  -1 OVER +!  @ to index
                  #I []SSortEntry @  index []SSortBuffer   !
                  #I SWipe   index  index []SSortBuffer @  SX0 SY0 DrawEntry
		  PAUSE
            NEXT
            #items FOR
               #I []SSortBuffer @    #I []SSortEntry    !
            NEXT
	    PAUSE
        LOOP  ;

: StraightRadixSort	(| -- |)
	XRange (StraightRadixSort)
        0 XRange SCheckResult ;

// Two task for sorting animation :

BACKGROUND: QuickSortAni
	BEGIN
	   clock to QStartTime  
	   0 XRange QuickSort
	   clock to QEndTime
	   SELF-SLEEP
	AGAIN ;

BACKGROUND: StraightRadixSortAni
	BEGIN
	   clock to SStartTime
	   StraightRadixSort
	   clock to SEndTime
	   SELF-SLEEP
	AGAIN  ;

: ANIMATION	(( -- ))
	QSortInit
	0 []QSortEntry  SSortInit2
	QuickSortAni WAKE
	StraightRadixSortAni WAKE MULTI
	BEGIN
	   PAUSE
	   QuickSortAni TASK-STATE? TASK-ASLEEP = ANDTHEN
	   StraightRadixSortAni TASK-STATE? TASK-ASLEEP = THEN-AND
	NUF? OR UNTIL
	CR ." * Quick sort elapsed time = " 
	QEndTime QStartTime - S>F CLOCKS_PER_SEC S>F F/ 2 4 F.R ." seconds."
	CR ." * Straight radix sort elapsed time = " 
	SEndTime SStartTime - S>F CLOCKS_PER_SEC S>F F/ 2 4 F.R
	." seconds." CR ;

// //////////////////////////////////////////////////////////////////////////
// Modify  'ShowText'  for background printing.

0 VALUE HndToPrint
0 VALUE HndPrinter

32 CONSTANT |BUFSIZ|	// four bytes at a time
CREATE ReadBuffer |BUFSIZ| ALLOT

: FailReadingMessage	(( err-code -- ))
	SINGLE CR BEEP ." *** Message from PRINT-TASK : " CR
     	."  Error reading file , error message : " HERROR$ (( err -- str len ))
     	TYPE CR
	MULTI ;
: FailWritingMessage
	SINGLE CR BEEP ." *** Message from PRINT-TASK : " CR
     	."  Error writing printer , error message : " HERROR$
     	TYPE CR
	MULTI ;

BACKGROUND: PRINT-TASK
    BEGIN
     	BEGIN
     	   ReadBuffer |BUFSIZ| HndToPrint HREAD // Rbytes T | Rerrcode F
     	   WHILE			// Rbytes
     	      ReadBuffer OVER 		// Rbytes buffer Rbytes
	      HndPrinter HWRITE 	// Rbytes Wbytes T | Werrcode F
	      500 MS			// 0.5 second delay
	      WHILE			// Rbytes Wbytes
		 DROP
     	         |BUFSIZ| < 		// T/F
     	UNTIL			    	// <empty>
	      ELSE			// Rbytes Werrcode
		 NIP FailWritingMessage
	      THEN
     	   ELSE			    	// Rerrcode
	      FailReadingMessage
     	   THEN
     	HndToPrint HCLOSE DROP   HndPrinter HCLOSE DROP
	SELF-SLEEP
    AGAIN ;

: PRINT    (( -- )TIB: <filename> )
	PRINT-TASK TASK-STATE? TASK-AWAKE = IF
	   BL WORD DROP ." * Printer is busy now ." EXIT
	ENDIF
	BL WORD COUNT READ/ONLY OPEN IF
	   to HndToPrint
	   " PRN" WRITE/ONLY OPEN IF
	      to HndPrinter 
	      PRINT-TASK WAKE		// wake up printing task .
	   ELSE
	      HndToPrint HCLOSE DROP
	      ." * Fail openning printer device at PRN: " HERROR$ TYPE CR
	   ENDIF
     	ELSE
     	   ." * Fail openning file " HERE COUNT TYPE 
	   ." : " HERROR$ TYPE CR
     	ENDIF ; 0 0 #PARMS

CR .( * Type ANIMATION for sorting animation. ) 
CR .( * Type PRINT <FILENAME> for background printing. )
CR
