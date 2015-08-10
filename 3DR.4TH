// dynamic 3D graphics, 5 independent tasks moving in 5 different ways
// Originally written: George Mike 840324
// Porting to Common Forth: Luke Lee 840910
// Rewritten:   Sam Chen 841219
NEEDS 387FLOAT.4TH // Try NEEDS FLOAT.4TH instead of 387FLOAT.4TH, if it fails.
NEEDS GRAPHICS.4TH
GRAPHICS-MODE ONLY HIDDEN ALSO GRAPHICS ALSO FORTH POSTFIX SYNTAX
CLS 0 300 GrMaxX GrMaxY 0 0 GSetScrollRange // 400 => grCursorBlinkDelay
CODE: PLUCK (( a b c -- a b c a ))  3 4 #PARMS
      EBP { EBP 4 - } LEA { EBP } EAX MOV EAX { EBP 8 + } MOV RET ;CODE MACRO
CODE: J (( -- j ))  0 1 #PARMS
      EBP { EBP 4 - } LEA { EBP } EAX MOV EAX { ESP 12 + } MOV RET ;CODE MACRO
CODE: 01+   (( n     -- n+01    ))  1 1 #PARMS  EAX       INC RET ;CODE MACRO
CODE: 02+   (( n     -- n+02    ))  1 1 #PARMS  EAX 02  # ADD RET ;CODE MACRO
CODE: 03+   (( n     -- n+03    ))  1 1 #PARMS  EAX 03  # ADD RET ;CODE MACRO
CODE: 04+   (( n     -- n+04    ))  1 1 #PARMS  EAX 04  # ADD RET ;CODE MACRO
CODE: 08+   (( n     -- n+08    ))  1 1 #PARMS  EAX 08  # ADD RET ;CODE MACRO
CODE: 12+   (( n     -- n+12    ))  1 1 #PARMS  EAX 12  # ADD RET ;CODE MACRO
CODE: 16+   (( n     -- n+16    ))  1 1 #PARMS  EAX 16  # ADD RET ;CODE MACRO
CODE: 20+   (( n     -- n+20    ))  1 1 #PARMS  EAX 20  # ADD RET ;CODE MACRO
CODE: 24+   (( n     -- n+24    ))  1 1 #PARMS  EAX 24  # ADD RET ;CODE MACRO
CODE: 28+   (( n     -- n+28    ))  1 1 #PARMS  EAX 28  # ADD RET ;CODE MACRO
CODE: 04-   (( n     -- n-04    ))  1 1 #PARMS  EAX 04  # SUB RET ;CODE MACRO
CODE: 08-   (( n     -- n-08    ))  1 1 #PARMS  EAX 08  # SUB RET ;CODE MACRO
CODE: 08*   (( n     -- n*08    ))  1 1 #PARMS  EAX 03  # SAL RET ;CODE MACRO
CODE: 16*   (( n     -- n*16    ))  1 1 #PARMS  EAX 04  # SAL RET ;CODE MACRO
CODE: 13>>  (( n     -- n>>13   ))  1 1 #PARMS  EAX 13  # SAR RET ;CODE MACRO
PI 180 S>F F/ FVALUE PI/180
: DEG>RAD (( d -- r )) S>F PI/180 F* ;
: GrXY.R (( b f y x v n -- )) >R str R>  SWAP - 08*  >R -ROT R> + GrTextXY ;
 VARIABLE ThePoint  VARIABLE EndThePoint  CREATE Pad 32 ALLOT
 VARIABLE WinPoint  VARIABLE EndWinPoint
 VARIABLE TheCLine  VARIABLE EndTheCLine
 VARIABLE ThePlane  VARIABLE EndThePlane
 VARIABLE TheCPlane VARIABLE EndTheCPlane VARIABLE #CPlanes
 VARIABLE Fx        VARIABLE Fy           VARIABLE TheKey
 VARIABLE Ox        VARIABLE Oy           VARIABLE Size     VARIABLE Delay
2VARIABLE NNx      2VARIABLE NNy         2VARIABLE NNz     2VARIABLE DK
2VARIABLE UUx      2VARIABLE UUy         2VARIABLE UUz
2VARIABLE Nx       2VARIABLE Ny          2VARIABLE Nz      2VARIABLE Nyz
2VARIABLE NDx    2VARIABLE NDy       2VARIABLE NDz   2VARIABLE NNxyz
2VARIABLE Wx       2VARIABLE Wy          2VARIABLE Qx      2VARIABLE Qy
 VARIABLE MinZ      VARIABLE MaxZ
