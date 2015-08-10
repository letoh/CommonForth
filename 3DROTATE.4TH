//  3D ROTATE , 3 tasks in 3 ways
//  Written by : George Mai
//  Porting by : Luke Lee ( I almost do nothing but change names )

NEEDS 387FLOAT.4TH // If it fails, try FLOAD FLOAT.4TH instead of 387FLOAT.4TH
NEEDS GRAPHICS.4TH
ALSO GRAPHICS ALSO FORTH

WARNING OFF

WHITE VALUE currColor

: COLOR GSetColor ;

: DOT   (( X0 Y0 -- ))
	GraphicsMode? ?{  GDrawPoint  }{  PAUSE 2DROP  }?  ;

: LINE  (( X0 Y0 X1 Y1 -- ))
	GraphicsMode? ?{  GDrawLine  }{  PAUSE 4DROP  }?  ;

: FILLBOX  (( X0 Y0 X1 Y1 -- ))
	GraphicsMode? ?{  GFillRectangle  }{  PAUSE 4DROP  }?  ;

// ------------------------------------------------------------------------
//                           T A S K     1
// ------------------------------------------------------------------------

// DYN ROTATE      1995/3/24

VARIABLE GPOT
8 VALUE MAXPTS
6 VALUE MAXPLNS
CREATE POINTS  //    MAXPTS 3 * CELLS ALLOT  //  SOURCE POINTS */
10 , 10 , 00 ,
20 , 10 , 00 ,
20 , 20 , 00 ,
10 , 20 , 00 ,
10 , 10 , 10 ,
20 , 10 , 10 ,
20 , 20 , 10 ,
10 , 20 , 10 ,

CREATE POINTSR   MAXPTS 3 * CELLS ALLOT  //  ROTATED POINTS

CREATE PLANES //   MAXPLNS 4 * CELLS ALLOT
0 , 1 , 2 , 3 ,
1 , 5 , 6 , 2 ,
3 , 2 , 6 , 7 ,
0 , 4 , 5 , 1 ,
7 , 6 , 5 , 4 ,
0 , 3 , 7 , 4 ,

CREATE DEPTH   MAXPLNS CELLS ALLOT   //  FOR SORTING OF DEPTH SORT METHOD */
CREATE ZV      MAXPLNS CELLS ALLOT   //  THE SMALLEST Z VALUE FOR EACH PLANE

20.0 FCONSTANT DK
0.0   FVALUE UUX
1.0   FVALUE UUY
0.0   FVALUE UUZ
0.0 FVALUE UX
0.0 FVALUE UY
0.0 FVALUE RX
0.0 FVALUE RY
0.0 FVALUE RZ

0.0 FVALUE NX
0.0 FVALUE NY
0.0 FVALUE NZ
0.0 FVALUE LK
0.0 FVALUE PK
0.0 FVALUE WK
-300.0 FVALUE NNX
-300.0 FVALUE NNY
-300.0 FVALUE NNZ

0.0 FVALUE XK
0.0 FVALUE YK
0.0 FVALUE ZK
0.0 FVALUE X1K
0.0 FVALUE Y1K
0.0 FVALUE UYW
0.0 FVALUE UXW

0 VALUE RXN   //  NEW X CENTER
0 VALUE RYN   //  NEW Y CENTER
VARIABLE S-XP  100 S-XP !
VARIABLE S-YP  200 S-YP !
3 VALUE BIG1

: C-LK-ALL
  NNX NNX F*  NNY NNY F* F+ NNZ NNZ F* F+ FSQRT F!> LK
  NNX DK F* LK  F/  F!> NX
  NNY DK F* LK  F/  F!> NY
  NNZ DK F* LK  F/  F!> NZ
  NY NY  F* NZ NZ F* F+ FSQRT F!> PK
     UUX PK F* DK F/  (( F1))
     UUY NY F*
     UUZ NZ F* F+
     NX F* DK F/
     PK F/            (( F2))
     F- F!> UX        (( --))
	 1.0 PK  F/    (( F1))
	 UUY NZ F*
	 UUZ NY F* F+ (( F2))
	  F*  F!> UY  (( --))
  UX UX F* UY UY F* F+ FSQRT    F!> WK
  WK F0= IF  0.0 F!> UXW ELSE UX WK F/ F!> UXW ENDIF
  WK F0= IF  0.0 F!> UYW ELSE UY WK F/ F!> UYW ENDIF
