// Common Forth Interrupt handling for GO32 
//
//						Written by  : Luke Lee
//						Version     : 1.0
//						Last update : 10/11/'95
//

NEEDS INVOKEC.4TH
NEEDS DOSCMD.4TH

NEEDS CPU80486.4TH

256 CONSTANT #Vectors

CODE: DISABLE
	CLI
	RET	
	;CODE MACRO 0 0 #PARMS

CODE: ENABLE
	STI	
	RET	
	;CODE MACRO 0 0 #PARMS

//
// Exception handlers for GO32 version :
//

VOCABULARY EXCEPTIONS
ALSO EXCEPTIONS ALSO DEFINITIONS

NEEDS LoadInfo.4TH		// Loader info from GO32

STRUCT: TRACEBACK:
	WORD: |ESP+00
	WORD: |ESP+04
	WORD: |ESP+08
	WORD: |ESP+0C
	WORD: |ESP+10
	WORD: |ESP+14
	WORD: |ESP+18
	WORD: |ESP+1C
	WORD: |ESP+20
	WORD: |EBX:UP
;STRUCT: TRACEBACKS

CODE: SetTraceBacks
	MOV	EAX CS: { BASE-ADDRESS |INIT-ENVIRON |OriginalRegisters |DS }
	MOV	DS	AX
	MOV    { TRACEBACKS |EBX:UP }	EBX	// save user pointer	
	MOV	EAX	{ ESP CELL+ }
	MOV    { TRACEBACKS |ESP+00 }	EAX	     // skip return address
	MOV	EAX	{ ESP 2 CELLS + }	     
	MOV    { TRACEBACKS |ESP+04 }	EAX	     
	MOV	EAX	{ ESP 3 CELLS + }    
	MOV    { TRACEBACKS |ESP+08 }	EAX	     
	MOV	EAX	{ ESP 4 CELLS + }    
	MOV    { TRACEBACKS |ESP+0C }	EAX	     
	MOV	EAX	{ ESP 5 CELLS + }    
	MOV    { TRACEBACKS |ESP+10 }	EAX	     
	MOV	EAX	{ ESP 6 CELLS + }    
	MOV    { TRACEBACKS |ESP+14 }	EAX
	MOV	EAX	{ ESP 7 CELLS + }    
	MOV    { TRACEBACKS |ESP+18 }	EAX
	MOV	EAX	{ ESP 8 CELLS + }    
	MOV    { TRACEBACKS |ESP+1C }	EAX
	MOV	EAX	{ ESP 9 CELLS + }    
	MOV    { TRACEBACKS |ESP+20 }	EAX
	RET
	;CODE MACRO

: .TRACEBACKS	(( -- ))
	CR TAB ." Tracing back stack : ( hex )" CR
	BASE @ HEX
	0  8 FOR
	    TAB 5 SPACES ." ESP + " DUP 2 U.0R ."  : "
	    DUP TRACEBACKS + @ 8 U.0R CR
	    CELL+
	NEXT DROP
	BASE ! ; 0 0 #PARMS

: .SingleTasking	(( -- ))
	TAB ." Single tasking now." CR ; 0 0 #PARMS INVISIBLE

: StopTask	(( UP -- ))
	DUP RootTask <> IF
	   DUP SLEEP TASK-STOPPED OVER TASK-STATE LOCAL !
	ENDIF DROP ; 1 0 #PARMS INVISIBLE

: valid-addr?	(( a -- T/F ))
	BASE-ADDRESS  BASE-ADDRESS CF-MemorySpace +  [...] 
	; 1 1 #PARMS INVISIBLE

: .TaskID	(( UP -- ))
	>R
	R@ UP>TASK
	DUP valid-addr? ANDTHEN  DUP HEAD> >BODY @ R@ =  THEN-AND
	IF
	    .ID
	ELSE
	    DROP ." {noname} ( task space corrupted )"
	ENDIF RDROP ; 1 0 #PARMS INVISIBLE

: .TaskStatus	(( up -- ))
	DUP valid-task? IF
	   DUP StopTask	// RootTask won't be stopped anyway
	   ."  , task name is " DUP .TaskID
	   DUP RootTask <> IF  CR ."   ; this task is forced to stop ."  ENDIF
	ELSE
	   ."  , not a valid task address, can't stop it. " CR
	   ."   * Warning ! Resume MULTI might crash the system now !" CR
	   ."               You should stop the crashed task before resume MULTI ."
	ENDIF DROP ; 1 0 #PARMS INVISIBLE