2VARIABLE Px       2VARIABLE Py          2VARIABLE Pz
: ComputeWinPoint   WinPoint @ 16+ DUP @ 0= SWAP 04+ @ 0= AND
  IF NNx 2@ 2DUP F* NNy 2@ 2DUP F* NNz 2@ 2DUP F* F+ F+ FSQRT
     NNx 2@ 2OVER F/                                                Nx   2!
     NNy 2@ 2OVER F/                                                Ny   2!
     NNz 2@ 2SWAP F/                                                Nz   2!
     Ny  2@ 2DUP  F* Nz 2@ 2DUP F* F+ FSQRT                         Nyz  2!
     UUx 2@ Nyz 2@ F*
     UUy 2@ Ny  2@ F* UUz 2@ Nz 2@ F* F+  Nx  2@ F* Nyz 2@ F/ F- (( WWx  ))
     UUy 2@ Nz  2@ F* UUz 2@ Ny 2@ F* F+  Nyz 2@ F/          (( WWx WWy  ))
     2OVER 2DUP F* 2OVER 2DUP F* F+ 2DUP F0=       (( WWx WWy WWxy  Flg  ))
     IF   2DROP                                    Wy    2!         Wx   2!
     ELSE FSQRT 2SWAP 2OVER F/                     Wy    2!   F/    Wx   2!
     ENDIF DK 2@ 2DUP 2DUP
     Nx 2@ F*                                                       NDx  2!
     Ny 2@ F*                                                       NDy  2!
     Nz 2@ F*                                                       NDz  2!
     ThePoint @    EndWinPoint @ WinPoint @ 16+
     DO 12+ DUP 04- DUP 04- DUP 04-
       @ Size @ * S>F                                               Px   2!
       @ Size @ * S>F                                               Py   2!
       @ Size @ * S>F                                               Pz   2!
       Px 2@ NDx 2@ F+ Nyz 2@ F*
       Py 2@ NDy 2@ F+ Ny  2@ F* Nyz 2@ F/ F-
       Pz 2@ NDz 2@ F+ Nz  2@ F* Nyz 2@ F/ Nx 2@ F* F+              Qx   2!
       Py 2@ NDy 2@ F+ Nz  2@ F* Nyz 2@ F/
       Pz 2@ NDz 2@ F+ Ny  2@ F* Nyz 2@ F/ F-                       Qy   2!
       Qx 2@ Wy  2@ F* Qy  2@    Wx  2@ F* F- F>S                   I     !
       Qx 2@ Wx  2@ F* Qy  2@    Wy  2@ F* F+ F>S                   I 04+ !
       Px 2@ NDx 2@ F+ Nx  2@ F*
       Py 2@ NDy 2@ F+ Ny  2@ F* F+
       Pz 2@ NDz 2@ F+ Nz  2@ F* F+ 1000.0 F* F>S                   I 08+ ! 16
     +LOOP DROP EndWinPoint @ WinPoint @ - 16 / 1-
                                           0 EndWinPoint @ WinPoint @ 16+
     DO I @ + 16 +LOOP OVER / WinPoint @ ! 0 EndWinPoint @ WinPoint @ 20+
     DO I @ + 16 +LOOP SWAP / WinPoint @ 04+ !
  THEN ;
CODE: GetYX (( p -- y x )) EBP { EBP 4 - } LEA      EAX INC  EAX     4 # SHL
  ESI WinPoint  # MOV  EAX { ESI } ADD  EDX { EAX 04+ } MOV  ECX { ESI } MOV
  EDX { ECX 04+ } SUB  ESI    Oy # MOV  EDX { ESI     } ADD  { EBP } EDX MOV
  EAX { EAX     } MOV  EAX { ECX } SUB  ESI   Ox      # MOV
  EAX { ESI     } ADD  RET ;CODE
CODE: GetZ  (( p -- z ))     EAX   INC  EAX         4 # SHL
  ESI WinPoint  # MOV  EAX { ESI } ADD  EAX { EAX 08+ } MOV RET ;CODE

: DrawCLines  GraphicsMode? NOT IF PAUSE EXIT THEN  Fx @ Ox @ = Fy @ Oy @ = AND
  IF  8 1 ELSE  0 8 THEN Oy @ 40 + Ox @ 40 + Oy @ 40 - Ox @ 40 - GrFilledBoxNC
  EndTheCLine @ TheCLine @
  DO  DUP I 02+ C@ OR  I C@ GetYX  I 1+ C@ GetYX  GrLineNC  4
  +LOOP DROP Delay @ TICKS ;

