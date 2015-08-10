// Invoke C(++) Functions
                                      // Written by : Luke Lee
                                      // Version 1.65
				      //	update : 08/19/'95
                                      // 	update : 09/19/'95
                                      // 	update : 12/25/'95
                                      // 	update : 01/02/'96
                                      //   	update : 01/05/'96
                                      //        update : 01/28/'96
                                      //   Last update : 07/02/'96
                                      // Written for DJGPP and Watcom C/C++
// Modification history :
// 09/19/'95 : Modify MACRO registration for SEE .
// 12/25/'95 : Add CLOCKS_PER_SECOND
// 01/02/'96 : Add 'struct tm' .
// 01/05/'96 : Use conditional compilation for both DJGPP and WATCOM.
// 01/28/'96 : Rename TRANSLATE-BLOCK into TRANSLATE .
// 07/02/'96 : Modify constant value of P_WAIT according to different compiler

// : DJGPP_GO32 ; INVISIBLE

// : WATCOM_C/C++ ; INVISIBLE

: BORLAND_C++ ; INVISIBLE

DECIMAL

VOCABULARY      C++
C++  ALSO  DEFINITIONS

$FF00   CONSTANT        UNKNOWN         // only the number of input parameters
                                        // could possibly be unknown
0       CONSTANT        void
1       CONSTANT        int
1       CONSTANT        unsigned
1       CONSTANT        long
1       CONSTANT        char*
1       CONSTANT        void*
1       CONSTANT        pointer
$F000   CONSTANT        Floating
$F001   CONSTANT        float	   // 32bit floating NOT implemented yet
$F002   CONSTANT        double

: CLEAN1        COMPILE DROP ;          : CLEAN2        COMPILE 2DROP ;
: CLEAN3        COMPILE 3DROP ;         : CLEAN4        COMPILE 4DROP ;
: CLEAN5        COMPILE 5DROP ;         : CLEAN6        COMPILE 6DROP ;
: CLEAN7        COMPILE 7DROP ;         : CLEAN8        COMPILE 8DROP ;

CREATE  CLEAN-UP
        ' CLEAN1 , ' CLEAN2 , ' CLEAN3 , ' CLEAN4 ,
        ' CLEAN5 , ' CLEAN6 , ' CLEAN7 , ' CLEAN8 ,

: (LayDownCleanUp)      (( in -- ))
        DUP 0> IF
           DUP 2/ 2/ 2/ 0 ?DO  CLEAN8  LOOP
           1- 7 AND CELL*   CLEAN-UP   +   @EXECUTE
        ELSE
           DROP
        ENDIF ; 1 0 #PARMS      // caller should always do clean-ups

: LayDownCleanUp        (( in -- ))      RECURSIVE
        DUP UNKNOWN >= IF DROP EXIT ENDIF
        (LayDownCleanUp) ; 1 0 #PARMS

CREATE function-name$   64 ALLOT

: too_many_return_values!
	CR ." * Too many return values : " .
	." for " LAST @ .ID
	CR ABORT ; 

: int_settle_return_value	(( in out -- ))
        CASE
           0 OF    1+ LayDownCleanUp       ENDOF
           1 OF    DUP UNKNOWN < IF
		       CASE
			  0 OF	    NOOP       ENDOF
			  1 OF   COMPILE NIP   ENDOF
			  (( default : ))
			  	 COMPILE >R
			  	 DUP LayDownCleanUp
			  	 COMPILE R>
		       ENDCASE
                   ELSE
                       DROP
                   ENDIF                   ENDOF
	   too_many_return_values!
        ENDCASE ; 2 0 #PARMS

#DEFINED DJGPP_GO32 #DEFINED BORLAND_C++ OR #IF