;

: TPT
   C-LK-ALL
  MAXPTS 0 DO
	     POINTS  #I  CELLS 3 * +             @ BIG1 * S>F F!> XK
	     POINTS  #I  CELLS 3 * + CELL+       @ BIG1 * S>F F!> YK
	     POINTS  #I  CELLS 3 * + CELL+ CELL+ @ BIG1 * S>F F!> ZK
       // X1

	    XK RX F- NX F+ PK F* DK F/
	    YK RY F- NY F+ NY F* PK F/  F-
	    ZK RZ F- NZ F+ NZ F* PK F/
	    NX F* DK F/   F+
	    F!> X1K
       // Y1
	    YK RY F- NY F+ NZ F* PK F/
	    ZK RZ F- NZ F+ NY F* PK F/  F-
	    F!> Y1K

       // SAVE TO TRANS OK BUF
       // NEW X
	     X1K UYW F*
	     Y1K UXW F*  F-             F>S
	     POINTSR  #I  CELLS 3 * +       !

       // NEW Y
	     X1K UXW F*
	     Y1K UYW F*  F+             F>S
	     POINTSR  #I  CELLS 3 * + CELL+    !

       // NEW Z
	     XK RX F- NX F+ NX F* DK F/
	     YK RY F- NY F+ NY F* PK F/
	     ZK RZ F- NZ F+ NZ F* PK F/ F+
	     PK F*
	     DK F/     F+ F>S
	     POINTSR  #I  CELLS 3 * + CELL+ CELL+ !
	     LOOP ;

: QW1
   8 0 DO    CR
	     POINTS  #I  CELLS 3 * +       @  .
	     POINTS  #I  CELLS 3 * + CELL+    @  .
	     POINTS  #I  CELLS 3 * + CELL+ CELL+ @  .
		     ." OLD----NEW "
	     POINTSR #I  CELLS 3 * +       @  .
	     POINTSR #I  CELLS 3 * + CELL+    @  .
	     POINTSR #I  CELLS 3 * + CELL+ CELL+ @  .
       LOOP ;
: CTR-POINT-OLD
  0 8 0 DO  POINTS  #I  CELLS 3 * +       @  +  LOOP 8 / S>F F!> RX
  0 8 0 DO  POINTS  #I  CELLS 3 * + CELL+    @  +  LOOP 8 / S>F F!> RY
  0 8 0 DO  POINTS  #I  CELLS 3 * + CELL+ CELL+ @  +  LOOP 8 / S>F F!> RZ
     ;

: CTR-POINT-NEW
  0 8 0 DO  POINTSR #I  CELLS 3 * +       @  +  LOOP 8 /  !> RXN
  0 8 0 DO  POINTSR #I  CELLS 3 * + CELL+ @  +  LOOP 8 /  !> RYN
     ;
: GET-XY-N (( 0~5--X,Y))
	     GPOT !
	     POINTSR  GPOT @ 12 *  +       @   (( 319 )) RXN -
	     70 +
	     POINTSR  GPOT @ 12 *  + CELL+ @   (( 239 )) RYN -
	     70 +
		;


: DW-PLANES
//     8 COLOR
     MAXPLNS 0 DO   G_WHITE COLOR
	       PLANES #I 16 * + 0 +  @  GET-XY-N
	       PLANES #I 16 * + 4 +  @  GET-XY-N  LINE
	       PLANES #I 16 * + 4 +  @  GET-XY-N
	       PLANES #I 16 * + 8 +  @  GET-XY-N  LINE
	       PLANES #I 16 * + 8 +  @  GET-XY-N
	       PLANES #I 16 * + 12 +  @  GET-XY-N  LINE
	       PLANES #I 16 * + 12 +  @  GET-XY-N
	       PLANES #I 16 * + 0 +  @  GET-XY-N  LINE
	       PAUSE LOOP ;