: DrawPlanes  GraphicsMode? NOT IF PAUSE EXIT THEN  Fx @ Ox @ = Fy @ Oy @ = AND
  IF 14 1 ELSE 15 8 THEN Oy @ 40 + Ox @ 40 + Oy @ 40 - Ox @ 40 - GrFilledBoxNC
  EndThePlane @ ThePlane @
  DO DUP I C@ GetYX I 01+ C@ GetYX GrLineNC DUP I 01+ C@ GetYX I 02+ C@ GetYX GrLineNC
     DUP I 02+ C@ GetYX I 03+ C@ GetYX GrLineNC DUP I 03+ C@ GetYX I C@ GetYX GrLineNC 4
  +LOOP DROP Fx @ Ox @ = Fy @ Oy @ = AND
  IF 1 11 Z$" T" WinPoint @ 112 + @ Oy @ +     Ox @ 18 + GrTextXY
     1 11 Z$" H" WinPoint @  80 + @ Oy @ + 12+ Ox @ 28 + GrTextXY
  THEN
  Delay @ TICKS ;

: ComputeViewDist EndTheCPlane @ TheCPlane @
  DO I I 04+ I 01+
    DO DUP C@ GetZ I C@ GetZ <
      IF DROP I
      THEN
    LOOP C@ GetZ 256* I 04+ C@ OR I 04+ ! 8
  +LOOP ;
: SortCPlanes EndTheCPlane @ 08- TheCPlane @
  DO I 04+ @ EndTheCPlane @ I 08+
     DO I 04+ @ 2DUP >
        IF NIP I @ J @ I ! J ! I 04+ @ J 04+ @ I 04+ ! J 04+ !
        ELSE DROP
        THEN 8
     +LOOP DROP 8
  +LOOP ;
: DrawCPlanes GraphicsMode? NOT IF PAUSE EXIT THEN ComputeViewDist SortCPlanes
  Fx @ Ox @ = Fy @ Oy @ = AND
  IF  8 1 ELSE  0 8 THEN Oy @ 40 + Ox @ 40 + Oy @ 40 - Ox @ 40 - GrFilledBoxNC
  EndTheCPlane @ TheCPlane @
  DO DUP I 04+ C@ OR I 03+ C@ GetYX I 02+ C@ GetYX I 01+ C@ GetYX I C@ GetYX
     Pad ! Pad 04+ ! Pad 08+ ! Pad 12+ ! Pad 16+ ! Pad 20+ ! Pad 24+ ! Pad 28+ !
     Pad 4 GrFilledPolygon // KEY 27 = ABORT" Escaped"
     8
  +LOOP DROP Delay @ TICKS ;

// ----------------------------- T A S K 1 ----------------------------------
//
//                         (-5,-5,-5)  0 ------- 1
//                                   / |       / |
//                                 4 ------- 5   |
//                                 |   |     |   | (05,05,-5)
//                                 |   3 --- | - 2
//                                 | /       | /
//                     (-5,05,05)  7 ------- 6
//
CREATE ThePoint1 // points of the cubic (X, Y, Z  are given for each point)
-5 , -5 , -5 ,   05 , -5 , -5 ,   05 , 05 , -5 ,   -5 , 05 , -5 ,
-5 , -5 , 05 ,   05 , -5 , 05 ,   05 , 05 , 05 ,   -5 , 05 , 05 ,
HERE DUP VALUE EndThePoint1 ThePoint1 - 12 / VALUE #Points1

CREATE TheCLine1  // Color lines of the cubic (2 points and 1 color for each)
0 C, 1 C, 7 C, 0 C, 0 C, 4 C, 7 C, 0 C, 0 C, 3 C, 6 C, 0 C, 1 C, 2 C, 3 C, 0 C,
1 C, 5 C, 7 C, 0 C, 2 C, 3 C, 2 C, 0 C, 2 C, 6 C, 2 C, 0 C, 3 C, 7 C, 2 C, 0 C,
4 C, 5 C, 7 C, 0 C, 4 C, 7 C, 5 C, 0 C, 5 C, 6 C, 4 C, 0 C, 6 C, 7 C, 2 C, 0 C,
HERE VALUE EndTheCLine1

CREATE ThePlane1  // Planes of the cubic (4 points are given for each plane)
0 C, 1 C, 2 C, 3 C, 3 C, 2 C, 6 C, 7 C, 0 C, 4 C, 5 C, 1 C, 7 C, 6 C, 5 C, 4 C,
HERE VALUE EndThePlane1