: float_settle_return_value	(( in out -- ))  // for DJGPP 
	Floating NOT AND
        CASE
          0 OF     2 + LayDownCleanUp      ENDOF
          1 OF     1+ LayDownCleanUp               
                   COMPILE SF>TOS          ENDOF
          2 OF     1+ LayDownCleanUp
                   COMPILE DF>TOS          ENDOF                           
          too_many_return_values!
        ENDCASE ; 2 0 #PARMS

#ELSE #DEFINED WATCOM_C/C++ #IF

: float_settle_return_value     (( in out -- ))  // for Watcom C++
	Floating NOT AND
	CASE
	  0 OF     2 + LayDownCleanUp           ENDOF
	  1 OF     1 int_settle_return_value    ENDOF
	  2 OF     COMPILE >R LayDownCleanUp COMPILE R>
		   COMPILE EDX>STACK            ENDOF
	  too_many_return_values!
	ENDCASE ; 2 0 #PARMS

#ELSE

    CR .( * Error : Unknown loader .) CR BEEP ABORT

#ENDIF #ENDIF

// ----------------------------------------
//     postfix function implementation
// ----------------------------------------

$20 CONSTANT C++POSTFIX

: Postfix_C_func  (( -- ))
	C++POSTFIX MaskNameAttr  ; 0 0 #PARMS

: postfix-function      (( in out C++fnadr -- FORTHfnadr))
        function-name$ COUNT "HEADER OVERT
        HERE >R
        \ LITERAL COMPILE C(++)invoke        // invoke fnadr
	2DUP #PARMS
        DUP Floating AND Floating = IF
	   float_settle_return_value
        ELSE
	   int_settle_return_value
        ENDIF
        COMPILE exit 
        R>  HERE OVER - LAST @ |SIZE ! 
	MACRO Postfix_C_func ; 3 1 #PARMS

// ----------------------------------------
//      Infix function implementation
// ----------------------------------------

STACK-EXPRESSION ALSO C++

$40 CONSTANT C++INFIX
VARIABLE funcall-nesting

STRUCT: ParsingFrame    // 6 CELLS, allow nesting C++ function calls
        WORD:   |old-(|SP|)
        WORD:   |old-^parameter
        WORD:   |old-eval
        WORD:   |in
        WORD:   |out
        WORD:   |fnadr
;STRUCT

// Top down allocation :
 CREATE transient-parameter      260 ALLOT
 transient-parameter  VALUE ^transient

// Bottom up allocation :
 CREATE parameter-buffer         4 K ALLOT <LF> C, 64 ALLOT
 parameter-buffer 4 K + CONSTANT end-parameter-buffer
 end-parameter-buffer VALUE ^parameter

 CREATE ParsingStack           SIZEOF ParsingFrame 16 * ALLOT
 HERE CONSTANT EndParsingStack
 EndParsingStack SIZEOF ParsingFrame - CONSTANT LastParsingStackItem
 EndParsingStack VALUE ParsingStack^


: InitParser (( -- ))
        funcall-nesting OFF
        transient-parameter => ^transient
        end-parameter-buffer => ^parameter
        EndParsingStack => ParsingStack^ ; 0 0 #PARMS

: PopFrame      (( -- ))
        ParsingStack^ |old-eval @  'EVAL  !
        ParsingStack^ |old-^parameter @  =>  ^parameter
        ParsingStack^ SIZEOF ParsingFrame LITERAL + => ParsingStack^
        ; 0 0 #PARMS

: AbortTranslation (( -- ))
        LastParsingStackItem |old-eval @     'EVAL    !
        funcall-nesting OFF
        InitParser CR ABORT ; 0 0 #PARMS

: C++SyntaxError (( -- ))
        CR ." Syntax error in nesting C(++) function call." CR
        AbortTranslation ; 0 0 #PARMS

