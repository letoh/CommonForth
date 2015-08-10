// Sorting Animation                            Written by : Luke Lee
                                                // 11/13/'95 implemented.
                                                // 12/30/'95 to GRAPHICS.4TH

NEEDS GRAPHICS.4TH
GRAPHICS-MODE

50   VALUE    DELAYCOUNT

GMaxY 40 -  CONSTANT YRange
GMaxX 1-    CONSTANT XRange

// General Routines  -------------------------------------------------

: DELAY         (| -- |)
        DELAYCOUNT FOR PAUSE NEXT NUF? DROP ;

: WipeEntry     (| x y -- |)
        DELAY  x 1+  YRange y -  G_BLACK  GDrawCPoint ;

: DrawEntry     (| x y -- |)
        x 1+  YRange y -  G_YELLOW  GDrawCPoint ;

: DrawAxis      (| -- |)
        0  0  0  YRange  G_WHITE GDrawCLine 
        0  YRange 1+  GMaxX  YRange 1+  G_WHITE GDrawCLine ;


// Sortions : -------------------------------------------------------

// ////////////// //
// 1. Quick Sort  //
// ////////////// //

CELL GSizeX  ARRAY:  []QSortEntry

: QWipe (( index -- ))    DUP []QSortEntry @ WipeEntry ; 1 0 #PARMS
: QDraw (( index -- ))    DUP []QSortEntry @ DrawEntry ; 1 0 #PARMS

: QExchange     (( i j -- ))
        2DUP QWipe QWipe
        2DUP []QSortEntry SWAP []QSortEntry 2DUP @ SWAP @ ROT ! SWAP !
        QDraw QDraw ; 2 0 #PARMS

0 VALUE MaxDepth

: (QuickSort)   (| left right | i j pivot -- |)   RECURSIVE
        MaxDepth DEPTH MAX to MaxDepth
        right left > IF
           right []QSortEntry @  to  pivot
           left 1- to i     right to j
           BEGIN
              BEGIN   i 1+ to i    i []QSortEntry @  pivot  >=   UNTIL
              BEGIN   j 1- to j    j []QSortEntry @  pivot  <=   UNTIL
           i j < WHILE
              i j QExchange
           REPEAT
           i right QExchange
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
        DrawAxis
        GSizeX 0 ?DO
           random YRange MOD     #I []QSortEntry   !    #I QDraw
        LOOP ;

: .QEntries     (( left right -- ))
        CR
        1+ SWAP ?DO
           #I []QSortEntry @ . TAB
        LOOP CR ; 2 0 #PARMS

: .QuickSort    (| -- |)
        GScrolling @ GScrolling OFF
        QSortInit
        ." *** Initial : " 0 GMaxX .QEntries
        0 GMaxX QuickSort
        CR ." *** Press any key to see result :" KEY DROP
        ." *** Result : "  0 GMaxX .QEntries
        GScrolling ! ;

: QuickSortAni  (| -- |)
        CLS
        QSortInit
        0 28 AT ." * Press any key to start ..." KEY DROP
        0 28 AT ." * Press any key to pause ..."
        0 GMaxX QuickSort ;

// /////////////////////// //
// 2. Straight Radix Sort  //
// /////////////////////// //

CELL GSizeX  ARRAY:  []SSortEntry
CELL GSizeX  ARRAY:  []SSortBuffer

: SWipe (( index -- ))    DUP []SSortEntry @ WipeEntry ; 1 0 #PARMS
: SDraw (( index -- ))    DUP []SSortEntry @ DrawEntry ; 1 0 #PARMS

: SSortInit     (| -- |)
        DrawAxis
        GSizeX 0 ?DO
           random YRange MOD     #I []SSortEntry   !    #I SDraw
        LOOP ;

: SCheckResult  (( left right -- ))
        SWAP ?DO
            #I []SSortEntry @  #I 1+ []SSortEntry @  >
            IF CR ." ** Straight Radix Sort failed " CR ABORT ENDIF
        LOOP ; 2 0 #PARMS

: POWER2   (( n -- 2^n ))       1 SWAP 0 ?DO 2* LOOP ;
// ///////////////////////////////////////////// //
 4   CONSTANT  mm       mm POWER2  CONSTANT  MM
// ///////////////////////////////////////////// //
CELL MM ARRAY: []count

: bits  (( key start bitnum -- x ))
     // mask out 'key', from 'start', 'bitnum' bits
        FOR -1 AFT 2* THEN NEXT NOT -ROT
        FOR AFT 2/ THEN NEXT  AND  ; 3 1 #PARMS

: StraightRadixSort     (| #items | pass index -- |)
        [ CELL 8 * mm / 1- ] LITERAL 0 ?DO
            #I to pass AT? ." Pass " pass . AT
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
                  #I SWipe   index  index []SSortBuffer @   DrawEntry
            NEXT
            #items FOR
               #I []SSortBuffer @    #I []SSortEntry    !
            NEXT
        LOOP  ;

: StraightRadixSortAni  (| -- |)
        CLS
        SSortInit
        0 28 AT ." * Press any key to start ..." KEY DROP
        0 28 AT ." * Press any key to pause ..."
        GMaxX StraightRadixSort
        0 GMaxX SCheckResult ;

' QuickSortAni          ALIAS  ANIQ
' StraightRadixSortAni  ALIAS  ANIS