: NT2 TPT CTR-POINT-NEW DW-PLANES ;

// WAY1

 : RT-X1    CTR-POINT-OLD
       200 -200 DO
	(( 1 SECONDS)) PAUSE
	BLUE COLOR 30 30 100 100 FILLBOX // CAN DO MORE
	#I S>F F!> NNY
	NT2
	40 MS PAUSE
    20 +LOOP  ;

  BACKGROUND: TASK1
	BEGIN
		PAUSE
		RT-X1
	AGAIN ;

// ------------------------------------------------------------------------
//                           T A S K     2
// ------------------------------------------------------------------------

VARIABLE GPOT
8 VALUE MAXPTS
6 VALUE MAXPLNS
CREATE POINTS  //    MAXPTS 3 * CELLS ALLOT  //  SOURCE POINTS */
10 , 10 , 00 ,
20 , 10 , 00 ,
20 , 20 , 00 ,
10 , 20 , 00 ,
10 , 10 , 10 ,
20 , 10 , 10 ,
20 , 20 , 10 ,
10 , 20 , 10 ,

CREATE POINTSR   MAXPTS 3 * CELLS ALLOT  //  ROTATED POINTS

CREATE PLANES //   MAXPLNS 4 * CELLS ALLOT
0 , 1 , 2 , 3 ,
1 , 5 , 6 , 2 ,
3 , 2 , 6 , 7 ,
0 , 4 , 5 , 1 ,
7 , 6 , 5 , 4 ,
0 , 3 , 7 , 4 ,

CREATE DEPTH   MAXPLNS CELLS ALLOT   //  FOR SORTING OF DEPTH SORT METHOD */
CREATE ZV      MAXPLNS CELLS ALLOT   //  THE SMALLEST Z VALUE FOR EACH PLANE

20.0 FCONSTANT DK
0.0   FVALUE UUX
1.0   FVALUE UUY
0.0   FVALUE UUZ
0.0 FVALUE UX
0.0 FVALUE UY
0.0 FVALUE RX
0.0 FVALUE RY
0.0 FVALUE RZ

0.0 FVALUE NX
0.0 FVALUE NY
0.0 FVALUE NZ
0.0 FVALUE LK
0.0 FVALUE PK
0.0 FVALUE WK
-300.0 FVALUE NNX
-300.0 FVALUE NNY
-300.0 FVALUE NNZ

0.0 FVALUE XK
0.0 FVALUE YK
0.0 FVALUE ZK
0.0 FVALUE X1K
0.0 FVALUE Y1K
0.0 FVALUE UYW
0.0 FVALUE UXW

0 VALUE RXN   //  NEW X CENTER
0 VALUE RYN   //  NEW Y CENTER
VARIABLE S-XP  100 S-XP !
VARIABLE S-YP  200 S-YP !
2 VALUE BIG2

: C-LK-ALL
  NNX NNX F*  NNY NNY F* F+ NNZ NNZ F* F+ FSQRT F!> LK
  NNX DK F* LK  F/  F!> NX
  NNY DK F* LK  F/  F!> NY
  NNZ DK F* LK  F/  F!> NZ
  NY NY  F* NZ NZ F* F+ FSQRT F!> PK
     UUX PK F* DK F/  (( F1))
     UUY NY F*
     UUZ NZ F* F+
     NX F* DK F/
     PK F/            (( F2))
     F- F!> UX        (( --))
	 1.0 PK  F/    (( F1))
	 UUY NZ F*
	 UUZ NY F* F+ (( F2))
	  F*  F!> UY  (( --))
  UX UX F* UY UY F* F+ FSQRT    F!> WK
  WK F0= IF  0.0 F!> UXW ELSE UX WK F/ F!> UXW ENDIF
  WK F0= IF  0.0 F!> UYW ELSE UY WK F/ F!> UYW ENDIF
;

