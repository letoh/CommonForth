// d3d.4th, 5 dynamic 3D graphics moving in 5 different ways (even on 386)        // 001
// Rewritten:   Sam Chen 841222                                                   // 002
// Porting to Common Forth: Luke Lee 840910                                       // 003
// Originally written: George Mai 840324                                         // 004
                                                                                  // 005
NEEDS 387FLOAT.4TH // Try NEEDS FLOAT.4TH instead of 387FLOAT.4TH, if it fails.   // 006
NEEDS GRAPHICS.4TH GRAPHICS-MODE ONLY HIDDEN ALSO GRAPHICS ALSO FORTH 		  // 007
POSTFIX SYNTAX CLS 0 200 GMaxX GMaxY 0 0 GSetScrollRange 			  // 008
                                                                                  // 009
CODE: 04+   (( n     -- n+04    ))  1 1 #PARMS  EAX 04  # ADD RET ;CODE MACRO     // 010
CODE: 08+   (( n     -- n+08    ))  1 1 #PARMS  EAX 08  # ADD RET ;CODE MACRO     // 011
CODE: 12+   (( n     -- n+12    ))  1 1 #PARMS  EAX 12  # ADD RET ;CODE MACRO     // 012
CODE: 04-   (( n     -- n-04    ))  1 1 #PARMS  EAX 04  # SUB RET ;CODE MACRO     // 013
CODE: 08*   (( n     -- n*08    ))  1 1 #PARMS  EAX 03  # SHL RET ;CODE MACRO     // 014
CODE: PLUCK (( a b c -- a b c a ))  3 4 #PARMS                                    // 015
      EBP { EBP 04- } LEA { EBP } EAX MOV EAX { EBP 08+ } MOV RET ;CODE MACRO     // 016
PI 180 S>F F/ FVALUE PI/180                            				  // 017
: DEG>RAD (( d -- r )) S>F PI/180 F* ;           				  // 018
: MS 320 * FOR #I 20 MOD 0= ?{ PAUSE }? NEXT ;
                                                                                  // 020
 VARIABLE ThePoint  VARIABLE EndThePoint  VARIABLE #Points                        // 021
 VARIABLE WinPoint  VARIABLE EndWinPoint                                          // 022
 VARIABLE TheCLine  VARIABLE EndTheCLine  VARIABLE #CLines                        // 023
 VARIABLE ThePlane  VARIABLE EndThePlane  VARIABLE #Planes                        // 024
 VARIABLE Fx        VARIABLE Fy           VARIABLE TheKey                         // 025
 VARIABLE Ox        VARIABLE Oy           VARIABLE Size     VARIABLE Delay        // 026
 VARIABLE WCx       VARIABLE WCy                         // Window Center         // 027
2VARIABLE NNx      2VARIABLE NNy         2VARIABLE NNz     2VARIABLE DK           // 028
2VARIABLE UUx      2VARIABLE UUy         2VARIABLE UUz                            // 029
2VARIABLE Nx       2VARIABLE Ny          2VARIABLE Nz      2VARIABLE Nyz          // 030
2VARIABLE Nx*DK    2VARIABLE Ny*DK       2VARIABLE Nz*DK                          // 031
2VARIABLE Wx       2VARIABLE Wy          2VARIABLE Qx      2VARIABLE Qy           // 032
2VARIABLE Px       2VARIABLE Py          2VARIABLE Pz                             // 033
                                                                                  // 034