CREATE TheCPlane1 // Color Planes of the cubic (4 points and 1 color for each)
0 C, 1 C, 2 C, 3 C, 7 ,   0 C, 1 C, 5 C, 4 C, 6 ,   0 C, 3 C, 7 C, 4 C, 5 ,
1 C, 2 C, 6 C, 5 C, 4 ,   2 C, 3 C, 7 C, 6 C, 3 ,   4 C, 5 C, 6 C, 7 C, 2 ,
HERE VALUE EndTheCPlane1

 299 VALUE E1   -301 VALUE B1      5 VALUE D1    D1 VALUE N1
-300 VALUE NNx1   B1 VALUE NNy1 -300 VALUE NNz1  20 VALUE DK1
   0 VALUE UUx1    1 VALUE UUy1    0 VALUE UUz1   1 VALUE Delay1
   3 VALUE Size1  70 VALUE Ox1    70 VALUE Oy1

120 VALUE #Frames1
CREATE WinPoint1 #Points1 1+ 16* #Frames1 * ALLOT  WinPoint1 HERE OVER - ERASE
WinPoint1 #Points1 1+ 16* + VALUE EndWinPoint1

: InitJob1  WinPoint1 #Points1 1+ 16* #Frames1 * ERASE ;
: SwitchTo1  NNy1 E1 N1 - 1- OVER < D1 0> AND OVER B1 N1 + 1+ < D1 0< AND OR
  IF  D1 NEGATE IS D1
  THEN  D1 +  DUP IS NNy1  B1 - N1 / #Points1 1+ 16* * DUP
  0 Oy1 52 + Ox1 40 + Oy1 42 + Ox1 40 - GrFilledBox
  0 11 112 30 Size1 2 GrXY.R 0 13 112 46 NNy1 4 GrXY.R 0 11 112 78 NNz1 4 GrXY.R
  WinPoint1 + WinPoint ! EndWinPoint1 + EndWinPoint !
  NNx1 S>F NNx 2! NNy1 S>F NNy 2! NNz1 S>F NNz 2! DK1 S>F DK 2!
  UUx1 S>F UUx 2! UUy1 S>F UUy 2! UUz1 S>F UUz 2!
  Size1 Size ! Ox1 Ox ! Oy1 Oy ! Delay1 Delay !
  ThePoint1 ThePoint ! EndThePoint1 EndThePoint !
  ThePlane1 ThePlane ! EndThePlane1 EndThePlane ! ;
BACKGROUND: Job1 0 14 30 Ox1 48 - 1 1 GrXY.R
  BEGIN SwitchTo1 ComputeWinPoint DrawPlanes
  AGAIN ;

// ----------------------------- T A S K 2 ----------------------------------
//
//              -5       -3       -1       01       03       05
//
//
//
//     -5        *        *        *       00-------01        *        -5
//                                       /   \       |\
//                                     /      14-------15
//                                   /      /        |  |
//     -3        *        *        /      /02        .  |     *        -3
//                              /       / / |\       |  |
//                            /       / /   | 16     |  .
//                          /      / /       / |     |  |
//     -1        *       /       / /       /   |     .  |     *        -1
//                     /       / /      /   |  |     |  |
//                   /      / /       /     |  .     |  .
//                 /      / /       /       |  |     |  |
//     01       03      /04----- / .-------05  |    06- | ---07        01
//               |\   /    \   /             \ |      \ |     |\
//               | 17       18--------.-------19       20-------21
//               |  |                                         |  |
//     03       08- | ----.--------.-------09       10-------11  |     03
//                \ |                       |\       |\        \ |
//                 22--------.--------.-------23     | 24-------25
//                                          |  |     |  |
//     05        *        *        *       12- | ---13  |     *        05
//                                           \ |      \ |
//                                            26-------27
//
//              -5       -3       -1       01       03       05
CREATE        ThePoint2
 1 , -5 , -2 ,     3 , -5 , -2 ,     1 , -3 , -2 ,    -5 ,  1 , -2 ,
-3 ,  1 , -2 ,     1 ,  1 , -2 ,     3 ,  1 , -2 ,     5 ,  1 , -2 ,
-5 ,  3 , -2 ,     1 ,  3 , -2 ,     3 ,  3 , -2 ,     5 ,  3 , -2 ,
 1 ,  5 , -2 ,     3 ,  5 , -2 ,
 1 , -5 ,  2 ,     3 , -5 ,  2 ,     1 , -3 ,  2 ,    -5 ,  1 ,  2 ,
-3 ,  1 ,  2 ,     1 ,  1 ,  2 ,     3 ,  1 ,  2 ,     5 ,  1 ,  2 ,
-5 ,  3 ,  2 ,     1 ,  3 ,  2 ,     3 ,  3 ,  2 ,     5 ,  3 ,  2 ,
 1 ,  5 ,  2 ,     3 ,  5 ,  2 ,
