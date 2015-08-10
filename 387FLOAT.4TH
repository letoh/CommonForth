// Floating point package for 80387 hardware
					// Written by : Luke Lee
					// Version 1.0
					// Last update 08/26/'95

// Before you FLOAD this package, if you defined a word named  "NOFMACRO"
// then all the floating operations will be treated as normal words instead
// of macros .

: 387FLOAT ;  
NEEDS FLOAT.4TH
NEEDS CPU80486.4TH

: FMACRO	(( -- ))
   [ #DEFINED NOFMACRO NOT ] #IF
	MACRO
   #ENDIF	; 0 0 #PARMS

: S>F	(( n -- f ))
     	INLINE[
		EBP  { EBP 2 CELLS - }  LEA
		{ EBP }		   EAX	MOV
		DWORD^ { EBP }  	FILD	
		QWORD^ { EBP }  	FSTP	]INLINE  // 32bit integer
	DROP ; FMACRO 1 2 #PARMS
	
: D>F	(( d -- f ))
	SWAP DUP 
	INLINE[	  
		QWORD^ { EBP }  FILD	
		QWORD^ { EBP }	FSTP	]INLINE  // 64bit integer
	DROP ; FMACRO 1 2 #PARMS	

: F>S	(( f -- n ))
	DUP
	INLINE[
		QWORD^ { EBP }  FLD	       
		DWORD^ { EBP }  FISTP		// 32bit integer
		EAX    { EBP }	MOV	
		EBP    { EBP 2 CELLS + }  LEA	]INLINE
	; FMACRO 2 1 #PARMS

: F>D	(( f -- d ))
	DUP
	INLINE[   
		QWORD^ { EBP }  FLD		
		QWORD^ { EBP }  FISTP	]INLINE	 // 64bit integer
	DROP SWAP ; FMACRO 2 2 #PARMS

: FABS	(( f -- |f| ))
	DUP
	INLINE[
		QWORD^ { EBP }	FLD
		 		FABS
		QWORD^ { EBP }	FSTP	]INLINE
	DROP ; FMACRO 2 2 #PARMS

: FNEG	(( f -- -f ))
	DUP
	INLINE[
				FLDZ
		QWORD^ { EBP }	FLD
				FSUB
		QWORD^ { EBP }	FSTP	]INLINE
	DROP ; FMACRO 2 2 #PARMS

' FNEG ALIAS FNEGATE

: FSQRT	(( f -- f' ))
	DUP 
	INLINE[
		QWORD^ { EBP }	FLD
				FSQRT
		QWORD^ { EBP }	FSTP	]INLINE
	DROP ; FMACRO 2 2 #PARMS

HIDDEN ALSO DEFINITIONS

: F0(>=<)(begin)	(( -- ))
	DUP
	INLINE[
				FLDZ
		QWORD^ { EBP }	FLD
				FCOMPP
			AX	FNSTSW
				SAHF
	]INLINE ; MACRO COMPILEONLY

: F0(>=<)(end)	(( -- ))
	INLINE[
			AL	1 #	SHR
			EAX	EAX	SBB
		EBP   { EBP 8 + }	LEA	
	]INLINE ; MACRO COMPILEONLY

: F(>=<)(BEGIN)	(( -- ))
	DUP
	INLINE[		
		QWORD^ { EBP }		FLD
		QWORD^ { EBP 8 + }	FLD
					FCOMPP
			AX		FNSTSW
					SAHF
	]INLINE ; MACRO COMPILEONLY

: F(>=<)(END)	(( -- ))
	INLINE[
			AL	1 #	SHR
		       EAX	EAX	SBB
		  EBP  { EBP 16 + }	LEA
	]INLINE ; MACRO COMPILEONLY

: F(+-*/)(BEGIN) (( -- ))
	DUP
	INLINE[  QWORD^ { EBP 2 CELLS + }	FLD	]INLINE
	; MACRO COMPILEONLY

: F(+-*/)(END)	(( -- ))
	INLINE[ 
		QWORD^ { EBP 2 CELLS + }	FSTP
		EAX	{ EBP 2 CELLS + }	MOV
		EBP	{ EBP 3 CELLS + }	LEA	
	]INLINE ; MACRO COMPILEONLY

FORTH DEFINITIONS

: F0>	(( f -- T ))
	F0(>=<)(begin)
	INLINE[	  AL	SETA    ]INLINE
	F0(>=<)(end)		; 2 1 #PARMS FMACRO

: F0>=	(( f -- T ))		
	F0(>=<)(begin)
	INLINE[	  AL	SETAE	]INLINE
	F0(>=<)(end)		; 2 1 #PARMS FMACRO

: F0<=	(( f -- T ))		
	F0(>=<)(begin)
	INLINE[	  AL	SETBE	]INLINE
	F0(>=<)(end)		; 2 1 #PARMS FMACRO

: F0<	(( f -- T ))		
	F0(>=<)(begin)
	INLINE[	  AL	SETB	]INLINE
	F0(>=<)(end)		; 2 1 #PARMS FMACRO

: F0=	(( fn -- T ))	       OR 0=	; 2 1 #PARMS FMACRO
: F0<>	(( fn -- T ))	       OR 0<>	; 2 1 #PARMS FMACRO


: F>	(( f1 f2 -- f ))	
	F(>=<)(BEGIN)
	INLINE[	  AL	SETA	]INLINE
	F(>=<)(END)		; 4 1 #PARMS FMACRO

: F>=	(( f1 f2 -- f ))	
	F(>=<)(BEGIN)
	INLINE[	  AL	SETAE	]INLINE
	F(>=<)(END)		; 4 1 #PARMS FMACRO

: F<=	(( f1 f2 -- f ))	
	F(>=<)(BEGIN)
	INLINE[	  AL	SETBE	]INLINE
	F(>=<)(END)		; 4 1 #PARMS FMACRO

: F<	(( f1 f2 -- f ))	
	F(>=<)(BEGIN)
	INLINE[	  AL	SETB	]INLINE
	F(>=<)(END)		; 4 1 #PARMS FMACRO

: F=	(( f1 f2 -- f ))  ROT =  -ROT =  AND ; 4 1 #PARMS FMACRO
: F<>	(( f1 f2 -- f ))  ROT <> -ROT <> OR  ; 4 1 #PARMS FMACRO

: F+	(( f1 f2 -- f1+f2 ))
	F(+-*/)(BEGIN)
	INLINE[   QWORD^ { EBP }  FADD   ]INLINE
	F(+-*/)(END)	; 4 2 #PARMS FMACRO

: F-	(( f1 f2 -- f1-f2 ))
	F(+-*/)(BEGIN)
	INLINE[   QWORD^ { EBP }  FSUB   ]INLINE
	F(+-*/)(END)	; 4 2 #PARMS FMACRO

: F*	(( f1 f2 -- f1*f2 ))
	F(+-*/)(BEGIN)
	INLINE[   QWORD^ { EBP }  FMUL   ]INLINE
	F(+-*/)(END)	; 4 2 #PARMS FMACRO

: F/	(( f1 f2 -- f1/f2 ))
	F(+-*/)(BEGIN)
	INLINE[   QWORD^ { EBP }  FDIV   ]INLINE
	F(+-*/)(END)	; 4 2 #PARMS FMACRO

: FR-	(( f1 f2 -- f2-f1 ))
	F(+-*/)(BEGIN)
	INLINE[   QWORD^ { EBP }  FSUBR   ]INLINE
	F(+-*/)(END)	; 4 2 #PARMS FMACRO

: FR/	(( f1 f2 -- f2/f1 ))
	F(+-*/)(BEGIN)
	INLINE[   QWORD^ { EBP }  FDIVR   ]INLINE
	F(+-*/)(END)	; 4 2 #PARMS FMACRO

: 1/F	(( f -- 1/f ))
	DUP
	INLINE[
				FLD1
		QWORD^ { EBP }	FDIV
		QWORD^ { EBP }	FSTP	]INLINE
	DROP ; 2 2 #PARMS FMACRO
		
: FSIN	(( f -- sinf ))
	DUP 
	INLINE[
		QWORD^ { EBP }	FLD
				FSIN
		QWORD^ { EBP }	FSTP	]INLINE
	DROP ; 2 2 #PARMS FMACRO

: FCOS	(( f -- cosf ))
	DUP 
	INLINE[
		QWORD^ { EBP }	FLD
				FCOS
		QWORD^ { EBP }	FSTP	]INLINE
	DROP ; 2 2 #PARMS FMACRO

: FTAN	(( f -- tanf ))
	DUP 
	INLINE[
		QWORD^ { EBP }	FLD
				FPTAN
				FMUL
		QWORD^ { EBP }	FSTP	]INLINE
	DROP ; 2 2 #PARMS FMACRO

: FCSC	(( f -- cscf ))
	DUP
	INLINE[			FLD1
		QWORD^ { EBP }	FLD
				FSIN
				FDIV	
		QWORD^ { EBP }	FSTP	]INLINE
	DROP ; 2 2 #PARMS FMACRO

: FCOT	(( f -- cotf ))
	DUP
	INLINE[
		QWORD^ { EBP }	FLD
				FPTAN
				FDIVR	
		QWORD^ { EBP }	FSTP	]INLINE
	DROP ; 2 2 #PARMS FMACRO

: FSEC	(( f -- secf ))
	DUP
	INLINE[			FLD1
		QWORD^ { EBP }	FLD
				FCOS
				FDIV
		QWORD^ { EBP }	FSTP	]INLINE
	DROP ; 2 2 #PARMS FMACRO

: FROUND        (( f -- f' ))
        DUP
        INLINE[ 
                QWORD^ { EBP }  FLD
                                FRNDINT
                QWORD^ { EBP }  FSTP    ]INLINE
        DROP ; 2 2 #PARMS FMACRO

: FATAN (( f -- f' ))
        DUP
        INLINE[
                QWORD^ { EBP }  FLD
                                FLD1
                                FPATAN
                QWORD^ { EBP }  FSTP    ]INLINE
        DROP ; 2 2 #PARMS FMACRO

: FLN   (( f -- f' ))
        DUP
        INLINE[
                FLD1    FLDL2E  FDIV
                QWORD^ { EBP }  FLD
                                FYL2X
                QWORD^ { EBP }  FSTP    ]INLINE
        DROP ; 2 2 #PARMS FMACRO

: FLOG  (( f -- f' ))
        DUP
        INLINE[
                FLD1    FLDL2T  FDIV
                QWORD^ { EBP }  FLD
                                FYL2X
                QWORD^ { EBP }  FSTP    ]INLINE
        DROP ; 2 2 #PARMS FMACRO

: FLG   (( f -- f' ))
        DUP
        INLINE[
                                FLD1
                QWORD^ { EBP }  FLD
                                FYL2X
                QWORD^ { EBP }  FSTP    ]INLINE
        DROP ; 2 2 #PARMS FMACRO

HIDDEN DEFINITIONS

: (F2**)
	INLINE[
			ST	FLD
				FRNDINT
		ST(1)	ST	FSUB	// make X valid for F2XM1
			ST(1)	FXCH
				F2XM1	// it must be -0.5 <= X <= +0.5
				FLD1
				FADD
				FSCALE		]INLINE
	; MACRO COMPILEONLY

FORTH DEFINITIONS

: F2**	(( f -- 2**f ))	// 2**A * 2**B = 2**(A+B)
	DUP
	INLINE[   QWORD^ { EBP }   FLD   	]INLINE
	(F2**)
	INLINE[	  QWORD^ { EBP }   FSTP
				   FINIT	]INLINE
	DROP ; 2 2 #PARMS FMACRO

: F**	(( x y -- x**y )) // x**y = 2**(y*LG(x))
	// FSWAP FLG F* F2**	
	DUP 
	INLINE[					FLD1
		QWORD^ { EBP 2 CELL* + }	FLD
						FYL2X
		QWORD^ { EBP }			FMUL	]INLINE
	(F2**)
	INLINE[	EBP	{ EBP 2 CELL* + }	LEA
		QWORD^ { EBP }	FSTP
				FINIT		]INLINE
	DROP  ; 4 2 #PARMS FMACRO

: FEXP	(( x -- e**x ))
	DUP
	INLINE[	  			FLDL2E    
		  QWORD^ { EBP }	FMUL	]INLINE
	(F2**)
	INLINE[	  QWORD^ { EBP }   FSTP
				   FINIT	]INLINE
	DROP  ; 2 2 #PARMS FMACRO

: F10**	(( x -- 10**x ))	
	DUP
	INLINE[	  			FLDL2T
		  QWORD^ { EBP }	FMUL	]INLINE
	(F2**)
	INLINE[	  QWORD^ { EBP }   FSTP
				   FINIT	]INLINE
	DROP  ; 2 2 #PARMS FMACRO

: FSP@	(( -- n ))
	DUP
	INLINE[	
			AX	FSTSW
		AX	11 #	SHR
		EAX	7 #	AND	]INLINE	; 0 1 #PARMS

: FSTAT	(( -- n ))
	DUP
	INLINE[		AX	FSTSW
		EAX    $FFFF #	AND	]INLINE ; 0 1 #PARMS
			
' sinh  ALIAS   FSINH	(( f -- f' ))
' cosh  ALIAS   FCOSH	(( f -- f' ))
' tanh  ALIAS   FTANH	(( f -- f' ))

' asin  ALIAS   FASIN	(( f -- f' ))
' acos  ALIAS   FACOS	(( f -- f' ))

' ceil	ALIAS	CEIL	(( f -- f' ))
' floor ALIAS	FLOOR	(( f -- f' ))

ONLY FORTH ALSO DEFINITIONS