: TPT
   C-LK-ALL
  MAXPTS 0 DO
	     POINTS  #I  CELLS 3 * +             @ BIG2 * S>F F!> XK
	     POINTS  #I  CELLS 3 * + CELL+       @ BIG2 * S>F F!> YK
	     POINTS  #I  CELLS 3 * + CELL+ CELL+ @ BIG2 * S>F F!> ZK
       // X1

	    XK RX F- NX F+ PK F* DK F/
	    YK RY F- NY F+ NY F* PK F/  F-
	    ZK RZ F- NZ F+ NZ F* PK F/
	    NX F* DK F/   F+
	    F!> X1K
       // Y1
	    YK RY F- NY F+ NZ F* PK F/
	    ZK RZ F- NZ F+ NY F* PK F/  F-
	    F!> Y1K

       // SAVE TO TRANS OK BUF
       // NEW X
	     X1K UYW F*
	     Y1K UXW F*  F-             F>S
	     POINTSR  #I  CELLS 3 * +       !

       // NEW Y
	     X1K UXW F*
	     Y1K UYW F*  F+             F>S
	     POINTSR  #I  CELLS 3 * + CELL+    !

       // NEW Z
	     XK RX F- NX F+ NX F* DK F/
	     YK RY F- NY F+ NY F* PK F/
	     ZK RZ F- NZ F+ NZ F* PK F/ F+
	     PK F*
	     DK F/     F+ F>S
	     POINTSR  #I  CELLS 3 * + CELL+ CELL+ !
	     LOOP ;

: QW1
   8 0 DO    CR
	     POINTS  #I  CELLS 3 * +       @  .
	     POINTS  #I  CELLS 3 * + CELL+    @  .
	     POINTS  #I  CELLS 3 * + CELL+ CELL+ @  .
		     ." OLD----NEW "
	     POINTSR #I  CELLS 3 * +       @  .
	     POINTSR #I  CELLS 3 * + CELL+    @  .
	     POINTSR #I  CELLS 3 * + CELL+ CELL+ @  .
       LOOP ;
: CTR-POINT-OLD
  0 8 0 DO  POINTS  #I  CELLS 3 * +       @  +  LOOP 8 / S>F F!> RX
  0 8 0 DO  POINTS  #I  CELLS 3 * + CELL+    @  +  LOOP 8 / S>F F!> RY
  0 8 0 DO  POINTS  #I  CELLS 3 * + CELL+ CELL+ @  +  LOOP 8 / S>F F!> RZ
     ;

: CTR-POINT-NEW
  0 8 0 DO  POINTSR #I  CELLS 3 * +       @  +  LOOP 8 /  !> RXN
  0 8 0 DO  POINTSR #I  CELLS 3 * + CELL+ @  +  LOOP 8 /  !> RYN
     ;
: GET-XY-N (( 0~5--X,Y))
	     GPOT !
	     POINTSR  GPOT @ 12 *  +       @   (( 319 )) RXN -
	     170 +
	     POINTSR  GPOT @ 12 *  + CELL+ @   (( 239 )) RYN -
	     70 +
		;


: DW-PLANES
     MAXPLNS 0 DO   YELLOW COLOR
	       PLANES #I 16 * + 0 +  @  GET-XY-N
	       PLANES #I 16 * + 4 +  @  GET-XY-N  LINE
	       PLANES #I 16 * + 4 +  @  GET-XY-N
	       PLANES #I 16 * + 8 +  @  GET-XY-N  LINE
	       PLANES #I 16 * + 8 +  @  GET-XY-N
	       PLANES #I 16 * + 12 +  @  GET-XY-N  LINE
	       PLANES #I 16 * + 12 +  @  GET-XY-N
	       PLANES #I 16 * + 0 +  @  GET-XY-N  LINE
	       PAUSE LOOP ;
: NT2 TPT CTR-POINT-NEW DW-PLANES ;