: ComputeWinPoint   WinPoint @ DUP @ SWAP 04+ @ OR 0=                             // 035
  IF NNx 2@ 2DUP F* NNy 2@ 2DUP F* NNz 2@ 2DUP F* F+ F+ FSQRT   (( NNxyz ))       // 036
     NNx 2@ 2OVER F/                                               Nx    2!       // 037
     NNy 2@ 2OVER F/                                               Ny    2!       // 038
     NNz 2@ 2SWAP F/                                               Nz    2!       // 039
     Ny  2@ 2DUP  F* Nz 2@ 2DUP F* F+ FSQRT                        Nyz   2!       // 040
     UUx 2@ Nyz 2@ F*                                                             // 041
     UUy 2@ Ny 2@ F* UUz 2@ Nz 2@ F* F+  Nx 2@ F* Nyz 2@ F/ F-  (( WWx   ))       // 042
     UUy 2@ Nz 2@ F* UUz 2@ Ny 2@ F* F+  Nyz 2@ F/          (( WWx WWy   ))       // 043
     2OVER 2DUP F* 2OVER 2DUP F* F+ 2DUP F0=       (( WWx WWy WWxy Flg   ))       // 044
     IF   2DROP                                   Wy    2!         Wx    2!       // 045
     ELSE FSQRT 2SWAP 2OVER F/                    Wy    2!   F/    Wx    2!       // 046
     ENDIF DK 2@ 2DUP 2DUP                                                        // 047
     Nx 2@ F*                                                      Nx*DK 2!       // 048
     Ny 2@ F*                                                      Ny*DK 2!       // 049
     Nz 2@ F*                                                      Nz*DK 2!       // 050
     ThePoint @    EndWinPoint @ WinPoint @                                       // 051
     DO 12+ DUP 04- DUP 04- DUP 04-                                               // 052
       @ Size @ * S>F                                              Px    2!       // 053
       @ Size @ * S>F                                              Py    2!       // 054
       @ Size @ * S>F                                              Pz    2!       // 055
       Px 2@ Nx*DK 2@ F+ Nyz 2@ F*                                                // 056
       Py 2@ Ny*DK 2@ F+ Ny  2@ F* Nyz 2@ F/ F-                                   // 057
       Pz 2@ Nz*DK 2@ F+ Nz  2@ F* Nyz 2@ F/ Nx 2@ F* F+           Qx    2!       // 058
       Py 2@ Ny*DK 2@ F+ Nz  2@ F* Nyz 2@ F/                                      // 059
       Pz 2@ Nz*DK 2@ F+ Ny  2@ F* Nyz 2@ F/ F-                    Qy    2!       // 060
       Qx 2@ Wy  2@ F* Qy 2@ Wx 2@ F* F- F>S                       I      !       // 061
       Qx 2@ Wx  2@ F* Qy 2@ Wy 2@ F* F+ F>S                       I 04+  !  8    // 062
     +LOOP DROP                                                                   // 063
  THEN                                                                            // 064
  0 EndWinPoint @ WinPoint @     DO I @ + 8 +LOOP #Points @ /      WCx    !       // 065
  0 EndWinPoint @ WinPoint @ 04+ DO I @ + 8 +LOOP #Points @ /      WCy    ! ;     // 066
CODE: GetXY (( p -- y x ))             EBP { EBP 04- } LEA    EAX   3 # SHL       // 067
  ESI WinPoint # MOV  EAX { ESI } ADD  EDX { EAX 04+ } MOV    ESI WCy # MOV       // 068
  EDX { ESI }    SUB  ESI    Oy # MOV  EDX { ESI }     ADD  { EBP } EDX MOV       // 069
  EAX { EAX }    MOV  ESI   WCx # MOV  EAX { ESI }     SUB    ESI  Ox # MOV       // 070
  EAX { ESI }    ADD  RET   ;CODE                                                 // 071
                                                                                  // 072
: DrawCLines  GModeNow? 0= IF PAUSE EXIT THEN  Fx @ Ox @ =  Fy @ Oy @ =  AND           // 073
  IF  8 1 ELSE  0 8 THEN  Oy @ 48 + Ox @ 48 + Oy @ 48 - Ox @ 48 -  GrFilledBox    // 074
  EndTheCLine @ TheCLine  @ // Redraw the color lines as soon as possible         // 075
  DO  DUP I 08+ @ OR  I @ GetXY  I 04+ @ GetXY  GrLine  12                        // 076
  +LOOP DROP Delay @ MS ;                                                         // 077
                                                                                  // 078
: DrawPlanes  GModeNow? 0= IF PAUSE EXIT THEN  Fx @ Ox @ =  Fy @ Oy @ =  AND           // 079
  IF 14 1 ELSE 15 8 THEN  Oy @ 48 + Ox @ 48 + Oy @ 48 - Ox @ 48 -  GrFilledBox    // 080
  EndThePlane @ ThePlane  @ // Redraw the planes as soon as possible              // 081
  DO DUP I @ GetXY I 04+ @ GetXY GrLine DUP I 04+ @ GetXY I 08+ @ GetXY GrLine    // 082
     DUP I 08+ @ GetXY I 12+ @ GetXY GrLine DUP I 12+ @ GetXY I @ GetXY GrLine 16 // 083
  +LOOP DROP Delay @ MS ;                                                         // 084