HERE VALUE EndThePoint2  EndThePoint2 ThePoint2 - 12 / VALUE #Points2
CREATE        TheCLine2
00 C, 01 C, 14 C, 00 C,     01 C, 06 C, 14 C, 00 C,     06 C, 07 C, 14 C, 00 C,
07 C, 11 C, 14 C, 00 C,     11 C, 10 C, 14 C, 00 C,     10 C, 13 C, 14 C, 00 C,
13 C, 12 C, 14 C, 00 C,     12 C, 09 C, 14 C, 00 C,     09 C, 08 C, 14 C, 00 C,
08 C, 03 C, 14 C, 00 C,     03 C, 00 C, 14 C, 00 C,     02 C, 04 C, 14 C, 00 C,
04 C, 05 C, 14 C, 00 C,     05 C, 02 C, 14 C, 00 C,
14 C, 15 C, 02 C, 00 C,     15 C, 20 C, 02 C, 00 C,     20 C, 21 C, 02 C, 00 C,
21 C, 25 C, 02 C, 00 C,     25 C, 24 C, 02 C, 00 C,     24 C, 27 C, 02 C, 00 C,
27 C, 26 C, 02 C, 00 C,     26 C, 23 C, 02 C, 00 C,     23 C, 22 C, 02 C, 00 C,
22 C, 17 C, 02 C, 00 C,     17 C, 14 C, 02 C, 00 C,     16 C, 18 C, 02 C, 00 C,
18 C, 19 C, 02 C, 00 C,     19 C, 16 C, 02 C, 00 C,
00 C, 14 C, 06 C, 00 C,     01 C, 15 C, 05 C, 00 C,     06 C, 20 C, 05 C, 00 C,
07 C, 21 C, 03 C, 00 C,     11 C, 25 C, 03 C, 00 C,     10 C, 24 C, 05 C, 00 C,
13 C, 27 C, 05 C, 00 C,     12 C, 26 C, 06 C, 00 C,     09 C, 23 C, 06 C, 00 C,
08 C, 22 C, 04 C, 00 C,     03 C, 17 C, 04 C, 00 C,     02 C, 16 C, 06 C, 00 C,
04 C, 18 C, 04 C, 00 C,     05 C, 19 C, 06 C, 00 C,
HERE VALUE EndTheCLine2
CREATE        ThePlane2
00 C, 01 C, 15 C, 14 C,     00 C, 03 C, 17 C, 14 C,     01 C, 06 C, 20 C, 15 C,
02 C, 04 C, 18 C, 16 C,     02 C, 05 C, 19 C, 16 C,     03 C, 08 C, 22 C, 17 C,
04 C, 05 C, 19 C, 18 C,     06 C, 07 C, 21 C, 20 C,     07 C, 11 C, 25 C, 21 C,
08 C, 09 C, 23 C, 22 C,     09 C, 12 C, 26 C, 23 C,     10 C, 11 C, 25 C, 24 C,
10 C, 13 C, 27 C, 24 C,     12 C, 13 C, 27 C, 26 C,
HERE VALUE EndThePlane2

-291 VALUE E2   -411 VALUE B2     10 VALUE D2    D2 VALUE N2
-300 VALUE NNx2   B2 VALUE NNy2 -300 VALUE NNz2   5 VALUE DK2
   0 VALUE UUx2 -200 VALUE UUy2    0 VALUE UUz2   1 VALUE Delay2
   5 VALUE Size2 170 VALUE Ox2    70 VALUE Oy2

120 VALUE #Frames2
CREATE WinPoint2 #Points2 1+ 16* #Frames2 * ALLOT  WinPoint2 HERE OVER - ERASE
WinPoint2 #Points2 1+ 16* + VALUE EndWinPoint2

: InitJob2              WinPoint2 #Points2 1+ 16* #Frames2 * ERASE ;
: SwitchTo2 NNy2 E2 N2 - 1- OVER < D2 0> AND OVER B2 N2 + 1+ < D2 0< AND OR
  IF  D2 NEGATE IS D2
  THEN D2 + DUP IS NNy2  B2 - N2 / #Points2 1+ 16* * DUP
  0 Oy2 52 + Ox2 40 + Oy2 42 + Ox2 40 - GrFilledBox
  0 11 112 130 Size2 2 GrXY.R 0 13 112 146 NNy2 4 GrXY.R 0 11 112 178 NNz2 4 GrXY.R
  WinPoint2 + WinPoint !  EndWinPoint2 + EndWinPoint !
  NNx2 S>F NNx 2! NNy2 S>F NNy 2! NNz2 S>F NNz 2! DK2 S>F DK 2!
  UUx2 S>F UUx 2! UUy2 S>F UUy 2! UUz2 S>F UUz 2!
  Size2 Size ! Ox2 Ox ! Oy2 Oy ! Delay2 Delay !
  ThePoint2 ThePoint ! EndThePoint2 EndThePoint !
  ThePlane2 ThePlane ! EndThePlane2 EndThePlane ! ;
