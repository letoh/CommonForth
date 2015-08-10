// 3D cubics dynamic rotation, 5 independent tasks working in 5 different ways
// Originally written: George Mai 840324
// Porting to Common Forth: Luke Lee 840910 ( Renaming F!> Color DrawLine ... )
// Final version rewritten:   Sam Chen 841212
NEEDS 387FLOAT.4TH // Try NEEDS FLOAT.4TH instead of 387FLOAT.4TH, if it fails.
NEEDS GRAPHICS.4TH GRAPHICS-MODE ONLY HIDDEN ALSO GRAPHICS ALSO FORTH 
POSTFIX SYNTAX CLS 0 300 GMaxX GMaxY 0 0 GSetScrollRange

CODE: PLUCK (( a b c -- a b c a ))  3 4 #PARMS
      EBP { EBP 4 - } LEA { EBP } EAX MOV EAX { EBP 8 + } MOV RET ;CODE MACRO
CODE: 04+   (( n     -- n+04    ))  1 1 #PARMS  EAX 04  # ADD RET ;CODE MACRO
CODE: 08+   (( n     -- n+08    ))  1 1 #PARMS  EAX 08  # ADD RET ;CODE MACRO
CODE: 12+   (( n     -- n+12    ))  1 1 #PARMS  EAX 12  # ADD RET ;CODE MACRO
CODE: 04-   (( n     -- n-04    ))  1 1 #PARMS  EAX 04  # SUB RET ;CODE MACRO
PI 180 S>F F/ FVALUE PI/180
: DEG>RAD (( d -- r )) S>F PI/180 F* ;
: MS 320 * FOR #I 20 MOD 0= ?{ PAUSE }? NEXT ;
: Color  GSetColor ;
: DrawLine   (( X0   Y0   X1   Y1 --          ))
  GraphicsMode? ?{  GDrawLine  }{  4DROP  }? ;
: FillBox    (( X0   Y0   X1   Y1 --          ))
  GraphicsMode? ?{  GFillRectangle  }{  4DROP  }? ;
CREATE ThePoint1 // points of the cubic (X, Y, Z  are given for each point)
-5 , -5 , -5 ,   05 , -5 , -5 ,   05 , 05 , -5 ,   -5 , 05 , -5 ,
-5 , -5 , 05 ,   05 , -5 , 05 ,   05 , 05 , 05 ,   -5 , 05 , 05 ,
HERE DUP VALUE EndThePoint1 ThePoint1 - 12 / VALUE #Points1
: WinPoint1 CP @ 80 + ; : EndWinPoint1 WinPoint1 #Points1 8 * + ;
CREATE TheCLine1  // Color lines of the cubic (2 points and 1 color for each)
0 , 1 , 7 ,  0 , 4 , 7 ,  0 , 3 , 6 ,  1 , 2 , 3 ,  1 , 5 , 7 ,  2 , 3 , 2 ,
2 , 6 , 2 ,  3 , 7 , 2 ,  4 , 5 , 7 ,  4 , 7 , 5 ,  5 , 6 , 4 ,  6 , 7 , 2 ,
HERE DUP VALUE EndTheCLine1 TheCLine1 - 12 / VALUE #CLines1
CREATE ThePlane1  // Planes of the cubic (4 points are given for each plane)
0 , 1 , 2 , 3 ,          1 , 5 , 6 , 2 ,          3 , 2 , 6 , 7 ,
0 , 4 , 5 , 1 ,          7 , 6 , 5 , 4 ,          0 , 3 , 7 , 4 ,
HERE DUP VALUE EndThePlane1 ThePlane1 - 16 / VALUE #Planes1
 VARIABLE ThePoint  VARIABLE EndThePoint  VARIABLE #Points
 VARIABLE WinPoint  VARIABLE EndWinPoint
 VARIABLE TheCLine  VARIABLE EndTheCLine  VARIABLE #CLines
 VARIABLE ThePlane  VARIABLE EndThePlane  VARIABLE #Planes
 VARIABLE Fx        VARIABLE Fy           VARIABLE TheKey
 VARIABLE Ox        VARIABLE Oy           VARIABLE Size     VARIABLE Delay
 VARIABLE WCx       VARIABLE WCy                         // Window Center