// WAY2

 : RT-X2   CTR-POINT-OLD
       200 -200 DO
	(( 1 SECONDS)) PAUSE
	DARKGRAY COLOR 130 30 200 100 FILLBOX // CAN DO MORE
	#I S>F F!> NNZ
	NT2
	60 MS PAUSE
    20 +LOOP  ;

  BACKGROUND: TASK2
	BEGIN
		PAUSE
		RT-X2
	AGAIN ;

// ------------------------------------------------------------------------
//                           T A S K     3
// ------------------------------------------------------------------------

VARIABLE GPOT
8 VALUE MAXPTS
6 VALUE MAXPLNS
CREATE POINTS  //    MAXPTS 3 * CELLS ALLOT  //  SOURCE POINTS */
10 , 10 , 00 ,
20 , 10 , 00 ,
20 , 20 , 00 ,
10 , 20 , 00 ,
10 , 10 , 10 ,
20 , 10 , 10 ,
20 , 20 , 10 ,
10 , 20 , 10 ,

CREATE POINTSR   MAXPTS 3 * CELLS ALLOT  //  ROTATED POINTS

CREATE PLANES //   MAXPLNS 4 * CELLS ALLOT
0 , 1 , 2 , 3 ,
1 , 5 , 6 , 2 ,
3 , 2 , 6 , 7 ,
0 , 4 , 5 , 1 ,
7 , 6 , 5 , 4 ,
0 , 3 , 7 , 4 ,

CREATE DEPTH   MAXPLNS CELLS ALLOT   //  FOR SORTING OF DEPTH SORT METHOD */
CREATE ZV      MAXPLNS CELLS ALLOT   //  THE SMALLEST Z VALUE FOR EACH PLANE

20.0 FCONSTANT DK
0.0   FVALUE UUX
1.0   FVALUE UUY
0.0   FVALUE UUZ
0.0 FVALUE UX
0.0 FVALUE UY
0.0 FVALUE RX
0.0 FVALUE RY
0.0 FVALUE RZ

0.0 FVALUE NX
0.0 FVALUE NY
0.0 FVALUE NZ
0.0 FVALUE LK
0.0 FVALUE PK
0.0 FVALUE WK
-300.0 FVALUE NNX
-300.0 FVALUE NNY
-300.0 FVALUE NNZ

0.0 FVALUE XK
0.0 FVALUE YK
0.0 FVALUE ZK
0.0 FVALUE X1K
0.0 FVALUE Y1K
0.0 FVALUE UYW
0.0 FVALUE UXW

0 VALUE RXN   //  NEW X CENTER
0 VALUE RYN   //  NEW Y CENTER
2 VALUE BIG3

: C-LK-ALL
  NNX NNX F*  NNY NNY F* F+ NNZ NNZ F* F+ FSQRT F!> LK
  NNX DK F* LK  F/  F!> NX
  NNY DK F* LK  F/  F!> NY
  NNZ DK F* LK  F/  F!> NZ
  NY NY  F* NZ NZ F* F+ FSQRT F!> PK
     UUX PK F* DK F/  (( F1))
     UUY NY F*
     UUZ NZ F* F+
     NX F* DK F/
     PK F/            (( F2))
     F- F!> UX        (( --))
	 1.0 PK  F/    (( F1))
	 UUY NZ F*
	 UUZ NY F* F+ (( F2))
	  F*  F!> UY  (( --))
  UX UX F* UY UY F* F+ FSQRT    F!> WK
  WK F0= IF  0.0 F!> UXW ELSE UX WK F/ F!> UXW ENDIF
  WK F0= IF  0.0 F!> UYW ELSE UY WK F/ F!> UYW ENDIF
;

