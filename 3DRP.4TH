// dynamic 3D graphics, 5 independent tasks moving in 5 different ways

// Originally written	   : George Mai 03/24/'95
// Porting to Common Forth : Luke Lee   09/10/'95 

// Rewritten	     	   : Sam Chen   12/19/'95
// Porting to GRAPHICS.4TH : Luke Lee	12/30/'95

NEEDS 387FLOAT.4TH // Try NEEDS FLOAT.4TH instead of 387FLOAT.4TH, if it fails.
NEEDS GRAPHICS.4TH 
ONLY HIDDEN ALSO GRAPHICS ALSO FORTH
GRAPHICS-MODE CLS 0 300 GMaxX GMaxY 0 0 GSetScrollRange
POSTFIX SYNTAX
CODE: PLUCK (( a b c -- a b c a ))  3 4 #PARMS
      EBP { EBP 4 - } LEA { EBP } EAX MOV EAX { EBP 8 + } MOV RET ;CODE MACRO
CODE: 04+   (( n     -- n+04    ))  1 1 #PARMS  EAX 04  # ADD RET ;CODE MACRO
CODE: 08+   (( n     -- n+08    ))  1 1 #PARMS  EAX 08  # ADD RET ;CODE MACRO
CODE: 12+   (( n     -- n+12    ))  1 1 #PARMS  EAX 12  # ADD RET ;CODE MACRO
CODE: 04-   (( n     -- n-04    ))  1 1 #PARMS  EAX 04  # SUB RET ;CODE MACRO
CODE: 08*   (( n     -- n*08    ))  1 1 #PARMS  EAX 03  # SHL RET ;CODE MACRO
PI 180 S>F F/ FVALUE PI/180
: DEG>RAD (( d -- r )) S>F PI/180 F* ;
: WAIT 320 * FOR #I 20 MOD 0= ?{ PAUSE }? NEXT ;
 VARIABLE ThePoint  VARIABLE EndThePoint  VARIABLE #Points
 VARIABLE WinPoint  VARIABLE EndWinPoint
 VARIABLE TheCLine  VARIABLE EndTheCLine  VARIABLE #CLines
 VARIABLE ThePlane  VARIABLE EndThePlane  VARIABLE #Planes
 VARIABLE Fx        VARIABLE Fy           VARIABLE TheKey
 VARIABLE Ox        VARIABLE Oy           VARIABLE Size     VARIABLE Delay
 VARIABLE WCx       VARIABLE WCy                         // Window Center
FVARIABLE NNx      FVARIABLE NNy         FVARIABLE NNz     FVARIABLE DK
FVARIABLE UUx      FVARIABLE UUy         FVARIABLE UUz
FVARIABLE Nx       FVARIABLE Ny          FVARIABLE Nz      FVARIABLE Nyz
FVARIABLE Nx*DK    FVARIABLE Ny*DK       FVARIABLE Nz*DK
FVARIABLE Wx       FVARIABLE Wy          FVARIABLE Qx      FVARIABLE Qy
FVARIABLE Px       FVARIABLE Py          FVARIABLE Pz
: ComputeWinPoint   WinPoint @ DUP @ 0= SWAP 04+ @ 0= AND
  IF NNx F@ FDUP F* NNy F@ FDUP F* NNz F@ FDUP F* F+ F+ FSQRT
     NNx F@ FOVER F/                                               Nx    F!
     NNy F@ FOVER F/                                               Ny    F!
     NNz F@ FSWAP F/                                               Nz    F!
     Ny  F@ FDUP  F* Nz F@ FDUP F* F+ FSQRT                        Nyz   F!
     UUx F@ Nyz F@ F*
     UUy F@ Ny F@ F* UUz F@ Nz F@ F* F+  Nx F@ F* Nyz F@ F/ F-  (( WWx ))
     UUy F@ Nz F@ F* UUz F@ Ny F@ F* F+  Nyz F@ F/          (( WWx WWy ))
     FOVER FDUP F* FOVER FDUP F* F+ FDUP F0=       (( WWx WWy WWxy Flg ))
     IF   FDROP                                   Wy    F!         Wx    F!
     ELSE FSQRT FSWAP FOVER F/                    Wy    F!   F/    Wx    F!
     ENDIF DK F@ FDUP FDUP
     Nx F@ F*                                                      Nx*DK F!
     Ny F@ F*                                                      Ny*DK F!
     Nz F@ F*                                                      Nz*DK F!
     ThePoint @    EndWinPoint @ WinPoint @
     DO 12+ DUP 04- DUP 04- DUP 04-
       @ Size @ * S>F                                              Px    F!
       @ Size @ * S>F                                              Py    F!
       @ Size @ * S>F                                              Pz    F!
       Px F@ Nx*DK F@ F+ Nyz F@ F*
       Py F@ Ny*DK F@ F+ Ny  F@ F* Nyz F@ F/ F-
       Pz F@ Nz*DK F@ F+ Nz  F@ F* Nyz F@ F/ Nx F@ F* F+           Qx    F!
       Py F@ Ny*DK F@ F+ Nz  F@ F* Nyz F@ F/
       Pz F@ Nz*DK F@ F+ Ny  F@ F* Nyz F@ F/ F-                    Qy    F!
       Qx F@ Wy  F@ F* Qy F@ Wx F@ F* F- F>S                       I      !
       Qx F@ Wx  F@ F* Qy F@ Wy F@ F* F+ F>S                       I 04+  !  8
     +LOOP DROP
  THEN
  0 EndWinPoint @ WinPoint @     DO I @ + 8 +LOOP #Points @ /      WCx    !
  0 EndWinPoint @ WinPoint @ 04+ DO I @ + 8 +LOOP #Points @ /      WCy    ! ;