// ------------------------------- J O B 1 --------------------------841222------ // 085
//                                                                                // 086
//                  (-5,-5,-5) 0---------1 (05,-5,-5)                             // 087
//                             |\        |\                                       // 088
//                    (-5,-5,05) 4 --------5 (05,-5,05)                           // 089
//                             | |       | |                                      // 090
//                  (-5,05,-5) 3-|-------2 |05,05,-5)                             // 091
//                              \|        \|                                      // 092
//                    (-5,05,05) 7 ------- 6 (05,05,05)                           // 093
//                                                                                // 094
CREATE ThePoint1 // points of the cubic (X, Y, Z  are given for each point)       // 095
-5 , -5 , -5 ,   05 , -5 , -5 ,   05 , 05 , -5 ,   -5 , 05 , -5 ,                 // 096
-5 , -5 , 05 ,   05 , -5 , 05 ,   05 , 05 , 05 ,   -5 , 05 , 05 ,                 // 097
HERE DUP VALUE EndThePoint1 ThePoint1 - 12 / VALUE #Points1                       // 098
                                                                                  // 099
CREATE TheCLine1  // Color lines of the cubic (2 points and 1 color for each)     // 100
0 , 1 , 7 ,  0 , 4 , 7 ,  0 , 3 , 6 ,  1 , 2 , 3 ,  1 , 5 , 7 ,  2 , 3 , 2 ,      // 101
2 , 6 , 2 ,  3 , 7 , 2 ,  4 , 5 , 7 ,  4 , 7 , 5 ,  5 , 6 , 4 ,  6 , 7 , 2 ,      // 102
HERE DUP VALUE EndTheCLine1 TheCLine1 - 12 / VALUE #CLines1                       // 103
                                                                                  // 104
CREATE ThePlane1  // Planes of the cubic (4 points are given for each plane)      // 105
0 , 1 , 2 , 3 ,     3 , 2 , 6 , 7 ,     0 , 4 , 5 , 1 ,      7 , 6 , 5 , 4 ,      // 106
HERE DUP VALUE EndThePlane1 ThePlane1 - 16 / VALUE #Planes1                       // 107
                                                                                  // 108
120 VALUE #Frames1                                                                // 109
CREATE WinPoint1 #Points1 08* #Frames1 * ALLOT  WinPoint1 HERE OVER - ERASE       // 110
WinPoint1 #Points1 08* + VALUE EndWinPoint1                                       // 111
                                                                                  // 112
 299 VALUE E1   -301 VALUE B1      5 VALUE D1    D1 VALUE N1                      // 113
-300 VALUE NNx1   B1 VALUE NNy1 -300 VALUE NNz1  20 VALUE DK1                     // 114
   0 VALUE UUx1    1 VALUE UUy1    0 VALUE UUz1  15 VALUE Delay1                  // 115
   3 VALUE Size1  70 VALUE Ox1    70 VALUE Oy1                                    // 116
                                                                                  // 117
: InitJob1  WinPoint1 #Points1 08* #Frames1 * ERASE ;                             // 118
                                                                                  // 119
: SwitchTo1  NNy1 E1 N1 - 1- OVER < D1 0> AND OVER B1 N1 + 1+ < D1 0< AND OR      // 120
  IF  D1 NEGATE IS D1                                                             // 121
  THEN  D1 +  DUP IS NNy1  B1 - N1 / #Points1 08* * DUP                           // 122
  WinPoint1 + WinPoint ! EndWinPoint1 + EndWinPoint !                             // 123
  NNx1 S>F NNx 2! NNy1 S>F NNy 2! NNz1 S>F NNz 2! DK1 S>F DK 2!                   // 124
  UUx1 S>F UUx 2! UUy1 S>F UUy 2! UUz1 S>F UUz 2!                                 // 125
  Size1 Size ! Ox1 Ox ! Oy1 Oy ! Delay1 Delay !                                   // 126
  ThePoint1 ThePoint ! EndThePoint1 EndThePoint ! #Points1 #Points !              // 127
  ThePlane1 ThePlane ! EndThePlane1 EndThePlane ! #Planes1 #Planes ! ;            // 128
                                                                                  // 129
BACKGROUND: Job1                                                                  // 130
  BEGIN SwitchTo1 ComputeWinPoint DrawPlanes                                      // 131
  AGAIN ;                                                                         // 132