: check-#inparms (| #inpars | defined#ins -- |)
          StkExprUsed?
        ANDTHEN
          ParsingStack^ |in @ => defined#ins
          defined#ins UNKNOWN <>
        ANDTHEN
          defined#ins #inpars - 0<>
        ANDTHEN
          TRUE CR ." Error : Too "
          defined#ins #inpars - 0< IF ." many" ELSE ." less" ENDIF
          ."  parameters in C(++) function call : " #inpars . CR
          AbortTranslation
        THEN-AND DROP ;

: indefinite-inputs-cleanup (| #inpars -- |)
          StkExprUsed?
        ANDTHEN
          ParsingStack^ |in @ UNKNOWN =
        ANDTHEN
          ParsingStack^ |out @ 0 ?DO COMPILE >R LOOP
          #inpars  (LayDownCleanUp)
          ParsingStack^ |out @ 0 ?DO COMPILE R> LOOP
          TRUE
        THEN-AND DROP ;

: TranslateParameters (| | len #inpars -- |)
        LastParsingStackItem |old-eval @     'EVAL    !
        ParsingStack^ |old-^parameter @  ^parameter  -  =>  len
        #LINESREAD @ >R
        ^parameter len TRANSLATE (( -- ERR? ))
        R> #LINESREAD !
        (( ERR? )) DUP IF  COUNT TYPE AbortTranslation  ELSE  DROP  ENDIF
        (|SP|) @ ParsingStack^ |old-(|SP|) @ - => #inpars
        #inpars check-#inparms
        ParsingStack^ |fnadr @ compile,
        #inpars indefinite-inputs-cleanup
        PopFrame ;

: is","?    (( $str -- T/F ))    $" ,"  2 COMP 0= ; 1 1 #PARMS
: is")"?    (( $str -- T/F ))    $" )"  2 COMP 0= ; 1 1 #PARMS
: is");"?   (( $str -- T/F ))    $" );" 3 COMP 0= ; 1 1 #PARMS

: >trailing     (( c -- ))
        ^transient C!
        ^transient 1+ => ^transient ; 1 0 #PARMS

: trailing-"    (| -- |)   ASCII " >trailing ;
: trailing-bl   (| -- |)   BL >trailing      ;

: copy-word     (( $str -- )) // always lay down a blanket at end.
        DUP COUNT ^transient SWAP CMOVE
        C@ ^transient + => ^transient
        trailing-bl ; 1 0 #PARMS

: copy-parameter (| | len -- |)
        ^transient transient-parameter - => len
        len IF
           ^parameter len - => ^parameter
           transient-parameter ^parameter len CMOVE
           transient-parameter => ^transient
        ENDIF ;

: scanfor-"     (( str$ -- T/F )) // return TRUE if found
        DUP COUNT
        FOR
           DUP C@ ASCII " <>
           WHILE
              1+
        NEXT
              2DROP FALSE
           ELSE
              RDROP (( FOR...NEXT )) DROP copy-word
              ASCII " PARSE (( skip BL in TIB ))
              ^transient 1- PACK$  (( skip trailing BL in ^transcient ))
              DUP COUNT + => ^transient
              BL SWAP C!  // change string length into BL
              trailing-"  // insert trailing " back
              trailing-bl // also a trailing BL
              TRUE
           THEN ; 1 1 #PARMS

: is-word-,     (| str$ -- T/F |) // return TRUE if it is ","
          funcall-nesting @ 0=
        ANDTHEN
          str$ is","? 
        ANDTHEN
          copy-parameter TRUE
        THEN-AND => T/F ;

: is-word-)     (| str$ -- T/F |) // return TRUE if it is ")"
          str$ is")"?
        ANDTHEN
            funcall-nesting @ 0<> DUP IF
              OVER copy-word 
              -1 funcall-nesting +!
              funcall-nesting @ 0<  IF  C++SyntaxError  ENDIF
            ELSE
              trailing-bl copy-parameter
              funcall-nesting OFF  
              TranslateParameters
            ENDIF
        THEN-AND => T/F ; 1 1 #PARMS

: is-word-);    (| str$ -- T/F |) // return TRUE if it is ");"
          str$ is");"?
        ANDTHEN
           funcall-nesting @ 0= DUP IF
             trailing-bl copy-parameter
             funcall-nesting OFF
             TranslateParameters 
           ELSE
             C++SyntaxError
           ENDIF
        THEN-AND => T/F ; 1 1 #PARMS

