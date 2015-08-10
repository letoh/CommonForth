// Floating point operations
				// Written by : Luke Lee
				// Version 1.4
				//      update : 08/13/'95
				// 	update : 11/28/'95
				// 	update : 12/22/'95
				// last update : 03/14/'95

NEEDS INVOKEC.4TH

HIDDEN ALSO DEFINITIONS

CREATE (FNUMBER$)    256 ALLOT 0 ,  
   // Original 40 to small which often overwrite Float$TypeBuf's code. 3/14/96
CREATE Float$TypeBuf 256 ALLOT 0 ,

FORTH DEFINITIONS

// Floating point support
// 
// !! Note !! 
// There is no floating point number stack here ! All floating number is 
// on data stack with 64-bit IEEE format. ( 'double' in C(++) )

COMMENT:

: FNUMBER? (( adr -- d T / n T / float T / adr F ))
	NUMBER? DUP NOT IF
	   DROP >R
	   R@ COUNT (FNUMBER$) PACK$ 1+ atof // return ( 0 0 ) if fail
	   2DUP OR ?{  1 DPL ! TRUE RDROP  }{  DROP R> SWAP  }?
	ENDIF ;

  I give up the above definition due to 'atof' 's problem :
  it accepts strings leading with digits like "2PI", "1234ASDFDS232" ;
  then it return the value of that leading number.

COMMENT;

: FNUMBER? (( adr -- d T / n T / float T / adr F ))
	NUMBER? DUP NOT IF
	   DROP >R
	   DPL  R@ COUNT (FNUMBER$) PACK$  fnumber  // n n
	   DPL @ -1 = IF  // 0.0	// 03/14/'96
	       R> NIP SWAP
	   ELSE		  // n.m
	       RDROP TRUE
	   ENDIF
	ENDIF ;

' FNUMBER? 'NUMBER !

' 2@    ALIAS  F@
' 2!    ALIAS  F!
' 2DUP  ALIAS  FDUP
' 2DROP ALIAS  FDROP
' 2SWAP ALIAS  FSWAP
' 2OVER ALIAS  FOVER
' 2ROT  ALIAS  FROT

: F.	(( nf -- ))
	sprintf( Float$TypeBuf , Z$" %12.10f" ); >R 4DROP 
	Float$TypeBuf R> TYPE  ; 2 0 #PARMS

: F.R   (( float precision width -- ))
	sprintf( Float$TypeBuf , Z$" %*.*f " ); >R 6DROP
	Float$TypeBuf R> TYPE  ; 4 0 #PARMS

: E.	(( nf -- ))
	sprintf( Float$TypeBuf , Z$" %12.10E" ); >R 4DROP 
	Float$TypeBuf R> TYPE  ; 2 0 #PARMS

: E.R   (( float precision width -- ))
	sprintf( Float$TypeBuf , Z$" %*.*E " ); >R 6DROP
	Float$TypeBuf R> TYPE  ; 4 0 #PARMS

: G.	(( nf -- ))
	sprintf( Float$TypeBuf , Z$" %12.10G" ); >R 4DROP 
	Float$TypeBuf R> TYPE ; 2 0 #PARMS

: G.R   (( float precision width -- ))
	sprintf( Float$TypeBuf , Z$" %*.*G " ); >R 6DROP
	Float$TypeBuf R> TYPE  ; 4 0 #PARMS

: FCONSTANT	(( f -- ))
	CREATE 
	    HERE 2 CELLS ALLOT F!   0 2 #PARMS
	DOES> 
	    F@ ; 2 0 #PARMS

: FVALUE	(( f -- ))	// 11/28/'95
	CREATE
	    , , 0 2 #PARMS
	DOES>
	    F@ ; 2 0 #PARMS

: FVARIABLE	(( -- a ))
	CREATE 0.0 , , ; 0 0 #PARMS

: F!>	(( f -- )TIB: fvalue_name )	// 11/28/'95
	STATE @ IF
	    ' >BODY \ LITERAL COMPILE F!
	ELSE
	    ' >BODY F! 	
	ENDIF ; IMMEDIATE 2 0 #PARMS

' F!> DUP 2DUP ALIAS FTO  ALIAS fto  ALIAS F=>   ALIAS F=:

// Miscellaneous constants 

2.7182818284590452354     FCONSTANT   EXP(1)	// e

2.30258509299404568402    FCONSTANT   LN(10)	// ln(10)  base e
0.69314718055994530942    FCONSTANT   LN(2)	// ln(2)   base e
0.43429448190325182765    FCONSTANT   LOG(E)	// log(e)  base 10