// ------------------------------- J O B 2 --------------------------841222------ // 133
//                                                                                // 134
//          -5    -3    -1    01    03    05                                      // 135
//                                                                                // 136
//                                                                                // 137
//     -5    *     *     *    00----01     *    -5                                // 138
//                          /   14----15                                          // 139
//     -3    *     *     /   /02     | |   *    -3                                // 140
//                    /   //   |16   | |                                          // 141
//     -1    *     /   //     /  |   | |   *    -1                                // 142
//              /   //     /   | |   | |                                          // 143
//     01   03   /04----/-----05 |  06-|--07    01                                // 144
//           |17    18----------19    20----21                                    // 145
//     03   08-|--------------09    10----11 |  03                                // 146
//            22----------------23   |24----25                                    // 147
//     05    *     *     *    12-|--13 |   *    05                                // 148
//                              26----27                                          // 149
//                                                                                // 150
//          -5    -3    -1    01    03    05                                      // 151
                                                                                  // 152
CREATE ThePoint2                                                                  // 153
 1 , -5 , -2 ,     3 , -5 , -2 ,     1 , -3 , -2 ,    -5 ,  1 , -2 ,              // 154
-3 ,  1 , -2 ,     1 ,  1 , -2 ,     3 ,  1 , -2 ,     5 ,  1 , -2 ,              // 155
-5 ,  3 , -2 ,     1 ,  3 , -2 ,     3 ,  3 , -2 ,     5 ,  3 , -2 ,              // 156
 1 ,  5 , -2 ,     3 ,  5 , -2 ,                                                  // 157
 1 , -5 ,  2 ,     3 , -5 ,  2 ,     1 , -3 ,  2 ,    -5 ,  1 ,  2 ,              // 158
-3 ,  1 ,  2 ,     1 ,  1 ,  2 ,     3 ,  1 ,  2 ,     5 ,  1 ,  2 ,              // 159
-5 ,  3 ,  2 ,     1 ,  3 ,  2 ,     3 ,  3 ,  2 ,     5 ,  3 ,  2 ,              // 160
 1 ,  5 ,  2 ,     3 ,  5 ,  2 ,                                                  // 161
                                                                                  // 162
HERE VALUE EndThePoint2  EndThePoint2 ThePoint2 - 12 / VALUE #Points2             // 163
                                                                                  // 164
CREATE ThePlane2                                                                  // 165
00 , 01 , 15 , 14 ,     00 , 03 , 17 , 14 ,     01 , 06 , 20 , 15 ,               // 166
02 , 04 , 18 , 16 ,     02 , 05 , 19 , 16 ,     03 , 08 , 22 , 17 ,               // 167
04 , 05 , 19 , 18 ,     06 , 07 , 21 , 20 ,     07 , 11 , 25 , 21 ,               // 168
08 , 09 , 23 , 22 ,     09 , 12 , 26 , 23 ,     10 , 11 , 25 , 24 ,               // 169
10 , 13 , 27 , 24 ,     12 , 13 , 27 , 26 ,                                       // 170
                                                                                  // 171
HERE VALUE EndThePlane2  EndThePlane2 ThePlane2 - 16 / VALUE #Planes2             // 172
                                                                                  // 173
64 VALUE #Frames2                                                                 // 174
CREATE WinPoint2 #Points2 08* #Frames2 * ALLOT  WinPoint2 HERE OVER - ERASE       // 175
WinPoint2 #Points2 08* + VALUE EndWinPoint2                                       // 176
                                                                                  // 177
-191 VALUE E2   -511 VALUE B2      5 VALUE D2    D2 VALUE N2                      // 178
-300 VALUE NNx2   B2 VALUE NNy2 -300 VALUE NNz2   5 VALUE DK2                     // 179
   0 VALUE UUx2 -200 VALUE UUy2    0 VALUE UUz2  15 VALUE Delay2                  // 180
   5 VALUE Size2 170 VALUE Ox2    70 VALUE Oy2                                    // 181
                                                                                  // 182
: InitJob2              WinPoint2 #Points2 08* #Frames2 * ERASE ;                 // 183
                                                                                  // 184