2VARIABLE NNx      2VARIABLE NNy         2VARIABLE NNz     2VARIABLE DK
2VARIABLE UUx      2VARIABLE UUy         2VARIABLE UUz
2VARIABLE Nx       2VARIABLE Ny          2VARIABLE Nz      2VARIABLE Nyz
2VARIABLE Nx*DK    2VARIABLE Ny*DK       2VARIABLE Nz*DK   2VARIABLE NNxyz
2VARIABLE WWx      2VARIABLE WWy         2VARIABLE WWxy
2VARIABLE Wx       2VARIABLE Wy          2VARIABLE Qx      2VARIABLE Qy
2VARIABLE Px       2VARIABLE Py          2VARIABLE Pz
2VARIABLE CCx      2VARIABLE CCy         2VARIABLE CCz  //  Cubic Center
: ComputeWinPoint  // Given ThePoint
  NNx 2@ 2DUP F* NNy 2@ 2DUP F* NNz 2@ 2DUP F* F+ F+ FSQRT      NNxyz 2!
  NNx 2@ NNxyz 2@ F/                                            Nx    2!
  NNy 2@ NNxyz 2@ F/                                            Ny    2!
  NNz 2@ NNxyz 2@ F/                                            Nz    2!
  Ny  2@ 2DUP  F* Nz 2@ 2DUP F* F+ FSQRT                        Nyz   2!
  UUx 2@ Nyz 2@ F*
  UUy 2@ Ny 2@ F* UUz 2@ Nz 2@ F* F+  Nx 2@ F* Nyz 2@ F/ F-     WWx   2!
  UUy 2@ Nz 2@ F*  UUz 2@ Ny 2@ F*  F+  Nyz 2@ F/               WWy   2!
  WWx 2@ 2DUP F* WWy 2@ 2DUP F* F+ FSQRT                        WWxy  2!
  WWxy 2@ F0= IF 0.0 ELSE WWx 2@ WWxy 2@ F/ ENDIF               Wx    2!
  WWxy 2@ F0= IF 0.0 ELSE WWy 2@ WWxy 2@ F/ ENDIF               Wy    2!
  DK 2@ 2DUP 2DUP
  Nx 2@ F*                                                      Nx*DK 2!
  Ny 2@ F*                                                      Ny*DK 2!
  Nz 2@ F*                                                      Nz*DK 2!
  ThePoint @    EndWinPoint @ WinPoint @
  DO 12+ DUP 04- DUP 04- DUP 04-
    @ Size @ * S>F                                              Px    2!
    @ Size @ * S>F                                              Py    2!
    @ Size @ * S>F                                              Pz    2!
    Px 2@ Nx*DK 2@ F+ Nyz 2@ F*
    Py 2@ Ny*DK 2@ F+ Ny  2@ F* Nyz 2@ F/ F-
    Pz 2@ Nz*DK 2@ F+ Nz  2@ F* Nyz 2@ F/ Nx 2@ F* F+           Qx    2!
    Py 2@ Ny*DK 2@ F+ Nz  2@ F* Nyz 2@ F/
    Pz 2@ Nz*DK 2@ F+ Ny  2@ F* Nyz 2@ F/ F-                    Qy    2!
    Qx 2@ Wy  2@ F* Qy 2@ Wx 2@ F* F- F>S                       I      !
    Qx 2@ Wx  2@ F* Qy 2@ Wy 2@ F* F+ F>S                       I 04+  !  8
  +LOOP DROP
  0 EndWinPoint @ WinPoint @     DO I @ + 8 +LOOP #Points @ /   WCx    !
  0 EndWinPoint @ WinPoint @ 04+ DO I @ + 8 +LOOP #Points @ /   WCy    ! ;
: GetXY (( p -- X Y ))
  8 * WinPoint @ + DUP @ WCx @ - Ox @ + SWAP 04+ @ WCy @ - Oy @ + ;
: DrawCLines ComputeWinPoint  Fx @ Ox @ = Fy @ Oy @ = AND
  IF 8 1 ELSE 0 8 THEN Color Ox @ 48 - Oy @ 48 - Ox @ 48 + Oy @ 48 + FillBox
  EndTheCLine @ TheCLine @
  DO  DUP I 08+ @ OR  Color  I @ GetXY  I 04+ @ GetXY  DrawLine  12
  +LOOP DROP Delay @ MS ;
: DrawPlanes ComputeWinPoint  Fx @ Ox @ = Fy @ Oy @ = AND
  IF 14 1 ELSE 15 8 THEN Color Ox @ 48 - Oy @ 48 - Ox @ 48 + Oy @ 48 + FillBox  Color
  EndThePlane @ ThePlane @
  DO I @ GetXY I 04+ @ GetXY DrawLine I 04+ @ GetXY I 08+ @ GetXY DrawLine
     I 08+ @ GetXY I 12+ @ GetXY DrawLine I 12+ @ GetXY I @ GetXY DrawLine 16
  +LOOP Delay @ MS ;
