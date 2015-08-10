// Meta compiler for Common Forth 1.6X
                                        // Version    :  1.66
                                        // Written by :  Luke Lee
                                        // Last update : 12/25/'95

     // Detail steps ( for manual meta-compilation ) :
     //   1. GO32 CF ................... ..... CF 1.6X, under MSDOS
     //   2. FLOAD CFMETA.4TH ................ loading this meta compiler
     //   3. AUTOMETA OFF .................... turn off autometa facility
     //   4. META1 ........................... start meta compiling pass 1
     //   5. FLOAD HI.4TH .................... after new system starts up
     //   6. FLOAD CFMETA.4TH ................ same as step 1.
     //   7. AUTOMETA OFF .................... same as step 3.
     //   8. META2 ........................... meta compiling pass 2
     //   9. FLOAD HI.4TH .................... for obtaining FSAVE ...etc.
     //  10. FSAVE BYE' ...................... save image and quit.

     // Quick steps ( for automatic meta-compilation ) :
     //   1. GO32 CF ......................... CF 1.6X, under MSDOS
     //   2. FLOAD CFMETA  ................... steps 2,4,5,6,8,9.
     //   3. FSAVE BYE' ...................... step 10.

ONLY FORTH ALSO DEFINITIONS

TRACER/RESET    // no tracing now 

NEEDS CPU80486.4TH

VARIABLE CPU
: .386  386 CPU ! ; IMMEDIATE
: .486  486 CPU ! ; IMMEDIATE
: CPU?  CPU @ ; IMMEDIATE
: .386? \ CPU? 386 = ; IMMEDIATE
: .486? \ CPU? 486 = ; IMMEDIATE

.386    // for 386 machines, modify this to .386

CR CR 
.( ********************************************* ) CR
.( ** Currently selecting .386 as target code ** ) CR
.( ********************************************* ) CR

VARIABLE AUTOMETA
AUTOMETA ON

: WriteCR (( T/F -- ))
        IF 13 Keyboard! DROP ENDIF ; 1 0 #PARMS

: WriteKeyboard (( str len -- T/F ))    // MUST BE ASCII string
      // Return FALSE if only partial string written.   
      // Return non-FALSE if complete string written.
        DUP 0> IF
           1- FOR 
              DUP C@ Keyboard!
              WHILE
                1+
           NEXT
                TRUE
              ELSE      // keyboard buffer full
                FALSE
              THEN
           NIP
        ELSE
           2DROP TRUE
        ENDIF ; 2 1 #PARMS
        
DECIMAL

1021        CONSTANT MAGIC-NUMBER  // key for hash function
#VOCS CELL* CONSTANT |VOCS|        // size of vocabulary stack
BASE-ADDRESS CONSTANT OLD-BASE-ADDRESS

VARIABLE T-TIB
VARIABLE ^UP
VARIABLE ^doUSER
// Variables initialized by META :
VARIABLE TCP0   VARIABLE TRP0   VARIABLE TSP0   VARIABLE TUP0
VARIABLE ^COLD

: USER, (( <string> -- )) // defining words for 'user variable compilers'
        CREATE ^UP @ , CELL ^UP +! IMMEDIATE
        DOES> ^doUSER @ DUP 0= ABORT" ^doUSER not initialized yet"
              compile,
              @ ,   0 1 #PARMS ; 0 0 #PARMS

: COPY-LoaderEnviron    (| newcp0 -- |)
        OLD-BASE-ADDRESS |INIT-ENVIRON
        newcp0 |INIT-ENVIRON    SIZEOF LoaderEnviron LITERAL   MOVE ;

: doMETA  (| cp0 up0 sp0 rp0 hp0 -- |)
        SINGLE
        cp0 CP !   up0 TUP0 !                   // top down allocation
        hp0 HP !   sp0 TSP0 !   rp0 TRP0 !      // bottom up allocation
        cp0 |CODE&HEAD-SPACE    TCP0  !
        cp0 |COLD-VECTOR        ^COLD !
        cp0 |WORK-SPACE |TERMINAL-INPUT-BUFFER   T-TIB !

        CR ." Meta-compiling CF.4TH ..." CR
        ONLY FORTH DEFINITIONS
        FILENAMES OFF   " CF0.4TH" $FLOAD
//      cp0 |INIT-ENVIRON   SIZEOF |INIT-ENVIRON LITERAL   0  FILL
        CR ." ... Finish meta-compiling" CR

        HEX ." Startup address = $" cp0 . CR
        cp0 COPY-LoaderEnviron

        CR ." New system starts ..." CR
        cp0 EXECUTE ;

: STARBAR       CR  50 FOR ASCII * EMIT NEXT ;

: META2 
        AUTOMETA @ IF  " FLOAD HI.4TH" WriteKeyboard WriteCR  ENDIF
        BASE-ADDRESS
        BASE-ADDRESS |WORK-SPACE |USER-AREA
        BASE-ADDRESS |WORK-SPACE |END-DATA-STACK
        BASE-ADDRESS |WORK-SPACE |END-RETURN-STACK
        BASE-ADDRESS |WORK-SPACE |END-FORTH-VOCTABLE
        CR CR CR STARBAR
        CR ." *          Meta  Compiling  ...  Pass 2           *"
        STARBAR CR CR CR CR
        doMETA ;

: META1
        AUTOMETA @ IF  " FLOAD META2" WriteKeyboard WriteCR   ENDIF
        HERE => BASE-ADDRESS
        HERE  (( cp0 ))  
	HP @  SIZEOF HighMemoryMap LITERAL - 8 K - >R
        R@ |USER-AREA		(( up0 ))
        R@ |END-DATA-STACK	(( sp0 ))
        R@ |END-RETURN-STACK	(( rp0 ))
        R> |END-FORTH-VOCTABLE	(( hp0 ))
        CR CR CR STARBAR
        CR ." *          Meta  Compiling  ...  Pass 1           *"
        STARBAR CR CR CR CR
        doMETA ;

: META  WARNING OFF META1 ;

POSTFIX SYNTAX

ASSEMBLER ALSO

// The following macros are used in kernel CF0.4TH

: $PUSHT
        EBP     { EBP CELL - }  LEA
        { EBP } EAX             MOV  
        ; IMMEDIATE

: $POPT // this routine takes 2 clock cycles in 80486 and 6 in 80386
        EAX     { EBP }         MOV
        EBP     { EBP CELL + }  LEA
        ; IMMEDIATE

: ??????        (( -- ? ? ? ? ? ? ))
        EBP   { EBP 6 CELL* - } LEA // allocate 6 cells
       { EBP 5 CELL* + }  EAX   MOV
        ; IMMEDIATE

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

CR CR .( ****   Common Forth Meta-compiler loaded   ****)
CR .( AUTOMETA is currently ON, turn it off for manual meta-compilation. )
CR .( Type "META" for meta-compiling. ) CR CR