3.14159265358979323846    FCONSTANT   PI
1.57079632679489661923    FCONSTANT   PI/2
0.78539816339744830962    FCONSTANT   PI/4
0.31830988618379067154    FCONSTANT   1/PI
0.63661977236758134308    FCONSTANT   2*PI
1.12837916709551257390    FCONSTANT   SQRT_PI 

1.41421356237309504880    FCONSTANT   SQRT(2)
0.70710678118654752440    FCONSTANT   1/SQRT(2)

// If this package is loaded by 386FLOAT.4TH, ignore the following

#DEFINED 387FLOAT NOT  #IF

// ALIAS is used for faster speed 

' itof	ALIAS  S>F	(( n -- f ))
' ftoi	ALIAS  F>S	(( f -- n ))
' fabs  ALIAS  FABS	(( f -- |f| ))
' fneg  ALIAS  FNEG	(( f -- -f ))
' FNEG  ALIAS  FNEGATE
' sqrt	ALIAS  FSQRT	(( f -- f' ))	

: F0>	(( f -- T ))		f0>   0<>   ; 2 1 #PARMS
: F0>=	(( f -- T ))		f0>=  0<>   ; 2 1 #PARMS
: F0<=	(( f -- T ))		f0<=  0<>   ; 2 1 #PARMS
: F0<	(( f -- T ))		f0<   0<>   ; 2 1 #PARMS
: F0=	(( f -- T ))	       OR 0=	; 2 1 #PARMS
: F0<>	(( f -- T ))	       OR 0<>	; 2 1 #PARMS

// the input sequence is reversed, so ( F> is f< )
: F>	(( f1 f2 -- f ))	f<   0<>    ; 4 1 #PARMS
: F>=	(( f1 f2 -- f ))	f<=  0<>    ; 4 1 #PARMS
: F<=	(( f1 f2 -- f ))	f>=  0<>    ; 4 1 #PARMS
: F<	(( f1 f2 -- f ))	f>   0<>    ; 4 1 #PARMS
: F=	(( f1 f2 -- f ))  ROT =  -ROT =  AND ; 4 1 #PARMS
: F<>	(( f1 f2 -- f ))  ROT <> -ROT <> OR  ; 4 1 #PARMS

' f+    ALIAS   F+	(( f1 f2 -- f ))    
' rf-   ALIAS   F-	(( f1 f2 -- f1-f2 ))    
' f-    ALIAS   FR-	(( f1 f2 -- f2-f1 ))
' f*    ALIAS   F*	(( f1 f2 -- f ))    
' rf/   ALIAS   F/	(( f1 f2 -- f1/f2 ))    
' f/    ALIAS   FR/	(( f1 f2 -- f2/f1 ))
	      : 1/F	(( f -- 1/f ))	1.0 FR/ ; 2 2 #PARMS

' sin   ALIAS   FSIN	(( f -- f' ))
' cos   ALIAS   FCOS	(( f -- f' ))
' tan   ALIAS   FTAN	(( f -- f' ))
	      : FCSC	(( f -- f' ))	 FSIN 1.0 FR/ ; 2 2 #PARMS
	      : FSEC	(( f -- f' ))	 FCOS 1.0 FR/ ; 2 2 #PARMS
	      : FCOT	(( f -- f' ))	 FTAN 1.0 FR/ ; 2 2 #PARMS

' sinh  ALIAS   FSINH	(( f -- f' ))
' cosh  ALIAS   FCOSH	(( f -- f' ))
' tanh  ALIAS   FTANH	(( f -- f' ))

' asin  ALIAS   FASIN	(( f -- f' ))
' acos  ALIAS   FACOS	(( f -- f' ))
' atan  ALIAS   FATAN	(( f -- f' ))

' ceil	ALIAS	CEIL	(( f -- f' ))
' floor ALIAS	FLOOR	(( f -- f' ))

' exp	ALIAS	FEXP	(( f -- f' ))
' log	ALIAS	FLN	// f -- ln(f)	base e
' log10 ALIAS	FLOG	// f -- log(f)	base 10
// ' log2  ALIAS   FLG     // f -- lg(f)   base 2

	      : F**	(( f1 f2 -- f1**f2 ))	FSWAP pow ; 4 2 #PARMS
// ' pow10	ALIAS	F10**	(( f -- 10**f ))
// ' pow2	ALIAS	F2**	(( f -- 2**f ))

#ENDIF	// 387FLOAT

ONLY FORTH ALSO DEFINITIONS

