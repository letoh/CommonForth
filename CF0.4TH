// ////////////////////////////////////////////////////////////////////////////
//       Common Forth
//       Experiment Version 1.669
//                              1991,1992,1993,1994,1995,1996,1997,1998,1999
//       Last update 07/25/1999
//
//       F.I.G. Taipei Chapter
//       Written by Luke Lee, ( Yuan-shune Lee )
//               Taipei, Taiwan
//       eMail address : comforth@ms2.hinet.net
// ////////////////////////////////////////////////////////////////////////////
//
//       Register usage :
//       EAX     Top of stack
//       EBX     User pointer
//       EBP     Parameter stack ( Data stack ) pointer
//       ESP     Return stack pointer
//       DS = SS = ES, CS maps to DS
//       FS, GS  Reserved for furture use
//       ESI,EDI ( reserved for OOP )

//  Attribute bits assignment : ( All other bits are reserved )
//         F E D C B A 9 8 7 6 5 4 3 2 1 0
//        ÚÄÂÄÂÄÂÄÂÄÂÄÂÄÂÄÒÄÂÄÂÄÂÄÂÄÂÄÂÄÂÄ¿
//        ³ ³ ³ ³ ³ ³ ³ ³ º ³ ³ ³ ³ ³ ³ ³ ³
//        ÀÄÁÄÁÄÁÄÁÄÁÄÁÄÁÄÐÄÁÄÁÄÁÄÁÄÁÄÁÄÁÄÙ
//                         ³ ³ ³ ³ ³ ³ ³ ÀÄ Immediate
//                         ³ ³ ³ ³ ³ ³ ÀÄ Compile only
//                         ³ ³ ³ ³ ³ ÀÄ Invisible
//                         ³ ³ ³ ³ ÀÄ
//                         ³ ³ ³ ÀÄ
//                         ³ ³ ÀÄ C(++) postfix function
//                         ³ ÀÄ C(++) infix function
//                         ÀÄ Macro


DECIMAL

// ///////////////// //
//   Entry  Point    //
// ///////////////// //

ASSEMBLER

PREFIX SYNTAX   // 09/19/'95

     // At this point, the loader must setup DS correctly.

	MOV   { BASE-ADDRESS |INIT-ENVIRON |OriginalRegisters |EAX }    EAX
	MOV   { BASE-ADDRESS |INIT-ENVIRON |OriginalRegisters |EBX }    EBX
	MOV   { BASE-ADDRESS |INIT-ENVIRON |OriginalRegisters |ECX }    ECX
	MOV   { BASE-ADDRESS |INIT-ENVIRON |OriginalRegisters |EDX }    EDX
	MOV   { BASE-ADDRESS |INIT-ENVIRON |OriginalRegisters |ESI }    ESI
	MOV   { BASE-ADDRESS |INIT-ENVIRON |OriginalRegisters |EDI }    EDI
	MOV   { BASE-ADDRESS |INIT-ENVIRON |OriginalRegisters |EBP }    EBP
	MOV   { BASE-ADDRESS |INIT-ENVIRON |OriginalRegisters |ESP }    ESP
	XOR     EAX     EAX
	MOV     AX      FS
	MOV   { BASE-ADDRESS |INIT-ENVIRON |OriginalRegisters |FS }     EAX
	MOV     AX      GS
	MOV   { BASE-ADDRESS |INIT-ENVIRON |OriginalRegisters |GS }     EAX
	CLI
	MOV     AX      DS
	MOV     SS      AX
	MOV     ESP   TRP0 @ #  // TRP0 : Meta-compiler variable
	STI
	MOV     EBP   TSP0 @ #  // TSP0 : Meta-compiler variable
	MOV     EBX   TUP0 @ #  // TUP0 : Meta-compiler variable
	JMP   { ^COLD @ }       // ^COLD : Meta-compiler variable

FORTH

VOCABULARY TARGET       // defined in host vocabulary

TARGET ALSO DEFINITIONS

TCP0 @ CP !     // Meta-compiler variable initialization

CR .( * Kernel macro words ...)

CODE: RESET-REGISTERS   ( -- )
	CLI
	MOV     EAX  CS: { BASE-ADDRESS |INIT-ENVIRON |OriginalRegisters |DS }
	MOV     DS      AX
	MOV     EAX   { BASE-ADDRESS |INIT-ENVIRON |OriginalRegisters |ES }
	MOV     ES      AX
	MOV     EAX   { BASE-ADDRESS |INIT-ENVIRON |OriginalRegisters |FS }
	MOV     FS      AX
	MOV     EAX   { BASE-ADDRESS |INIT-ENVIRON |OriginalRegisters |GS }
	MOV     GS      AX
     // restoreing user area    
	MOV     EBX     TUP0 @ #        // TUP0 : Meta-compiler variable
	STI
	XOR     EAX     EAX
	RET
	;CODE MACRO 0 0 #PARMS INVISIBLE COMPILEONLY

CODE: RESET-STACK       ( -- )
     // restoring stack
	CLI
	MOV     EAX   { BASE-ADDRESS |INIT-ENVIRON |OriginalRegisters |SS }
	MOV     SS      AX
	MOV     ESP     TRP0 @ #        // TRP0 : Meta-compiler variable
	MOV     EBP     TSP0 @ #        // TSP0 : Meta-compiler variable
	STI
	RET
	;CODE MACRO 0 0 #PARMS INVISIBLE COMPILEONLY

POSTFIX SYNTAX

CODE: !         ( w a -- ) // Pop the data stack to memory.
	EDX     { EBP } MOV
	{ EAX } EDX     MOV
	EAX     { EBP CELL + }  MOV
	EBP     { EBP CELL 2* + }       LEA
	RET     ;CODE 2 0 #PARMS MACRO

CODE: H!        ( hw a -- ) // Pop the data stack to half-word ( 16bit ) memory.
	EDX     { EBP } MOV
	WORD^ { EAX }   DX      MOV
	EAX     { EBP CELL + }  MOV
	EBP     { EBP CELL 2* + }       LEA
	RET     ;CODE 2 0 #PARMS MACRO

CODE: C!        ( c b -- ) // Pop the data stack to byte memory.
	DL      BYTE^ { EBP }   MOV
	BYTE^ { EAX }   DL      MOV
	EAX     { EBP CELL + }  MOV
	EBP     { EBP CELL 2* + }       LEA
	RET     ;CODE 2 0 #PARMS MACRO

CODE: @         ( a -- w ) // Push memory location to the data stack.
	EAX     { EAX } MOV
	RET     ;CODE 1 1 #PARMS MACRO

CODE: H@        ( a -- hw ) // Push halfword memory location to the data stack.
	EAX     WORD^ { EAX }   MOVZX
	RET     ;CODE 1 1 #PARMS MACRO

CODE: C@        ( b -- c ) // Push byte memory location to the data stack.
	EAX     BYTE^ { EAX }   MOVZX
	RET     ;CODE 1 1 #PARMS MACRO

CODE: DROP      ( w -- )        // Discard top stack item.
        EAX     { EBP }         MOV
        EBP     { EBP CELL + }  LEA
	RET     ;CODE 1 0 #PARMS MACRO

CODE: DUP       ( w -- w w )    // Duplicate the top stack item.
        EBP     { EBP CELL - }  LEA
        { EBP } EAX             MOV
	RET     ;CODE 1 2 #PARMS MACRO

COMMENT:    // optimize for memory size
CODE: SWAP      ( w1 w2 -- w2 w1 ) // Exchange top two stack items.
        { EBP } EAX     XCHG
        RET     ;CODE 2 2 #PARMS MACRO

CODE: ROT       ( w1 w2 w3 -- w2 w3 w1 ) // Rot 3rd item to top.
        EAX     { EBP }         XCHG
        EAX     { EBP CELL + }  XCHG
        RET     ;CODE 3 3 #PARMS MACRO

CODE: -ROT      ( w1 w2 w3 -- w3 w1 w2 ) // Rot top item to 3rd.
        EAX     { EBP CELL + }  XCHG
        EAX     { EBP }         XCHG
        RET     ;CODE 3 3 #PARMS MACRO
;COMMENT

CODE: SWAP      ( w1 w2 -- w2 w1 )      // Exchange top two stack items.
        EDX     { EBP } MOV             // Speedup by Charles Liu 01/08/1999
        { EBP } EAX     MOV
        EAX     EDX     MOV
        RET     ;CODE 2 2 #PARMS MACRO

CODE: ROT    ( w1 w2 w3 -- w2 w3 w1 )   // Rot 3rd item to top.
        EDX     { EBP } MOV             // Speedup by Charles Liu 01/08/1999
        { EBP } EAX     MOV
        EAX     { EBP CELL+ }   MOV
        { EBP CELL+ }   EDX     MOV
        RET     ;CODE 3 3 #PARMS MACRO

CODE: -ROT    ( w1 w2 w3 -- w3 w1 w2 )  // Rot top item to 3rd.
        EDX     { EBP CELL+ }   MOV     // Speedup by Charles Liu 01/08/1999
        { EBP CELL+ } EAX       MOV
        EAX     { EBP } MOV
        { EBP } EDX     MOV
        RET     ;CODE 3 3 #PARMS MACRO

