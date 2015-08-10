// ~T38X0L8Q(99,70)D(50,50,2399,50,1)D(50,50,50,3149,1)D(50,3149,2399,3149,1)D(2399,50,2399,3149,1);
// Extend Head Attribute A Little Bit /////////////////////////////////////////////////////////////////////////// // 002
//                      7 6 5 4 3 2 1 0   F E D C B A 9 8                                                         // 003
//                    ¢z¢s¢s¢s¢s¢s¢s¢s¢{¢z¢s¢s¢s¢s¢s¢s¢s¢{                                                        // 004
//                    ¢|¢r¢r¢r¢r¢r¢r¢r¢}¢|¢r¢r¢r¢r¢r¢r¢r¢}                                                        // 005
//               Macro ¢}¢x¢x¢x¢x¢x¢x¢x  ¢x¢x¢x¢x¢x¢x¢x¢| Inline 1-Byte Handler                                   // 006
//  C(++) infix function ¢}¢x¢x¢x¢x¢x¢x  ¢x¢x¢x¢x¢x¢x¢| Inline 2 -Byte Handler                                    // 007
//                         ¢}¢x¢x¢x¢x¢x  ¢x¢x¢x¢x¢x¢| Inline 4-Byte Handler                                       // 008
//                           ¢}¢x¢x¢x¢x  ¢x¢x¢x¢x¢| Not-debugable                                                 // 009
//                             ¢}¢x¢x¢x  ¢x¢x¢x¢| 1-Token Handler                                                 // 010
//                     Invisible ¢}¢x¢x  ¢x¢x¢| 2-Token Handler                                                   // 011
//                    Compile only ¢}¢x  ¢x¢| Inline Z-String Handler                                             // 012
//                         Immediate ¢}  ¢| Inline Counted String Handler                                         // 013
NEEDS SEE.4TH
ONLY HIDDEN DEFINITIONS ALSO ASSEMBLER ALSO FORTH ALSO HEX POSTFIX SYNTAX  // 841128³¯²n  For Common Forth 1.650  // 001
80 VALUE $Msk    40 VALUE ZMsk    07 VALUE PMsk   C7 VALUE IMsk   08 VALUE NMsk                                   // 029
// Extend Assembler A Little Bit //////////////////////////////////////////////////////////////////////////////// // 014
E8 VALUE CalCod  E9 VALUE JmpCod  C3 VALUE RetCod  0 VALUE CurIns  0 VALUE NxtIp  0 VALUE NxtIns  0 VALUE Key     // 030
 0 VALUE Indent