: is-C++?       (| str$ | ha/F -- T/F |)
        // Allow nesting C++ function calls .
        str$ FIND NIP => ha/F           // Search current ORDER
          ha/F
        ANDTHEN
          ha/F |ATTRIBUTE H@ C++INFIX AND C++INFIX =
        ANDTHEN
          str$ copy-word
          1 funcall-nesting +! TRUE
        THEN-AND => T/F ;

: ParseParameter (( str$ -- ))
       // 1. Scan for string pattern : "....."
        DUP  scanfor-"   ORELSE
       // 2. If it is the word ","
        DUP  is-word-,   ORELSE
       // 3. It is not ",", check if it is ")"
        DUP  is-word-)   ORELSE
       // 4. It is not ")", check if it is ");"
        DUP  is-word-);  ORELSE
       // 5. A C++ function ?
        DUP  is-C++?     ORELSE
       // 6. Not any situation above, copy word into transient parameter.
        DUP copy-word 0  ELSE-OR 2DROP ; 1 0 #PARMS

: infix-function        (( in out FORTHfnadr -- ))
	function-name$ " (" $+ COUNT
        "CREATE
           , , ,
	   C++INFIX MaskNameAttr INVISIBLE IMMEDIATE COMPILEONLY 0 0 #PARMS
        DOES>   (( -- ))
           DUP @ SWAP CELL+ DUP @ SWAP CELL+ @  (( fnadr out in ))
           'EVAL @ ^parameter (|SP|) @      (( fnadr out in 'EVAL@ ^par LSP@ ))
           ParsingStack^  6 CELL*  -  =>  ParsingStack^
           SP@  ParsingStack^  6 CELL*   CMOVE  6DROP
           ['] ParseParameter 'EVAL ! ; 3 0 #PARMS

FORTH DEFINITIONS

: C:    (( in out C++fnadr -- ))
        >R 2DUP R>
        BL WORD function-name$ 64 CMOVE
        postfix-function
        infix-function ; 3 0 #PARMS

: C&	(( -- )TIB: <function_name> -- )
	' DUP >HEAD |ATTRIBUTE H@ C++POSTFIX AND 0<> IF
	   SIZEOF (LIT) LITERAL 1- + @
	   STATE @ IF  \ LITERAL  ENDIF
	ELSE
	   DROP CR ." * ERROR : C& must be applied on a C(++) function name " CR
	   ABORT
	ENDIF ; IMMEDIATE 0 1 #PARMS

C++ DEFINITIONS

VARIABLE BUFSIZE

2  int	BASE-ADDRESS |INIT-ENVIRON |C(++)Linking() @     C:  C(++)Linking
void void
        BASE-ADDRESS |INIT-ENVIRON |C(++)EndLinking() @  C:  C(++)EndLinking

: Establish-Linkage (( -- ))
        ['] <forth_interpret> BUFSIZE C(++)Linking
        BUFSIZE @ TRANSLATE (( -- T/F ))
        C(++)EndLinking
        IF
           ." * Fail establishing linkage between FORTH and C(++)." CR
        ENDIF ;

Establish-Linkage

STRUCT: tm
        WORD:        |tm_sec         // seconds after the minute [0-60] 
        WORD:        |tm_min         // minutes after the hour [0-59] 
        WORD:        |tm_hour        // hours since midnight [0-23] 
        WORD:        |tm_mday        // day of the month [1-31] 
        WORD:        |tm_mon         // months since January [0-11] 
        WORD:        |tm_year        // years since 1900 
        WORD:        |tm_wday        // days since Sunday [0-6] 
        WORD:        |tm_yday        // days since January 1 [0-365] 
        WORD:        |tm_isdst       // Daylight Savings Time flag 
    __sizeof_tm OFFSET |tm_isdst - CELL-
	0 MAX FIELD: |_rest_of_tm
;STRUCT

: (ONLY)  (( -- ))
        CONTEXT #VOCS CELL* 0 FILL 
        FORTH CONTEXT @ CONTEXT CELL+ ! C++ ALSO FORTH ; 0 0 #PARMS

' (ONLY) PATCH ONLY

#DEFINED DJGPP_GO32 #DEFINED BORLAND_C++ OR #IF

  WARNING @ WARNING OFF

  #EXISTED (dokey)  #IF

  HIDDEN ALSO C++ DEFINITIONS

  2 VALUE curstype

  : toggle-cursor
     3 curstype XOR 3 AND DUP => curstype _setcursortype ; 0 0 #PARMS

  is-insert? #IF  toggle-cursor  #ENDIF

  : C++(dokey)	(( buf #chars_got #max_got key -- #chars_got' #max_got' ))
  	DUP ins = IF
  	   toggle-cursor
  	ENDIF
  	DEFERS dokey ; 4 2 #PARMS

  ' C++(dokey) IS dokey

  #ENDIF	// #EXISTED (dokey)

  WARNING !

#ENDIF  // #DEFINED DJGPP_GO32

ONLY FORTH ALSO DEFINITIONS

// COLORS :
// dark colors :
0 CONSTANT BLACK        1 CONSTANT BLUE         2 CONSTANT GREEN
3 CONSTANT CYAN         4 CONSTANT RED          5 CONSTANT MAGENTA
6 CONSTANT BROWN        7 CONSTANT LIGHTGRAY
// light colors :
8  CONSTANT DARKGRAY     9 CONSTANT LIGHTBLUE   10 CONSTANT LIGHTGREEN
11 CONSTANT LIGHTCYAN   12 CONSTANT LIGHTRED    13 CONSTANT LIGHTMAGENTA
14 CONSTANT YELLOW      15 CONSTANT WHITE

$80 CONSTANT BLINK

// Other constants 

#EXISTED DJGPP_GO32 #IF
  1	CONSTANT	P_WAIT
  3	CONSTANT	P_OVERLAY
#ELSE 
#EXISTED WATCOM_C/C++
#EXISTED BORLAND_C++ OR #IF         // 07/02/'96 modified
  0     CONSTANT    P_WAIT
#ENDIF #ENDIF

-1	CONSTANT 	EOF

#EXISTED clock(  #EXISTED DJGPP_GO32  AND
#IF

1000000 CONSTANT 	CLOCKS_PER_SEC	// defined in <time.h>
clock DROP  // initialize
: MS	(( n -- ))	// pause for n MS
	[ CLOCKS_PER_SEC 1000 / ] LITERAL  *
	clock 
	BEGIN  PAUSE 
	   2DUP clock - ABS <=
	UNTIL 2DROP ; 1 0 #PARMS

#ENDIF

#EXISTED clock(  #EXISTED WATCOM_C/C++  AND
#EXISTED clock(  #EXISTED BORLAND_C++   AND OR
#IF

#EXISTED WATCOM_C/C++ #IF
100     CONSTANT 	CLOCKS_PER_SEC	// defined in <time.h>
#ELSE
1000    CONSTANT 	CLOCKS_PER_SEC	// defined in <time.h>
#ENDIF

clock DROP  // initialize
: MS	(( n -- ))  // pause for n MS, minimum available amount is 10 MS
	[ 1000 CLOCKS_PER_SEC / ] LITERAL /
	clock
	BEGIN  PAUSE 
	   2DUP clock - ABS <=
	UNTIL 2DROP ; 1 0 #PARMS

#ENDIF