CODE: OVER      ( w1 w2 -- w1 w2 w1 ) // Copy second stack item to top.
	] DUP [         // macro expansion
	EAX     { EBP CELL + }  MOV
	RET     ;CODE 2 3 #PARMS MACRO

CODE: PICK      ( ... +n -- ... w ) // Copy the nth stack item to tos.
	EAX     { EBP EAX *4 + } MOV
	RET     ;CODE 1 1 #PARMS MACRO

CODE: NIP       ( w1 w2 -- w2 )
	EBP     { EBP CELL + }  LEA
	RET     ;CODE 2 1 #PARMS MACRO

CODE: NOT       ( w -- w ) // One's complement of tos.
	EAX     NOT
	RET     ;CODE 1 1 #PARMS MACRO

CODE: AND       ( w w -- w ) // Bitwise AND.
	EAX     { EBP } AND
	EBP     { EBP CELL + }  LEA
	RET     ;CODE 2 1 #PARMS MACRO

CODE: OR        ( w w -- w ) // Bitwise inclusive OR.
	EAX     { EBP } OR
	EBP     { EBP CELL + }  LEA
	RET     ;CODE 2 1 #PARMS MACRO

CODE: XOR       ( w w -- w ) // Bitwise exclusive OR.
	EAX     { EBP } XOR
	EBP     { EBP CELL + }  LEA
	RET     ;CODE 2 1 #PARMS MACRO

CODE: 0<        ( n -- t ) // Return true if n is negative.
        EAX     31 #    SAR     // modified by Leo Liu 06/22/'98
        RET     ;CODE 1 1 #PARMS MACRO

CODE: 0=        ( n -- t )
	EAX     1 #     SUB
	EAX     EAX     SBB
	RET     ;CODE 1 1 #PARMS MACRO

CODE: 0<>       ( n -- t )
	EAX     NEG
	EAX     EAX     SBB
	RET     ;CODE 1 1 #PARMS MACRO

CODE: 0>        ( n -- f )              // Bug fix by Leo Liu 06/22/'98
        EAX     DEC
        EAX     $7FFFFFFF #     CMP                  
        EAX     EAX     SBB
        RET     ;CODE 1 1 #PARMS MACRO

CODE: SGN       ( n -- -1/0/1 )         // : SGN DUP 0< SWAP 0> - ;
        // return -1 if negative, 0 if zero, 1 if positive
        EDX     EAX     MOV             // Bug fix by Leo Liu 06/22/'98
        EAX     31 #    SAR
        EDX     NEG
        EAX     EAX     ADC
        RET     ;CODE 1 1 #PARMS MACRO

CODE: =     ( w w -- t )    // Return true if top two are equal.
	EAX   { EBP }   XOR     // : =   XOR 0= ;
	EAX     1 #     SUB
	EAX     EAX     SBB
	EBP   { EBP CELL+ }     LEA
	RET     ;CODE 2 1 #PARMS MACRO

CODE: <         ( n1 n2 -- t ) // Signed compare of top two items.
	EDX     EAX     MOV
	] DROP [                // macro expansion
	EAX     EDX     CMP
	AL      SETL
	AL      1 #     SHR
	EAX     EAX     SBB
	RET     ;CODE 2 1 #PARMS MACRO

CODE: >         ( n1 n2 -- t ) // Signed compare of top two items.
	EDX     EAX     MOV
	] DROP [
	EAX     EDX     CMP
	AL      SETG
	AL      1 #     SHR
	EAX     EAX     SBB
	RET     ;CODE 2 1 #PARMS MACRO

CODE: U<        ( u1 u2 -- t )
	EDX   { EBP }   MOV
	EDX     EAX     SUB
	EAX     EAX     SBB
	EBP   { EBP CELL+ }     LEA
	RET     ;CODE 2 1 #PARMS MACRO

CODE: U>        ( u1 u2 -- t )   // : U> SWAP U< ;
	EAX   { EBP }   SUB
	EAX     EAX     SBB
	EBP   { EBP CELL+ }     LEA
	RET     ;CODE 2 1 #PARMS MACRO

CODE: NEGATE    ( n -- -n ) // Two's complement of tos.
	EAX     NEG
	RET     ;CODE 1 1 #PARMS MACRO

CODE: UM+       ( u u -- udsum )
	// Add two unsigned single numbers and return a double sum.
	EDX     EDX     XOR
      { EBP }   EAX     ADD
	EDX     1 #     RCL     // get carry
	EAX     EDX     MOV
	RET     ;CODE 2 2 #PARMS MACRO

CODE: UM/MOD    ( udl udh un -- ur uq )
	// Unsigned divide of a double by a single. Return mod and quotient.
	ECX     EAX     MOV
	] DROP [
	EDX     EAX     MOV     // udh
	EAX     { EBP } MOV     // udl
	ECX     DIV
	{ EBP } EDX     MOV
	RET     ;CODE 3 2 #PARMS MACRO

CODE: UM*       ( u u -- ud ) // Unsigned multiply. Return double product.
	DWORD^ { EBP }  MUL
	{ EBP } EAX     MOV
	EAX     EDX     MOV
	RET     ;CODE 2 2 #PARMS MACRO

CODE: +         ( n1 n2 -- sum ) // Add top two items.
	EAX     { EBP } ADD
	EBP     { EBP CELL + }  LEA
	RET     ;CODE 2 1 #PARMS MACRO

CODE: -         ( n1 n2 -- n1-n2 ) // Subtraction.
	EDX     { EBP } MOV
	EDX     EAX     SUB
	EAX     EDX     MOV
	EBP     { EBP CELL + }  LEA
	RET     ;CODE 2 1 #PARMS MACRO

CODE: *         ( n1 n2 -- n1*n2 )
	DWORD^ { EBP }  MUL
	EBP    { EBP CELL+ }    LEA
	RET     ;CODE 2 1 #PARMS MACRO

CODE: /         ( n1 n2 -- n1/n2 ) // floored and signed division
	ECX     EAX     MOV
	EAX   { EBP }   MOV
	EBP   { EBP CELL+ }     LEA
	CDQ
	EDI     ECX     MOV
	EDI     EDX     XOR
  //    0>=  IF
	$78 C, $04 C,
		ECX     IDIV
  //    ELSE
	$EB C, $07 C,
		ECX     IDIV
		EDX     EDX     OR
	  //  0<>  IF
	      $74 C, $01 C,
			EAX     DEC
	  //  ENDIF
  //    ENDIF
	RET     ;CODE  2 1 #PARMS MACRO

CODE: /MOD      ( n1 n2 -- rem quot ) // floored and signed division
	ECX     EAX     MOV
	EAX   { EBP }   MOV
	CDQ
	EDI     ECX     MOV
	EDI     EDX     XOR
  //    0>=  IF
	$78 C, $04 C,
		ECX     IDIV
  //    ELSE
	$EB C, $09 C,
		ECX     IDIV
		EDX     EDX     OR
	  //  0<>  IF
	      $74 C, $03 C,
			EDX     ECX     ADD
			EAX     DEC
	  //  ENDIF
  //    ENDIF
      { EBP }   EDX     MOV
	RET     ;CODE  2 2 #PARMS MACRO

CODE: CELL+     ( a -- a ) // Add cell size in byte to address.
	EAX     CELL #  ADD
	RET     ;CODE 1 1 #PARMS MACRO

CODE: CELL-     ( a -- a ) // Subtract cell size in byte from address.
	EAX     CELL #  SUB
	RET     ;CODE 1 1 #PARMS MACRO

CODE: CELL*     ( n -- n ) // Multiply tos by cell size in bytes.
	EAX     { EAX *4 }      LEA
	RET     ;CODE 1 1 #PARMS MACRO

CODE: CELL/     ( n -- n' ) // Shift tos 2 bits rightward.
	EAX     2 #     SHR
	RET     ;CODE 1 1 #PARMS MACRO

CODE: 2*        ( N -- n*2 ) // Shift tos 1 bit leftward.
	EAX     1 #     SHL
	RET     ;CODE 1 1 #PARMS MACRO

CODE: U2/       ( N -- n/2 ) // Shift tos 1 bit rightward.
	EAX     1 #     SHR
	RET     ;CODE 1 1 #PARMS MACRO

CODE: 2/        ( N -- n/2 ) // Shift tos 1 bit rightward.
	EAX     1 #     SAR
	RET     ;CODE 1 1 #PARMS MACRO

CODE: 1+        ( n -- n+1 ) // Increase TOS by 1 .
	EAX     INC
	RET     ;CODE 1 1 #PARMS MACRO

CODE: 1-        ( n -- n-1 ) // Decrease TOS by 1 .
	EAX     DEC
	RET     ;CODE 1 1 #PARMS MACRO

CODE: (LIT)     ( -- w ) // Push an inline literal.
	] DUP [
	EAX     $7FFFFFFF #     MOV     -4 ALLOT
	RET     ;CODE 0 1 #PARMS MACRO COMPILEONLY

CODE: 0         ( -- 0 ) // constant 0
	] DUP [
	EAX     EAX     XOR
	RET     ;CODE 0 1 #PARMS MACRO

CODE: RP@       ( -- a ) // Push the current RP to the data stack.
	] DUP [
	EAX     ESP     MOV
	RET     ;CODE 0 1 #PARMS MACRO

CODE: RP!       ( a -- ) // Set the return stack pointer.
	ESP     EAX     MOV
	] DROP [
	RET     ;CODE 1 0 #PARMS MACRO COMPILEONLY

CODE: >R        ( w -- ) // Push the data stack to the return stack.
	EAX     PUSH
	] DROP [
	RET     ;CODE 1 0 #PARMS MACRO COMPILEONLY

CODE: R>        ( -- w ) // Pop the return stack to the data stack.
	] DUP [
	EAX     POP
	RET     ;CODE 0 1 #PARMS MACRO COMPILEONLY

CODE: R@        ( -- w ) // Copy top of return stack to the data stack.
	] DUP [
	EAX     { ESP } MOV
	RET     ;CODE 0 1 #PARMS MACRO

CODE: RDROP     ( -- )
	ESP     { ESP CELL + }  LEA
	RET     ;CODE 0 0 #PARMS MACRO COMPILEONLY

CODE: SP@       ( -- a ) //  Push the current data stack pointer.
	] DUP [
	EAX     EBP     MOV
	RET     ;CODE 0 1 #PARMS MACRO

CODE: SP!       ( a -- ) // Set the data stack pointer.
	EBP     EAX     MOV
	] DROP [
	RET     ;CODE 1 0 #PARMS MACRO

CODE: ?BRANCH   ( f -- ) // Branch if flag is zero.
	EAX     EAX     OR
	] DROP [
	HERE 256 + #    JZ      -4 ALLOT
	RET     ;CODE 1 0 #PARMS MACRO COMPILEONLY

CODE: BRANCH    ( -- ) // Branch to an inline address.
	HERE 256 + #    JMP     -4 ALLOT
	RET     ;CODE 0 0 #PARMS MACRO COMPILEONLY

CODE: JT=0      ( T -- T ) // branch if TOS zero, but don't POPT
	EAX     EAX     OR
	HERE 256 + #    JZ      -4 ALLOT
	RET     ;CODE 1 1 #PARMS MACRO COMPILEONLY

CODE: JT<>0     ( T -- T ) // branch if TOS is not zero, don't POPT
	EAX     EAX     OR
	HERE 256 + #    JNZ     -4 ALLOT
	RET     ;CODE 1 1 #PARMS MACRO COMPILEONLY

CODE: next      ( -- )  // Run time code for the single index loop.
	ECX     POP
	$E3 C, $07 C,
	ECX     DEC
	ECX     PUSH
	$E9 C,
	RET     ;CODE 0 0 #PARMS MACRO COMPILEONLY

CODE: UP@       ( -- a ) // Pointer to the user area.
	] DUP [
	EAX     EBX     MOV
	RET     ;CODE 0 1 #PARMS MACRO

CODE: UP!       ( a -- ) // Set user pointer .
	EBX     EAX     MOV
	] DROP [
	RET     ;CODE 1 0 #PARMS MACRO

CODE: EXECUTE   ( ca -- ) // Execute the word at ca.
	EDX     EAX     MOV
	] DROP [
	EDX     CALL
	RET     ;CODE 1 0 #PARMS MACRO

CODE: @EXECUTE  ( a -- ) // Execute vector stored in address a.
	EDX     EAX     MOV
	] DROP [
	{ EDX } CALL
	RET     ;CODE 1 0 #PARMS MACRO

CODE: PC@       ( addr -- byte )
	EDX     EAX     MOV
	EAX     EAX     XOR
	AL      DX      IN
	RET     ;CODE 1 1 #PARMS MACRO

CODE: PH@       ( addr -- byte )
	EDX     EAX     MOV
	EAX     EAX     XOR
	AX      DX      IN
	RET     ;CODE 1 1 #PARMS MACRO

CODE: P@        ( addr -- byte )
	EDX     EAX     MOV
	EAX     DX      IN
	RET     ;CODE 1 1 #PARMS MACRO

CODE: PC!       ( byte addr -- )
	EDX     EAX     MOV
	EAX    { EBP }  MOV
	DX      AL      OUT
	EAX    { EBP 4 + }  MOV
	EBP    { EBP 8 + }  LEA
	RET     ;CODE 2 0 #PARMS MACRO
	
CODE: PH!       ( 16bit addr -- )
	EDX     EAX     MOV
	EAX    { EBP }  MOV 
	DX      AX      OUT
	EAX    { EBP 4 + }  MOV
	EBP    { EBP 8 + }  LEA
	RET     ;CODE 2 0 #PARMS MACRO

CODE: P!        ( 32bit addr -- )
	EDX     EAX     MOV
	EAX    { EBP }  MOV
	DX      EAX     OUT
	EAX    { EBP 4 + }  MOV
	EBP    { EBP 8 + }  LEA
	RET     ;CODE 2 0 #PARMS MACRO

CODE: EXIT      ( -- )
	RET
	RET     ;CODE 0 0 #PARMS MACRO

CODE: exit      ( -- )
	RET
	RET     ;CODE 0 0 #PARMS MACRO

: <=    ( n1 n2 -- t )
	> NOT ; MACRO 2 1 #PARMS

: >=    ( n1 n2 -- t )
	< NOT ; MACRO 2 1 #PARMS

: <>    ( n1 n2 -- t )
	= NOT ; MACRO 2 1 #PARMS

: U>=   ( u1 u2 -- t )
	U< NOT ; MACRO 2 1 #PARMS

: U<=   ( u1 u2 -- t )
	U> NOT ; MACRO 2 1 #PARMS

: 0>=   ( n -- t )
	0< NOT ; MACRO 1 1 #PARMS

: 0<=   ( n -- t )
	0> NOT ; MACRO 1 1 #PARMS

CR .( * System variables ...)

CODE: doUSER    ( -- a ) // Run time routine for user variables.
	] DUP [
	EAX     EBX     MOV
	EAX     $7FFFFFFF #     ADD     -4 ALLOT
	RET     ;CODE 0 1 #PARMS MACRO COMPILEONLY

' doUSER   ^doUSER   !  // Meta-compiler variable initialization

CODE: doVAR ( -- a ) // Run time routine for VARIABLE and CREATE.
	] DUP [
	EAX     POP
	RET     ;CODE 0 1 #PARMS COMPILEONLY

CODE: doCONST   ( -- N )
	] DUP [
	EDX     POP
	EAX     { EDX } MOV
	RET     ;CODE 0 1 #PARMS

CR .( * Device dependent I/O words ...)

CODE: C(++)invoke       ( ... function_addr -- ... return_value )
	EBX     PUSH
	ESP     EBP             XCHG     // Swap data stack and return stack

	EAX     CALL

	ESP     EBP             XCHG    // swap back data/return stack
	EBX     POP
	RET     ;CODE 1 1 #PARMS MACRO  // return value in EAX already

.386? #IF

: trapbuf doVAR [ 0 , ] ; INVISIBLE

#ENDIF

CODE: trap  // (    EBP EDI ESI EDX ECX EBX EAX int#   
	    //    -- EBP EDI ESI EDX ECX EBX EAX flag )

	EAX     $FF #       AND
	EAX     $8 #        SHL
	EAX     $C300CD #   OR          // XX # INT  RET    =    $C3XXCD
	EBP   { EBP CELL - }	LEA     // ] DUP [

   .486? #IF
      { EBP }   EAX     MOV
   #ELSE .386? #IF
      { trapbuf }	EAX	MOV
   #ELSE
      #ERROR : CPU type not defined ( either .386 or .486 )     
   #ENDIF #ENDIF

	ESP     EBP     XCHG    // operate on data stack

	EAX   { ESP $04 + }	XCHG
	EBX   { ESP $08 + }	XCHG
	ECX   { ESP $0C + }	XCHG
	EDX   { ESP $10 + }	XCHG
	ESI   { ESP $14 + }	XCHG
	EDI   { ESP $18 + }	XCHG
	EBP   { ESP $1C + }	XCHG

   .486? #IF	// routine ( XX # INT RET ) is now on stack, so call it
	ESP	CALL	// 486 only !! ( this fails in 386 )      
   #ELSE
        trapbuf	#	CALL
   #ENDIF

      { ESP $04 + }    EAX	XCHG        
      { ESP $08 + }    EBX	XCHG
      { ESP $0C + }    ECX	XCHG
      { ESP $10 + }    EDX	XCHG
      { ESP $14 + }    ESI	XCHG
      { ESP $18 + }    EDI	XCHG
      { ESP $1C + }    EBP	XCHG

	PUSHFD          // XCHG never change a flag
	EAX     POP
	EBP     ESP     XCHG

	EBP     { EBP CELL+ }    LEA
	RET     ;CODE 8 8 #PARMS

CODE: 256*      ( n -- n*256 )
	EAX     8 #     SHL
	RET     ;CODE 1 1 #PARMS MACRO

CODE: U256/      ( u -- u/256 )
	EAX     8 #     SHR
	RET     ;CODE 1 1 #PARMS MACRO

CODE: 256/       ( n -- n/256 )
	EAX     8 #     SAR
	RET     ;CODE 1 1 #PARMS MACRO

CODE: 2>R        ( D -- ) // Push double to return stack.
	ESP   { ESP 2 CELLS - }	LEA
      { ESP }	EAX 	MOV
      	EAX   { EBP }	MOV
      { ESP CELL+ }	EAX	MOV
	EAX   { EBP CELL+ }	MOV
        EBP   { EBP 2 CELLS + }	LEA
	RET     ;CODE 2 0 #PARMS MACRO COMPILEONLY

CODE: 2R>        ( -- D ) // Pop double from the return stack
	EBP   { EBP 2 CELLS - } LEA
      { EBP CELL+ }	EAX	MOV
	EAX   { ESP CELL+ }	MOV	
      { EBP }	EAX		MOV
	EAX   { ESP }		MOV
	ESP   { ESP 2 CELL* + } LEA
	RET     ;CODE 0 2 #PARMS MACRO COMPILEONLY

CODE: 2R@	( -- D )
	EBP   { EBP 2 CELLS - } LEA
      { EBP CELL+ }	EAX	MOV
	EAX   { ESP CELL+ }	MOV	
      { EBP }	EAX		MOV
	EAX   { ESP }		MOV
	RET	;CODE 0 2 #PARMS MACRO

CODE: 2RDROP ( -- )
	ESP     { ESP 2 CELL* + }  LEA
	RET     ;CODE 0 0 #PARMS MACRO COMPILEONLY

CODE: 3RDROP ( -- )	// for DO...LOOP leaving.
	ESP     { ESP 3 CELL* + }  LEA
	RET     ;CODE 0 0 #PARMS MACRO COMPILEONLY

CODE: 2DUP  ( a b -- a b a b )
	EDX   { EBP }   MOV
	EBP   { EBP 2 CELL* - } LEA
       { EBP CELL+ }    EAX     MOV
       { EBP }          EDX     MOV
	RET     ;CODE 2 4 #PARMS MACRO

CODE: 2SWAP ( a b A B -- A B a b )
        EDX   { EBP 2 CELL* + } MOV
       { EBP }  EDX             XCHG
       { EBP 2 CELL* + }  EDX   MOV
        EAX   { EBP CELL+ }     XCHG
        RET     ;CODE 4 4 #PARMS MACRO

CODE: 2DROP ( n n -- )
	EAX   { EBP CELL+ }     MOV  
	EBP   { EBP 2 CELL* + } LEA
	RET     ;CODE 2 0 #PARMS MACRO

CODE: 3DROP ( n n n -- )
	EAX   { EBP 2 CELL* + }   MOV
	EBP   { EBP 3 CELL* + } LEA
	RET     ;CODE 3 0 #PARMS MACRO

CODE: 4DROP ( n n n n -- )
	EAX   { EBP 3 CELL* + } MOV        
	EBP   { EBP 4 CELL* + } LEA
	RET     ;CODE 4 0 #PARMS MACRO

CODE: 5DROP ( n n n n n -- )
	EAX   { EBP 4 CELL* + } MOV
	EBP   { EBP 5 CELL* + } LEA
	RET     ;CODE 5 0 #PARMS MACRO

CODE: 6DROP ( n n n n n n -- )
	EAX   { EBP 5 CELL* + } MOV
	EBP   { EBP 6 CELL* + } LEA
	RET     ;CODE 6 0 #PARMS MACRO

CODE: 7DROP ( n n n n n n n -- )
	EAX   { EBP 6 CELL* + } MOV
	EBP   { EBP 7 CELL* + } LEA
	RET     ;CODE 7 0 #PARMS MACRO

CODE: 8DROP ( n n n n n n n n -- )
	EAX   { EBP 7 CELL* + } MOV
	EBP   { EBP 8 CELL* + } LEA
	RET     ;CODE 8 0 #PARMS MACRO

: TASK	( -- a )  
	// Current task pointer, global variable, since there is no
	// local task support in this system, otherwise it will be defined
	// as an USER variable.
	doVAR [ 0 , ]	; 0 1 #PARMS 	// Current task pointer

CODE: PAUSE     ( -- )  // task switching routines
    // NOTE ! This word cannot be a MACRO !
	] DUP [
	{ EBX CELL+ CELL+ }     ESP     MOV
	{ EBX CELL+ }           EBP     MOV
	EBX                   { EBX }   MOV
      { TASK }			EBX	MOV	// current task pointer
	EBP             { EBX CELL+ }   MOV
	ESP       { EBX CELL+ CELL+ }   MOV
	] DROP [
	RET     ;CODE 0 0 #PARMS

CODE: SINGLE ( -- )   //   $C3  ['] PAUSE  C!
	EAX     PUSH
	AL      $C3 #   MOV
	BYTE^ { ' PAUSE }       AL      MOV
	EAX     POP
	RET     ;CODE 0 0 #PARMS

SINGLE

: NOOP  ( -- )  // Do nothing
	; 0 0 #PARMS

: BYEFUNC^      ( -- a )      doVAR [ ' NOOP , ] ; 0 1 #PARMS

CODE: BYE       ( -- ) // Exit Forth system .
	// Return to loader with EAX as return value.
	] RESET-REGISTERS [     // macro expansion
	] RESET-STACK [         // macro expansion
	{ BYEFUNC^ }    CALL
//        EAX     { BASE-ADDRESS |INIT-ENVIRON |OriginalRegisters |EAX }  MOV
	EBX     { BASE-ADDRESS |INIT-ENVIRON |OriginalRegisters |EBX }  MOV
	ECX     { BASE-ADDRESS |INIT-ENVIRON |OriginalRegisters |ECX }  MOV
	EDX     { BASE-ADDRESS |INIT-ENVIRON |OriginalRegisters |EDX }  MOV
	ESI     { BASE-ADDRESS |INIT-ENVIRON |OriginalRegisters |ESI }  MOV
	EDI     { BASE-ADDRESS |INIT-ENVIRON |OriginalRegisters |EDI }  MOV
	CLI
	EBP     { BASE-ADDRESS |INIT-ENVIRON |OriginalRegisters |EBP }  MOV
	ESP     { BASE-ADDRESS |INIT-ENVIRON |OriginalRegisters |ESP }  MOV
	STI
	RET     ;CODE 0 0 #PARMS

CODE: BYE'      ( -- )        // FORCE TERMINATION
	] RESET-REGISTERS [     // macro expansion
	] RESET-STACK [         // macro expansion
        { BYEFUNC^ }    CALL
	EAX     $4C00 # MOV
	$21 #   INT     ;CODE 0 0 #PARMS

CODE: !IO       ( -- )  // Initialize the serial I/O devices.
	RET     ;CODE 0 0 #PARMS INVISIBLE

CODE: ?BIOSKEY  ( -- c T | F )
	// Return input character and true, or a false if no input.
	EBX     PUSH
	ESP     EBP     XCHG
	EAX     PUSH
	EAX     EAX     XOR
	AH      $01 #   MOV
	$16 #   INT
	0<>     IF                      // key stroke already
		AH      $00 #   MOV     
		$16 #   INT             // read key stroke
		AL      AL      OR
		0<>     IF
			AH      AH      XOR
		ENDIF
		EAX     PUSH
		EAX     -1 #    MOV
	ELSE
		EAX     EAX     XOR
	ENDIF
	ESP     EBP     XCHG
	EBX     POP
	RET     ;CODE

CODE: BIOSEMIT  ( c -- ) // Send character c to the output device.
	EBP     PUSH
	EBX     PUSH
	EDX     EAX     MOV
	AH      $0F #   MOV             // get current screen setting
	$10 #   INT                     // BH = current display page
	EAX     EDX     MOV
	AH      $0E #   MOV
	$10 #   INT
	EBX     POP
	EBP     POP
	] DROP [
	RET     ;CODE 1 0 #PARMS MACRO

CODE: Keyboard!  ( c -- T/F ) // push ASCII character into keyboard buffer
      // Return FALSE if keyboard buffer is full.
	ECX     EAX     MOV
	AH      $05 #   MOV
	$16 #   INT             // AL = 0 if succeed; AL = 1 if keyboard full;
	AL      1 #     SUB
	CBW
	CWDE
	RET     ;CODE 1 1 #PARMS INVISIBLE

CODE: EDX>STACK ( -- half-double )    // move EDX to stack for Watcom C++
	EBP     { EBP CELL- }   LEA
      { EBP }   EDX     MOV
	RET     ;CODE 0 1 #PARMS MACRO INVISIBLE

CODE: SF>TOS    ( -- float )    // move ST(0) to TOS, single precision
	EBP     { EBP 2 CELL* - }       LEA
      { EBP CELL+ }     EAX             MOV
      DWORD^ { EBP }    FSTP
	] DROP [
	RET     ;CODE 0 1 #PARMS MACRO

CODE: DF>TOS    ( -- double )   // move ST(0) to TOS, double precision
	EBP     { EBP 3 CELL* - }       LEA
      { EBP 2 CELL* + }   EAX           MOV
      QWORD^ { EBP }    FSTP
	] DROP [
	RET     ;CODE 0 2 #PARMS MACRO
	
CODE: COMP      ( S D len -- flag )     // Modified by Charles Liu on 01/30/1999
        //       Compare len bytes, flag=0 if S=D,
        //                          flag<0 if S<D,
        //                          flag>0 if S>D.
        EDI   { EBP }             MOV
        ESI   { EBP CELL+ }       MOV
        EBP   { EBP 2 CELL* + }   LEA
        ECX     EAX               MOV
        $E3 C, $0B C,           // skip if ECX = 0
        CLD
        REPE    CMPSB
        AL      SETA            // if S<=D, AL = 0; if S>D, AL = 1
        AL      0 #     SBB     // if S<D, AL = -1; if S=D, AL = 0; if S>D, AL = 1
        EAX     AL      MOVSX   // sign-extend
        RET     ;CODE 3 1 #PARMS

: (get-page)    ( -- ? ? ? ? ? EBX )
      // EBP EDI ESI EDX ECX EBX  EAX  int#/flag
         2DUP    2DUP    2DUP   ( not used, any value will do )
	                        $0F00    $10   trap     2DROP
			  // BH = current display page
	 ; 0 6 #PARMS INVISIBLE

: BIOSAT?   ( -- x y )
     // EBP EDI ESI EDX ECX EBX EAX   int#/flag
       (get-page)              $0300    $10   trap      4DROP
		 // DH = Y, DL = X
		       DUP 256/ $FF AND >R      // Y
		   $FF AND >R                   // X
		   3DROP
       R> R> ; 0 2 #PARMS

: BIOSAT    ( x y -- )
	>R >R
      // EBP EDI ESI EDX ECX EBX
	(get-page)              ROT DROP
	R>  R> 256* OR  -ROT
	$0200 $10 trap 8DROP ; 2 0 #PARMS

: CLS   ( -- )  // clear screen
	0 DUP BIOSAT
      // EBP EDI ESI EDX ECX EBX
	(get-page)          $FF00 AND 7 OR // color
			NIP [ 80 25 * ] LITERAL SWAP
	$0920 $10 trap 8DROP ; 0 0 #PARMS

// The following two code words are used for name searching

CODE: HASH      ( str-adr -- key )
	//  String to 10-bit integer mapping function.
	// ( use XOR and rotation to keep 10-bit integer )
	// NOTE: the input string MUST be ASCIIZ string.
	CLD
	ESI     EAX     MOV
	EAX     EAX     XOR
	EDX     MAGIC-NUMBER #  MOV
	BEGIN
		LODSB
		AL      AL      OR
	0<>     WHILE
		DX      AX      XOR     // DH : the higher 5 bits always zero
		CL      DH      MOV     // keep the lower 3 bits of DH in CL
		DX      3 #     SHL
		DH      07 #    AND     // keep only 3 bits in DH
		DL      CL      OR
	REPEAT
	DX      1 #     SHR     // keep 10 bits
	EAX     EDX     MOV
	EDX     EDX     XOR
	CX      MAGIC-NUMBER #  MOV
	CX      DIV             // DX:AX div CX
	EAX     EDX     MOV     // keep remainder
	RET     ;CODE 1 1 #PARMS

CODE: (FIND) ( str_adr key h_table_adr -- str_adr ca ha | str_adr key F )
	// Search a hash table. Input string is a counted ASCIIZ string.
	EDI   { EBP }   MOV     // EDI = KEY = INDEX of hash-table[]
	EDX   { EAX EDI *4 + }  MOV
	BEGIN
		EDX     EDX     OR
	0<>     WHILE
		EDX     EAX     ADD     // the table entry is a relative value
		EDI   { EBP CELL + }    MOV     // str_adr
		ESI   { EDX |NAME-STRING }     LEA
		ECX     ECX     XOR
		CL    BYTE^ { EDI }     MOV
		CL    BYTE^ { EDX |NAME-LENGTH }   CMP
						// compare string length
		=       IF
			EDI     INC     // strings comparision starts here.
		      REPE      CMPSB
			=       IF      // same string?
				EAX     EDX     MOV     // head address
				ECX   { EDX |REFERENCE }   MOV
			      { EBP }   ECX     MOV
				RET
			ENDIF
		ENDIF
		EDX   { EDX |LINK }    MOV
	REPEAT
	EAX     EAX     XOR
	RET     ;CODE 3 3 #PARMS INVISIBLE

: TICKS_PER_10SEC	( -- 182 )
	doCONST [ 11931800 65536 / , ] ; 0 1 #PARMS

: StartDays	( -- a )	// Day count since program start
	doVAR [ 0 , ] ; 0 1 #PARMS

CODE: BIOSTICKS?   ( -- clock_ticks )
      // Return clock ticks since today 00:00:00.
	] DUP [
	EAX     EAX     XOR
	$1A #           INT
	ECX     16 #    SHL
	CX      DX      MOV
	AL	AL	OR
	0<>	IF
	       { StartDays }	INC
	ENDIF
	EAX    { StartDays }	MOV
	EDX    24 60 * 6 * TICKS_PER_10SEC * #		MOV
	EDX		MUL	// unsigned
	EAX     ECX     ADD
	RET     ;CODE 0 1 #PARMS

: TICKS        ( n -- )
      // Wait 'n' clock ticks
	BIOSTICKS?
	BEGIN PAUSE
	   2DUP BIOSTICKS? SWAP - U<=
	UNTIL 2DROP ; 1 0 #PARMS

CR .( * User variables ...)

// All user variables behaves ( -- a )
: SUCCTASK      SUCCTASK, ; // Pointer to next task
: SP-SAVED      SP-SAVED, ; // saved SP during task switching
: RP-SAVED      RP-SAVED, ; // saved RP during task switching
: PREVTASK      PREVTASK, ; // Pointer to previous task
: SP0           SP0, ;    // Pointer to bottom of the data stack.
: RP0           RP0, ;    // Pointer to bottom of the return stack.
: '?KEY         '?KEY, ;   // Execution vector of ?KEY.
: 'EMIT         'EMIT, ;   // Execution vector of EMIT.
: 'EXPECT       'EXPECT, ; // Execution vector of EXPECT.
: 'TAP          'TAP, ;    // Execution vector of TAP.
: 'ECHO         'ECHO, ;   // Execution vector of ECHO.
: 'PROMPT       'PROMPT, ; // Execution vector of PROMPT.
: BASE          BASE, ;   // Storage of the radix base for numeric I/O.
: tmp           tmp, ; // A temporary storage location used in parse and find.
: SPAN          SPAN, ;   // Hold character count received by EXPECT.
: >IN           >IN, ;    // Hold the character pointer while parsing input stream.
: #TIB          #TIB, ;   // Hold the current count in and address of the terminal input buffer.
: 'TIB          'TIB, ;    // hold the base address of the terminal input buffer
: CSP           CSP, ;    // Hold the stack pointer for error checking.
: 'EVAL         'EVAL, ;   // Execution vector of EVAL.
: 'NUMBER       'NUMBER, ; // Execution vector of NUMBER?.
: HLD           HLD, ;    // Hold a pointer in building a numeric output string.
: HANDLER       HANDLER, ; // Hold the return stack pointer for error handling.
: CONTEXT       CONTEXT, ; // A area to specify vocabulary search order.
: CURRENT       CURRENT, ; // Point to the vocabulary to be extended.
: VOC-LINK      VOC-LINK, ; // Vocabulary link pointer.
: CP            CP, ;     // Point to the top of the code dictionary.
: HP            HP, ;     // Point to the bottom of the head dictionary.
: LAST          LAST, ;   // Point to the last name in the name dictionary.
: STATE         STATE, ;  // TRUE for compiling mode and FALSE for interpreting mode.
: DPL           DPL, ;    // double precision number .
: 'CONSOLE      'CONSOLE, ; // terminal interface reset vector
: LastCalled    LastCalled, ; // latest compiled CALLed word.
: 'INTERPRETER  'INTERPRETER, ; // Execution vector of interpreter
: 'COMPILER     'COMPILER, ;    // Execution vector of compiler
: 'TYPE         'TYPE, ;       // vector for TYPE
: 'AT           'AT, ;         // vector for AT
: 'AT?          'AT?, ;        // vector for AT?
: 'RESET-LIST   'RESET-LIST, ; // vector for Resetting on abortion
: 'UP>TASK      'UP>TASK, ;    // reverse link to task's head

// <-- New user variable added here //

: FREE-USER  ( -- a ) doVAR [ 0 , ] ; 0 1 #PARMS INVISIBLE
'UP>TASK SUCCTASK - CELL+  FREE-USER  !   // 04/27/'96  // 09/19/'96 CELL+

// ROOT vocabulary of new system.

: doVOC ( -- )  // Run time action of FORTH VOCABULARY.
	R> @ CONTEXT !  ; 0 0 #PARMS

: FORTH ( -- ) // TARGET vocabulary is the FORTH vocabulary of new system.
	doVOC [ ' TARGET >BODY @ , 0 , ] ; 0 0 #PARMS

CR .( * Commonly used functions ...)

: OFF   ( adr -- ) // clear the content of adr .
	0 SWAP ! ; 1 0 #PARMS

: ON    ( adr -- ) // set the content of adr .
	-1 SWAP ! ; 1 0 #PARMS

: TRUE  ( -- T )      -1 ; 0 1 #PARMS MACRO

: FALSE ( -- F )      0 ; 0 1 #PARMS MACRO

: CELL  ( -- cell-size )
	4 ; 0 1 #PARMS

: ?DUP  ( w -- w w | 0 ) // Dup tos if its is not zero.
	DUP IF DUP ENDIF ;

: DNEGATE       ( d -- -d ) // Two's complement of top double.
	NOT >R NOT 1 UM+ R> + ; 2 2 #PARMS

: ABS   ( n -- n ) // Return the absolute value of n.
	DUP 0< IF NEGATE ENDIF ; 1 1 #PARMS

: MAX   ( n n -- n )    // Return the greater of two top stack items.
	2DUP < IF SWAP ENDIF DROP ; 2 1 #PARMS

: MIN   ( n n -- n )    // Return the smaller of top two stack items.
	2DUP SWAP < IF SWAP ENDIF DROP ; 2 1 #PARMS

: [...]  ( n l h -- t ) // TRUE if l <= n <= h
        -ROT OVER ( h n l n )    <=   -ROT   >=   AND ; 3 1 #PARMS
: [...)  ( n l h -- t ) // TRUE if l <= n < h
        -ROT OVER ( h n l n )    <=   -ROT   >    AND ; 3 1 #PARMS
: (...]  ( n l h -- t ) // TRUE if l < n <= h
        -ROT OVER ( h n l n )    <    -ROT   >=   AND ; 3 1 #PARMS
: (...)  ( n l h -- t ) // TRUE if l < n < h
        -ROT OVER ( h n l n )    <    -ROT   >    AND ; 3 1 #PARMS

: BETWEEN       ( N LO HI -- T/F )    [...] ; 3 1 #PARMS

: WITHIN        ( u ul uh -- t ) // unsigned comparsion
	// Return true if u is within the range of ul and uh. ( ul <= u < uh )
	OVER - >R - R> U< ; 3 1 #PARMS

CR .( * Arithmatic ...)
// Division

: MOD   ( n n -- r )
	/MOD DROP ; 2 1 #PARMS

: M/MOD ( d n -- r q ) // floored
	DUP 0< DUP >R IF NEGATE >R DNEGATE R> ENDIF
	>R DUP 0< IF R@ + ENDIF
	R> UM/MOD R> IF SWAP NEGATE SWAP ENDIF ; 3 2 #PARMS

// Multiplication

: M*    ( n n -- d )
	2DUP XOR 0< >R  ABS SWAP ABS UM*  R> IF DNEGATE ENDIF ; 2 2 #PARMS

: */MOD ( n n n -- r q )
	>R M* R> M/MOD ; 3 2 #PARMS

: */    ( n n n -- q )
	*/MOD NIP ; 3 1 #PARMS

CR .( * Miscellaneous ...)

: ALIGNED       ( b -- a ) // Align address to the cell boundary.
	[ CELL 1- ] LITERAL + [ $FFFFFFFF CELL 1- - ] LITERAL AND ; 1 1 #PARMS

: BL    ( -- 32 ) // Return 32, the blank character.
	$20 ; 0 1 #PARMS

: >CHAR ( c -- c ) // Filter non-printing characters.
	DUP $FF BL WITHIN IF DROP ASCII _ ENDIF ; 1 1 #PARMS

: DEPTH ( -- n ) // Return the depth of the data stack.
	SP@ SP0 @ SWAP - 2/ 2/ ; 0 1 #PARMS  // signed.

CR .( * Memory access ... )

: +!    ( n a -- ) // Add n to the contents at address a.
	SWAP OVER @ + SWAP ! ; 2 0 #PARMS

: 2!    ( d a -- ) // Store the double integer to address a.
	SWAP OVER ! CELL+ ! ; 3 0 #PARMS

: 2@    ( a -- d ) // Fetch double integer from address a.
	DUP CELL+ @ SWAP @ ; 1 2 #PARMS

: COUNT ( b -- b +n ) // Return count byte of a string and add 1 to byte address.
	DUP 1+ SWAP C@ ; 1 2 #PARMS

: HERE  ( -- a ) // Return the top of the code dictionary.
	CP @ ; 0 1 #PARMS

: PAD   ( -- a )
	// Return the address of the text buffer above the code dictionary.
	HERE $50 + ; 0 1 #PARMS

: TIB   ( -- a ) // Return the address of the terminal input buffer.
	'TIB @ ; 0 1 #PARMS

: CMOVE ( b1 b2 u -- ) // Copy u bytes from b1 to b2.
	>R R@ [ CELL 1- ] LITERAL AND FOR AFT
	   OVER C@ OVER C! 1+ SWAP 1+ SWAP
	THEN NEXT
	R> [ -1 CELL 1- - ] LITERAL AND CELL/ FOR AFT
	   OVER @ OVER ! CELL+ SWAP CELL+ SWAP
	THEN NEXT 2DROP ; 3 0 #PARMS

: FILL  ( addr count ch -- )
	// Fill 'count' bytes of character 'ch' to area beginning at 'addr'.
	SWAP FOR SWAP AFT 2DUP C! 1+ THEN NEXT 2DROP ; 3 0 #PARMS

: -TRAILING     ( b u -- b u )
	// Adjust the count to eliminate trailing white space.
	FOR AFT
	   BL OVER R@ + C@ < IF R> 1+ EXIT ENDIF
	THEN NEXT 0 ; 2 2 #PARMS

: PACK$ ( from len to -- to ) // 05/09/'96 rewrite
      // Build a counted string with len characters from 'from'. 
      // Null trailing zeros to make it ends at cell boundary.
      // this make it an ASCIIZ string which might have it's 
      // actual length up to len+cell bytes.
        >R R@ OVER DUP [ CELL 1- ] LITERAL AND - OVER +
        0 SWAP 1+ ! 2DUP C! 1+ SWAP CMOVE R> ; 3 1 #PARMS

CR .( * Numeric output, single precision ...)

: DIGIT ( u -- c ) // Convert digit u to a character.
	$9 OVER < $7 AND + ASCII 0 + ; 1 1 #PARMS

: EXTRACT       ( n base -- n c ) // Extract the least significant digit from n.
	0 SWAP UM/MOD SWAP DIGIT ; 2 2 #PARMS

: <#    ( -- ) // Initiate the numeric output process.
	PAD HLD ! ; 0 0 #PARMS

: HOLD  ( c -- ) // Insert a character into the numeric output string.
	HLD @ 1- DUP HLD ! C! ; 1 0 #PARMS

: #     ( u -- u ) // Extract one digit from u and append the digit to output string.
	BASE @ EXTRACT HOLD ; 1 1 #PARMS

: #S    ( u -- 0 ) // Convert u until all digits are added to the output string.
	BEGIN # DUP WHILE REPEAT ; 1 1 #PARMS

: SIGN  ( n -- ) 0< IF ASCII - HOLD ENDIF ; 1 0 #PARMS

: #>    ( w -- b u ) DROP HLD @ PAD OVER - ; 1 2 #PARMS

: str   ( w -- b u ) DUP >R ABS <# #S R> SIGN #> ; 1 2 #PARMS

: HEX   ( -- ) $10 BASE ! ; 0 0 #PARMS

: DECIMAL ( -- ) $0A BASE ! ; 0 0 #PARMS

CR .( * Numeric Input ...)

: DIGIT? ( c base -- u t )
	>R ASCII 0 - $9 OVER <
	IF $7 - DUP $0A < OR ENDIF DUP R> U< ; 2 2 #PARMS

: DOUBLE?       ( -- f )
// Returns non-zero if a period was encountered during last numeric scan.
       DPL @ 1+   0<> ; 0 1 #PARMS

: D+    ( d1 d2 -- d3 ) // l1 h1 l2 h2
       >R ROT UM+ ROT + R> + ; 4 2 #PARMS

: CONVERT       ( +d1 adr1 -- +d2 adr2 )
// Convert the string at adr1 to a double number until an unconvertable
// character is encountered (pointed to by adr2).  Accumulate in +d1.
	BEGIN   1+  DUP >R  C@  BASE @  DIGIT?
	WHILE   SWAP  BASE @ UM*  DROP  ROT  BASE @ UM*  D+
		DOUBLE?  IF  1 DPL +! ENDIF R>
	REPEAT  DROP  R>  ; 3 3 #PARMS

: (NUMBER?)     ( adr -- d flag )
// Convert string at  adr  to a number.  If successful, leave  TRUE  flag.
// The string should terminate with an ASCII space.
// Only ',' is legal separator.
	0 0  ROT  DUP 1+  C@  ASCII -  =  DUP  >R  -  -1 DPL !
	BEGIN   CONVERT  DUP C@
		ASCII , =
	WHILE   0 DPL !
	REPEAT  -ROT  R> IF  DNEGATE  ENDIF ROT C@ 0=  ; 1 3 #PARMS INVISIBLE

: <NUMBER?>       ( adr -- d T / n T / ??? F )
// Convert a counted string to a number.  The string should terminate
// with an ASCII space and contain a valid, possibly signed, number.
// Does not allow 1233-412-432 to became double number, so as to prevent
// misuse of "4-" or "2-" or..., which means "4 -" or "2 -"or ... .
// Numbers like "234/" are illegal either.
	FALSE OVER COUNT // adr f adr len
	FOR AFT // adr f adr
	   DUP C@   BASE @   DIGIT? NIP // adr f adr t/f
	   IF NIP TRUE SWAP RDROP 0 >R ENDIF
	   1+
	THEN NEXT DROP // adr f
	DUP IF 
	   DROP (NUMBER?) DOUBLE? NOT IF NIP ENDIF
	ENDIF ; INVISIBLE

: NUMBER?  ( adr -- d T / n T / adr F )
	>R R@ BASE @ >R
	DUP 1+ C@ ASCII $ = IF
	    $10 BASE !
	    COUNT SWAP 1+ SWAP 1-  HP @ 256 -  PACK$
	ENDIF
	<NUMBER?> R> BASE !
	DUP IF  RDROP  ELSE  NIP R> SWAP  ENDIF ;

CR .( * Basic I/O ...)

: AT?   ( -- col_x row_y )
	'AT? @EXECUTE ; 0 2 #PARMS

: AT    ( col_x row_y -- )
	'AT @EXECUTE ; 2 0 #PARMS

: ?KEY  ( -- c T | F ) // Return input character and true, or a false if no input.
	'?KEY @EXECUTE ;

: KEY   ( -- c ) // Wait for and return an input character.
	BEGIN  PAUSE ?KEY  UNTIL ; 0 1 #PARMS

: EMIT  ( c -- ) // Send a character to the output device.
	'EMIT @EXECUTE PAUSE ; 1 0 #PARMS

: NUF?  ( -- f ) ?KEY DUP IF 2DROP KEY $0D = ENDIF PAUSE ; 0 1 #PARMS

: PACE  ( -- ) $0B EMIT ; 0 0 #PARMS

: SPACE ( -- ) BL EMIT ; 0 0 #PARMS

: SPACES ( +n -- ) 0 MAX FOR AFT SPACE THEN NEXT ; 1 0 #PARMS

: (TYPE)   ( b u -- )
	FOR AFT DUP C@ EMIT 1+ THEN NEXT DROP ; 2 0 #PARMS

: TYPE  ( b u -- )
	'TYPE @EXECUTE PAUSE ; 2 0 #PARMS

: <CR>  ( -- $0D )    // carrage return
        $0D ; 0 1 #PARMS

: <LF>  ( -- $0A )    // line feed
	$0A ; 0 1 #PARMS

: CR    ( -- ) <CR> EMIT <LF> EMIT ; 0 0 #PARMS

: do$   // str(0) -- str(1) endstr // 'str' is the address of counted string
	DUP COUNT + ; 1 2 #PARMS

: doZ$  // str(0) -- str(1) endstr // 'str' is the address of ASCIIZ string
	DUP COUNT + 1+ ; 1 2 #PARMS

// Don't interfere caller's return stack, it's very dangerous and it will
// reduce their extensibility greatly !
// : do$   ( -- a )   // do$ in eFORTH
//        R> R> DUP COUNT + >R SWAP >R ; 0 1 #PARMS COMPILEONLY
// : doZ$  ( a -- a' ) // ASCIIZ string
//        R> R> DUP COUNT + 1+ >R SWAP >R ; 0 1 #PARMS COMPILEONLY

: $"|   ( -- a )
	R> do$ >R ; 0 1 #PARMS COMPILEONLY INVISIBLE

: Z$"|  ( -- a ) // ASCIIZ string
	R> doZ$ >R 1+ ; 0 1 #PARMS COMPILEONLY INVISIBLE

: "|	( -- str len )
	// Run time routine compiled by " . Return address of a compiled string.
	R> do$ >R COUNT ; 0 2 #PARMS COMPILEONLY INVISIBLE

: .$    ( a -- ) COUNT TYPE ; 1 0 #PARMS

: ."|   ( -- ) R> do$ >R .$ ; 0 0 #PARMS COMPILEONLY INVISIBLE

: .R    ( n +n -- ) >R str      R> OVER - SPACES TYPE ; 2 0 #PARMS
: U.R   ( u +n -- ) >R <# #S #> R> OVER - SPACES TYPE ; 2 0 #PARMS

: U.    ( u -- ) <# #S #> TYPE SPACE ; 1 0 #PARMS
: .     ( n -- ) // BASE @ 10 XOR IF U. EXIT THEN
		   str TYPE SPACE ; 1 0 #PARMS

: .ZEROS ( +n -- )
	0 MAX FOR AFT ASCII 0 EMIT THEN NEXT ; 1 0 #PARMS
: U.0R  ( n +n -- ) // zeros leading fill output.
	>R <# #S #> R> OVER - .ZEROS TYPE ; 2 0 #PARMS

: .H    ( n -- ) BASE @ HEX SWAP . BASE ! ; 1 0 #PARMS
: U.H   ( n -- ) BASE @ HEX SWAP U. BASE ! ; 1 0 #PARMS

: ?     ( a -- ) @ . ; 1 0 #PARMS

CR .( * Parsing ...)

: parse ( b u c -- b u delta // <string> )
	// Scan string delimited by c. Return found string and its offset.
	tmp !  OVER >R  DUP // b u u
	IF 1-  tmp @ BL =
	  IF // b u' // 'skip'
	    FOR 
		BL OVER C@ >=
		WHILE   1+
	    NEXT        ( b ) R> DROP 0 DUP EXIT  // all delim
		THEN    R>
	  ENDIF
	  OVER SWAP     // b' b' u' // 'scan'
	  FOR tmp @ OVER C@ -  tmp @ BL =
	      IF  0<  ENDIF
	      WHILE  1+
	  NEXT       DUP >R
	      ELSE   R> DROP DUP 1+ >R
	      THEN
	  OVER -  R>  R> - EXIT
	ENDIF ( b u )
	OVER R> -  ; 3 3 #PARMS INVISIBLE

: PARSE ( c -- b u // <string> )
	// Scan input stream and return counted string delimited by c.
	>R  TIB >IN @ +  #TIB @ >IN @ -  R> parse >IN +! ; 1 2 #PARMS

: .(    ( -- )  ASCII ) PARSE TYPE ; IMMEDIATE  0 0 #PARMS

: //    ( -- )  #TIB @ >IN ! ; IMMEDIATE 0 0 #PARMS

: (     ( -- )   ASCII ) PARSE 2DROP ; IMMEDIATE 0 0 #PARMS

: ((    ( -- )   1 FOR  \ (   NEXT ; IMMEDIATE 0 0 #PARMS

: CHAR  ( -- c ) BL PARSE DROP C@ ; 0 1 #PARMS

: CTRL  ( -- c ) CHAR $1F AND ; 0 1 #PARMS

: "TOKEN ( b u -- a )
	[ SIZEOF |NAME-STRING CELL- ] LITERAL MIN // can't overwrite LAST head
	HP @ 
	[ |HEAD| ] LITERAL 2DUP - SWAP $CC FILL // fill memory with $CC 5/8/'95
	[ OFFSET |NAME-LENGTH |HEAD| - ] LITERAL
	+ PACK$ ; 2 1 #PARMS

: TOKEN ( -- a ; <string> )
	// Parse a word from input stream and copy it to name dictionary.
	BL PARSE "TOKEN ; 0 1 #PARMS

: WORD  ( c -- a ; <string> )
	// Parse a word from input stream and copy it to code dictionary.
	PARSE HERE PACK$ ; 1 1 #PARMS

CR .( * Dictionary search ...)

: >HEAD ( ca -- ha ) // Convert code address into head address
	CELL- @  ; 1 1 #PARMS

: NAME> ( na -- ca ) // Return a code address given a name address.
	OFFSET |NAME-LENGTH LITERAL - @ ; 1 1 #PARMS

: FIND  ( stradr -- ca ha | stradr F )
	// Search all context vocabularies for a string.
	// The stradr must be the starting address of Counted ASCIIZ string.
	DUP 1+ HASH CONTEXT
	BEGIN ( stradr key ctx^ )
	  >R R@ @ DUP
	WHILE ( stradr key ctx )
	  (FIND) DUP IF ( stradr ca ha )
	     ROT DROP R> DROP EXIT
	  ENDIF ( stradr key F )
	  DROP R> CELL+
	REPEAT ( stradr key ctx )
	R> DROP 2DROP 0 ; 1 2 #PARMS

CR .( * Terminal response ...)

: TAB   ( -- )
	$08 AT? DROP $07 AND - SPACES ; 0 0 #PARMS

: (EMIT) ( c -- )
	DUP [ CTRL I ] LITERAL ( TAB ) = 
	IF  DROP TAB  ELSE  BIOSEMIT  ENDIF ; 1 0 #PARMS

: BKSPC ( -- ) // back space
	[ CTRL H ] LITERAL 'ECHO @EXECUTE ; 0 0 #PARMS

: ^H    ( bot eot cur -- bot eot cur ) // Backup the cursor by one character.
	>R OVER R> SWAP OVER XOR IF
	   $08 'ECHO @EXECUTE 1- BL 'ECHO @EXECUTE $08 'ECHO @EXECUTE
	ENDIF ; 3 3 #PARMS INVISIBLE

: TAP   ( bot eot cur c -- bot eot cur )
	// Accept and echo the key stroke and bump the cursor.
	DUP 'ECHO @EXECUTE OVER C! 1+ ; 4 3 #PARMS INVISIBLE

: kTAP  ( bot eot cur key -- bot eot cur )
	// Process a key stroke, CR or backspace.
	DUP [ CTRL M ] LITERAL XOR
	IF
	    [ CTRL H ] LITERAL XOR IF BL TAP EXIT ELSE ^H EXIT ENDIF
	ELSE
	    BL 'ECHO @EXECUTE
	ENDIF DROP NIP DUP ; 4 3 #PARMS INVISIBLE

: accept ( b u -- b u )
	// Accept characters to input buffer. Return with actual count.
	OVER + OVER
	BEGIN
	   2DUP XOR
	WHILE
	   KEY DUP BL $FF WITHIN IF  TAP  ELSE  'TAP @EXECUTE  ENDIF
	REPEAT DROP OVER - ; 2 2 #PARMS

: EXPECT ( b u -- ) // Accept input stream and store count in SPAN.
	'EXPECT @EXECUTE SPAN ! DROP ; 2 0 #PARMS

: QUERY ( -- ) // Accept input stream to terminal input buffer.
	TIB 80 'EXPECT @EXECUTE #TIB ! DROP 0 >IN ! ; 0 0 #PARMS

CR .( * Error handling ...)

: CATCH ( ca -- 0 | err# )
	// Execute word at ca and set up an error frame for it.
	SP@ >R HANDLER @ >R // Save error frame
	RP@ HANDLER !
	EXECUTE R> HANDLER ! // restore error frame
	R> DROP 0 ; 1 1 #PARMS

: THROW ( err# -- ) ( CATCH: -- err# )
	// Reset system to current local error frame an update error flag.
	HANDLER @ RP!               // restore return stack
	R> HANDLER ! R> SWAP >R SP! // restore data   stack
	DROP R> ; 1 0 #PARMS // !! Not 1 1 #PARMS !!

: NULL$ ( -- a ) // Return address of a null string with zero count.
	doVAR [ 0 , ] ; 0 1 #PARMS

: ABORT ( -- ) // Reset data stack and jump to QUIT.
	NULL$ THROW ; 0 0 #PARMS

: abort" ( f -- ) // Run time routine of ABORT" . Abort with a message.
	R> do$ >R SWAP
	IF DUP .$ CR THROW EXIT ENDIF
	DROP ; 1 0 #PARMS COMPILEONLY INVISIBLE

// Resetter data structure : 2 cells ( 2variable )
//      | vector for reset | address of previous reset structure |

: PUSH-RESETTER ( vector reset-struct-node -- )
    // push into reset list if 'vector' not existed yet.
	'RESET-LIST @
	BEGIN   // check whether the node has already been in list
		// to prevent circular linkage.
	    DUP 0<>
	    WHILE
		2DUP <>
	WHILE
	    CELL+ @
	REPEAT
		3DROP
	    ELSE  // node have not been pushed yet, push it.
		DROP SWAP OVER !
		'RESET-LIST @ OVER CELL+ !
		'RESET-LIST !
	    THEN  ; 2 0 #PARMS

: POP-RESETTER ( reset-struct-node -- )
     // Pop if node exists, otherwise ignore. Only pop top element.
	DUP 'RESET-LIST @ = IF
	   CELL+ @ 'RESET-LIST !
	ELSE 
	   DROP
	ENDIF ; 1 0 #PARMS

: RESET-TILL    ( reset-struct-node -- )
     // Reset till reset-struct-node is reached.
	>R
	BEGIN
	   'RESET-LIST @ DUP 0<> SWAP R@ <> AND
	WHILE
	   'RESET-LIST @  DUP @EXECUTE  CELL+ @  'RESET-LIST !
	REPEAT RDROP ; 1 0 #PARMS INVISIBLE

: RESETTING     ( -- ) RECURSIVE      // reset on error , tail recursive
	'RESET-LIST @ ?DUP IF
	   DUP @EXECUTE CELL+ @ 'RESET-LIST !
	   RESETTING
	ENDIF ; 0 0 #PARMS INVISIBLE

CR .( * Text interpreter ...)

: Unrecognized  ( a -- )
	SPACE .$ TRUE ."| [ $,"  : unrecognized." ] CR
	ABORT ; 1 0 #PARMS INVISIBLE

: NUMBER     ( a -- d T / n T / a F )
        'NUMBER @EXECUTE ;

: $INTERPRET ( a -- )
	// Interpret a word. If failed, try to convert it to an integer.
	FIND ?DUP IF
	   |ATTRIBUTE H@ [ COMPO ] LITERAL AND
	   abort" [ $,"  Compile only words can't be used while interpreting." ] 
	   EXECUTE EXIT
	ELSE
	   NUMBER IF EXIT ELSE Unrecognized ENDIF
	ENDIF ; 1 0 #PARMS

: INTERPRETER   ( -- a )
	'INTERPRETER @ ; 0 1 #PARMS

: [     ( -- ) // Start the text interpreter.
	INTERPRETER 'EVAL ! 0 STATE ! ; 0 0 #PARMS IMMEDIATE

: .OK   ( -- ) // Display 'ok' only while interpreting.
	INTERPRETER 'EVAL @ = IF  
	   ."| [ $,"  ok" ]
	   DEPTH ?DUP IF    256 MIN FOR AFT ASCII . EMIT THEN NEXT    ENDIF
	ENDIF  CR   ; 0 0 #PARMS

: ?STACK ( -- ) // Abort if the data stack underflows.
	DEPTH 0< abort" [ $,"  Stack underflow !" ] ; 0 0 #PARMS

: EVAL  ( -- ) // Interpret the input stream.
	BEGIN
	   TOKEN DUP C@
	WHILE
	   'EVAL @EXECUTE ?STACK
	REPEAT
	DROP 'PROMPT @EXECUTE ; 0 0 #PARMS

CR .( * Shell ...)

: PRESET ( -- ) // Reset data stack pointer and the terminal input buffer.
	SP0 @ SP!
	[ T-TIB @ ] LITERAL 'TIB ! ; 0 0 #PARMS

: xio   ( a a a -- ) // Reset the I/O vectors 'EXPECT, 'TAP, 'ECHO and 'PROMPT.
	['] accept 'EXPECT ! 'TAP ! 'ECHO ! 'PROMPT ! 
	; 3 0 #PARMS INVISIBLE

: FILE  ( -- ) // Select I/O vectors for file download.
	['] PACE ['] DROP ['] kTAP xio ; 0 0 #PARMS

: HAND  ( -- ) // Select I/O vectors for terminal interface.
	['] .OK ['] EMIT ['] kTAP xio ; 0 0 #PARMS

: I/O   ( -- a ) // Array to store default I/O vectors.
	doVAR [ ' ?BIOSKEY , ' (EMIT) , ] ; 0 1 #PARMS

: (CONSOLE) ( -- ) // Initiate terminal interface.
	I/O 2@ '?KEY ! 'EMIT !  ['] (TYPE)  'TYPE !
	['] BIOSAT 'AT !        ['] BIOSAT? 'AT? !
	HAND ; 0 0 #PARMS

: CONSOLE ( -- )
	'CONSOLE @EXECUTE ; 0 0 #PARMS

CR .( * Name compiler ...)

: OVERT ( -- )  // Link a new word into the current vocabulary.
	LAST @ DUP |NAME-STRING HASH CELL* // ( ha index )
	CURRENT @ DUP ROT + ( ha tab entry )
	-ROT - SWAP ! ; 0 0 #PARMS

: MaskNameAttr  ( n -- )
	LAST @ |ATTRIBUTE SWAP OVER H@ OR SWAP H! 
	; 1 0 #PARMS INVISIBLE

: IMMEDIATE ( -- ) // Make the last compiled word an immediate word.
	[ IMMED ] LITERAL MaskNameAttr ; 0 0 #PARMS

: COMPILEONLY ( -- ) // Make the last compiled word be 'compile-only' word.
	[ COMPO ] LITERAL MaskNameAttr ; 0 0 #PARMS

: MACRO     ( -- ) // Make the last definition a macro
	[ MACRO-MASK ] LITERAL MaskNameAttr ; 0 0 #PARMS

: INVISIBLE     ( -- ) // Make the last definition to be invisible
	[ INVIS-MASK ] LITERAL MaskNameAttr ; 0 0 #PARMS

: INVIS         INVISIBLE ;     // alias for easy typing

WARNING @       // host system's WARNING

: WARNING ( -- adr ) // redefinition warning.
	doVAR [ 0 , ] ; 0 1 #PARMS

WARNING !       // target system's WARNING

: ?UNIQUE ( a -- a ) // Display a warning message if the word already exists.
	DUP FIND WARNING @ AND IF
	  SPACE OVER .$ ."| [ $,"  : redefined. " ]
	ENDIF DROP ; 1 1 #PARMS INVISIBLE

: $,n   ( na -- ) // Build a new head entry using the string at na.
	DUP C@ IF
	    ?UNIQUE DUP OFFSET |NAME-LENGTH LITERAL - SWAP 1+
	    ( ha na+1 )
	    HASH SWAP   ( key ha ) // compute head address
	    DUP HERE ! CELL CP +!       ( key ha ) // set >HEAD linkage
				// and advance dictionary pointer
	    DUP LAST ! DUP HP ! HERE OVER ! CELL+
	    ( key ha.link ) // set |REFERENCE
	    SWAP CELL* CURRENT @ + @ OVER ! CELL+
	    ( ha.size ) // set |LINK
	    0 OVER ! CELL+ ( ha.user_defined )
	    // initialize |SIZE field to 0
	    0 OVER ! CELL+ ( ha.attribute )
	    // initialize |USER-DEFINED field to 0
	    0 OVER H! 2 +       ( ha.in-parm )
	    // set |ATTRIBUTE field
	    $FF OVER C! 1+
	    // |IN-PARMS = FF
	    $FF SWAP C!
	    // |OUT-PARMS = FF
	// set the rest bytes to zero (if there are)
	ELSE
	    ."| [ $,"  Missing name !" ] THROW
	ENDIF ; 1 0 #PARMS INVISIBLE

CR .( * Compilers ...)

: #PARMS ( #in #out -- ) // Set input/output parameter numbers
	LAST @ DUP |OUT-PARMS ROT SWAP C!
	|IN-PARMS C! ; 2 0 #PARMS

: EXPAND ( ca -- ) // Perform a macro expansion .
	DUP >HEAD |SIZE @
	1- ( delete RET instruction ) HERE 2DUP + CP !
	SWAP CMOVE ; 1 0 #PARMS

: '     ( -- ca ) // Search context vocabularies for the next word in input stream.
	TOKEN FIND IF EXIT ENDIF Unrecognized ; 0 1 #PARMS

: .FREE         ( -- )        // 05/04/'96
        BASE @ DECIMAL 
        HP @ HERE - .
        BASE ! ."| [ $," bytes of memory left." ] ; 0 0 #PARMS

: FreeMemChk    ( -- )        // 05/04/'96
        WARNING @ IF 
           HP @ CP @ -
           DUP 0< abort" [ $," * Fatal error : Out of memory ." ]
           [ 16384 ] LITERAL < IF  // less than 16 k left
              CR ."| [ $," Warning : Only " ] .FREE CR
           ENDIF
        ENDIF ; 0 0 #PARMS INVIS

: ALLOT ( n -- )  // Allocate n bytes to the code dictionary.
	CP +! FreeMemChk  ; 1 0 #PARMS

: ,     ( w -- ) // Compile an integer into the code dictionary.
	HERE ! [ CELL ] LITERAL CP +! ; 1 0 #PARMS

: H,    ( HWORD -- )
	// Compile a half-word ( 2 bytes ) into the code dictionary.
	HERE H! 2 CP +! ; 1 0 #PARMS

: C,    ( c -- ) // Compile a byte (char) into the code dictionary.
	HERE C! 1 CP +! ; 1 0 #PARMS

: rel,  ( ca -- ) // Compile a relative address .
	HERE CELL+ - , ; 1 0 #PARMS INVISIBLE

OPTIMIZE @      // host system's optimize flag

: OPTIMIZE doVAR [ 0 , ] ; 0 1 #PARMS

OPTIMIZE !      // target system's optimize flag

: call, ( ca -- )
	// Compile a 'call' instruction .(Subroutine threaded)
	$E8 C, rel, ; 1 0 #PARMS

: compile, ( ca -- ) // ( Macro expansion subroutine threaded )
	// Compile a call instruction to ca. Or perfrom a macro expansion.
	DUP >HEAD |ATTRIBUTE H@ DUP
	$80 AND IF // is Macro ?
	   DROP EXPAND
	ELSE
	   SWAP call, // 80x86 relative call
	   OPTIMIZE @ IF
	      $02 AND 0= IF // is it NOT Compile only ?
		 HERE LastCalled !
	      ENDIF
	   ELSE
	      DROP      
	   ENDIF                  
	ENDIF ; 1 0 #PARMS INVISIBLE

: LITERAL   ( w -- ) // Compile tos to code dictionary as an integer literal.
	['] (LIT) compile, , ; 1 0 #PARMS IMMEDIATE COMPILEONLY

: $,"   ( -- ) // Compile a literal string up to next " .
	ASCII " WORD COUNT + CP ! ; 0 0 #PARMS

: RECURSIVE ( -- ) // Make the current word available for compilation.
	OVERT ; 0 0 #PARMS IMMEDIATE COMPILEONLY

: RECURSE   ( -- ) // Make a recursive call to current word.
	LAST @ |REFERENCE @ compile, ; 0 0 #PARMS IMMEDIATE COMPILEONLY

CR .( * Forth compiler ...)

: $COMPILE ( a -- )
	// Compile next word to code dictionary as a token or literal.
	FIND ?DUP IF
	   |ATTRIBUTE H@ [ IMMED ] LITERAL AND IF
	     EXECUTE EXIT
	   ELSE
	     compile, EXIT
	   ENDIF
	ELSE
	   NUMBER IF
	      DOUBLE? IF SWAP \ LITERAL ENDIF
	      \ LITERAL EXIT
	   ENDIF
	ENDIF
	LAST @ // Fail compiling, adjust HP back
	[ |HEAD| ] LITERAL + DUP HP ! LAST ! 
	Unrecognized ; 1 0 #PARMS

: COMPILER      ( -- a )
	'COMPILER @ ; 0 1 #PARMS

: ]     ( -- ) // Start compiling the words in the input stream.
	COMPILER 'EVAL ! -1 STATE ! ; 0 0 #PARMS

: COMPILE   ( -- ) // An immediate word !!! ( for checking macro expansion )
	// Compile the next address in colon list to code dictionary.
	' \ LITERAL
	['] compile, compile, ; 0 0 #PARMS IMMEDIATE

: [']   ( -- ) ' \ LITERAL ; 0 0 #PARMS IMMEDIATE COMPILEONLY

: \     ( -- ; <string> )
	// Compile the next immediate word into code dictionary.
	' compile, ; 0 0 #PARMS IMMEDIATE

: "HEADER   ( b u -- )
	"TOKEN $,n ; 2 0 #PARMS

: HEADER    ( -- ; <string> )
	TOKEN $,n ; 0 0 #PARMS

: ;     ( -- ) // Terminate a colon definition.
	OPTIMIZE @ IF
	   LastCalled @   HERE  =  IF   $E9 HERE 5 - C!   ENDIF
	ENDIF
	COMPILE EXIT    // always compile a RET in case of IF..THEN branching.
	OVERT HERE LAST @ |REFERENCE @ -
	LAST @ |SIZE !
	\ [     
        FreeMemChk  ; 0 0 #PARMS IMMEDIATE COMPILEONLY

: :     ( -- ; <string> )
	// Start a new colon definition using next word as its name.
	HEADER ] ; 0 0 #PARMS

CR .( * Defining words ...)

: TooManyUserVars?      ( n -- )
        [ |USERS| ] LITERAL   >=  
        abort" [ $," * Too many user variables !" ]  ; 1 0 #PARMS INVIS

: USERVAR  ( -- ; <string> ) // Compile a new user variable.
        FREE-USER @  TooManyUserVars?
	HEADER OVERT 0 1 #PARMS
        ['] doUSER compile,  FREE-USER @ ,  CELL FREE-USER +!
        COMPILE EXIT  ; 0 0 #PARMS

: 2USERVAR  ( -- ; <string> ) // Compile a new user 2variable.
        FREE-USER @ CELL+  TooManyUserVars?
        USERVAR CELL FREE-USER +!  ; 0 0 #PARMS

: align-body    ( -- ) // align created object body
	HERE 3 + ALIGNED 1- CP ! ; INVISIBLE

: "CREATE ( b u -- )
	align-body "HEADER OVERT 0 1 #PARMS ['] doVAR compile, ; 2 0 #PARMS

: CREATE ( -- ; <string> )
	// Compile a new array entry without allocating code space.
	align-body HEADER OVERT 0 1 #PARMS ['] doVAR compile, ; 0 0 #PARMS

: VARIABLE ( -- ; <string> ) // Compile a new variable initialized to 0.
	CREATE 0 , CELL LAST @ |SIZE ! ; 0 0 #PARMS

: 2VARIABLE ( -- ; <name> )
	CREATE 0 DUP , , CELL 2* LAST @ |SIZE ! ; 0 0 #PARMS

: CONSTANT ( c -- ) // Create a constant name.
	align-body HEADER OVERT 0 1 #PARMS ['] doCONST compile, ,
	CELL LAST @ |SIZE ! ; 1 0 #PARMS

: ;DOES ( -- ) // Set the code field to the address of the following.
	R> CELL+ LAST @ |REFERENCE @  DUP $E8 SWAP C! 1+ DUP CELL+ ROT SWAP
	- SWAP ! // Subroutine Threaded Code
	; 0 0 #PARMS COMPILEONLY

: DOES> ( -- )
	['] ;DOES compile,
	LAST @ |REFERENCE @ ,   // >HEAD pointer
	['] R> compile, ; 0 0 #PARMS IMMEDIATE COMPILEONLY

CR .( * Structure control words ...)
	// For modifing all absolute addresses to relative addresses,
	// just replace all '!' which performed on addresses into '+!'
	// and all ',' which perfromed on addresses into 'rel,' .

: FOR   ( -- 0 a ) // Start a FOR-NEXT loop structure in a colon definition.
	['] >R compile, 0 HERE ; 0 2 #PARMS IMMEDIATE COMPILEONLY

: NEXT  ( 0 a -- ) // Terminate a FOR-NEXT loop structure.
	NIP ['] next compile, rel, ; 2 0 #PARMS IMMEDIATE COMPILEONLY

: BEGIN ( -- 0 a ) // Start an infinite or indefinite loop structure.
	0 HERE ; 0 2 #PARMS IMMEDIATE COMPILEONLY

: UNTIL ( 0 a -- ) // Terminate a BEGIN-UNTIL indefinite loop structure.
	NIP ['] ?BRANCH compile, rel, ; 2 0 #PARMS IMMEDIATE COMPILEONLY

: AGAIN ( 0 a -- ) // Terminate a BEGIN-AGAIN infinite loop structure.
	NIP ['] BRANCH compile, rel, ; 2 0 #PARMS IMMEDIATE COMPILEONLY

: IF    ( -- 0 A ) // Begin a conditional branch structure.
	['] ?BRANCH compile, 0 HERE 0 rel, ; 0 2 #PARMS IMMEDIATE COMPILEONLY

: AHEAD ( -- 0 A ) // Compile a forward branch instruction.
	['] BRANCH compile, 0 HERE 0 rel, ; 0 2 #PARMS IMMEDIATE COMPILEONLY

: REPEAT ( 0 A 0 a -- ) // Terminate a BEGIN-WHILE-REPEAT indefinite loop.
	\ AGAIN NIP HERE SWAP +! ; 4 0 #PARMS IMMEDIATE COMPILEONLY

: ENDIF ( 0 A -- ) // Terminate a conditional branch structure.
	NIP HERE SWAP +! ; 2 0 #PARMS IMMEDIATE COMPILEONLY

: THEN  \ ENDIF ; 2 0 #PARMS IMMEDIATE COMPILEONLY

: AFT   ( 0 a -- 0 a 0 A )
	// Jump to THEN in a FOR-AFT-THEN-NEXT loop the first time through.
	2DROP \ AHEAD
	\ BEGIN 2SWAP ; 2 4 #PARMS IMMEDIATE COMPILEONLY

: ELSE  ( 0 A -- 0 A ) // Start the false clause in an IF-ELSE-THEN structure.
	\ AHEAD 2SWAP \ ENDIF ; 2 2 #PARMS IMMEDIATE COMPILEONLY

: WHILE ( 0 a -- 0 A 0 a ) 
        // Conditional branch out of a BEGIN-WHILE-REPEAT loop.
	\ IF 2SWAP ; 2 4 #PARMS IMMEDIATE COMPILEONLY

: ABORT" ( -- ; <string> ) // Conditional abort with an error message.
	['] abort" compile, $," ; 0 0 #PARMS IMMEDIATE COMPILEONLY

: $"    ( -- ; <string> ) // Compile an inline string literal.
	['] $"| compile, $," ; 0 0 #PARMS IMMEDIATE COMPILEONLY

: Z$"   ( -- ; <string> ) // Compile an counted ASCIIZ string.
	['] Z$"| compile, $," 0 C, ; 0 0 #PARMS IMMEDIATE COMPILEONLY

: ."    ( -- ; <string> )
	// Compile an inline string literal to be typed out at run time.
	['] ."| compile, $," ; 0 0 #PARMS IMMEDIATE COMPILEONLY

: "     ( -- )
	['] "| compile, $," ; 0 0 #PARMS IMMEDIATE COMPILEONLY

CR .( * MS-DOS file interface ...)

0 CONSTANT READ/ONLY    1 CONSTANT WRITE/ONLY   2 CONSTANT READ/WRITE
0 CONSTANT SEEK_SET     1 CONSTANT SEEK_CUR     2 CONSTANT SEEK_END

: HCREATE   ( fattr asciiz-adr -- handle True / err-code False )
	 // fattr = 0 : normal , 1 : read-only, 2 : hidden, 4 : system .
	>R >R 
      // EBP EDI ESI EDX ECX EBX EAX #int/flags
	 2DUP   DUP
		    R> R> SWAP 
			     0 $3C00 $21 trap
				     $1 AND 0=  // carry flag set ?
				>R >R 6DROP
	R> R> ; 2 2 #PARMS

: HOPEN ( mode asciiz-adr -- handle True / err-code False )
	>R >R
      // EBP EDI ESI EDX ECX EBX EAX #int/flags
	 2DUP   DUP R> R> SWAP
			     0  DUP 
				ROT $00FF AND $3D00 OR
				       $21  trap
				       $1 AND 0=
				 >R >R 6DROP
	R> R> ; 2 2 #PARMS

: HCLOSE        ( handle -- T/F )
      // EBP EDI ESI EDX ECX EBX EAX #int/flags
	>R 
	 2DUP   2DUP    DUP R>  $3E00   $21  trap
					$1 AND 0=
					>R 6DROP DROP
	R> ; 1 1 #PARMS

: (HREAD/WRITE)   // ( buf bytes<65536 handle rd/wr
		    //   -- bytes-read/written T / err-code F )
	>R >R >R >R
      // EBP EDI ESI EDX ECX EBX EAX  #int/flags
	 2DUP   DUP R>  R>  R>  R>      $21    trap
					$1 AND 0=
				  >R >R 6DROP
	R> R> ; 4 2 #PARMS INVISIBLE

: (HREAD/WRITE)   // ( buffer bytes handle rd/wr
		  //   -- bytes-read/written T / err-code F )
	0 >R ROT ( buf handle rd/wr |R: counts )
	$FFFF /MOD ( buf h rd/wr rem quot |R: counts )
	?DUP IF
	   RDROP SWAP >R 0 SWAP ( hide 'rem' ... buf h rd/wr 0 quot |R: rem )
	   1- FOR ( buf h rd/wr 0 |R: rem #I )
		 >R >R 2DUP $FFFF SWAP R@ (HREAD/WRITE)
	      WHILE ( buf h bytes |R: rem #I counts rd/wr )
		 ROT OVER + -ROT ( buf' h bytes |R: rem #I counts rd/wr )
		 R> SWAP R> OVER + SWAP ( buf' h rd/wr cnts' bytes |R: rem #I)
		 $FFFF < IF // read : EOF; write : disk full.
		    >R 2DROP DROP R> ( counts' |R: rem #I )
		    RDROP RDROP TRUE EXIT  ( returns : counts' TRUE )
		 ENDIF
		 ( buf' h rd/wr counts' |R: rem #I )
	   NEXT
	      ELSE  ( buf h err-code |R: rem #I counts rd/wr )
		 RDROP ( rd/wr ) RDROP ( counts ) RDROP ( #I ) RDROP ( rem )
		 -ROT 2DROP FALSE EXIT
	      THEN
	   ( buf' h rd/wr counts' |R: rem )     
	   R> SWAP >R ( reveal 'rem' ... buf' h rd/wr rem |R: counts )
	ENDIF
	( buf h rd/wr rem |R: counts )
	?DUP IF
	   -ROT (HREAD/WRITE)         ( bytes T | err F   |R: counts )
	   IF   R> + TRUE   ELSE   RDROP FALSE   ENDIF
	ELSE
	   2DROP DROP R> TRUE
	ENDIF   ; 4 2 #PARMS INVISIBLE

: HREAD ( buffer bytes handle -- bytes-read T / err-code F )
	$3F00 (HREAD/WRITE) ; 3 2 #PARMS
	
: HWRITE  ( buffer bytes handle -- bytes-written T / err-code F )
	$4000 (HREAD/WRITE) ; 3 2 #PARMS

: HSEEK ( mode offset handle -- file_pointer T / err-code F )
	ROT >R >R // D: offset   R: mode handle
      // EBP EDI ESI EDX ECX EBX EAX  #int/flags
	     DUP     2DUP $FFFF AND
			 OVER 256/ 256/ $FFFF AND
			     R>
				 R> $FF AND $4200 OR  // AH=$42  AL=mode
				      $21       trap
				      $1 AND 0= >R
				 $FFFF AND -ROT 2DROP
		     SWAP 256* 256* OR >R   // AX = LO16  DX = HI16
		 3DROP
	R>
	R> DUP NOT IF // AX = error code
	   SWAP $FFFF AND  SWAP
	ENDIF ; 3 2 #PARMS

CREATE FNAMEBUF $100 ALLOT INVISIBLE

: OPEN  ( stradr len mode -- handle True / err-code False )
	// Open a EXISTED file with "mode"
	>R FNAMEBUF SWAP 2DUP + 0 SWAP C!
	CMOVE R> FNAMEBUF HOPEN ; 3 2 #PARMS

: FOPEN ( stradr len mode -- handle True / err-code False )
	// If file already exists, open it with 'mode'
	// otherwise create a new file .
	OPEN IF
	  TRUE
	ELSE
	  DUP 2 = IF
	    DROP 0 FNAMEBUF HCREATE
	  ELSE
	    FALSE
	  ENDIF
	ENDIF ; 3 2 #PARMS

: READLN ( buffer handle -- bytes-read T / err-code F )
	>R 0 ( buf count ; R: h )
	BEGIN
	  OVER 1 R@ HREAD IF ( buf count 1/0 )
	     ?DUP IF // EOF? ( buf c 1 )
		  SWAP OVER + -ROT OVER ( count+1 buf 1 buf )
		  C@ $0A = IF ( end-of-line ? )
		     TRUE
		  ELSE
		     FALSE
		  ENDIF
		  >R + SWAP ( buf+1 count+1 R: FLAG handle )
		ELSE // EOF, LEAVE ( buf c )
		TRUE >R
	      ENDIF
	  ELSE ( buf count err-code ; R: h )
	    RDROP -ROT 2DROP FALSE EXIT
	  THEN
	R> UNTIL
	SWAP DROP RDROP TRUE ; 2 2 #PARMS

CR .( * Tools ...)

: _TYPE ( b u -- ) // Display a string. Filter non-printing characters.
	FOR AFT
	  DUP C@ >CHAR EMIT 1+
	THEN NEXT DROP ; 2 0 #PARMS INVISIBLE

: dm+   ( a u -- a ) // Dump u bytes from , leaving a+u on the stack.
	OVER [ CELL 2 * ] LITERAL U.R SPACE
	FOR AFT  
	   DUP C@ SPACE 2 U.0R 1+
	THEN NEXT ; 2 1 #PARMS INVISIBLE

: DUMP  ( a u -- ) // Dump u bytes from a, in a formatted manner.
	BASE @ >R HEX // Save radix, set hex
	$10 / FOR
	   CR $10 2DUP dm+ -ROT 2 SPACES _TYPE NUF? NOT
	   WHILE
	NEXT
	   ELSE R> DROP THEN DROP
	R> BASE ! ; 2 0 #PARMS

: .S    ( -- ) // Display the contents of the data stack.
	CR ?STACK DEPTH 0 MAX 1024 MIN 
	FOR AFT R@ PICK . THEN NEXT ."| [ $," <- SP" ] ; 0 0 #PARMS

: !CSP  ( -- ) // Save stack pointer in CSP for error checking.
	SP@ CSP ! ; 0 0 #PARMS INVISIBLE

: ?CSP  ( -- ) // Abort if stack pointer differs from that saved in CSP.
	SP@ CSP @ XOR abort" [ $,"  Stack changed !" ] ; 0 0 #PARMS INVISIBLE

: >NAME ( ca -- na | F ) // Convert code address to a name address.
	>HEAD |NAME-LENGTH ; 1 1 #PARMS

: .ID   ( ha -- ) // Display the name at address.
	?DUP IF
	   |NAME-LENGTH .$
	ELSE
	   ."| [ $," {NoName}" ]
	ENDIF ; 1 0 #PARMS

: BREAK ; INVISIBLE // a label for external debugger

CR .( * Forth source code loader ...)

// Fast FLOAD ( read buffering )         08/23/'93
// The old FLOAD spend more than 98% of time on file I/O. That's why
// it seems so slow.


// These variables should be user-dependent if multi-user system is needed.

: #LINESREAD    ( -- a )
	doVAR [ 0 , ] ; 0 1 #PARMS INVISIBLE
: point-error   
      // A flag,Point out the error if TRUE
	doVAR [ 0 , ] ; 0 1 #PARMS INVISIBLE
: fload-nesting doVAR [ 0 , ] ; 0 1 #PARMS INVISIBLE
: io-error      doVAR [ 0 , ] ; 0 1 #PARMS INVISIBLE
: SHOWLINE      doVAR [ 0 , ] ; 0 1 #PARMS INVISIBLE    // 05/09/'96
: .#linesread   ( -- )        // display current line if showline is ON
        SHOWLINE @ IF  <CR> EMIT #LINESREAD @ . ENDIF ; 0 0 #PARMS

2VARIABLE FLOAD-RESETTER INVISIBLE

: RESET-FLOAD   ( -- )
	#LINESREAD OFF  fload-nesting OFF  io-error OFF
	[ T-TIB @ ] LITERAL 'TIB !
	['] FLOAD-RESETTER POP-RESETTER  ; 0 0 #PARMS INVISIBLE

: till-endofline ( buf handle -- end-of-buf )
      // It assumes that no source line exceed 255 characters !!!
      // That's why the MEMMAP.4TH use 256 as safety margin between buffers.
      // Since 255 + 1 = 256 . ( one byte of zero to stop compiliation )
	>R DUP 
        BEGIN  ( buf0 buf' )
            2DUP SWAP - 255 > 
            abort" [ $," * Source code line too long ! ( > 255 characters )" ]
	    DUP 1 R@ HREAD IF  ( buf0 buf 1/0 )   // Now check EOL or EOF
	       0= DUP NOT IF                          ( buf0 buf F )
                  DROP DUP C@ SWAP 1+                 ( buf0 c buf+1 )
                  SWAP <LF> =                         ( buf0 buf+1 T/F )
               ENDIF
	    ELSE               ( buf0 buf err )
	       io-error !   TRUE
	    ENDIF
	UNTIL  ( buf0 buf+1 )
        NIP RDROP   0  OVER  C!  // End of compiling marker.  04/29/'96
        ; 2 1 #PARMS INVISIBLE

: SHOW-ERROR    ( err -- )
	point-error @ IF
	   CR ." Error in line "
	   BASE @ DECIMAL #LINESREAD @ . 58 EMIT CR CR BASE !
	   TIB #TIB @ 2 - TYPE CR
	   TIB >IN @ 1- FOR
	       DUP C@ $09 = IF TAB ELSE SPACE ENDIF 1+
	   NEXT
	   DROP BKSPC BKSPC 24 EMIT SPACE // point out the error
	   .$ ."  <-- Error " CR  // error message from THROW
	ELSE
	   DROP
	ENDIF ; 1 0 #PARMS INVISIBLE

: TRANSLATE     ( buffer bufsiz -- ERR? )
      // Compile codes in 'buffer', compile 'bufsiz' bytes of source codes.
      // Keep data stack while calling 'EVAL'
	>IN @ >R  #TIB @ >R  TIB >R  'PROMPT @ >R
	SWAP 'TIB !  // work on TIB
	TIB >R R@ +  // end of buffer
	>R           // empty out data stack ( for ?STACK check )
	BEGIN                                               ( R: oldTIB eob )
	   >IN OFF 1 #LINESREAD +! .#linesread
	   ['] NOOP 'PROMPT !
	  // find End-of-line or end-of-buffer
	   TIB BEGIN
	      DUP R@ < NOT DUP NOT IF
		DROP DUP 1+ SWAP
		C@  DUP 0=   SWAP <LF> =  OR
	      ENDIF
	   UNTIL
	  // Evaluate TIB
	   DUP >R TIB - #TIB !   ( R: oldTIB eob nextline )   
	   ['] EVAL CATCH        ( D: ??? CATCHED ; R: oldTIB eob nextline )
	   ?DUP 0<> IF
	       RDROP RDROP RDROP
	       DUP SHOW-ERROR 
	       R> 'PROMPT !  R> 'TIB !  R> #TIB !  R> >IN ! 
	       FLOAD-RESETTER RESET-TILL
	       EXIT
	   ENDIF                 ( D: ??? ; R: oldTIB eob nextline )
	   R> DUP 'TIB ! // next line
	   R@ - 0< NOT  // (a>=b) = ~(a<b) = ~(a-b)<0)
	UNTIL
	RDROP RDROP R> 'PROMPT ! R> 'TIB !  R> #TIB !  R> >IN !
	FALSE  ; 2 1 #PARMS

CODE: <forth_interpret>  ( ? -- Error? ) ( RStack: length string retadr )
     // Call FORTH from C(++) functions.
     // Use C(++)'s stack for data stack and return stack.
	EBP     PUSH    // RSTK: len str ret ebp
	EBP   { ESP 64 CELLS - }  LEA   // return stack is 64 cells in depth
	EAX   { ESP 2 CELLS + }   MOV   // string
      { EBP }   EAX     	  MOV
	EAX   { ESP 3 CELLS + }   MOV   // length
	EBX   { TASK }		  MOV   // Current task
	' TRANSLATE #     CALL  // result in EAX
	EBP     POP     // any data on stack will be dropped here
	RET  ;CODE 1 1 #PARMS INVISIBLE

: $FLOAD        ( str strlen -- )
	fload-nesting @ 0= IF
	  ['] RESET-FLOAD  FLOAD-RESETTER PUSH-RESETTER
	ENDIF
	point-error @ >R point-error ON // show error
	1 fload-nesting +!
	SWAP OVER READ/ONLY OPEN IF       ( strlen handle )
	   TIB >R 
	   fload-nesting @ 1 = IF
		[ BASE-ADDRESS |WORK-SPACE |BUFFERS ] LITERAL 'TIB !
	   ELSE
		TIB [ 4096 256 + ] LITERAL + 'TIB !     
	   ENDIF
	   BASE @ >R  DECIMAL
	   >IN @ >R  #TIB @ >R
	   #LINESREAD @ >R      #LINESREAD OFF
	   SWAP                 >R ( strlen )
	   ( handle )         >R
	   BEGIN
	      io-error OFF
	      TIB 4096 R@ HREAD IF      ( count )
		 DUP 4096 < IF
		    0 OVER TIB + !      // stop compiliation marker
		    TIB SWAP TRANSLATE TRUE
		 ELSE
		    TIB + R@ till-endofline TIB -
		    TIB SWAP TRANSLATE DUP
		 ENDIF
		 SWAP IF  \ [  ENDIF // Fail Translattion
	      ELSE                      ( #err )
		 io-error ! TRUE
	      ENDIF
	   UNTIL
	   R> ( handle ) R> ( strlen )
	   io-error @ IF
	      CR ."  Error reading file : " FNAMEBUF SWAP TYPE 
	   ELSE 
	      DROP 
	   ENDIF
	   HCLOSE DROP  R> #LINESREAD !
	   R> #TIB !  R> >IN !  R> BASE !  R> 'TIB !
	ELSE
	   DROP CR ."  Error opening file : " FNAMEBUF SWAP TYPE
	ENDIF
	-1 fload-nesting +!
	fload-nesting @ 0= IF  FLOAD-RESETTER POP-RESETTER  ENDIF
	R> point-error ! ; 2 0 #PARMS

: FLOAD ( -- )
	BL WORD COUNT $FLOAD ; 0 0 #PARMS

CR .( * Hardware reset ...)

: VER   ( -- n ) // Return the version number of this implementation.
	$1668 ; 0 1 #PARMS

: hi    ( -- ) // Display the sign-on message of Common Forth.
        CR
." Ú-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-¿" CR
." ³                          Common  Forth  System                            ³" CR
." ³       [  A  Forth & C++  Environment  for  Software  Development   ]      ³" CR
." ³                    Copyright (C) 1991-1999  Luke Lee                      ³" CR
." Ã-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-´" CR
." ³                       Experiment Version : "
                  BASE @ HEX VER <# # # # ASCII . HOLD # #> TYPE BASE !
                                                  ."                           ³" CR
." ³                Written by : Luke Lee  [ Taipei,Taiwan ]                   ³" CR
." ³                    eMail to : comforth@ms2.hinet.net                      ³" CR
." ³                       [ Last Update : 07/25/'99 ]                         ³" CR
." À-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ä-Ù" CR
        ; 0 0 #PARMS INVISIBLE

: 'BOOT ( -- a ) // The application startup vector.
	doVAR [ ' hi , ] ; 0 1 #PARMS

: RESET-TRANSLATOR      ( -- )
	NOOP    // could be PATCHed later.
	['] $INTERPRET 'INTERPRETER !
	['] $COMPILE   'COMPILER    !  ; 0 0 #PARMS INVISIBLE

2VARIABLE LastError  // this should be user-dependent for multi-user system

: QUIT  ( -- ) // clear return stack ONLY
	// Reset return stack pointer and start text interpreter.
	RP0 @ RP!
	BEGIN
	   CONSOLE PRESET       // 01/30/'96
	   RESETTING 'RESET-LIST OFF 
	   RESET-TRANSLATOR \ [
	   BEGIN
	       ['] QUERY CATCH DUP 0=           // for KEYTABLE.4TH
	       WHILE
		  DROP ['] EVAL CATCH ?DUP
	   UNTIL
		  1 ( err_from_eval 1 )       // type 1 error
	       ELSE
		  2
	       THEN ( err_from_query 2 )      // type 2 error
	   SWAP LastError 2!
	AGAIN ; 0 0 #PARMS

: COMMAND-LINE>TIB      ( -- )   // 05/27/'96 : take out from COMMAND-LINE
        NOOP    // for patching
        TIB [ BASE-ADDRESS |INIT-ENVIRON |ARGV ] LITERAL @
        [ BASE-ADDRESS |INIT-ENVIRON |ARGC ] LITERAL @  
        1- 0 MAX  FOR                     ( ^tib ^arg$ )
           CELL+    // skip argv[0] (full path name of this executable).
           AFT
              SWAP                            ( ^arg$ ^tib ) 
              OVER @                          ( ^arg$ ^tib arg$ ) 
              BEGIN                             
                 SWAP OVER C@ DUP 0<>         ( ^arg$ arg$ ^tib c t/f ) 
              WHILE
                 OVER C! 1+ SWAP 1+           ( ^arg$ ^tib+1 arg$+1 ) 
              REPEAT
              DROP BL OVER C! 1+ NIP          ( ^arg$ ^tib+n ) 
              SWAP CELL+                      ( ^tib+n ^arg$++ )
           THEN
        NEXT                              ( ^tib' ^arg$' )
        DROP TIB - #TIB !  0 >IN ! ; 0 0 #PARMS

: COMMAND-LINE  ( -- )        // 05/04/'96
        NOOP    // for patching
        0  [ BASE-ADDRESS |INIT-ENVIRON |ARGC ] LITERAL   !
                                // COMMAND-LINE is executed only once
        ['] EVAL CATCH ?DUP IF  1 LastError 2!  ENDIF
        ; 0 0 #PARMS

: Translator?      ( -- T/F )
        // Head existed, can interpreting or compiling.
        NOOP // Could be patched.
        HP @ [ HP0 ] LITERAL <>  ; 0 1 #PARMS

: COLD  ( -- )  // The hi-level cold start sequence.
	SINGLE RESET-REGISTERS RESET-STACK
	UP@  TASK  !
	0  StartDays  !
	BEGIN
	   (CONSOLE)    // Root console
	   PRESET       // initialize data stack and TIB
	   RESET-TRANSLATOR \ [
           ['] TRANSLATE >NAME $" TRANSLATE" DUP C@ 1+ COMP 0<> 
           IF  // Turnkey system working, without heads
               [ HP0 ] LITERAL  HP  !
           ENDIF
           COMMAND-LINE>TIB
	   'BOOT @ CATCH ?DUP IF   2 LastError 2!   ENDIF
           Translator? IF // No need to load source since no translator.
	      " CF.INI      " 2DUP READ/ONLY OPEN IF  // 10/21/'95
		  HCLOSE DROP $FLOAD
              ELSE
                  3DROP 
	      ENDIF
              COMMAND-LINE  // Execute command line in TIB
	      QUIT          // Start interpreter
           ELSE  // No translator, no need to stay.
              BYE       // BYEFUNC^ executes here.
           ENDIF
	AGAIN // just in case
	; 0 0 #PARMS

' COLD  ^COLD @  !    // Set COLD start vector

CR .( * Initialize all user variables ...)

CP @ TUP0 @ CP ! TUP0 ! // exchange TUP0 and CP

0 ,                             // SUCCTASK
0 ,                             // SP-SAVED
0 ,                             // RP-SAVED
0 ,                             // PREVTASK
TSP0 @ ,                        // SP0
TRP0 @ ,                        // RP0
' ?BIOSKEY ,                    // '?KEY
' (EMIT) ,                      // 'EMIT
' accept ,                      // 'EXPECT
' kTAP ,                        // 'TAP
' (EMIT) ,                      // 'ECHO
' .OK ,                         // 'PROMPT
$0A ,                           // BASE
0 ,                             // tmp
0 ,                             // SPAN
0 ,                             // >IN
0 ,                             // #TIB
T-TIB @ ,                       // 'TIB
0 ,                             // CSP
' $INTERPRET ,                  // 'EVAL
' NUMBER? ,                     // 'NUMBER
0 ,                             // HLD
0 ,                             // HANDLER
' FORTH >BODY @ ,               // CONTEXT pointer
' FORTH >BODY @ ,               // ROOT vocabulary
HERE |VOCS| CELL- 0 FILL        // vocabulary stack
|VOCS| CELL- CP +!
' FORTH >BODY @ ,               // CURRENT pointer
' FORTH >BODY ,                 // vocabulary link pointer VOC-LINK
TUP0 @ ,                        // CP ( currently host's CP is stored in TUP0 )
HP @ ,                          // HP
LAST @ ,                        // LAST
0 ,                             // STATE
-1 ,                            // DPL
' (CONSOLE) ,                   // 'CONSOLE
0 ,                             // LastCalled
' $INTERPRET ,                  // 'INTERPRETER
' $COMPILE ,                    // 'COMPILER
' (TYPE) ,                      // 'TYPE
' BIOSAT ,                      // 'AT
' BIOSAT? ,                     // 'AT?
0 ,                             // 'RESET-LIST
0 ,                             // 'UP>TASK

TUP0 @ CP ! // restore host's CP

WARNING ON

' FORTH >BODY DUP @ $3FF CELL* + ! // cut new system