BACKGROUND: Job2 0 14 30 Ox2 48 - 2 1 GrXY.R
  BEGIN SwitchTo2 ComputeWinPoint DrawPlanes
  AGAIN ;
// ----------------------------- T A S K 3 ----------------------------------
-300 VALUE NNx3 -300 VALUE NNy3 -300 VALUE NNz3  20 VALUE DK3
   1 VALUE UUx3    1 VALUE UUy3    1 VALUE UUz3   1 VALUE Delay3
   3 VALUE Size3 270 VALUE Ox3    70 VALUE Oy3   90 VALUE #Frames3

CREATE WinPoint3 #Points1 1+ 16* #Frames3 * ALLOT  WinPoint3 HERE OVER - ERASE
WinPoint3 #Points1 1+ 16* + VALUE EndWinPoint3

: InitJob3    WinPoint3 #Points1 1+ 16* #Frames3 * ERASE ;
: SwitchTo3 (( degree/4 -- )) DUP 16* #Points1 1+ * DUP
  WinPoint3 + WinPoint ! EndWinPoint3 + EndWinPoint ! CELLS 1+
  DEG>RAD 2DUP FCOS 300.0 F* F>S IS NNy3 FSIN 300.0 F* F>S IS NNz3
  0 Oy3 52 + Ox3 40 + Oy3 42 + Ox3 40 - GrFilledBox
  0 11 112 230 Size3 2 GrXY.R 0 13 112 246 NNy3 4 GrXY.R 0 11 112 278 NNz3 4 GrXY.R
  NNx3 S>F NNx 2! NNy3 S>F NNy 2! NNz3 S>F NNz 2! DK3 S>F DK 2!
  UUx3 S>F UUx 2! UUy3 S>F UUy 2! UUz3 S>F UUz 2!
  Size3 Size ! Ox3 Ox ! Oy3 Oy ! Delay3 Delay !
  ThePoint1 ThePoint ! EndThePoint1 EndThePoint !
  TheCLine1 TheCLine ! EndTheCLine1 EndTheCLine ! ;
BACKGROUND: Job3 0 14 30 Ox3 48 - 3 1 GrXY.R
  BEGIN 90 0
    DO I SwitchTo3 ComputeWinPoint DrawCLines
    LOOP
  AGAIN ;
// ----------------------------- T A S K 4 ----------------------------------
-300 VALUE NNx4 -300 VALUE NNy4 -300 VALUE NNz4  20 VALUE DK4
   0 VALUE UUx4    1 VALUE UUy4    0 VALUE UUz4   1 VALUE Delay4
   3 VALUE Size4 370 VALUE Ox4    70 VALUE Oy4

CREATE WinPoint4 #Points1 1+ 16* #Frames3 * ALLOT  WinPoint4 HERE OVER - ERASE
WinPoint4 #Points1 1+ 16* + VALUE EndWinPoint4

: InitJob4    WinPoint4 #Points1 1+ 16* #Frames3 * ERASE ;
: SwitchTo4 (( degree/4 -- )) DUP 16* #Points1 1+ * DUP
  WinPoint4 + WinPoint ! EndWinPoint4 + EndWinPoint ! CELLS 1+
  DEG>RAD 2DUP FCOS 300.0 F* F>S IS NNy4 FSIN 300.0 F* F>S IS NNz4
  0 Oy4 52 + Ox4 40 + Oy4 42 + Ox4 40 - GrFilledBox
  0 11 112 330 Size4 2 GrXY.R 0 13 112 346 NNy4 4 GrXY.R 0 11 112 378 NNz4 4 GrXY.R
  NNx4 S>F NNx 2! NNy4 S>F NNy 2! NNz4 S>F NNz 2! DK4 S>F DK 2!
  UUx4 S>F UUx 2! UUy4 S>F UUy 2! UUz4 S>F UUz 2!
  Size4 Size ! Ox4 Ox ! Oy4 Oy ! Delay4 Delay !
  ThePoint1 ThePoint ! EndThePoint1 EndThePoint !
  ThePlane1 ThePlane ! EndThePlane1 EndThePlane ! ;
