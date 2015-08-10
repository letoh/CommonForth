// Meta compiler for Common Forth 1.7X
					// Version    :  1.70
					// Written by :  Luke Lee
					// Last update : 02/09/'97

     // Detail steps ( for manual meta-compilation ) :
     //   1. CF.EXE .......................... CF 1.7X, under MSDOS
     //   2. FLOAD CFMETA.4TH ................ loading this meta compiler
     //   3. META1 ........................... start meta compiling pass 1
     //   4. FLOAD HI.4TH .................... after new system starts up
     //   5. FLOAD CFMETA.4TH ................ same as step 1.
     //   6. META2 ........................... meta compiling pass 2
     //   7. FLOAD HI.4TH .................... for obtaining FSAVE ...etc.
     //   8. FSAVE BYE  ...................... save image and quit.

     // Quick steps ( for automatic meta-compilation ) :
     //   1. CF.EXE .......................... CF 1.7X, under MSDOS
     //   2. FLOAD METASAVE .................. steps 2...8.

ONLY FORTH ALSO DEFINITIONS

TRACER/RESET    // no tracing now 
#DEFINED SEE-MACROS #IF
   SEE-MACROS OFF       // prevent any registration of macros for SEE
#ENDIF

NEEDS CPU80486.4TH

VARIABLE AUTOMETA
VARIABLE AUTOSAVE       // 02/09/'97
AUTOMETA OFF
AUTOSAVE OFF

POSTFIX SYNTAX

DECIMAL

$140000      CONSTANT CF-SYSTEM-BASE-ADDRESS
1021         CONSTANT MAGIC-NUMBER  // key for hash function
#VOCS CELL*  CONSTANT |VOCS|        // size of vocabulary stack
BASE-ADDRESS CONSTANT OLD-BASE-ADDRESS

VARIABLE T-TIB
VARIABLE ^UP
VARIABLE ^doUSER
// Variables initialized by META :
VARIABLE TCP0   VARIABLE TRP0   VARIABLE TSP0   VARIABLE TUP0
VARIABLE ^COLD
0 VALUE  T-BASE-ADDRESS         // 02/09/'97

// Simulate loader's command line parameters    // 02/09/'97
CREATE AUTOMETA_ARGV[1]    256 CELL+ ALLOT      0 AUTOMETA_ARGV[1] C!
CREATE AUTOMETA_ARGV       NULL$ , AUTOMETA_ARGV[1] 1+ ,

: USER, ( <string> -- ) // defining words for 'user variable compilers'
	CREATE ^UP @ , CELL ^UP +! IMMEDIATE
	DOES> ^doUSER @ DUP 0= ABORT" ^doUSER not initialized yet"
	      compile,
	      @ ,   0 1 #PARMS ; 0 0 #PARMS

: COPY-LoaderEnviron    (| newcp0 -- |)         // 02/09/'97 modified
	OLD-BASE-ADDRESS |INIT-ENVIRON
	newcp0 |INIT-ENVIRON    SIZEOF LoaderEnviron LITERAL   MOVE
        AUTOMETA @ IF
            2              newcp0 |INIT-ENVIRON |ARGC  !
            AUTOMETA_ARGV  newcp0 |INIT-ENVIRON |ARGV  !
        ENDIF ;

: doMETA  (| cp0 up0 sp0 rp0 hp0 -- |)
        BASE-ADDRESS to OLD-BASE-ADDRESS                // 02/09/'97 modified
        cp0 to T-BASE-ADDRESS cp0 to BASE-ADDRESS       // 02/09/'97 modified

	SINGLE
	cp0 CP !   up0 TUP0 !                   // top down allocation
	hp0 HP !   sp0 TSP0 !   rp0 TRP0 !      // bottom up allocation
	cp0 |CODE&HEAD-SPACE    TCP0  !
	cp0 |COLD-VECTOR        ^COLD !
	cp0 |WORK-SPACE |TERMINAL-INPUT-BUFFER   T-TIB !

	CR ." Meta-compiling CF.4TH ..." CR
	ONLY FORTH DEFINITIONS

        FILENAMES OFF " CF0.4TH" $FLOAD
        FAIL-FLOAD @ IF
           ONLY FORTH DEFINITIONS
           OLD-BASE-ADDRESS to BASE-ADDRESS     // restore base address
           AUTOMETA_ARGV[1] 0 OVER !  // use it as error message buffer
           CRLF$ COUNT$+ " * META ERROR : Fail meta-compiling ." $+ 
           CRLF$ COUNT$+ " * Please leave system as soon as possible." $+ 
           BEEP$ COUNT$+ THROW
        ENDIF
	CR ." ... Finish meta-compiling" CR

	HEX ." Startup address = $" cp0 . CR
	cp0 COPY-LoaderEnviron

	CR ." New system starts ..." CR
        // $201C EXECUTE // current break_mark()'s address = $201C
        ^COLD @ @EXECUTE        // 02/07/'97, prevent the need of BYE'
        ;