FORTH DEFINITIONS                                                                                                 // 031
: (: 0 BEGIN BL WORD COUNT 2 = >R " --" COMP 0= R> AND NOT   (( n TOKENs ))                                       // 021
       WHILE 1+ REPEAT                                                                                            // 022
     0 BEGIN BL WORD COUNT 2 = >R " :)" COMP 0= R> AND NOT                                                        // 023
       WHILE 1+ REPEAT #PARMS ;         IMMEDIATE             0 0 #PARMS                                          // 024
: [COMPILE]      (: -- :) ' call, ; IMMEDIATE COMPILEONLY                                                         // 015
' CODE: ALIAS A: (: -- :)                                                                                         // 016
: ;M             (: -- :) CONTEXT @ HASHTABLE>BODY BODY> ['] ASSEMBLER =                                          // 017
  IF RetCod C, [ ASSEMBLER ' ;CODE call, FORTH ]                                                                  // 018
  ELSE [COMPILE] ;                                                                                                // 019
  THEN MACRO ;                          IMMEDIATE                                                                 // 020
A: AdrCalled (: na  -- ca    :) EAX { EAX CELL- } ADD                ;M                                           // 025
 : BOUNDS    (: a n -- a+n a :) INLINE[ EAX { EBP } ADD ]INLINE SWAP ;M                                           // 026
 : COL       (: x   --       :) AT? NIP AT                           ;   // move cursor to x position             // 027
 : #TKN DUP 3 > ABORT" Can't handle more than 3 tokens" ' >HEAD |ATTRIBUTE 1+                                     // 034
   (( n a )) DUP C@ 30 NOT AND ROT 10 * OR SWAP C! ;                                                              // 035
 : INLINE    (: msk --       :) IMsk AND ' >HEAD |ATTRIBUTE 1+ DUP C@ ROT  OR SWAP C! ; 1 #TKN INLINE             // 032
 : NotDebug  (:     --       :)          ' >HEAD |ATTRIBUTE 1+ DUP C@ NMsk OR SWAP C! ; 1 #TKN NotDebug           // 033
HIDDEN DEFINITIONS                                                                                                // 036
 : DisAsm1   (: a   -- b     :) DUP DISASSEMBLE SWAP SHOW-CODES @
   IF   BASE @ >R HEX DUP 6 U.R SPACE
        BEGIN DUP TC@ 2 U.0R 1+ 2DUP =
        UNTIL DROP AT? NIP 15 Indent + SWAP AT SPACE R> BASE !
   ELSE DROP
   THEN DisassembledInstruction DUP ShowPrefixes DUP ShowOperands ShowMemonic ;
 : Code>Head (: a   -- h     :) DUP valid-addr? // Return 0 if not valid
   IF   >HEAD DUP valid-addr? NOT
        IF   DROP 0
        ELSE DUP @
             DUP valid-addr?       // This line is added by SamChen 841127
             IF                    // This line is added by SamChen 841127
                  >HEAD OVER = NOT
                  IF DROP 0
                  ENDIF
             ELSE 2DROP 0          // This line is added by SamChen 841127
             THEN                  // This line is added by SamChen 841127
        THEN
   ELSE DROP 0
   THEN ;
: AtrChk: CREATE ] DOES> >R (( na ))                                                                              // 037
   DUP DUP 5 - C@ (( na na CurIns ))                                                                              // 038
   DUP CalCod = SWAP JmpCod = OR (( na na f ))          // If it's CALL or JMP                                    // 039
   IF DUP 0 SP@ BETWEEN                                 // If the addr is in RAM                                  // 040
      IF AdrCalled Code>Head (( na h )) DUP             // If it is a real HEAD                                   // 041
         IF (( na h )) |ATTRIBUTE 1+ C@ EXIT            // Get extended attribute                                 // 042
         THEN                                                                                                     // 043
      THEN                                              // Not a Real Head                                        // 044
   THEN (( na h ))                                                                                                // 045
   R> 2DROP FALSE ;                                     // Neither CALL nor JMP                                   // 046
AtrChk: ZMsk? (: na -- na f :) ZMsk AND 0<> ;   AtrChk: $Msk? (: na -- na f :) $Msk AND 0<> ;                     // 047
AtrChk: NMsk? (: na -- na f :) NMsk AND 0<> ;   AtrChk: PMsk? (: na -- na f :) PMsk AND     ;                     // 048
: DMsk? (: -- f :) NxtIp NMsk? NIP NOT ;                                                                          // 049
: ZStr. (: a -- a' :) CR DUP . DUP DUP C@ 2 + 6 Indent + MIN BOUNDS DO I C@ <# # # #> TYPE LOOP COUNT 15 Indent + COL      // 052
  2DUP ."  $," ASCII " EMIT SPACE TYPE ASCII " EMIT + DUP C@ SPACE . ." C, " 1+ ;                                 // 053
: $Str. (: a -- a' :) CR DUP . DUP DUP C@  1+ 6 Indent + MIN BOUNDS DO I C@ <# # # #> TYPE LOOP COUNT 15 Indent + COL      // 050
  2DUP ."  $," ASCII " EMIT SPACE TYPE ASCII " EMIT + ; // 123                                                    // 051
: .INLINE (: na -- na' :) ZMsk?                       // If inline z-string                                       // 054
  IF ZStr.                                                                                                        // 055
  ELSE $Msk?                                          // If inline counted string                                 // 056
     IF $Str.                                                                                                     // 057
     ELSE PMsk? ?DUP                                                                                              // 058
        IF DUP 5 =                                    // If inline 5-byte                                         // 059
           IF DROP CR DisAsm1                                                                                     // 060
           ELSE CR OVER . TUCK 0                      // If inline n-byte                                         // 061
              DO DUP C@ <# # # #> TYPE 1+                                                                         // 062
              LOOP SWAP 4 =                                                                                       // 063
              IF 16 Indent + COL DUP CELL- @ . ." ,"                                                              // 064
              THEN                                                                                                // 065
// ~T38X0L8Q(99,70)D(50,50,2399,50,1)D(50,50,50,3149,1)D(50,3149,2399,3149,1)D(2399,50,2399,3149,1);
           THEN                                                                                                   // 066
        THEN                                                                                                      // 067
     THEN                                                                                                         // 068
  THEN ;                                                                                                          // 069
FORTH DEFINITIONS                                                                                                 // 070
// Extend Disassembler A Little Bit ///////////////////////////////////////////////////////////////////////////// // 071
: <D> (: start -- :) 0 IS Indent   // start is the location to be disassembled                                    // 072
  BASE @ SWAP (( base start )) HEX // switch base to hexadecimal                                                  // 073
  DUP Code>Head ?DUP               // give 0 if no head                                                           // 074
  IF DUP CR ." The word " .ID SPACE                                                                               // 075
     DUP |ATTRIBUTE C@ ?DUP             // check if some attributes exist                                         // 076
     IF ." is " DUP IMMED AND           // if it is an immediate word                                             // 077
        IF ." Immediate "                                                                                         // 078
        THEN  DUP COMPO AND             // if it is a compile-only word                                           // 079
        IF ." CompileOnly "                                                                                       // 080
        THEN  DUP INVIS-MASK AND        // if it is an invisible word                                             // 081
        IF ." Invisible "                                                                                         // 082
        THEN  DUP 40 AND                // if it is a C(++) infix function                                        // 083
        IF ." C(++) infix function "                                                                              // 084
        THEN  MACRO-MASK AND            // if it is a macro for expansion                                         // 085
        IF ." Macro "                                                                                             // 086
        THEN                                                                                                      // 087
     THEN DUP |ATTRIBUTE 1+ C@ NMsk AND // if it is not debugable                                                 // 088
     IF CR ." Not debugable "                                                                                     // 089
     THEN DUP |ATTRIBUTE 1+ C@ IMsk AND ?DUP   // if an inline parm handler                                       // 090
     IF CR ." Handling inline " DUP $Msk AND   //       inline counted string                                     // 091
        IF DROP ." counted string "                                                                               // 092
        ELSE DUP ZMsk AND                                                                                         // 093
           IF DROP ." z-string "               //       inline z-string                                           // 094
           ELSE 7 AND 1 .R ." -byte "          //       inline n-byte                                             // 095
           THEN                                                                                                   // 096
        THEN                                                                                                      // 097
     THEN DUP |ATTRIBUTE 1+ C@ 30 AND ?DUP     // if a token handler                                              // 098
     IF 10 / ." Handling " DUP . ." token" 1 >                                                                    // 099
        IF ." s"                                                                                                  // 100
        THEN SPACE                                                                                                // 101
     THEN DUP |OUT-PARMS C@ OVER |IN-PARMS C@                                                                     // 102
     2DUP AND 0FF XOR                          // check if #PARMS are declared                                    // 103
     IF ." , " . . ." #PARMS"                                                                                     // 104
     ELSE 2DROP                                                                                                   // 105
     THEN  |SIZE @                             // size of the body                                                // 106
  ELSE 80                                      // 128 bytes as default size                                       // 107
  THEN OVER + SWAP                             // (( base limit start ))                                          // 108
  BEGIN CR DisAsm1 SPACE .INLINE                                                                                  // 109
     BEGIN KEY DUP 1B = OVER ASCII q = OR OVER ASCII Q = OR                                                       // 110
        IF 3DROP BASE ! CR ." Escaped" CR QUIT                                                                    // 111
        THEN DUP ASCII f = OVER ASCII F = OR                                                                      // 112
        IF DROP CR ." f> " QUERY EVAL FALSE                                                                       // 113
        THEN                                                                                                      // 114
     UNTIL 2DUP <=                            // check if the location is still in body                           // 115
  UNTIL 2DROP BASE ! CR ;                     // restore base                                                     // 116
: D (: -- :) ' <D> ;    (( 1 TOKEN ))                                                                             // 117
// A Simple Debuger ///////////////////////////////////////////////////////////////////////////////////////////// // 118
DEFER SetBrk                                                                                                      // 119
HIDDEN DEFINITIONS                                                                                                // 120
CREATE BrkBuf 90 ALLOT BrkBuf 90 0 FILL  HERE CONSTANT BrkLmt  CREATE Reg 20 ALLOT VARIABLE OldBas                // 121
: RcvCod (: -- :) BrkLmt BrkBuf                                                                                   // 122
  BEGIN DUP @                                                                                                     // 123
     IF  DUP CELL+  OVER @  5  CMOVE   0 OVER !                                                                   // 124
     THEN  9 + 2DUP <=                                                                                            // 125
  UNTIL 2DROP ;                                                                                                   // 126
A: SavReg (: -- :) PUSHFD                                                                                         // 127
        EAX PUSH   EAX   Reg  # MOV      { EAX } POP  { EAX 1C + } POP                                            // 128
      { EAX 04 + } EDX   MOV  { EAX 08 + } ECX   MOV                                                              // 129
      { EAX 0C + } ESI   MOV  { EAX 10 + } EDI   MOV                                                              // 130
// ~T38X0L8Q(99,70)D(50,50,2399,50,1)D(50,50,50,3149,1)D(50,3149,2399,3149,1)D(2399,50,2399,3149,1);
      { EAX 14 + } EBP   MOV  { EAX 18 + } ESP   MOV                                                              // 131
        EDX     { BASE } MOV   // get  current base                                                               // 132
      { OldBas }   EDX   MOV   // save current base                                                               // 133
        EDX         10 # MOV  { BASE }     EDX   MOV   // switch to HEX                                           // 134
        EAX      { EAX } MOV  ;M                                                                                  // 135
A: LoaReg (: -- :) EAX Reg # MOV                                                                                  // 136
        EDX { OldBas }   MOV   // get original base                                                               // 137
      { BASE }   EDX     MOV   // back to original base                                                           // 138
        ESP { EAX 18 + } MOV    EBP { EAX 14 + } MOV                                                              // 139
        EDI { EAX 10 + } MOV    ESI { EAX 0C + } MOV                                                              // 140
        ECX { EAX 08 + } MOV    EDX { EAX 04 + } MOV                                                              // 141
      { EAX 1C + } PUSH  POPFD  EAX { EAX }      MOV  ;M
: CurRet (: -- f :) CurIns RetCod = ; : NxtRet (: -- f :) NxtIns RetCod = ;                                       // 143
: CurJmp (: -- f :) CurIns JmpCod = ; : CurCal (: -- f :) CurIns CalCod = ;                                       // 144
: ClrTop (: -- :)                    // clear top lines of the screen                                             // 145
  0 DUP BIOSAT  (get-page) FF00 AND 7 OR NIP 140 SWAP  920 10 trap 8DROP ;                                        // 146
' (LOOP) VALUE 'loop ' (+LOOP) VALUE '+loop ' (?DO) VALUE '?do 0 VALUE NxtIp'                                     // 147
: GetDbgKey (: -- k :)                                                                                            // 148
  BEGIN 40 COL SPACE KEY DUP 1B = OVER ASCII q = OR OVER ASCII Q = OR                                             // 149
     IF DROP CR ." Quited from " . CR QUIT                                                                        // 150
     THEN DUP 20 < OVER 7E > OR                                                                                   // 151
     IF DROP 20                                                                                                   // 152
     THEN DUP EMIT SPACE DUP ASCII f = OVER ASCII F = OR                                                          // 153
     IF DROP CR ." f> " QUERY EVAL FALSE                                                                          // 154
     ELSE DUP ASCII ? =                                                                                           // 155
        IF DROP CR ." q  quit"                                                                                    // 156
                CR ." ?  show this hint"                                                                          // 157
                CR ." f  enter forth words to be executed"                                                        // 158
                CR ." r  resume"                                                                                  // 159
                CR ." o  break at next upper level instruction when return from this subroutine"                  // 160
                CR ." s  break at first instruction of the subroutine being called"                               // 161
                CR ." n  break at next instruction"                                                               // 162
                CR ." d  display next instruction"                                                                // 163
           FALSE                                                                                                  // 164
        ELSE TRUE                                                                                                 // 165
        THEN                                                                                                      // 166
     THEN                                                                                                         // 167
  UNTIL ;                                                                                                         // 168
: .Reg TYPE <# # # # # # # # #> TYPE SPACE ;
: check1 DEPTH 0< ABORT" Stack underflow" .S ."  1>" KEY 1B = ABORT" aborted" ;
: check2 DEPTH 0< ABORT" Stack underflow" .S ."  2>" KEY 1B = ABORT" aborted" ;
: check3 DEPTH 0< ABORT" Stack underflow" .S ."  3>" KEY 1B = ABORT" aborted" ;
: ClrEOL (: -- :) 80 AT? DROP - SPACES ;
: ShwStatus (: -- :)
  AT? (( col row )) >R >R 0 0 AT
  Reg 0C + @ " esi" .Reg  Reg 10 + @ " edi" .Reg
  Reg 08 + @ " ecx" .Reg  Reg 04 + @ " edx" .Reg  Reg 14 + @ " ebp" .Reg
  Reg 18 + @ " esp" .Reg  Reg 1C + @ " efd" .Reg  ClrEOL 0 1 AT
  Indent CELL+ 0
  DO PAD I 2* + 2@ OVER >HEAD .ID ." ." SWAP - . 4
  +LOOP ClrEOL 0 2 AT  SP@ SP0 @ 2DUP <
  IF 2DUP SWAP - 4 / ." [" DUP 1 .R ." ] " 5 MIN NIP CELLS OVER +
     BEGIN 2DUP <                                                                                                    // 171
     WHILE CELL- DUP @ .             // show values on data stack                                                 // 172
     REPEAT
  THEN 2DROP ." <- SP  "                                                                                        // 173
  R> R> (( col row )) RP@ 8 + RP0 @ 1C - 2DUP <
  IF 2DUP SWAP - 4 / ." [" DUP 1 .R ." ] " 5 MIN NIP CELLS OVER +
     BEGIN 2DUP <                                                                                                    // 175
     WHILE CELL- DUP @ .                // show values on return stack                                               // 176
     REPEAT
  THEN 2DROP ." <- RP " ClrEOL AT
  ; COMPILEONLY                                                                     // 177
: Brk (: -- :) SavReg RcvCod  R> 5 - DUP >R                                                                       // 178
  BEGIN (( a )) DUP C@ IS CurIns     // get current instruction code                                              // 179
     DUP PAD Indent 2* + !
     CR DisAsm1                      // show current instruction                                                  // 180
     SPACE                                                                                                        // 184
     (( na )) DUP IS NxtIp           // save next instruction pointer                                             // 185
     .INLINE                                                                                                      // 186
     DUP C@ IS NxtIns (( na ))       // get next instruction code                                                 // 187
     IS NxtIp' ShwStatus NxtIp'                                                                                   // 188
     GetDbgKey                                                                                                    // 189
     DUP ASCII r = OVER ASCII R = OR // if want resume                                                            // 190
     IF DROP (( na )) FALSE SWAP     // no more setting for break points                                          // 191
        RP@ RP0 @ 20 -                                                                                            // 192
        BEGIN 2DUP <                                                                                              // 193
        WHILE                                                                                                     // 194
           DUP @ DUP valid-addr?                                                                                  // 195
// ~T38X0L8Q(99,70)D(50,50,2399,50,1)D(50,50,50,3149,1)D(50,3149,2399,3149,1)D(2399,50,2399,3149,1);
           IF                        // CR ." Check if RET at " DUP .                                             // 196
              C@ RetCod = OVER @ 5 - // CR ." Check if JMP at " DUP .                                             // 197
              C@ CalCod = AND                                                                                     // 198
              IF JmpCod OVER @ 5 - C!                                                                             // 199
              THEN                                                                                                // 200
           THEN CELL-                                                                                             // 201
        REPEAT 2DROP                                                                                              // 202
     ELSE (( na k )) OVER CELL- AdrCalled DUP ['] doCONST = SWAP ['] doVAR = OR CurCal AND                        // 203
        OVER ASCII o = OR  OVER ASCII O = OR  CurRet  OR                                                          // 204
        DMsk? NOT CurJmp AND NxtRet AND OR                                                                        // 205
        OVER ASCII s <>  CurJmp AND  NxtRet AND  OR                                                               // 206
        IF DROP (( na )) 6 - DUP C@ CalCod = (( a f )) CurRet AND                                                 // 207
           IF JmpCod OVER C!                                                                                      // 208
           THEN Indent                                                                                            // 209
           IF (( na )) DROP Indent CELL- IS Indent R> R@ SWAP >R TRUE                                             // 210
           ELSE FALSE SWAP                  // no more breaking on top level                                      // 211
           THEN                                                                                                   // 212
        ELSE DUP ASCII s = OVER ASCII S = OR  DMsk? AND  CurJmp NxtRet AND CurCal OR  AND                         // 213
           IF DROP (( na )) CurJmp                                                                                // 214
              IF CalCod OVER 5 - C! 5 - 0D EMIT DisAsm1                                                           // 215
              THEN Indent CELL+ IS Indent DUP CELL- AdrCalled (( na ca ))                                         // 216
              DUP   'loop = (( na ca f1 ))                                                                        // 217
              OVER '+loop = (( na ca f1 f2 )) OR                                                                  // 218
              SWAP   '?do = (( na f3 f4 )) OR                                                                     // 219
              CurCal AND                                                                                          // 220
              IF CELL-                                                                                            // 221
              THEN AdrCalled DUP DUP PAD Indent 2* + 2! TRUE                                                              // 222
           ELSE DUP ASCII n = OVER ASCII N = OR OVER ASCII s = OR OVER ASCII S = OR                               // 223
              IF DROP (( na )) CurJmp                                                                             // 224
                 IF AdrCalled                                                                                     // 225
                 ELSE DUP 6 - H@ DUP 840F = SWAP 850F = OR (( na f ))                                             // 226
                    IF DUP AdrCalled SetBrk                                                                       // 227
                    ELSE DUP CELL- AdrCalled (( na ca ))                                                          // 228
                       DUP   'loop = (( na ca f1 ))                                                               // 229
                       OVER '+loop = (( na ca f1 f2 )) OR                                                         // 230
                       SWAP   '?do = (( na ca f3 f4 )) OR                                                         // 231
                       CurCal AND                                                                                 // 232
                       IF DUP CELL- @ SetBrk                                                                      // 233
                       ELSE DUP 2 - C@ E3 =                                                                       // 234
                          IF DUP 1- C@ OVER + SetBrk                                                              // 235
                          THEN                                                                                    // 236
                       THEN                                                                                       // 237
                    THEN                                                                                          // 238
                 THEN TRUE                                                                                        // 239
              ELSE DROP 8 EMIT 8 EMIT ASCII d EMIT FALSE                                                          // 240
              THEN                                                                                                // 241
           THEN                                                                                                   // 242
        THEN                                                                                                      // 243
     THEN                                                                                                         // 244
  UNTIL ?DUP                                                                                                      // 245
  IF SetBrk                                                                                                       // 246
  THEN LoaReg ;                                                                                                   // 247
FORTH DEFINITIONS                                                                                                 // 248
: setBrk (: a -- :) DUP Code>Head ?DUP                                                                            // 249
  IF |ATTRIBUTE 1+ C@ NMsk AND                                                                                    // 250
     IF CR ." How can we set a break point into the word " >HEAD .ID                                                // 251
        TRUE ABORT" not debugable"                                                                                // 252
     THEN                                                                                                         // 253
  THEN TRUE (( a -1 )) BrkLmt BrkBuf                                                                              // 254
  DO OVER I @ =                                                                                                   // 255
     IF 2DROP FALSE (( 0 )) LEAVE                                                                                 // 256
     THEN 9                                                                                                       // 257
  +LOOP                                                                                                           // 258
  IF TRUE (( a -1 )) BrkLmt BrkBuf                                                                                // 259
     DO I @ 0=                                                                                                    // 260
// ~T38X0L8Q(99,70)D(50,50,2399,50,1)D(50,50,50,3149,1)D(50,3149,2399,3149,1)D(2399,50,2399,3149,1);
        IF DROP DUP I ! DUP I CELL+ 5 CMOVE 0 LEAVE                                                               // 261
        THEN 9                                                                                                    // 262
     +LOOP ABORT" No more more room for break points" CP @ SWAP CP ! ['] Brk call, CP !                           // 263
  THEN ; ' setBrk IS SetBrk                                                                                       // 264
: DBG   (: -- :) 0 IS Indent ' DUP DUP PAD 2! DUP setBrk CLS  0 3 AT EXECUTE ;                                          // 265
1 #TKN #TKN   1 #TKN [']       1 #TKN [COMPILE] 1 #TKN :                                                          // 266
1 #TKN '      1 #TKN A:        1 #TKN AtrChk:   1 #TKN CODE:  1 #TKN CONSTANT                                     // 267
1 #TKN CREATE 1 #TKN DEFER     1 #TKN FORGET                                                                      // 268
1 #TKN USER   1 #TKN VARIABLE  1 #TKN VALUE     1 #TKN WORD                                                       // 269
NotDebug #          NotDebug #>         NotDebug #S         NotDebug $Msk                                         // 270
NotDebug $Msk?      NotDebug $Str.      NotDebug '?KEY      NotDebug 'CONSOLE                                     // 271
NotDebug 'EMIT      NotDebug 'RESET-LIST                    NotDebug (DO)                                    ASSEMBLER         // 272
NotDebug 'TAP       NotDebug 'TYPE      NotDebug (?DO)      NotDebug (CONSOLE)                                    // 273
NotDebug (Disassemble)                  NotDebug (EMIT)     NotDebug (LOOP)                                       // 274
NotDebug (TYPE)     NotDebug (get-page) NotDebug *          NotDebug (+LOOP)                                                      // 275
NotDebug .          NotDebug ."|        NotDebug .$         NotDebug .OK                                          // 276
NotDebug .R         NotDebug .S         NotDebug 16Bits     NotDebug 2@                                           // 277
NotDebug "|         NotDebug <#         NotDebug >HEAD      NotDebug ?BIOSKEY                                     // 278
NotDebug ?DUP       NotDebug ?KEY       NotDebug ?KEY       NotDebug ABS                                          // 279
NotDebug ABS        NotDebug AT         NotDebug AT?        NotDebug AddressOperand                               // 280
NotDebug Assembler-Phase                NotDebug BASE       NotDebug BETWEEN                                      // 281
NotDebug BIOSAT     NotDebug BIOSAT?    NotDebug BKSPC      NotDebug BL                                           // 282
NotDebug CATCH      NotDebug CF-DISASM  NotDebug CF-ShowOperand                                                   // 283
NotDebug CMOVE      NotDebug Code>Head  NotDebug COL        NotDebug COMP                                         // 284
NotDebug CONSOLE    NotDebug COUNT      NotDebug CR         NotDebug CURR-SYNTAX                                  // 285
NotDebug CalCod     NotDebug ClrTop     NotDebug CurCal     NotDebug CurJmp                                       // 286
NotDebug CurRet     NotDebug CurrMemonic                                                                          // 287
NotDebug DisAsm1    NotDebug DISASSEMBLE                                                                          // 288
NotDebug DMsk?      NotDebug DMsk?      NotDebug DisassembleTable                                                 // 289
NotDebug DisassembleTable[]             NotDebug DisassembledInstruction                                          // 290
NotDebug DisassemblingPhase             NotDebug EMIT       NotDebug EVAL                                         // 291
NotDebug HAND       NotDebug HEX        NotDebug I/O        NotDebug ImmediateOperand                             // 292
NotDebug Indent     NotDebug JmpCod     NotDebug KEY        NotDebug MAX                                          // 293
NotDebug MIN        NotDebug MemoryOperand                                                                        // 294
NotDebug NMsk       NotDebug NMsk?      NotDebug NULL$      NotDebug NxtIp                                        // 295
NotDebug NxtRet     NotDebug OFF        NotDebug PAUSE      NotDebug PMsk                                         // 296
NotDebug PMsk?      NotDebug POSTFIX    NotDebug PREFIX     NotDebug PRESET                                       // 297
NotDebug PerformDisAsm                  NotDebug PrefixDisassembled                                               // 298
NotDebug QUERY      NotDebug QUIT       NotDebug RESETTING  NotDebug RP0                                          // 299
NotDebug RcvCod     NotDebug RegisterOperand                                                                      // 300
NotDebug SHOW-CODES NotDebug SIGN       NotDebug SP0        NotDebug SPACE                                        // 301
NotDebug SPACEAPPEND                    NotDebug SPACES     NotDebug SYNTAX?                                      // 302
NotDebug SetBrk     NotDebug ShowMemonic                                                                          // 303
NotDebug ShowOperand                    NotDebug ShowOperands                                                     // 304
NotDebug ShowPrefixes                   NotDebug ShowStr    NotDebug ShwStatus                                    // 305
NotDebug TAB                                                                                                      // 306
NotDebug TAP        NotDebug TC@        NotDebug TC@-VECTOR NotDebug TYPE                                         // 307
NotDebug U.0R       NotDebug U.R        NotDebug USE@       NotDebug UseXX                                        // 308
NotDebug WITHIN     NotDebug ZMsk       NotDebug ZMsk?                                        // 309
NotDebug ZStr.      NotDebug [          NotDebug ^H         NotDebug abort"                                       // 310
NotDebug accept     NotDebug do$        NotDebug doCONST                                      // 311
NotDebug doVAR      NotDebug is-CALL?   NotDebug is-J(E)CXZ?                                                      // 312
NotDebug is-JMP?    NotDebug kTAP       NotDebug not-JMPF/CALLF?                                                  // 313
NotDebug setBrk     NotDebug str        NotDebug trap       NotDebug xio                                          // 314
NotDebug .INLINE    NotDebug GetDbgKey  NotDebug Brk        NotDebug DBG                                          // 315
$Msk INLINE abort"  ZMsk INLINE Z$"|  $Msk INLINE $"|  $Msk INLINE ."|   $Msk INLINE "|                          // 316
   4 INLINE (DO)       4 INLINE (?DO)    4 INLINE (LOOP)  4 INLINE (+LOOP)  4 INLINE ;DOES                        // 317
   4 INLINE doCONST    4 INLINE doVAR                                                                             // 318
STACK-EXPRESSION         NotDebug %!>    5 INLINE %!>                                                             // 319
HERE ' doCONST CP ! ] R> @ [ CP ! ' doCONST >HEAD |ATTRIBUTE DUP C@ COMPO OR SWAP C!                              // 320
: X1 CR ." X1 is done" ; : X2 0D EMIT 0A EMIT " X2 is here" TYPE ;                                                // 322
: X3 X1 X2 CR ." And " ['] X1 0A + COUNT TYPE ."  again" ;                                                        // 323
: X4 CR ?DUP IF . ." is non-zero" ELSE ." 0 is entered" THEN ;                                                    // 324
: X5 X3 11 X4 0 X4 ;
: X6 X5 X1 ; : X7 5 BEGIN DUP . 1- ?DUP 0= UNTIL X6 ;                                                  // 325
FORTH ONLY // ////////////////////////////////////////////////////////////////////////////////////////////////////// 321