: .ExceptionAddress (( errEIP errCS -- ))
	$FFFF AND
	BASE @ >R HEX
	BEEP CR ."   Exception address "
	DUP  0 INLINE[  CS PUSH   EAX POP   ]INLINE $FFFF AND  =  ANDTHEN
	OVER BASE-ADDRESS   DUP CF-MemorySpace +   [...] THEN-AND
	IF
	   DROP ." inside FORTH system space, EIP=" 8 U.0R CR
	   ."   ; UP = " TRACEBACKS |EBX:UP @ DUP 8 U.0R .TaskStatus
	ELSE
	   ." outside FORTH system space : CS:EIP=" 
	   4 U.0R ASCII : EMIT 8 U.0R
	ENDIF
	.TRACEBACKS
	R> BASE !  ; 1 0 #PARMS INVISIBLE

: .ErrorCode	(( -- ))
	BASE @ HEX
	CR ."    Error code on stack = " TRACEBACKS |ESP+00 @ 8 U.0R
	BASE ! ;

: /QUIT  ." QUIT" CR QUIT ; 0 0 #PARMS

// Exception 0 
: DivideFault  (( -- ))	// divided by zero
	SetTraceBacks
	RESET-REGISTERS RESET-STACK CONSOLE PRESET 
	SINGLE
	CR ." * Fault 0 : Divided by zero or destination operand not fit."
	TRACEBACKS |ESP+00 @  TRACEBACKS |ESP+04 @  .ExceptionAddress
	.SingleTasking TAB ." BASE is DECIMAL now." CR
	DECIMAL
	/QUIT ; 0 0 #PARMS

// Exception 1
: DebuggerTrap	(( -- ))
	SetTraceBacks
	RESET-REGISTERS RESET-STACK CONSOLE PRESET
	SINGLE
	CR ." * Fault 1 : Unhandled debugging trap ."
	TRACEBACKS |ESP+00 @  TRACEBACKS |ESP+04 @  .ExceptionAddress
	.SingleTasking
	/QUIT ; 0 0 #PARMS

// NMI
: NonMaskableInterrupt	(( -- )) // NMI
	SetTraceBacks
	RESET-REGISTERS RESET-STACK CONSOLE PRESET
	SINGLE
	CR ." * NMI : Non maskable interrupt, should not occur." CR BEEP
	.SingleTasking
	/QUIT ; 0 0 #PARMS

// Exception 3
: BreakpointTrap	(( -- ))
	SetTraceBacks
	RESET-REGISTERS RESET-STACK CONSOLE PRESET
	SINGLE
	CR ." * Trap 3 : Unhandled breakpoint trap ."
	TRACEBACKS |ESP+00 @  TRACEBACKS |ESP+04 @  .ExceptionAddress
	.SingleTasking
	/QUIT ; 0 0 #PARMS

// Exception 4
: OverflowTrap	(( -- ))
	SetTraceBacks
	RESET-REGISTERS RESET-STACK CONSOLE PRESET
	CR ." * Trap 4 : Overflow trap ."
	TRACEBACKS |ESP+00 @  TRACEBACKS |ESP+04 @  .ExceptionAddress
	/QUIT ; 0 0 #PARMS

// Exception 5
: BoundsCheck	(( -- ))
	SetTraceBacks
	RESET-REGISTERS RESET-STACK CONSOLE PRESET
	CR ." * Fault 5 : Boundary check fault ."
	TRACEBACKS |ESP+00 @  TRACEBACKS |ESP+04 @  .ExceptionAddress
	/QUIT ; 0 0 #PARMS

// Exception 6
: InvalidOpcode	(( -- ))
	SetTraceBacks
	RESET-REGISTERS RESET-STACK CONSOLE PRESET
	SINGLE 
	CR ." * Fault 6 : Invalid opcode; illegal instruction ."
	TRACEBACKS |ESP+00 @  TRACEBACKS |ESP+04 @  .ExceptionAddress
	.SingleTasking
	/QUIT ; 0 0 #PARMS

