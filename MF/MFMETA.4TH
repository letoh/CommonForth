// Meta compiler for MetaForth from Common Forth
// Simulate MetaForth's Meta compiling environment .

NEEDS CPU80486.4TH

HERE $178000 > #IF
  BEEP CR CR
  .( ----------------------------------------------------------------------) CR
  .( * MFMETA.4TH : Cannot perform META, you must FORGET something to free ) CR
  .(   some memory space. For performing META , HERE must not exceed $180000 .)
  .( ----------------------------------------------------------------------) CR
  CR CR ABORT

#ENDIF

VOCABULARY MFMETA

MFMETA ALSO DEFINITIONS

64   CONSTANT	SAFE	// Safety margin ( 16 cells )

// MetaForth's head structure

STRUCT: MFHEAD	// 40 bytes
	40 4 - 4 - 4 - FIELD: |Name
	4	       FIELD: |Link
	4	       FIELD: |Size
	4	       FIELD: |Attr
;STRUCT

// Create alias for redefined names :

' '	    ALIAS  H'
' [']	    ALIAS  H[']
' IMMEDIATE ALIAS  H-IMMEDIATE
' : 	    ALIAS  H:
' ;	    ALIAS  H;
' 'EVAL	    ALIAS  H'EVAL

// MetaForth's system variables :
//    BASEADDR  ^COLD  LAST  CURR  DP  SP0  RP0  TIB0  HANDLER
//    'EVAL  FILEBUF0 	>IN  SPAN  #TIB

$180000 64 +    : BASEADDR [ DUP ] LITERAL ;
CELL+  		: ^COLD	   [ DUP ] LITERAL ;
CELL+     	: LAST	   [ DUP ] LITERAL ;
CELL+		: CURR	   [ DUP ] LITERAL ;
CELL+		: DP	   [ DUP ] LITERAL ;
CELL+		: SP0	   [ DUP ] LITERAL ;
CELL+		: RP0	   [ DUP ] LITERAL ;
CELL+		: TIB0	   [ DUP ] LITERAL ;
CELL+		: HANDLER  [ DUP ] LITERAL ;
CELL+		: 'EVAL	   [ DUP ] LITERAL ;
CELL+		: FILEBUF0 [ DUP ] LITERAL ;
CELL+		: >IN	   [ DUP ] LITERAL ;
CELL+		: SPAN	   [ DUP ] LITERAL ;
CELL+		: #TIB	   [ DUP ] LITERAL ; DROP

$180000    			BASEADDR 	!
2 M        			RP0      	!
RP0 @ 64 K -			TIB0		!
TIB0 @ SAFE -			SP0	 	!
SP0 @ 64 K - SAFE - 64 K -	FILEBUF0	!

// Codes for MetaForth .
			 
CODE:	MFINIT	// Initial codes for MetaForth
	CLI
	MOV	AX	DS
	MOV	SS	AX
	MOV	EBP	2 M 64 K - #	// DATA STACK
	MOV	ESP	2 M #		// RETURN STACK
	STI
	JMP	{ ^COLD }		// COLD vector
	RET
	;CODE

CODE:   (KEY)	(( -- c ))
	] DUP [
	PUSHAD	// on return stack
	XCHG	EBP	ESP
	MOV	AH	$01 #
	INT	$21 #
	AND	EAX	$FF #
	PUSH	EAX	// on data stack
	XCHG	EBP	ESP
	POPAD   // from return stack
	MOV	EAX	{ EBP CELL- }
	RET
	;CODE

CODE:   (EMIT)	(( c -- ))
	PUSHAD
	XOR	EDX	EDX
	MOV	DL	AL
	MOV	AH	$02 #
	INT	$21 #
	POPAD
	] DROP [
	RET
	;CODE

CODE:   BYE	(( -- ))
	MOV	AH	$4C #
	INT	$21 #
	RET
	;CODE

CODE:   (OPEN)	(( fname -- T/F ))
	// Open file with READ/WRITE mode
	PUSHAD
	MOV	EDX	EAX
	MOV	EAX	$3D00 #		// Open file, READ/ONLY mode
	INT	$21 #
	U<	IF	// carry bit set
		XOR	EAX	EAX
	ELSE
		PUSH    EAX
		MOV	EDX	{ FILEBUF0 }
		MOV	ECX	64 K #
		MOV	EBX	{ ESP }		// handle
		MOV	EAX	$3F00 #		// Read file
		INT	$21 #
		POP	EBX			// handle
		PUSHFD		// flag of read operation
		MOV	EAX	$3E00 #		// Close file
		INT	$21 #
		POPFD		// flag from read operation
		U<	IF
			XOR	EAX	EAX
		ELSE
			MOV	EAX	TRUE #
		ENDIF
	ENDIF
	MOV	{ EBP CELL- }	EAX
	POPAD
	MOV	EAX	{ EBP CELL- }
	RET
	;CODE

CODE:  (FSAVE)  (( size fname -- T/F ))
	PUSHAD
	MOV	EDX	EAX
	XOR	ECX	ECX	// normal file type
	MOV	EAX	$3C00 #
	INT	$21 #
	U<	IF
		MOV	{ EBP }		0 #
	ELSE	// AX = file handle
		PUSH	EAX
		MOV	EBX	EAX
		MOV	ECX	{ EBP }		// size
		MOV	EDX	{ BASEADDR } 	// base address
		MOV	EAX	$4000 #
		INT	$21 #
		POP	EBX
		PUSHFD		// flag of read operation
		MOV	EAX	$3E00 #		// Close file
		INT	$21 #
		POPFD		// flag from read operation
		U<	IF
			MOV	{ EBP }   0 #
		ELSE
			MOV	{ EBP }   TRUE #
		ENDIF
	ENDIF
	POPAD
	MOV	EAX	{ EBP }
	LEA	EBP 	{ EBP CELL+ }
	RET
	;CODE 2 1 #PARMS

// Rename or extend VCPU instruction set.
: call    [ $E8 C, ] ; 
: exit    [ $C3 C, ] ;
' ?BRANCH ALIAS ?branch
' BRANCH  ALIAS branch
' (LIT)   ALIAS literal

// Macro expansion :
// Only macro-expandable words in host can be expanded. Which means only
// those words which have not reference to outside words can be expanded.
// For example, all VCPU instructions are macro-expandable and [ abort" ]
// cannot be expanded. Not all immediate words in host system could be
// used in target system .

: $	' EXPAND ; IMMEDIATE  // do macro expansion from HOST

// Target system's word structure :

: >NAME 40 - ;  : >LINK 12 - ;  : >SIZE 8 - ;  : >ATTR 4 - ;  : >BODY 5 + ;
: NAME> 40 + ;  : LINK> 12 + ;  : SIZE> 8 + ;  : ATTR> 4 + ;  : BODY> 5 - ;

: .NAME >NAME .$ ;

// Vocabulary search of target's FIND

: MFFIND  (( stradr -- cfa nfa | stradr 0 ))	// same as FIND in MF.MF
	LAST @ // stradr nfa
	BEGIN
	   DUP 0<>
	   WHILE
   	      2DUP $= NOT // stradr nfa t/f
	WHILE
	   NAME> >LINK @ // str nfa'
	REPEAT	// stradr NFA
	      NIP DUP NAME> SWAP // cfa nfa
           THEN // stradr 0
	; 1 2 #PARMS

// All IMMEDIATE words and interpreting mode words are executed in HOST.
// So use HOST's '[' . But during [ ... ] block, search order cannot be
// changed !!!

: SearchHostImmed	(( $A -- ))
     // Searching Host vocabulary for IMMEDIATE words.	
	FIND DUP IF
	    |ATTRIBUTE H@ IMMED AND IF  // Host's IMMEDIATE word
	        EXECUTE
	    ELSE
		DROP TRUE ABORT" Cannot reference to host's word."
	    ENDIF
	ELSE
	    DROP NUMBER? IF  \ LITERAL  ENDIF
	ENDIF ; 1 0 #PARMS

: '	TOKEN MFFIND 0= IF ."  * MFFIND : Cannot find " .$ CR ABORT ENDIF ;
: T	' >R ;	// Run target word.
: [']	' \ LITERAL ; IMMEDIATE	// Target's [']

: (     ASCII ) PARSE 2DROP ; IMMEDIATE

VARIABLE HDCOUNT
: HEADER	(( -- ))	// Simulate Target system's HEADER
	LAST @ 0= IF  // First header, placed at $180000+128
	    BASEADDR @ 128 + CP !
	ENDIF
	HERE CURR !	
	HERE 40 ERASE BL WORD C@ 0= ABORT" HEADER : Missing Name."	
	40 ALLOT
	LAST @  CURR @ |Link  !
	1 HDCOUNT +! CR ." Header " HDCOUNT @ . CURR @ .$
	; 0 0 #PARMS

: OVERT		(( -- ))  CURR @ LAST ! ; 0 0 #PARMS

: ATTRIBUTE     LAST @ NAME> >ATTR SWAP OVER @ OR SWAP ! ; 0 0 #PARMS

: IMMEDIATE     $01 ATTRIBUTE ; 0 0 #PARMS
: MACRO		$80 ATTRIBUTE ; 0 0 #PARMS

: expand   (( ca -- )) // Perform a Target system's macro expansion .
        DUP >SIZE @ 1- HERE OVER ALLOT SWAP CMOVE ; 1 0 #PARMS

: compile, (( ca -- ))
	DUP >ATTR @ $80 AND IF  expand  ELSE  call,  ENDIF   ; 1 0 #PARMS

: $,"	ASCII " WORD COUNT + 1+ CP ! ; 0 0 #PARMS

: $MFCOMPILE	(( $a -- ))	// Simulate Target's $COMPILE
	>R R@ MFFIND IF	// cfa
	   DUP >ATTR @ $01 AND IF // Immediate word, Search host.
	      DROP R@ SearchHostImmed
	   ELSE
	      compile,
	   ENDIF
	ELSE // stradr
	   SearchHostImmed
	ENDIF RDROP ;

: ]	H['] $MFCOMPILE H'EVAL ! STATE ON ;

: META 	$180000 CP ! // Host system's HERE
	$180000 128 ERASE
	$180000    			BASEADDR 	!
	2 M        			RP0      	!
	RP0 @ 64 K -			TIB0		!
	TIB0 @ SAFE -			SP0	 	!
	SP0 @ 64 K - SAFE - 64 K -	FILEBUF0	!
	0				LAST		!
	0				CURR		!
	ONLY MFMETA ALSO DEFINITIONS
	FILENAMES OFF " MF.MF" $FLOAD	;

: ;	$C3 C,  HERE  CURR @ 40 +  -   CURR @ |Size   !
        OVERT  \ [   HERE DP ! ; H-IMMEDIATE

: ;M	\ ; MACRO H; H-IMMEDIATE

: :	HEADER   ]  H;

H: \	(( -- )TIB: name)
	' compile,  H; H-IMMEDIATE

ONLY MFMETA ALSO DEFINITIONS

META