// ----------------------------- T A S K 1 ----------------------------------
-300 VALUE NNx1 -300 VALUE NNy1 -300 VALUE NNz1  20 VALUE DK1
   0 VALUE UUx1    1 VALUE UUy1    0 VALUE UUz1   5 VALUE Delay1
   3 VALUE Size1  70 VALUE Ox1    70 VALUE Oy1
 301 VALUE E1   -301 VALUE B1      9 VALUE D1    B1 VALUE N1
: SwitchTo1
  D1 0>  N1 E1 >  AND  D1 0<  N1 B1 <  AND  OR
  IF  D1 NEGATE IS D1
  THEN  N1 D1 + DUP IS N1 IS NNy1
  NNx1 S>F NNx 2! NNy1 S>F NNy 2! NNz1 S>F NNz 2! DK1 S>F DK 2!
  UUx1 S>F UUx 2! UUy1 S>F UUy 2! UUz1 S>F UUz 2!
  Size1 Size ! Ox1 Ox ! Oy1 Oy ! Delay1 Delay !
  ThePoint1 ThePoint ! EndThePoint1 EndThePoint ! #Points1 #Points !
  WinPoint1 WinPoint ! EndWinPoint1 EndWinPoint !
  ThePlane1 ThePlane ! EndThePlane1 EndThePlane ! #Planes1 #Planes ! ;
BACKGROUND: TASK1
  BEGIN SwitchTo1 DrawPlanes
  AGAIN ;
// ----------------------------- T A S K 2 ----------------------------------
//
//              -5       -3       -1       01       03       05
//
//
//                                        00       01
//     -5        *        *        *        *--------*        *        -5
//                                        /  14      |15
//                                     /       .--------.
//                                   /    02 /       |  |
//     -3        *        *        /      / *        *  |     *        -3
//                              /       / / |16      |  |
//                            /       / /   |  .     |  .
//                          /      / /       / |     |  |
//     -1        *       /       / /       /   |     *  |     *        -1
//                     /       / /      /   |  |     |  |
//                   /      / /       /     |  .     |  .
//             03  /    04/ /       /     05|  |   06|  |    07
//     01        *      / *----- / *--------*  |     *- | ----*        01
//               |17  /    18  /             19|      20|     |21
//               |  .        .--------.--------.        .--------.
//             08|  |                     09       10       11|  |
//     03        *- | ----*--------*--------*        *--------*  |     03
//                22|                       |23      |24       25|
//                  .--------.--------.--------.     |  .--------.
//                                        12|  |   13|  |
//     05        *        *        *        *- | ----*  |     *        05
//                                           26|      27|
//                                             .--------.
//
//              -5       -3       -1       01       03       05
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
: WinPoint2 CP @ 80 + ; : EndWinPoint2 WinPoint2 #Points2 8 * + ;
CREATE ThePlane2
00 , 01 , 15 , 14 ,     00 , 03 , 17 , 14 ,     01 , 06 , 20 , 15 ,
02 , 04 , 18 , 16 ,     02 , 05 , 19 , 16 ,     03 , 08 , 22 , 17 ,
04 , 05 , 19 , 18 ,     06 , 07 , 21 , 20 ,     07 , 11 , 25 , 21 ,
08 , 09 , 23 , 22 ,     09 , 12 , 26 , 23 ,     10 , 11 , 25 , 24 ,
10 , 13 , 27 , 24 ,     12 , 13 , 27 , 26 ,
HERE VALUE EndThePlane2  EndThePlane2 ThePlane2 - 16 / VALUE #Planes2
-300 VALUE NNx2 -300 VALUE NNy2 -300 VALUE NNz2   5 VALUE DK2
   0 VALUE UUx2 -300 VALUE UUy2    0 VALUE UUz2  10 VALUE Delay2
   5 VALUE Size2 170 VALUE Ox2    70 VALUE Oy2
-301 VALUE E2   -401 VALUE B2     20 VALUE D2    B2 VALUE N2
: SwitchTo2
  D2 0>  N2 E2 >  AND  D2 0<  N2 B2 <  AND  OR
  IF  D2 NEGATE IS D2
  THEN  N2 D2 + IS N2  N2 IS NNy2
  NNx2 S>F NNx 2! NNy2 S>F NNy 2! NNz2 S>F NNz 2! DK2 S>F DK 2!
  UUx2 S>F UUx 2! UUy2 S>F UUy 2! UUz2 S>F UUz 2!
  Size2 Size ! Ox2 Ox ! Oy2 Oy ! Delay2 Delay !
  ThePoint2 ThePoint ! EndThePoint2 EndThePoint ! #Points2 #Points !
  WinPoint2 WinPoint ! EndWinPoint2 EndWinPoint !
  ThePlane2 ThePlane ! EndThePlane2 EndThePlane ! #Planes2 #Planes ! ;