: STARBAR       CR  50 FOR ASCII * EMIT NEXT ;

: META2                         // 02/09/'97 modified
	AUTOMETA @ IF
            AUTOMETA_ARGV[1] " FLOAD HI.4TH " $+ 
            AUTOSAVE @ IF    " FSAVE BYE" $+  ENDIF
            NULL$ 1 $+ DROP
        ENDIF
	CR CR CR STARBAR
	CR ." *          Meta  Compiling  ...  Pass 2           *"
	STARBAR CR CR CR CR

	CF-SYSTEM-BASE-ADDRESS
	CF-SYSTEM-BASE-ADDRESS |WORK-SPACE |USER-AREA
	CF-SYSTEM-BASE-ADDRESS |WORK-SPACE |END-DATA-STACK
	CF-SYSTEM-BASE-ADDRESS |WORK-SPACE |END-RETURN-STACK
	CF-SYSTEM-BASE-ADDRESS |WORK-SPACE |END-FORTH-VOCTABLE
	doMETA ;

: META1                         // 02/09/'97 modified
	AUTOMETA @ IF
            AUTOMETA_ARGV[1]
            " FLOAD HI.4TH NEEDS CPU80486.4TH WARNING OFF " $+
            " NEEDS CFMETA.4TH AUTOMETA ON " $+
            AUTOSAVE @ IF  " AUTOSAVE ON " $+   ENDIF
            " META2" $+  NULL$ 1  $+ DROP
        ENDIF
	CR CR CR STARBAR
	CR ." *          Meta  Compiling  ...  Pass 1           *"
	STARBAR CR CR CR CR

	HERE  ( cp0 )
	HP @  SIZEOF HighMemoryMap LITERAL - 8 K - >R
	R@ |USER-AREA           ( up0 )
	R@ |END-DATA-STACK      ( sp0 )
	R@ |END-RETURN-STACK    ( rp0 )
	R> |END-FORTH-VOCTABLE  ( hp0 )
	doMETA ;

: META     WARNING OFF AUTOMETA ON META1 ;      // 02/09/'97 modified
: METASAVE AUTOSAVE ON META ;                   // 02/09/'97

ONLY FORTH ALSO DEFINITIONS

// define user variable compilers
USER,   SUCCTASK,
USER,   SP-SAVED,
USER,   RP-SAVED,
USER,   PREVTASK,
USER,   SP0,
USER,   RP0,
USER,   '?KEY,
USER,   'EMIT,
USER,   'EXPECT,
USER,   'TAP,
USER,   'ECHO,
USER,   'PROMPT,
USER,   BASE,
USER,   tmp,
USER,   SPAN,
USER,   >IN,
USER,   #TIB,
USER,   'TIB,
USER,   CSP,
USER,   'EVAL,
USER,   'NUMBER,
USER,   HLD,
USER,   HANDLER,
USER,   CONTEXT,        |VOCS| ^UP +!
USER,   CURRENT,
USER,   VOC-LINK,
USER,   CP,
USER,   HP,
USER,   LAST,
USER,   STATE,
USER,   DPL,
USER,   'CONSOLE,
USER,   LastCalled,
USER,   'INTERPRETER,
USER,   'COMPILER,
USER,   'TYPE,
USER,   'AT,            // 08-16-95
USER,   'AT?,
USER,   'RESET-LIST,    // 08/22/'95
USER,   'UP>TASK,       // 10/10/'95
USER,   'LastQuit,      // 02/02/'97
USER,   'TOKEN,         // 02/08/'97

CR CR .( ****   Common Forth Meta-compiler loaded   ****)
CR .( Type "META" for automatic meta-compiling. ) CR CR