BACKGROUND: Job4 0 14 30 Ox4 48 - 4 1 GrXY.R
  BEGIN 90 0
    DO I SwitchTo4 ComputeWinPoint DrawPlanes
    LOOP
  AGAIN ;
// ----------------------------- T A S K 5 ----------------------------------
-300 VALUE NNx5 -300 VALUE NNy5 -300 VALUE NNz5  20 VALUE DK5
   0 VALUE UUx5 -200 VALUE UUy5    0 VALUE UUz5   1 VALUE Delay5
   5 VALUE Size5 470 VALUE Ox5    70 VALUE Oy5   90 VALUE #Frames5

CREATE WinPoint5 #Points2 1+ 16* #Frames5 * ALLOT  WinPoint5 HERE OVER - ERASE
WinPoint5 #Points2 1+ 16* + VALUE EndWinPoint5

: InitJob5  WinPoint5 #Points2 1+ 16* #Frames5 * ERASE ;
: SwitchTo5 (( degree -- )) DUP 16* #Points2 1+ * DUP
  WinPoint5 + WinPoint ! EndWinPoint5 + EndWinPoint ! CELLS 1+ 360 SWAP -
  DEG>RAD 2DUP FCOS 300.0 F* F>S IS NNy5 FSIN 300.0 F* F>S IS NNz5
  0 Oy5 52 + Ox5 40 + Oy5 42 + Ox5 40 - GrFilledBox
  0 11 Oy5 42 + Ox5 40 - Size5 2 GrXY.R
  0 13 Oy5 42 + Ox5 24 -  NNy5 4 GrXY.R
  0 11 Oy5 42 + Ox5  8 +  NNz5 4 GrXY.R
  NNx5 S>F NNx 2! NNy5 S>F NNy 2! NNz5 S>F NNz 2! DK5 S>F DK 2!
  UUx5 S>F UUx 2! UUy5 S>F UUy 2! UUz5 S>F UUz 2!
  Size5 Size ! Ox5 Ox ! Oy5 Oy ! Delay5 Delay !
  ThePoint2 ThePoint ! EndThePoint2 EndThePoint !
  TheCLine2 TheCLine ! EndTheCLine2 EndTheCLine ! ;
BACKGROUND: Job5 0 14 30 Ox5 48 - 5 1 GrXY.R
  BEGIN 90 0
    DO I SwitchTo5 ComputeWinPoint DrawCLines
    LOOP
  AGAIN ;
// ----------------------------- T A S K 6 ----------------------------------
-300 VALUE NNx6 -300 VALUE NNy6 -300 VALUE NNz6  20 VALUE DK6
   1 VALUE UUx6    0 VALUE UUy6    1 VALUE UUz6   1 VALUE Delay6
   3 VALUE Size6 570 VALUE Ox6    70 VALUE Oy6

CREATE WinPoint6 #Points1 1+ 16* #Frames3 * ALLOT  WinPoint6 HERE OVER - ERASE
WinPoint6 #Points1 1+ 16* + VALUE EndWinPoint6

: InitJob6    WinPoint6 #Points1 1+ 16* #Frames3 * ERASE ;
: SwitchTo6 (( degree/4 -- )) DUP 16* #Points1 1+ * DUP
  WinPoint6 + WinPoint ! EndWinPoint6 + EndWinPoint ! CELLS 1+
  DEG>RAD 2DUP FCOS 300.0 F* F>S IS NNy6 FSIN 300.0 F* F>S IS NNz6
  0 Oy6 52 + Ox6 56 + Oy6 42 + Ox6 40 - GrFilledBox
  0 11 Oy6 42 + Ox6 40 - Size6 2 GrXY.R
  0 13 Oy6 42 + Ox6 24 -  NNy6 4 GrXY.R
  0 11 Oy6 42 + Ox6  8 +  NNz6 4 GrXY.R
  NNx6 S>F NNx 2! NNy6 S>F NNy 2! NNz6 S>F NNz 2! DK6 S>F DK 2!
  UUx6 S>F UUx 2! UUy6 S>F UUy 2! UUz6 S>F UUz 2!
  Size6 Size ! Ox6 Ox ! Oy6 Oy ! Delay6 Delay !
  ThePoint1 ThePoint ! EndThePoint1 EndThePoint !
  TheCPlane1 TheCPlane ! EndTheCPlane1 EndTheCPlane ! ;
BACKGROUND: Job6 0 14 30 Ox6 48 - 6 1 GrXY.R
  BEGIN 90 0
    DO I SwitchTo6 ComputeWinPoint DrawCPlanes
    LOOP
  AGAIN ;