// Exception 7 : GO32 system defined, do not patch.
: DeviceNotAvailable	(( -- ))
	SetTraceBacks
	RESET-REGISTERS RESET-STACK CONSOLE PRESET
	SINGLE
	CR ." * Fault 7 : Coprocessor not available ."
	TRACEBACKS |ESP+00 @  TRACEBACKS |ESP+04 @  .ExceptionAddress
	.SingleTasking
	/QUIT ; 0 0 #PARMS

// Exception 8 ( with error code 0 )
: DoubleFault	(( -- ))
	SetTraceBacks
	RESET-REGISTERS RESET-STACK CONSOLE PRESET
	SINGLE CR
	TRACEBACKS |ESP+00 @  0<> IF
	   ." * Exception 8 occuried, but not because of double fault ."
	   TRACEBACKS |ESP+00 @   TRACEBACKS |ESP+04 @	
	ELSE
	   ." * Fault 8 : Double fault ."
	   TRACEBACKS |ESP+04 @   TRACEBACKS |ESP+08 @
	ENDIF
	.ExceptionAddress
	.SingleTasking
	/QUIT ; 0 0 #PARMS

// Exception 9
: CoprocessorSegmentOverrun	(( -- ))
	SetTraceBacks
	RESET-REGISTERS RESET-STACK CONSOLE PRESET
	SINGLE CR
	." * Abort 9 : Coprocessor segment overrun ."
	TRACEBACKS |ESP+00 @  TRACEBACKS |ESP+04 @  .ExceptionAddress
	.SingleTasking
	/QUIT ; 0 0 #PARMS

// Exception 10
: InvalidTSS	(( -- ))
	SetTraceBacks
	RESET-REGISTERS RESET-STACK CONSOLE PRESET
	SINGLE CR
	." * Fault 10 : Invalid task state segment ."  .ErrorCode
	TRACEBACKS |ESP+04 @  TRACEBACKS |ESP+08 @  .ExceptionAddress
	.SingleTasking
	/QUIT ; 0 0 #PARMS

// Exception 11
: NotPresent	(( -- ))
	SetTraceBacks
	RESET-REGISTERS RESET-STACK CONSOLE PRESET
	SINGLE CR
	." * Fault 11 : Not present fault ."  .ErrorCode
	TRACEBACKS |ESP+04 @   TRACEBACKS |ESP+08 @  .ExceptionAddress
	.SingleTasking
	/QUIT ; 0 0 #PARMS

// Exception 12 not implemented, since it requires a task swith for 
// new stack, otherwise it might cause double fault which again use
// the same stack and became third fault. The system will crash on
// such situations. 

// Exception 13
: GeneralProtectionFault	(( -- ))
	SetTraceBacks
	RESET-REGISTERS RESET-STACK CONSOLE PRESET
	SINGLE CR
	." * Fault 13 : General protection fault ." .ErrorCode
	TRACEBACKS |ESP+04 @  TRACEBACKS |ESP+08 @  .ExceptionAddress
	.SingleTasking
	/QUIT ; 0 0 #PARMS

FORTH DEFINITIONS

VARIABLE (387DetectBuf)		INVISIBLE