: SwitchTo2 NNy2 E2 N2 - 1- OVER < D2 0> AND OVER B2 N2 + 1+ < D2 0< AND OR       // 185
  IF  D2 NEGATE IS D2                                                             // 186
  THEN D2 + DUP IS NNy2  B2 - N2 / #Points2 08* * DUP                             // 187
  WinPoint2 + WinPoint !  EndWinPoint2 + EndWinPoint !                            // 188
  NNx2 S>F NNx 2! NNy2 S>F NNy 2! NNz2 S>F NNz 2! DK2 S>F DK 2!                   // 189
  UUx2 S>F UUx 2! UUy2 S>F UUy 2! UUz2 S>F UUz 2!                                 // 190
  Size2 Size ! Ox2 Ox ! Oy2 Oy ! Delay2 Delay !                                   // 191
  ThePoint2 ThePoint ! EndThePoint2 EndThePoint ! #Points2 #Points !              // 192
  ThePlane2 ThePlane ! EndThePlane2 EndThePlane ! #Planes2 #Planes ! ;            // 193
                                                                                  // 194
BACKGROUND: Job2                                                                  // 195
  BEGIN SwitchTo2 ComputeWinPoint DrawPlanes                                      // 196
  AGAIN ;                                                                         // 197
                                                                                  // 198
// ------------------------------- J O B 3 --------------------------841222------ // 199
-300 VALUE NNx3 -300 VALUE NNy3 -300 VALUE NNz3  20 VALUE DK3                     // 200
   1 VALUE UUx3    1 VALUE UUy3    0 VALUE UUz3  15 VALUE Delay3                  // 201
   3 VALUE Size3 270 VALUE Ox3    70 VALUE Oy3   90 VALUE #Frames3                // 202
CREATE WinPoint3 #Points1 08* #Frames3 * ALLOT  WinPoint3 HERE OVER - ERASE       // 203
WinPoint3 #Points1 08* + VALUE EndWinPoint3                                       // 204
: InitJob3    WinPoint3 #Points1 08* #Frames3 * ERASE ;                           // 205
: SwitchTo3 (( degree/4 -- )) DUP 08* #Points1 * DUP                              // 206
  WinPoint3 + WinPoint ! EndWinPoint3 + EndWinPoint ! CELLS 1+                    // 207
  DEG>RAD 2DUP FCOS 300.0 F* F>S IS NNy3 FSIN 300.0 F* F>S IS NNz3                // 208
  NNx3 S>F NNx 2! NNy3 S>F NNy 2! NNz3 S>F NNz 2! DK3 S>F DK 2!                   // 209
  UUx3 S>F UUx 2! UUy3 S>F UUy 2! UUz3 S>F UUz 2!                                 // 210
  Size3 Size ! Ox3 Ox ! Oy3 Oy ! Delay3 Delay !                                   // 211
  ThePoint1 ThePoint ! EndThePoint1 EndThePoint ! #Points1 #Points !              // 212
  TheCLine1 TheCLine ! EndTheCLine1 EndTheCLine ! #CLines1 #CLines ! ;            // 213
BACKGROUND: Job3                                                                  // 214
  BEGIN 90 0 DO I SwitchTo3 ComputeWinPoint DrawCLines                            // 215
             LOOP                                                                 // 216
  AGAIN ;                                                                         // 217
// ------------------------------- J O B 4 --------------------------841222------ // 218
-300 VALUE NNx4 -300 VALUE NNy4 -300 VALUE NNz4  20 VALUE DK4                     // 219
   0 VALUE UUx4    1 VALUE UUy4    0 VALUE UUz4  10 VALUE Delay4                  // 220
   3 VALUE Size4 370 VALUE Ox4    70 VALUE Oy4    2 VALUE D4                      // 221
: InitJob4    WinPoint3 #Points1 08* #Frames3 * ERASE ;                           // 222
: SwitchTo4 (( degree/4 -- )) DUP 08* #Points1 * DUP                              // 223
  WinPoint3 + WinPoint ! EndWinPoint3 + EndWinPoint ! CELLS 1+                    // 224
  DEG>RAD 2DUP FCOS 300.0 F* F>S IS NNy4 FSIN 300.0 F* F>S IS NNz4                // 225
  NNx4 S>F NNx 2! NNy4 S>F NNy 2! NNz4 S>F NNz 2! DK4 S>F DK 2!                   // 226
  UUx4 S>F UUx 2! UUy4 S>F UUy 2! UUz4 S>F UUz 2!                                 // 227
  Size4 Size ! Ox4 Ox ! Oy4 Oy ! Delay4 Delay !                                   // 228
  ThePoint1 ThePoint ! EndThePoint1 EndThePoint ! #Points1 #Points !              // 229
  ThePlane1 ThePlane ! EndThePlane1 EndThePlane ! #Planes1 #Planes ! ;            // 230