BACKGROUND: TASK2
  BEGIN SwitchTo2 DrawPlanes
  AGAIN ;
// ----------------------------- T A S K 3 ----------------------------------
-300 VALUE NNx3 -300 VALUE NNy3 -300 VALUE NNz3  20 VALUE DK3
   0 VALUE UUx3    1 VALUE UUy3    0 VALUE UUz3   5 VALUE Delay3
   3 VALUE Size3 270 VALUE Ox3    70 VALUE Oy3
: SwitchTo3 (( degree -- ))
  DEG>RAD 2DUP FCOS 300.0 F* F>S IS NNy3 FSIN 300.0 F* F>S IS NNz3
  NNx3 S>F NNx 2! NNy3 S>F NNy 2! NNz3 S>F NNz 2! DK3 S>F DK 2!
  UUx3 S>F UUx 2! UUy3 S>F UUy 2! UUz3 S>F UUz 2!
  Size3 Size ! Ox3 Ox ! Oy3 Oy ! Delay3 Delay !
  ThePoint1 ThePoint ! EndThePoint1 EndThePoint ! #Points1 #Points !
  WinPoint1 WinPoint ! EndWinPoint1 EndWinPoint !
  TheCLine1 TheCLine ! EndTheCLine1 EndTheCLine ! #CLines1 #CLines ! ;
BACKGROUND: TASK3
  BEGIN 361 1
    DO I SwitchTo3 DrawCLines 3
    +LOOP
  AGAIN ;
// ----------------------------- T A S K 4 ----------------------------------
-300 VALUE NNx4 -300 VALUE NNy4 -300 VALUE NNz4  20 VALUE DK4
   0 VALUE UUx4    1 VALUE UUy4    0 VALUE UUz4  10 VALUE Delay4
   3 VALUE Size4 370 VALUE Ox4    70 VALUE Oy4
: SwitchTo4
  DEG>RAD 2DUP FCOS 300.0 F* F>S IS NNy4 FSIN 300.0 F* F>S IS NNz4
  NNx4 S>F NNx 2! NNy4 S>F NNy 2! NNz4 S>F NNz 2! DK4 S>F DK 2!
  UUx4 S>F UUx 2! UUy4 S>F UUy 2! UUz4 S>F UUz 2!
  Size4 Size ! Ox4 Ox ! Oy4 Oy ! Delay4 Delay !
  ThePoint1 ThePoint ! EndThePoint1 EndThePoint ! #Points1 #Points !
  WinPoint1 WinPoint ! EndWinPoint1 EndWinPoint !
  ThePlane1 ThePlane ! EndThePlane1 EndThePlane ! #Planes1 #Planes ! ;
BACKGROUND: TASK4
  BEGIN 361 1
    DO I SwitchTo4 DrawPlanes 3
    +LOOP
  AGAIN ;
// ----------------------------- T A S K 5 ----------------------------------
-300 VALUE NNx5 -300 VALUE NNy5 -300 VALUE NNz5  20 VALUE DK5
   0 VALUE UUx5 -200 VALUE UUy5    0 VALUE UUz5  10 VALUE Delay5
   5 VALUE Size5 470 VALUE Ox5    70 VALUE Oy5
: SwitchTo5
  DEG>RAD 2DUP FCOS 300.0 F* F>S IS NNy5 FSIN 300.0 F* F>S IS NNz5
  NNx5 S>F NNx 2! NNy5 S>F NNy 2! NNz5 S>F NNz 2! DK5 S>F DK 2!
  UUx5 S>F UUx 2! UUy5 S>F UUy 2! UUz5 S>F UUz 2!
  Size5 Size ! Ox5 Ox ! Oy5 Oy ! Delay5 Delay !
  ThePoint2 ThePoint ! EndThePoint2 EndThePoint ! #Points2 #Points !
  WinPoint2 WinPoint ! EndWinPoint2 EndWinPoint !
  ThePlane2 ThePlane ! EndThePlane2 EndThePlane ! #Planes2 #Planes ! ;
BACKGROUND: TASK5
  BEGIN 0 -359
    DO I NEGATE SwitchTo5 DrawPlanes 4
    +LOOP
  AGAIN ;