// Detect 80387
CODE: Detect387		(( -- T/F ))
	] DUP [
	PUSH	EDX
	FNINIT
	LEA	EDX	{ (387DetectBuf) }
	MOV	{ (387DetectBuf) }	$5A5A #
	FNSTSW	WORD^ { EDX }
	CMP	{ EDX }	 0 #
    =	IF
		FNSTCW	WORD^ { EDX }
		MOV	EAX	{ EDX }
		AND	EAX	$103F #
		CMP	AX	$3F #
	     =	IF
			FLD1
			FLDZ
			FDIV
			FLD	ST
			FCHS
			FCOMPP
			FSTSW	WORD^ { EDX }
			MOV	EAX	{ EDX }
			SAHF
		   <>	IF	// initialize 387
			FNINIT
			FNSTCW	WORD^ { EDX }
			WAIT
			AND	WORD^ { EDX }	$FFFA #
			FLDCW	WORD^ { EDX }
			MOV	EAX	TRUE #
			POP	EDX
			RET
			ENDIF	
		ENDIF
	ENDIF
	XOR	EAX	EAX	// return FALSE
	POP	EDX
	RET
	;CODE 0 1 #PARMS

// ///////////////////// //
// Old handlers invokers //
// ///////////////////// //

EXCEPTIONS DEFINITIONS

0 VALUE FarPtrToOldTSS		INVISIBLE
0 VALUE FarPtrToOldIntGate	INVISIBLE
0 VALUE OldPageFaultPtr		INVISIBLE

: $CLTS	(( -- ))
	Detect387  IF
	   $060F H,	// CLTS	machine code
	ENDIF ; 0 0 #PARMS IMMEDIATE INVISIBLE

CODE: INTviaTSS
    HERE
	CALLF	0 #  0 #
    HERE SWAP - CELL- 2 -  to  FarPtrToOldTSS
	RET
	;CODE MACRO INVISIBLE

CODE: INTviaIntGate
    HERE
	PUSHFD			// for IRETD
	CALLF	0 # 0 #
    HERE SWAP - CELL- 2 -  to  FarPtrToOldIntGate
	RET
	;CODE MACRO INVISIBLE

// ////////////////////// //
// New Interrupt handlers //
// ////////////////////// //

0 VALUE ExceptionPtr		INVISIBLE
0 VALUE HardwareIntPtr		INVISIBLE
0 VALUE SoftwareIntPtr		INVISIBLE

CODE: ExceptionHandler
    HERE
	CALL	{ 0 }	// call Extended Interrupt Service Routine
    HERE SWAP - CELL-  to  ExceptionPtr
	STI
//	$CLTS
	IRETD
	;CODE

CODE: HardwareInterrupt
    HERE
	PUSHAD	// in case that the interrupt occuried in C functions
	CALL	{ 0 }	// call Extended Interrupt Service Routine
    HERE SWAP - CELL-  to  HardwareIntPtr
	POPAD
	PUSH	EAX
	MOV	AL    $20 #
	OUT	$20 #  AL	// EOI
	POP	EAX
	STI
//	$CLTS
	IRETD
	;CODE
		
CODE: SoftwareInterrupt
    HERE
	CALL	{ 0 }	// call Extended Interrupt Service Routine
    HERE SWAP - CELL-  to  SoftwareIntPtr
	PUSH	EAX
	STI
	PUSHFD
	POP	EAX
	MOV   {	ESP 3 CELLS + }	 EAX	// modify flag in stack
	POP	EAX
//	$CLTS
	IRETD
	;CODE

CODE: $10000*	(( n -- n<<16 ))
	SHL	EAX	16 #
	RET
	;CODE MACRO 1 1 #PARMS

CODE: $10000/
	SHR	EAX	16 #
	RET
	;CODE MACRO 1 1 #PARMS

// //////////////////////////////// //
//   Tables  and  Data structures   //
// //////////////////////////////// //

EXCEPTIONS DEFINITIONS

//
// Table 1 : Original IDT 
//

STRUCT: IDTE:	// IDT Entry
   HWORD: |offset0..15
   HWORD: |selector
   BYTE:  |zeros
   BYTE:  |type		// P:1 | DPL:2 | S:1 | TYPE:4
   HWORD: |offset16..31
;STRUCT: IDTE

CREATE OriginalIDT	INVISIBLE	// hope user don't interfere them
	#Vectors SIZEOF IDTE *  ALLOT	// 256 IDTE Interrupt Descriptor Table Entry
CREATE CurrentIDT	INVISIBLE
	#Vectors SIZEOF IDTE *  ALLOT

//
// Table 2 : Old ISR invoker
//

SIZEOF INTviaTSS
SIZEOF INTviaIntGate   MAX   CONSTANT |OldISR|		INVISIBLE

CREATE OldISRs
	#Vectors   |OldISR|  *   ALLOT
: []OldISRs	(( n -- OldISRn ))
	|OldISR| *  OldISRs  +  ; 1 1 #PARMS

// 
// Table3 : New interrupt service routines
//

// $70..$77 : master PIC; $78..$7F : slave PIC
$70  CONSTANT	CF_PIC_BASE	// ideal position

SIZEOF ExceptionHandler
SIZEOF HardwareInterrupt   MAX
SIZEOF SoftwareInterrupt   MAX   CONSTANT  |NewISR|	INVISIBLE

CREATE NewISRs
	#Vectors   |NewISR|  *    ALLOT
: []NewISRs	(( n -- ISRn ))
	|NewISR| *  NewISRs  +  ; 1 1 #PARMS

//
// Table 4 : Extended Interrupt Service Routine Table
//

CREATE EISRs // Extended ISR written in FORTH
	#Vectors CELL* ALLOT
: []EISRs	(( n -- EISR )
	CELL* EISRs + ; 1 1 #PARMS

: <NOWORK> ; INVISIBLE

' <NOWORK> 14 []EISRs !	// Extended Page Fault handler is NOOP, but I don't
			// use NOOP here in case it is PATCHed.

// 
// Table 5 : Vector remapping table
//

CREATE VectorMapping       256 ALLOT	VectorMapping 256 ERASE

: []VectorMapping	(( i -- mapping[] ))
	VectorMapping +  ; 1 1 #PARMS

// //////////////////////////////////////////////// //
//     486  Interrupt  Service  Routine  Setups     //
// //////////////////////////////////////////////// //

0 VALUE IDTsaved?	// a flag for RestoreIDT, prevent restore without
	INVISIBLE 	// save first.
0 VALUE VectorSetupped	// Flag for preventing multiple vector setup
	INVISIBLE

STRUCT: DTR:		// discriptor table register
     HWORD: |LIMIT
     WORD:  |LINEAR	
;STRUCT: IDTR		// IDT register

: IDTE|offset@	(( -- offset ))
	IDTE |offset16..31 H@ $10000*
	IDTE |offset0..15 H@  OR  ; 0 1 #PARMS INVISIBLE

0 VALUE IDT^	INVISIBLE	// setup by SaveIDT

: []IDT	(( n -- IDTE ))	// work only if IDT^ is setted
	8 * IDT^ +  ; 1 1 #PARMS

// Assume that it is impossible that the IDT would switch to another
// address during SaveIDT or RestoreIDT, and vectors should not change
// during the following operations .

: SaveIDT	(( -- ))
	IDTsaved? NOT IF	// in case overwrite original values
	    INLINE[  { IDTR	}  SIDT  ]INLINE
	    $E0000000 IDTR |LINEAR @ +  TO  IDT^
	    DISABLE
	    IDT^  OriginalIDT   [ #Vectors 8 * ] LITERAL   CMOVE    
	    ENABLE
	    TRUE to IDTsaved? 
	ENDIF  ; 0 0 #PARMS	INVISIBLE

: RestoreIDT	(( -- ))
	IDTsaved? IF
	    INLINE[  { IDTR }  SIDT  ]INLINE
	    $E0000000 IDTR |LINEAR @ +  TO  IDT^ // in case IDT^ corrupted
	    DISABLE
	    OriginalIDT  IDT^   [ #Vectors 8 * ] LITERAL   CMOVE	
	    ENABLE
	ENDIF	; 0 0 #PARMS	INVISIBLE

0 VALUE ISR^ // local variable for any use, but not for parameter passing
	INVISIBLE

: DBG_FILL	(( p size -- )) // fill with int 03 ( for easy debugging )
	$CC FILL  ; 2 0 #PARMS	INVISIBLE

: SetOldISR	(( index -- ISR^ ))
	>R
	R@ []OldISRs  to  ISR^
	ISR^ |OldISR| DBG_FILL
	R@ []IDT IDTE 8 CMOVE	// copy current IDT to IDTE
	IDTE |type C@ $0F AND
	DUP $05 = IF // Task Gate
	    ['] INTviaTSS  ISR^  |OldISR|   CMOVE
	    IDTE|offset@  ISR^ FarPtrToOldTSS +   !  // set far calling offset
	    IDTE |selector H@   ISR^ FarPtrToOldTSS + CELL+  H! // set selector
	ELSE DUP $0E $0F [...] IF  // Trap Gate or Interrupt Gate
	    ['] INTviaIntGate  ISR^  |OldISR|   CMOVE
	    IDTE|offset@  ISR^ FarPtrToOldIntGate +  !
	    IDTE |selector H@   ISR^ FarPtrToOldIntGate + CELL+  H!
	ELSE
	    CR ." Invalid IDT entry encounterred." ABORT
	ENDIF ENDIF
	DROP RDROP ISR^ ; 1 1 #PARMS INVISIBLE

: SetNewSoftwareISR	(( index -- ))
	>R  R@ []NewISRs   to  ISR^
	ISR^ |NewISR| DBG_FILL
	['] SoftwareInterrupt  ISR^  SIZEOF SoftwareInterrupt LITERAL  CMOVE
	R@ []EISRs   ISR^ SoftwareIntPtr +   !
	RDROP ; 1 0 #PARMS INVISIBLE

: SetNewHardwareISR	(( index -- ))
	>R  R@ []NewISRs  to  ISR^
	ISR^ |NewISR| DBG_FILL
	['] HardwareInterrupt  ISR^  SIZEOF HardwareInterrupt LITERAL  CMOVE
	R@ []EISRs   ISR^ HardwareIntPtr +   !
	RDROP  ; 1 0 #PARMS INVISIBLE

: SetNewExceptionISR	(( index -- ))
	>R  R@ []NewISRs   to  ISR^
	ISR^ |NewISR| DBG_FILL
	['] ExceptionHandler   ISR^  SIZEOF ExceptionHandler LITERAL   CMOVE
	R@ []EISRs   ISR^ ExceptionPtr +   !
	RDROP ; 1 0 #PARMS INVISIBLE

: 1.SetupSoftwareInterrupts	(( -- ))
     // First, assume interrupts are all software interrupts initial.
     // Initialize VectorMapping table also.	
	#Vectors 0 DO
	   #I DUP []VectorMapping C!  // initial : direct mapping, no crossing
	   #I  SetOldISR  #I []EISRs  !
	   #I  SetNewSoftwareISR
	LOOP  ;

: SwapMapping	(( i j -- ))
	[]VectorMapping SWAP []VectorMapping	// M[j] M[i]
	2DUP C@ SWAP C@		// M[j] M[i] MI MJ
	ROT C! SWAP C!		// MJ to M[i] ; MI to M[j]
	; 2 0 #PARMS INVISIBLE

0 VALUE PICBASE	// local value for SetPICVectors
	INVISIBLE
: SetPICVectors  (( oldPICbase newPICbase -- ))
	to PICBASE
	$07 FOR
	    >R R@ SetOldISR   PICBASE []EISRs   !
	    PICBASE  R@  SwapMapping
	    PICBASE SetNewHardwareISR
	    R> 1+  PICBASE 1+  to  PICBASE
	NEXT DROP ; 2 0 #PARMS INVISIBLE

: 2.SetupHardwareInterrupts     (( -- ))
        MasterPICbase	// from LoadInfo.4TH
	CF_PIC_BASE	SetPICVectors
	SlavePICbase	// from LoadInfo.4TH
	CF_PIC_BASE 8 + SetPICVectors
	; 0 0 #PARMS

: 3.SetupExceptions	(( -- ))
     // Assume that MasterPICbase is redirected by loader.	
	$10 0 DO  // $10 and $11 are used by PC BIOS, what a shame !
	   #I DUP []VectorMapping C@ SwapMapping  // should be #I swap with #I
	   #I  SetOldISR   #I []EISRs   !
	   #I  SetNewExceptionISR
	LOOP  ; 0 0 #PARMS

: offset>IDTE!	(( off -- ))
	DUP $FFFF AND IDTE |offset0..15 H!
	$10000/ IDTE |offset16..31 H! ; 1 0 #PARMS INVISIBLE

// Page fault : CPU will push an error code on stack. But GO32 handle
// this fault with task switching, the error code is pushed into task's
// stack .

: 4.SetupIDTVectors	(( -- ))
     // Redirect all NewISRs into IDT
	IDTE 8 0 FILL
	$00  INLINE[   AX   CS   MOV   ]INLINE
	IDTE |selector H!   // selector is  CS
	$8E IDTE |type C! // 8E=10001110 : P=1|DPL=00|TYPE=1110 interrupt gate
	DISABLE	
	#Vectors 0 DO
	   #I 14 <> ANDTHEN  // Normal page fault can be handled, but for
		      	     // graphics page faults, it will crash !
	   #I 7 <> THEN-AND
	   IF	// skip page fault exception
	      #I []VectorMapping C@ []NewISRs  offset>IDTE!
	      IDTE  #I []IDT  8  CMOVE
	   ENDIF
	LOOP
	ENABLE ; 0 0 #PARMS INVISIBLE

: 5.SetupExtendedExceptionHandler
	DISABLE
	['] DivideFault	   	 	$00 []EISRs !
	['] DebuggerTrap	 	$01 []EISRs !
	['] NonMaskableInterrupt 	$02 []EISRs !
	['] BreakpointTrap	 	$03 []EISRs !
	['] OverflowTrap	 	$04 []EISRs !
	['] BoundsCheck	   	 	$05 []EISRs !
	['] InvalidOpcode	 	$06 []EISRs !
	// Exception 7 remains
	['] DoubleFault		 	$08 []EISRs !
	['] CoprocessorSegmentOverrun	$09 []EISRs !
	['] InvalidTSS			$0A []EISRs !
	['] NotPresent			$0B []EISRs !
	['] GeneralProtectionFault	$0D []EISRs !
	// Exception 14 remains
	ENABLE ; INVISIBLE

: .CR0	(( -- ))	// display CR0 register in binary format
	0 INLINE[ EAX CR0 MOV ]INLINE
	BASE @ >R BINARY CR U. R> BASE ! ;

0 VALUE NewIDTSaved?

: SaveNewIDT	(( -- ))
	INLINE[  { IDTR	}  SIDT  ]INLINE
	$E0000000 IDTR |LINEAR @ +  TO  IDT^
	DISABLE
	IDT^ CurrentIDT [ #Vectors SIZEOF IDTE * ] LITERAL CMOVE
	TRUE to NewIDTSaved? 
	ENABLE  ; 0 0 #PARMS

: RestoreNewIDT	(( -- ))
	NewIDTSaved? IF
	    INLINE[  { IDTR	}  SIDT  ]INLINE
	    $E0000000 IDTR |LINEAR @ +  TO  IDT^
	    CurrentIDT	IDT^ [ #Vectors SIZEOF IDTE * ] LITERAL CMOVE
	    FALSE  to  NewIDTSaved?	// IDT might change later.
	ENDIF ; 0 0 #PARMS

: SHOWIDT
	INLINE[	  { IDTR }	SIDT	]INLINE
	CR
	IDTR |LIMIT H@ ." IDT Limit = " .H
	." | Linear addr =  " IDTR |LINEAR @ .H  CR
	$E0000000 IDTR |LINEAR @ +
	256 0 DO
	   DUP IDTE 8 CMOVE 8 +
	   CR ." ENTRY " #I . ." : "
	   4 SPACES ." selector = " IDTE |selector H@ .H
	   4 SPACES ." offset = "   IDTE|offset@ .H
	   4 SPACES ." type = "     IDTE |type  C@ .H
	   4 SPACES ." zeros = "    IDTE |zeros C@ .H
	   NUF? ?LEAVE
	LOOP DROP ;

: InitPagingFile    (( -- ))
	HERE HP @ OVER - $CC FILL
	system( Z$"   " ) DROP ; 0 0 #PARMS

// Swap to original IDT, then swap back

0 VALUE isMulti?

: RestoreVectBeforeDOS	(( -- ))
	MULTI? to isMulti? SINGLE
	SaveNewIDT RestoreIDT 
	DEFERS ShellToDosHook ; 0 0 #PARMS

: BackFromDOSSetVect (( -- ))
	DEFERS BackFromDosHook
	RestoreNewIDT
	isMulti? IF MULTI ENDIF ; 0 0 #PARMS

' RestoreVectBeforeDOS IS ShellToDosHook
' BackFromDOSSetVect   IS BackFromDosHook

FORTH DEFINITIONS

: SetupVectors	(( -- ))
	VectorSetupped	NOT IF // prevent duplicate setup
	    SaveIDT
            1.SetupSoftwareInterrupts
            2.SetupHardwareInterrupts
            3.SetupExceptions
	    4.SetupIDTVectors
	    5.SetupExtendedExceptionHandler
	    TRUE  to  VectorSetupped 
	ENDIF ; 0 0 #PARMS

WARNING @ 
WARNING OFF

: BYE 	RestoreIDT BYE  ;

: BYE'  RestoreIDT BYE' ;

// CR .( Initializing ... please wait ... )
// InitPagingFile	// initialize paging file
// SetupVectors

WARNING !
ONLY EXCEPTIONS ALSO FORTH ALSO DEFINITIONS

CREATE IDT2 256 8 * ALLOT

: SaveIDT2	(( -- ))
	    INLINE[  { IDTR	}  SIDT  ]INLINE
	    $E0000000 IDTR |LINEAR @ +  TO  IDT^
	    DISABLE
	    IDT^  IDT2  [ #Vectors 8 * ] LITERAL   CMOVE    
	    ENABLE	; 