BACKGROUND: Job4 BEGIN 90 0 DO I SwitchTo4 ComputeWinPoint DrawPlanes             // 231
                            LOOP                                                  // 232
                 AGAIN ;                                                          // 233
// ------------------------------- J O B 5 ------------------------ 841222 ------ // 234
-300 VALUE NNx5 -300 VALUE NNy5 -300 VALUE NNz5  20 VALUE DK5                     // 235
   0 VALUE UUx5 -200 VALUE UUy5    0 VALUE UUz5  10 VALUE Delay5                  // 236
   5 VALUE Size5 470 VALUE Ox5    70 VALUE Oy5   90 VALUE #Frames5                // 237
CREATE WinPoint5 #Points2 08* #Frames5 * ALLOT  WinPoint5 HERE OVER - ERASE       // 238
WinPoint5 #Points2 08* + VALUE EndWinPoint5                                       // 239
: InitJob5  WinPoint5 #Points2 08* #Frames5 * ERASE ;                             // 240
: SwitchTo5 (( degree -- )) DUP 08* #Points2 * DUP                                // 241
  WinPoint5 + WinPoint ! EndWinPoint5 + EndWinPoint ! CELLS 1+ 360 SWAP -         // 242
  DEG>RAD 2DUP FCOS 300.0 F* F>S IS NNy5 FSIN 300.0 F* F>S IS NNz5                // 243
  NNx5 S>F NNx 2! NNy5 S>F NNy 2! NNz5 S>F NNz 2! DK5 S>F DK 2!                   // 244
  UUx5 S>F UUx 2! UUy5 S>F UUy 2! UUz5 S>F UUz 2!                                 // 245
  Size5 Size ! Ox5 Ox ! Oy5 Oy ! Delay5 Delay !                                   // 246
  ThePoint2 ThePoint ! EndThePoint2 EndThePoint ! #Points2 #Points !              // 247
  ThePlane2 ThePlane ! EndThePlane2 EndThePlane ! #Planes2 #Planes ! ;            // 248
BACKGROUND: Job5 BEGIN 90 0 DO I SwitchTo5 ComputeWinPoint DrawPlanes             // 249
                            LOOP                                                  // 250
                 AGAIN ;                                                          // 251
: Job6 CLS 0 3 AT ." i Oxi Oyi Sizei Delayi UUxi UUyi UUzi NNxi NNyi NNzi"        // 252
           0 4 AT 1 .  0 5 AT 2 .  0 6 AT 3 .  0 7 AT 4 .  0 8 AT 5 .             // 253
  BEGIN 2 4 AT Ox1 3 .R Oy1 4 .R Size1 6 .R Delay1 7 .R                           // 254
        NNz1 NNy1 NNx1 UUz1 UUy1 UUx1 5 .R 5 .R 5 .R 5 .R 5 .R 5 .R               // 255
        2 5 AT Ox2 3 .R Oy2 4 .R Size2 6 .R Delay2 7 .R                           // 256
        NNz2 NNy2 NNx2 UUz2 UUy2 UUx2 5 .R 5 .R 5 .R 5 .R 5 .R 5 .R               // 257
        2 6 AT Ox3 3 .R Oy3 4 .R Size3 6 .R Delay3 7 .R                           // 258
        NNz3 NNy3 NNx3 UUz3 UUy3 UUx3 5 .R 5 .R 5 .R 5 .R 5 .R 5 .R               // 259
        2 7 AT Ox4 3 .R Oy4 4 .R Size4 6 .R Delay4 7 .R                           // 260
        NNz4 NNy4 NNx4 UUz4 UUy4 UUx4 5 .R 5 .R 5 .R 5 .R 5 .R 5 .R               // 261
        2 8 AT Ox5 3 .R Oy5 4 .R Size5 6 .R Delay5 7 .R                           // 262
        NNz5 NNy5 NNx5 UUz5 UUy5 UUx5 5 .R 5 .R 5 .R 5 .R 5 .R 5 .R  ?KEY         // 263
  UNTIL DROP ; Job1 WAKE  Job2 WAKE  Job3 WAKE  Job4 WAKE  Job5 WAKE  Job6        // 264