: TPT
   C-LK-ALL
  MAXPTS 0 DO
	     POINTS  #I  CELLS 3 * +             @ BIG3 * S>F F!> XK
	     POINTS  #I  CELLS 3 * + CELL+       @ BIG3 * S>F F!> YK
	     POINTS  #I  CELLS 3 * + CELL+ CELL+ @ BIG3 * S>F F!> ZK
       // X1

	    XK RX F- NX F+ PK F* DK F/
	    YK RY F- NY F+ NY F* PK F/  F-
	    ZK RZ F- NZ F+ NZ F* PK F/
	    NX F* DK F/   F+
	    F!> X1K
       // Y1
	    YK RY F- NY F+ NZ F* PK F/
	    ZK RZ F- NZ F+ NY F* PK F/  F-
	    F!> Y1K

       // SAVE TO TRANS OK BUF
       // NEW X
	     X1K UYW F*
	     Y1K UXW F*  F-             F>S
	     POINTSR  #I  CELLS 3 * +       !

       // NEW Y
	     X1K UXW F*
	     Y1K UYW F*  F+             F>S
	     POINTSR  #I  CELLS 3 * + CELL+    !

       // NEW Z
	     XK RX F- NX F+ NX F* DK F/
	     YK RY F- NY F+ NY F* PK F/
	     ZK RZ F- NZ F+ NZ F* PK F/ F+
	     PK F*
	     DK F/     F+ F>S
	     POINTSR  #I  CELLS 3 * + CELL+ CELL+ !
	     LOOP ;

: QW1
   8 0 DO    CR
	     POINTS  #I  CELLS 3 * +       @  .
	     POINTS  #I  CELLS 3 * + CELL+    @  .
	     POINTS  #I  CELLS 3 * + CELL+ CELL+ @  .
		     ." OLD----NEW "
	     POINTSR #I  CELLS 3 * +       @  .
	     POINTSR #I  CELLS 3 * + CELL+    @  .
	     POINTSR #I  CELLS 3 * + CELL+ CELL+ @  .
       LOOP ;
: CTR-POINT-OLD
  0 8 0 DO  POINTS  #I  CELLS 3 * +       @  +  LOOP 8 / S>F F!> RX
  0 8 0 DO  POINTS  #I  CELLS 3 * + CELL+    @  +  LOOP 8 / S>F F!> RY
  0 8 0 DO  POINTS  #I  CELLS 3 * + CELL+ CELL+ @  +  LOOP 8 / S>F F!> RZ
     ;

: CTR-POINT-NEW
  0 8 0 DO  POINTSR #I  CELLS 3 * +       @  +  LOOP 8 /  !> RXN
  0 8 0 DO  POINTSR #I  CELLS 3 * + CELL+ @  +  LOOP 8 /  !> RYN
     ;
: GET-XY-N (( 0~5--X,Y))
	     GPOT !
	     POINTSR  GPOT @ 12 *  +       @   (( 319 )) RXN -
	    (( S-XP @ )) 270 +
	     POINTSR  GPOT @ 12 *  + CELL+ @   (( 239 )) RYN -
	    (( S-YP @ )) 70 +
		;

: DW-PLANES
//     8 COLOR
     MAXPLNS 0 DO   04 COLOR
	       PLANES #I 16 * + 0 +  @  GET-XY-N
	       PLANES #I 16 * + 4 +  @  GET-XY-N  LINE
	       PLANES #I 16 * + 4 +  @  GET-XY-N
	       PLANES #I 16 * + 8 +  @  GET-XY-N  LINE
	       PLANES #I 16 * + 8 +  @  GET-XY-N
	       PLANES #I 16 * + 12 +  @  GET-XY-N  LINE
	       PLANES #I 16 * + 12 +  @  GET-XY-N
	       PLANES #I 16 * + 0 +  @  GET-XY-N  LINE
	       PAUSE LOOP ;
: NT2 TPT CTR-POINT-NEW DW-PLANES ;

// WAY3

 : RT-X3    CTR-POINT-OLD
       200 -200 DO
	PAUSE
	G_LIGHTGRAY COLOR 230 30 300 100 FILLBOX // CAN DO MORE
	#I S>F F!> NNX
	NT2
	40 MS PAUSE
    20 +LOOP  ;

  BACKGROUND: TASK3
	BEGIN
		PAUSE
		RT-X3
	AGAIN ;

// -----------------------------------------------------------------------

GRAPHICS-MODE

CLS  
0 300 GMaxX GMaxY 0 0 GSetScrollRange

TASK1 WAKE TASK2 WAKE TASK3 WAKE

WARNING ON