// ----------------------------- T A S K 0 ----------------------------------
-300 VALUE NNx0 -300 VALUE NNy0 -300 VALUE NNz0  20 VALUE DK0
   0 VALUE UUx0 -200 VALUE UUy0    0 VALUE UUz0   1 VALUE Delay0
   3 VALUE Size0 470 VALUE Ox0   190 VALUE Oy0   90 VALUE #Frames0

CREATE WinPoint0 #Points2 1+ 16* #Frames0 * ALLOT  WinPoint0 HERE OVER - ERASE
WinPoint0 #Points2 1+ 16* + VALUE EndWinPoint0

: InitJob0  WinPoint0 #Points2 1+ 16* #Frames0 * ERASE ;
: SwitchTo00 (( i -- )) DUP 16* #Points2 1+ * DUP
  WinPoint0 + WinPoint !         EndWinPoint0 + EndWinPoint !
  CELLS 450 OVER -              DUP DUP IS Ox0      Ox ! Fx !
  DEG>RAD 2DUP FCOS 200.0 F* 400.0 F- 2DUP F>S IS NNy0 NNy 2!
  0 262 610 252 30 GrFilledBox
  0 11 252 Ox0 40 - Size0 2 GrXY.R 0 13 252 Ox0 24 - NNy0 4 GrXY.R
  0 11 252 Ox0  8 +  NNz0 4 GrXY.R
  190 -ROT FCOS 20.0 F* F>S +   DUP DUP IS Oy0      Oy ! Fy !
  NNx0 S>F NNx 2!        DK0 S>F  DK 2!       NNz0 S>F NNz 2!
  UUx0 S>F UUx 2!       UUy0 S>F UUy 2!       UUz0 S>F UUz 2!
  Size0 Size ! Delay0 Delay !
  ThePoint2 ThePoint ! EndThePoint2 EndThePoint !
  ThePlane2 ThePlane ! EndThePlane2 EndThePlane ! ;
: SwitchTo01 (( i -- ))     16* #Points2 1+ * DUP
  WinPoint0 + WinPoint ! EndWinPoint0 + EndWinPoint !
  Delay0 Delay ! Ox0 DUP Ox ! Fx ! Oy0 DUP Oy ! Fy !
  ThePlane2 ThePlane ! EndThePlane2 EndThePlane ! ;
BACKGROUND: Job0 0 14 130 22 0 1 GrXY.R
  BEGIN
    1 250 610 130 30 GrFilledBoxNC 90 0
    DO I SwitchTo00 ComputeWinPoint DrawPlanes
    LOOP 3 0
    DO 90 0
      DO I SwitchTo01 ComputeWinPoint DrawPlanes 5
      +LOOP
    LOOP
  AGAIN ;
: Job7 	   0 3 AT ." i Oxi Oyi Sizei Delayi UUxi UUyi UUzi"
           0 4 AT 1 . 0 5 AT 2 . 0 6 AT 3 . 0 7 AT 4 . 0 8 AT 5 . 0 9 AT 0 .
  BEGIN    2 4 AT Ox1 3 .R Oy1 4 .R Size1 6 .R Delay1 7 .R
           UUz1 UUy1 UUx1 5 .R 5 .R 5 .R
           2 5 AT Ox2 3 .R Oy2 4 .R Size2 6 .R Delay2 7 .R
           UUz2 UUy2 UUx2 5 .R 5 .R 5 .R
           2 6 AT Ox3 3 .R Oy3 4 .R Size3 6 .R Delay3 7 .R
           UUz3 UUy3 UUx3 5 .R 5 .R 5 .R
           2 7 AT Ox4 3 .R Oy4 4 .R Size4 6 .R Delay4 7 .R
           UUz4 UUy4 UUx4 5 .R 5 .R 5 .R
           2 8 AT Ox5 3 .R Oy5 4 .R Size5 6 .R Delay5 7 .R
           UUz5 UUy5 UUx5 5 .R 5 .R 5 .R
           2 9 AT Ox0 3 .R Oy0 4 .R Size0 6 .R Delay0 7 .R
           UUz0 UUy0 UUx0 5 .R 5 .R 5 .R  ?KEY
  UNTIL DROP ; Job3 WAKE
Job1 WAKE Job2 WAKE Job3 WAKE Job4 WAKE Job5 WAKE Job6 WAKE Job0 WAKE Job7
: X EndTheCPlane @ TheCPlane @
  DO CR 0 I 04+ I
     DO I C@ DUP . GetZ DUP . +
     LOOP I 04+ C@ . .
     (( KEY 27 = ABORT" escaped" )) 8
  +LOOP ;
: Z SwitchTo6 ComputeViewDist SortCPlanes X DrawCPlanes ;