TASK1 WAKE  TASK2 WAKE  TASK3 WAKE  TASK4 WAKE  TASK5 WAKE
: Frame (( ox oy -- )) Fy ! Fx !
  Fx @ 50 - Fy @ 49 - OVER Fy @ 49 + DrawLine
  Fx @ 49 - Fy @ 50 - Fx @ 49 + OVER DrawLine
  Fx @ 50 + Fy @ 49 - OVER Fy @ 49 + DrawLine
  Fx @ 49 - Fy @ 50 + Fx @ 49 + OVER DrawLine ;
: .TASK1
  WHITE Color Fx @ Fy @ Frame YELLOW Color Ox1 Oy1 Frame
  0 2 AT ."   Ox1 Oy1 Size1 Delay1 NNx1 NNy1 NNz1"
  0 3 AT Ox1 5 .R Oy1 4 .R Size1 6 .R
         Delay1 7 .R NNz1 NNy1 NNx1 5 .R 5 .R 5 .R ;
: .TASK2
  WHITE Color Fx @ Fy @ Frame  YELLOW Color Ox2 Oy2 Frame
  0 2 AT ."   Ox2 Oy2 Size2 Delay2 NNx2 NNy2 NNz2"
  0 3 AT Ox2 5 .R Oy2 4 .R Size2 6 .R
         Delay2 7 .R NNz2 NNy2 NNx2 5 .R 5 .R 5 .R ;
: .TASK3
  WHITE Color Fx @ Fy @ Frame  YELLOW Color Ox3 Oy3 Frame
  0 2 AT ."   Ox3 Oy3 Size3 Delay3 NNx3 NNy3 NNz3"
  0 3 AT Ox3 5 .R Oy3 4 .R Size3 6 .R
         Delay3 7 .R NNz3 NNy3 NNx3 5 .R 5 .R 5 .R ;
: .TASK4
  WHITE Color Fx @ Fy @ Frame  YELLOW Color Ox4 Oy4 Frame
  0 2 AT ."   Ox4 Oy4 Size4 Delay4 NNx4 NNy4 NNz4"
  0 3 AT Ox4 5 .R Oy4 4 .R Size4 6 .R
         Delay4 7 .R NNz4 NNy4 NNx4 5 .R 5 .R 5 .R ;
: .TASK5
  WHITE Color Fx @ Fy @ Frame  YELLOW Color Ox5 Oy5 Frame
  0 2 AT ."   Ox5 Oy5 Size5 Delay5 NNx5 NNy5 NNz5"
  0 3 AT Ox5 5 .R Oy5 4 .R Size5 6 .R
         Delay5 7 .R NNz5 NNy5 NNx5 5 .R 5 .R 5 .R ;
: .Dynamic (( 0 -- 0 / k -1 -- k -1 ))
  22 3 AT   Fx @ Ox1 = Fy @ Oy1 = AND
  IF          NNz1 NNy1 NNx1
  ELSE      Fx @ Ox2 = Fy @ Oy2 = AND
    IF        NNz2 NNy2 NNx2
    ELSE    Fx @ Ox3 = Fy @ Oy3 = AND
       IF     NNz3 NNy3 NNx3
       ELSE Fx @ Ox4 = Fy @ Oy4 = AND
         IF   NNz4 NNy4 NNx4
         ELSE NNz5 NNy5 NNx5
         THEN
       THEN
    THEN
  THEN 5 .R 5 .R 5 .R ;
: Monitoring
   CLS ." Press the key ESC, '1', '2', '3', '4' or '5': " 47 0 AT 49 EMIT
   WHITE  Color Ox5 Oy5 Frame Ox4 Oy4 Frame Ox3 Oy3 Frame Ox2 Oy2 Frame
   YELLOW Color Ox1 Oy1 Frame .TASK1
   BEGIN PAUSE 1 1 AT ?KEY .Dynamic
     IF DUP
       CASE
         27 OF 0  4 AT ." All the following VALUEs may be changed directly: "               CR ."    Ox1 Oy1 Size1 BackGround1 ForeGround1 Delay1   "
               0  5 AT ."    Ox1 Oy1 Size1 Delay1"
               0  6 AT ."    Ox2 Oy2 Size2 Delay2"
               0  7 AT ."    . . . . . . . . . ."
               0  8 AT ."    Ox5 Oy5 Size5 Delay5"
               0  9 AT ." Change them by word IS.   For example: 4 IS Size1 "
               0 10 AT QUIT ENDOF
         49 OF .TASK1 ENDOF
         50 OF .TASK2 ENDOF
         51 OF .TASK3 ENDOF
         52 OF .TASK4 ENDOF
         53 OF .TASK5 ENDOF BEEP
       ENDCASE  47 0 AT EMIT
     THEN
   AGAIN ; Monitoring