CODE: GetXY (( p -- x y )) EBP { EBP 4 - } LEA  EAX 3 # SHL
  ESI WinPoint # MOV  EAX { ESI } ADD   EDX { EAX 04+ } MOV    ESI WCy # MOV
  EDX { ESI    } SUB  ESI    Oy # MOV   EDX { ESI     } ADD  { EBP } EDX MOV
  EAX { EAX    } MOV  ESI   WCx # MOV   EAX { ESI     } SUB    ESI  Ox # MOV
  EAX { ESI    } ADD  EAX { EBP } XCHG  RET   ;CODE 1 2 #PARMS
CODE: 4PICK (( c x y x y -- c x y x y c ))
  ] DUP [ EAX { EBP 4 CELLS + } MOV  RET ;CODE 5 6 #PARMS MACRO
: DrawCLines
  GraphicsMode? 0= IF PAUSE EXIT THEN  Fx @ Ox @ = Fy @ Oy @ = AND 
  IF  8 1 ELSE  0 8 THEN >R Ox @ 48 - Oy @ 48 - Ox @ 48 + Oy @ 48 + 
  R> GFillCRectangle
  EndTheCLine @ TheCLine @
  DO  DUP I 08+ @ OR I @ GetXY I 04+ @ GetXY 4PICK GDrawCLine DROP 12
  +LOOP DROP Delay @ WAIT ;

: DrawPlanes
  GraphicsMode? 0= IF PAUSE EXIT THEN  Fx @ Ox @ = Fy @ Oy @ = AND
  IF 14 1 ELSE 15 8 THEN >R Ox @ 48 + Oy @ 48 + Ox @ 48 - Oy @ 48 - 
  R> GFillCRectangle
  GSetColor
  EndThePlane @ ThePlane @
  DO I @ GetXY I 04+ @ GetXY 	  GDrawLine
     I 04+ @ GetXY I 08+ @ GetXY  GDrawLine
     I 08+ @ GetXY I 12+ @ GetXY  GDrawLine
     I 12+ @ GetXY I @ GetXY 	  GDrawLine 16
  +LOOP Delay @ WAIT ;
// ----------------------------- T A S K 1 ----------------------------------
//                                     x
//                                     |
//                         (-5,-5,-5)  0 ------- 1
//                                   / |       / |
//                                 4 ------- 5   |
//                                 |   |     |   | (05,05,-5)
//                                 |   3 --- | - 2 --- y
//                                 | /       | /
//                     (-5,05,05)  7 ------- 6
//                               /
//                             z
CREATE ThePoint1 // points of the cubic (X, Y, Z  are given for each point)
-5 , -5 , -5 ,   05 , -5 , -5 ,   05 , 05 , -5 ,   -5 , 05 , -5 ,
-5 , -5 , 05 ,   05 , -5 , 05 ,   05 , 05 , 05 ,   -5 , 05 , 05 ,
HERE DUP VALUE EndThePoint1 ThePoint1 - 12 / VALUE #Points1

CREATE TheCLine1  // Color lines of the cubic (2 points and 1 color for each)
0 , 1 , 7 ,  0 , 4 , 7 ,  0 , 3 , 6 ,  1 , 2 , 3 ,  1 , 5 , 7 ,  2 , 3 , 2 ,
2 , 6 , 2 ,  3 , 7 , 2 ,  4 , 5 , 7 ,  4 , 7 , 5 ,  5 , 6 , 4 ,  6 , 7 , 2 ,
HERE DUP VALUE EndTheCLine1 TheCLine1 - 12 / VALUE #CLines1

CREATE ThePlane1  // Planes of the cubic (4 points are given for each plane)
0 , 1 , 2 , 3 ,     3 , 2 , 6 , 7 ,     0 , 4 , 5 , 1 ,      7 , 6 , 5 , 4 ,
HERE DUP VALUE EndThePlane1 ThePlane1 - 16 / VALUE #Planes1

120 VALUE #Frames1
CREATE WinPoint1 #Points1 08* #Frames1 * ALLOT  WinPoint1 HERE OVER - ERASE
WinPoint1 #Points1 08* + VALUE EndWinPoint1

 299 VALUE E1   -301 VALUE B1      5 VALUE D1    D1 VALUE N1
-300 VALUE NNx1   B1 VALUE NNy1 -300 VALUE NNz1  20 VALUE DK1
   0 VALUE UUx1    1 VALUE UUy1    0 VALUE UUz1   3 VALUE Delay1
   3 VALUE Size1  70 VALUE Ox1    70 VALUE Oy1

: InitJob1  WinPoint1 #Points1 08* #Frames1 * ERASE ;
: SwitchTo1  NNy1 E1 N1 - 1- OVER < D1 0> AND OVER B1 N1 + 1+ < D1 0< AND OR
  IF  D1 NEGATE IS D1
  THEN  D1 +  DUP IS NNy1  B1 - N1 / #Points1 08* * DUP
  WinPoint1 + WinPoint ! EndWinPoint1 + EndWinPoint !
  NNx1 S>F NNx F! NNy1 S>F NNy F! NNz1 S>F NNz F! DK1 S>F DK F!
  UUx1 S>F UUx F! UUy1 S>F UUy F! UUz1 S>F UUz F!
  Size1 Size ! Ox1 Ox ! Oy1 Oy ! Delay1 Delay !
  ThePoint1 ThePoint ! EndThePoint1 EndThePoint ! #Points1 #Points !
  ThePlane1 ThePlane ! EndThePlane1 EndThePlane ! #Planes1 #Planes ! ;
BACKGROUND: Job1
  BEGIN SwitchTo1 ComputeWinPoint DrawPlanes
  AGAIN ;

// ----------------------------- T A S K 2 ----------------------------------
//
//          -5    -3    -1    01    03    05
//
//     -5    *     *     *    00----01     *    -5
//                          /   14----15
//     -3    *     *     /   /02     | |   *    -3
//                    /   //   |16   | |
//     -1    *     /   //     /  |   | |   *    -1
//              /   //     /   | |   | |
//     01   03   /04----/-----05 |  06-|--07    01
//           |17    18----------19    20----21
//     03   08-|--------------09    10----11 |  03
//            22----------------23   |24----25
//     05    *     *     *    12-|--13 |   *    05
//                              26----27
//
//          -5    -3    -1    01    03    05

CREATE ThePoint2
 1 , -5 , -2 ,     3 , -5 , -2 ,     1 , -3 , -2 ,    -5 ,  1 , -2 ,
-3 ,  1 , -2 ,     1 ,  1 , -2 ,     3 ,  1 , -2 ,     5 ,  1 , -2 ,
-5 ,  3 , -2 ,     1 ,  3 , -2 ,     3 ,  3 , -2 ,     5 ,  3 , -2 ,
 1 ,  5 , -2 ,     3 ,  5 , -2 ,
 1 , -5 ,  2 ,     3 , -5 ,  2 ,     1 , -3 ,  2 ,    -5 ,  1 ,  2 ,
-3 ,  1 ,  2 ,     1 ,  1 ,  2 ,     3 ,  1 ,  2 ,     5 ,  1 ,  2 ,
-5 ,  3 ,  2 ,     1 ,  3 ,  2 ,     3 ,  3 ,  2 ,     5 ,  3 ,  2 ,
 1 ,  5 ,  2 ,     3 ,  5 ,  2 ,

HERE VALUE EndThePoint2  EndThePoint2 ThePoint2 - 12 / VALUE #Points2

CREATE ThePlane2
00 , 01 , 15 , 14 ,     00 , 03 , 17 , 14 ,     01 , 06 , 20 , 15 ,
02 , 04 , 18 , 16 ,     02 , 05 , 19 , 16 ,     03 , 08 , 22 , 17 ,
04 , 05 , 19 , 18 ,     06 , 07 , 21 , 20 ,     07 , 11 , 25 , 21 ,
08 , 09 , 23 , 22 ,     09 , 12 , 26 , 23 ,     10 , 11 , 25 , 24 ,
10 , 13 , 27 , 24 ,     12 , 13 , 27 , 26 ,

HERE VALUE EndThePlane2  EndThePlane2 ThePlane2 - 16 / VALUE #Planes2

120 VALUE #Frames2
CREATE WinPoint2 #Points2 08* #Frames2 * ALLOT  WinPoint2 HERE OVER - ERASE
WinPoint2 #Points2 08* + VALUE EndWinPoint2

-291 VALUE E2   -411 VALUE B2     10 VALUE D2    D2 VALUE N2
-300 VALUE NNx2   B2 VALUE NNy2 -300 VALUE NNz2   5 VALUE DK2
   0 VALUE UUx2 -200 VALUE UUy2    0 VALUE UUz2   3 VALUE Delay2
   5 VALUE Size2 170 VALUE Ox2    70 VALUE Oy2

: InitJob2              WinPoint2 #Points2 08* #Frames2 * ERASE ;

: SwitchTo2 NNy2 E2 N2 - 1- OVER < D2 0> AND OVER B2 N2 + 1+ < D2 0< AND OR
  IF  D2 NEGATE IS D2
  THEN D2 + DUP IS NNy2  B2 - N2 / #Points2 08* * DUP
  WinPoint2 + WinPoint !  EndWinPoint2 + EndWinPoint !
  NNx2 S>F NNx F! NNy2 S>F NNy F! NNz2 S>F NNz F! DK2 S>F DK F!
  UUx2 S>F UUx F! UUy2 S>F UUy F! UUz2 S>F UUz F!
  Size2 Size ! Ox2 Ox ! Oy2 Oy ! Delay2 Delay !
  ThePoint2 ThePoint ! EndThePoint2 EndThePoint ! #Points2 #Points !
  ThePlane2 ThePlane ! EndThePlane2 EndThePlane ! #Planes2 #Planes ! ;

BACKGROUND: Job2
  BEGIN SwitchTo2 ComputeWinPoint DrawPlanes
  AGAIN ;

// ----------------------------- T A S K 3 ----------------------------------
-300 VALUE NNx3 -300 VALUE NNy3 -300 VALUE NNz3  20 VALUE DK3
   1 VALUE UUx3    1 VALUE UUy3    0 VALUE UUz3   4 VALUE Delay3
   3 VALUE Size3 270 VALUE Ox3    70 VALUE Oy3   90 VALUE #Frames3
CREATE WinPoint3 #Points1 08* #Frames3 * ALLOT  WinPoint3 HERE OVER - ERASE
WinPoint3 #Points1 08* + VALUE EndWinPoint3
: InitJob3    WinPoint3 #Points1 08* #Frames3 * ERASE ;
: SwitchTo3 (( degree/4 -- )) DUP 08* #Points1 * DUP
  WinPoint3 + WinPoint ! EndWinPoint3 + EndWinPoint ! CELLS 1+
  DEG>RAD FDUP FCOS 300.0 F* F>S IS NNy3 FSIN 300.0 F* F>S IS NNz3
  NNx3 S>F NNx F! NNy3 S>F NNy F! NNz3 S>F NNz F! DK3 S>F DK F!
  UUx3 S>F UUx F! UUy3 S>F UUy F! UUz3 S>F UUz F!
  Size3 Size ! Ox3 Ox ! Oy3 Oy ! Delay3 Delay !
  ThePoint1 ThePoint ! EndThePoint1 EndThePoint ! #Points1 #Points !
  TheCLine1 TheCLine ! EndTheCLine1 EndTheCLine ! #CLines1 #CLines ! ;
BACKGROUND: Job3
  BEGIN 90 0 DO I SwitchTo3 ComputeWinPoint DrawCLines
             LOOP
  AGAIN ;
// ----------------------------- T A S K 4 ----------------------------------
-300 VALUE NNx4 -300 VALUE NNy4 -300 VALUE NNz4  20 VALUE DK4
   0 VALUE UUx4    1 VALUE UUy4    0 VALUE UUz4   3 VALUE Delay4
   3 VALUE Size4 370 VALUE Ox4    70 VALUE Oy4    2 VALUE D4
: InitJob4    WinPoint3 #Points1 08* #Frames3 * ERASE ;
: SwitchTo4 (( degree/4 -- )) DUP 08* #Points1 * DUP
  WinPoint3 + WinPoint ! EndWinPoint3 + EndWinPoint ! CELLS 1+
  DEG>RAD FDUP FCOS 300.0 F* F>S IS NNy4 FSIN 300.0 F* F>S IS NNz4
  NNx4 S>F NNx F! NNy4 S>F NNy F! NNz4 S>F NNz F! DK4 S>F DK F!
  UUx4 S>F UUx F! UUy4 S>F UUy F! UUz4 S>F UUz F!
  Size4 Size ! Ox4 Ox ! Oy4 Oy ! Delay4 Delay !
  ThePoint1 ThePoint ! EndThePoint1 EndThePoint ! #Points1 #Points !
  ThePlane1 ThePlane ! EndThePlane1 EndThePlane ! #Planes1 #Planes ! ;
BACKGROUND: Job4 BEGIN 90 0 DO I SwitchTo4 ComputeWinPoint DrawPlanes
                            LOOP
                 AGAIN ;
// ----------------------------- T A S K 5 ----------------------------------
-300 VALUE NNx5 -300 VALUE NNy5 -300 VALUE NNz5  20 VALUE DK5
   0 VALUE UUx5 -200 VALUE UUy5    0 VALUE UUz5   2 VALUE Delay5
   5 VALUE Size5 470 VALUE Ox5    70 VALUE Oy5   90 VALUE #Frames5
CREATE WinPoint5 #Points2 08* #Frames5 * ALLOT  WinPoint5 HERE OVER - ERASE
WinPoint5 #Points2 08* + VALUE EndWinPoint5
: InitJob5  WinPoint5 #Points2 08* #Frames5 * ERASE ;
: SwitchTo5 (( degree -- )) DUP 08* #Points2 * DUP
  WinPoint5 + WinPoint ! EndWinPoint5 + EndWinPoint ! CELLS 1+ 360 SWAP -
  DEG>RAD FDUP FCOS 300.0 F* F>S IS NNy5 FSIN 300.0 F* F>S IS NNz5
  NNx5 S>F NNx F! NNy5 S>F NNy F! NNz5 S>F NNz F! DK5 S>F DK F!
  UUx5 S>F UUx F! UUy5 S>F UUy F! UUz5 S>F UUz F!
  Size5 Size ! Ox5 Ox ! Oy5 Oy ! Delay5 Delay !
  ThePoint2 ThePoint ! EndThePoint2 EndThePoint ! #Points2 #Points !
  ThePlane2 ThePlane ! EndThePlane2 EndThePlane ! #Planes2 #Planes ! ;
BACKGROUND: Job5 BEGIN 90 0 DO I SwitchTo5 ComputeWinPoint DrawPlanes
                            LOOP
                 AGAIN ;
// ----------------------------- T A S K 0 ----------------------------------
-300 VALUE NNx0 -300 VALUE NNy0 -300 VALUE NNz0  20 VALUE DK0
   0 VALUE UUx0 -200 VALUE UUy0    0 VALUE UUz0   4 VALUE Delay0
   5 VALUE Size0 470 VALUE Ox0   190 VALUE Oy0   90 VALUE #Frames0
CREATE WinPoint0 #Points2 08* #Frames0 * ALLOT  WinPoint0 HERE OVER - ERASE
WinPoint0 #Points2 08* + VALUE EndWinPoint0
: InitJob0  WinPoint0 #Points2 08* #Frames0 * ERASE ;
: SwitchTo00 (( i -- ))
  DUP 08* #Points2 * DUP
  WinPoint0 + WinPoint ! EndWinPoint0 + EndWinPoint !
  CELLS 450 OVER -                DUP IS  Ox0  Fx   !
  DEG>RAD FDUP FCOS 200.0 F* 400.0 F- FDUP F>S IS NNy0  NNy F!
  190 -ROT FCOS 20.0 F* F>S +     DUP IS  Oy0  Fy   !
  NNx0 S>F NNx F!    DK0 S>F  DK F!   NNz0 S>F NNz F!
  UUx0 S>F UUx F!   UUy0 S>F UUy F!   UUz0 S>F UUz F!
  Size0 Size ! Ox0 Ox ! Oy0 Oy ! Delay0 Delay !
  ThePoint2 ThePoint ! EndThePoint2 EndThePoint ! #Points2 #Points !
  ThePlane2 ThePlane ! EndThePlane2 EndThePlane ! #Planes2 #Planes ! ;
: SwitchTo01 (( i -- )) DUP 08* #Points2 * DUP
  WinPoint0 + WinPoint ! EndWinPoint0 + EndWinPoint ! CELLS 1+ 360 SWAP -
  DEG>RAD FDUP FCOS 200.0 F* F>S IS NNy0 FSIN 200.0 F* F>S IS NNz0
  NNx0 S>F NNx F! NNy0 S>F NNy F! NNz0 S>F NNz F! DK0 S>F DK F!
  UUx0 S>F UUx F! UUy0 S>F UUy F! UUz0 S>F UUz F!
  Size0 Size ! Ox0 Ox ! Oy0 Oy ! Delay0 Delay !
  ThePoint2 ThePoint ! EndThePoint2 EndThePoint ! #Points2 #Points !
  ThePlane2 ThePlane ! EndThePlane2 EndThePlane ! #Planes2 #Planes ! ;
BACKGROUND: Job0
  BEGIN
    21 121 519 259 1 GFillCRectangle 90 0
    DO I SwitchTo00 ComputeWinPoint DrawPlanes
    LOOP
    90 0
    DO I SwitchTo01 ComputeWinPoint DrawPlanes I 3 / 4 + IS Delay0
    LOOP InitJob0 40 IS Delay0
    90 0
    DO I SwitchTo01 ComputeWinPoint DrawPlanes
    LOOP 4 IS Delay0
  AGAIN ;
: Job6 	   0 2 AT ." þ Press <Enter> twice to quit this job (Job6) ..."
           0 3 AT ." i Oxi Oyi Sizei Delayi UUxi UUyi UUzi NNxi NNyi NNzi"
           0 4 AT 1 . 0 5 AT 2 . 0 6 AT 3 . 0 7 AT 4 . 0 8 AT 5 . 0 9 AT 0 .
  BEGIN 2 4 AT Ox1 3 .R Oy1 4 .R Size1 6 .R Delay1 7 .R
        NNz1 NNy1 NNx1 UUz1 UUy1 UUx1 5 .R 5 .R 5 .R 5 .R 5 .R 5 .R
        2 5 AT Ox2 3 .R Oy2 4 .R Size2 6 .R Delay2 7 .R
        NNz2 NNy2 NNx2 UUz2 UUy2 UUx2 5 .R 5 .R 5 .R 5 .R 5 .R 5 .R
        2 6 AT Ox3 3 .R Oy3 4 .R Size3 6 .R Delay3 7 .R
        NNz3 NNy3 NNx3 UUz3 UUy3 UUx3 5 .R 5 .R 5 .R 5 .R 5 .R 5 .R
        2 7 AT Ox4 3 .R Oy4 4 .R Size4 6 .R Delay4 7 .R
        NNz4 NNy4 NNx4 UUz4 UUy4 UUx4 5 .R 5 .R 5 .R 5 .R 5 .R 5 .R
        2 8 AT Ox5 3 .R Oy5 4 .R Size5 6 .R Delay5 7 .R
        NNz5 NNy5 NNx5 UUz5 UUy5 UUx5 5 .R 5 .R 5 .R 5 .R 5 .R 5 .R
        2 9 AT Ox0 3 .R Oy0 4 .R Size0 6 .R Delay0 7 .R
        NNz0 NNy0 NNx0 UUz0 UUy0 UUx0 5 .R 5 .R 5 .R 5 .R 5 .R 5 .R  
        NUF?
  UNTIL ;
CLS
Job0 WAKE  Job1 WAKE  Job2 WAKE  Job3 WAKE  Job4 WAKE  Job5 WAKE  Job6

