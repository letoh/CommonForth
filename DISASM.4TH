// Disassembler Output                           Written by : Luke Lee
                                                //     Version : 1.5
                                                //      update : 09/19/'95
                                                //      update : 11/15/'96
                                                //      update : 01/24/'97 v1.5
                                                // Last update : 01/27/'97 v1.5

// This program require CPU80486.4TH for disassembler

// Output look :
//   CFASM-LOOK : Default value, the output is EXACTLY the same syntax
//                as you are writing CPU80486.4TH assembly.
//   MASM-LOOK  : Use this word and the outputs will looks like MASM
//                syntax.

NEEDS CPU80486.4TH      // 5/6/'94

DEFER DISASM1

HIDDEN ALSO DEFINITIONS

VARIABLE SHOW-CODES	// 1/15/'95 for SEE.4TH

ASSEMBLER ' TC@ ALIAS TargetC@ FORTH    // 08/14/'94

DEFER ShowOperand

VARIABLE SPACEAPPEND
VARIABLE OperandCount   // for MASM look

: ShowStr       ( adr -- )
        COUNT SWAP OVER TYPE 0> SPACEAPPEND @ AND IF SPACE ENDIF ;

: CurrMemonic   ( -- a )
        DisassembledInstruction .DisMemonic 1+ ;

: is-CALL?      ( -- T/F )
        CurrMemonic " CALL" COMP 0= ;

: is-JMP?       ( -- T/F )
        CurrMemonic " JMP" COMP 0= ;

: is-CALLF?     ( -- T/F )
        CurrMemonic " CALLF" COMP 0= ;

: is-JMPF?      ( -- T/F )
        CurrMemonic " JMPF" COMP 0= ;

: is-J(E)CXZ?   ( -- T/F )
        CurrMemonic " J(E)CXZ" COMP 0= ;

: not-JMPF/CALLF?  ( -- T/F )
        is-CALLF? ORELSE is-JMPF? ELSE-OR  NOT ;

: CF-ShowOperand   ( .opr -- )
        DUP .OperandType C@ 
        CASE
           RegisterOperand  OF  .RegName1 ShowStr SPACE       ENDOF
           ImmediateOperand OF  .AssocImmediate @ . ." # "    ENDOF
           AddressOperand   OF  .AssocImmediate @
                is-CALL? is-JMP? OR  ANDTHEN DUP CODE>HEAD 0<>  THEN-AND
                IF
                    DUP ." ' " >HEAD .ID SPACE // transform CFA to word name
                    ." ( " . ." ) "
                ELSE
                    .
                ENDIF
                ." # "                                           ENDOF
           MemoryOperand    OF
                DUP .OperandSize C@ CASE
                  $08  OF  ." BYTE^ "                            ENDOF
                  $10  OF  not-JMPF/CALLF? IF ." WORD^ " ENDIF   ENDOF
                  $20  OF  not-JMPF/CALLF? IF ." DWORD^ " ENDIF  ENDOF
                  $40  OF  ." QWORD^ "                           ENDOF
                ENDCASE
                >R ." { "
                R@ .RegName1 DUP ShowStr C@ 0<>
                R@ .RegName2 DUP ShowStr C@ 0<>
                DUP IF R@ .AssocScale C@
                    DUP 1 > IF  ." *" .  ELSE  DROP  ENDIF
                ENDIF
                2DUP AND IF ." + " ENDIF
                R> .AssocDisplacement @ DUP 0< IF
                     -ROT OR IF  ABS . ." - "  ELSE  ." -" ABS .  ENDIF
                ELSE DUP 0> IF
                     . OR IF ." + " ENDIF
                ELSE // 0=                              // 01/24/'97 modified
                     -ROT OR NOT IF  .  ELSE  DROP  ENDIF
                ENDIF ENDIF
                ." } "                                          ENDOF
          // Otherwise :
                DROP
        ENDCASE  ;

: MASM-H.       ( val -- )
        ASCII 0 EMIT . BKSPC ASCII H EMIT ;

: OperandCount++  ( -- )
        1 OperandCount +!
        OperandCount @ 1 > ANDTHEN not-JMPF/CALLF? THEN-AND
        IF  ASCII , EMIT  ENDIF ;

: MASM-ShowOperand   ( .opr -- )
        DUP .OperandType C@
        CASE
           RegisterOperand  OF  OperandCount++ .RegName1 ShowStr  ENDOF
           ImmediateOperand OF
                is-CALL? ORELSE is-JMP? ORELSE is-CALLF? ORELSE is-JMPF? 
                ELSE-OR  OperandCount @ 1 >= AND  IF
                    ASCII : EMIT 1 OperandCount +!
                ELSE
                    OperandCount++
                ENDIF
                .AssocImmediate @ MASM-H.                      ENDOF
           AddressOperand   OF  OperandCount++
                .AssocImmediate @
                is-CALL? is-JMP? OR  ANDTHEN  DUP CODE>HEAD 0<>  THEN-AND
                IF
                    DUP >HEAD .ID SPACE // transform CFA to word name
                    TAB ." ; "
                ENDIF
                MASM-H.                                         ENDOF
           MemoryOperand    OF   OperandCount++
                DUP .OperandSize C@ CASE
                  $08  OF  ." BYTE PTR "                            ENDOF
                  $10  OF  not-JMPF/CALLF? IF  ." WORD PTR " 
                           ELSE ." FAR " ENDIF                      ENDOF
                  $20  OF  not-JMPF/CALLF? IF ." DWORD PTR " 
                           ELSE ." FAR " ENDIF                      ENDOF
                  $40  OF  ." QWORD PTR "                           ENDOF
                ENDCASE
                >R ." ["
                R@ .RegName1 DUP ShowStr C@ 0<>         ( R1? )
                R@ .RegName2 DUP C@ 0<> ROT             ( R2 R2? R1? )
                OVER ANDTHEN DUP THEN-AND IF  ASCII + EMIT  ENDIF
                ROT ShowStr                             ( R2? R1? )
                OVER IF R@ .AssocScale C@
                    DUP 1 > IF  ." *" . BKSPC  ELSE  DROP  ENDIF
                ENDIF                                   ( R2? R1? )
                R> .AssocDisplacement @ DUP 0< IF
                     -ROT 2DROP ASCII - EMIT ABS MASM-H.
                ELSE DUP 0> IF
                     -ROT OR IF ASCII + EMIT ENDIF MASM-H.
                ELSE // 0=                              // 01/24/'97 modified
                     -ROT OR NOT IF  MASM-H.  ELSE  DROP  ENDIF
                ENDIF ENDIF
                ." ]"                                          ENDOF
          // Otherwise :
                DROP
        ENDCASE  ;

: ShowOperands  ( DisassembledInstruction -- )
        DUP .DisOperand1  ShowOperand
        DUP .DisOperand2  ShowOperand
        .DisOperand3  ShowOperand  ;

: PerformDisAsm ( ^code -- ^next )
        DUP DISASSEMBLE SWAP ( ^next ^code )
	SHOW-CODES @ IF	
	   BASE @ >R HEX
           DUP 6 U.R SPACE 
           BEGIN
              DUP TargetC@ 2 U.0R 1+
           2DUP = UNTIL DROP
           29 AT? DROP - DUP 0> IF  SPACES  ELSE  DROP  ENDIF SPACE // 01/27/'97
	   R> BASE !
	ELSE 
	   DROP
	ENDIF ;

: ShowPrefixes  ( DisassembledInstruction -- )
        DUP .DisPrefixName1 ShowStr
        DUP .DisPrefixName2 ShowStr
        DUP .DisPrefixName3 ShowStr
        .DisPrefixName4 ShowStr ;

: ShowMemonic   ( DisassembledInstruction -- )
        is-J(E)CXZ? IF
            DROP
            USE@ PrefixDisassembled @ 2 AND IF  $30 XOR ENDIF
            ( $10 XOR $30 = $20; $20 XOR $30 = $10 )
            $20 = IF
                ." JECXZ"
            ELSE
                ." JCXZ"
            ENDIF
        ELSE
            .DisMemonic ShowStr
        ENDIF ;
        
: CF-DISASM  ( ^code -- ^next )
        PerformDisAsm
        DisassembledInstruction 
	SYNTAX? PREFIX =  IF  DUP ShowMemonic TAB BKSPC ENDIF // 09/19/'95
        DUP ShowPrefixes
        DUP ShowOperands
        SYNTAX? POSTFIX = IF  ShowMemonic  ELSE  DROP  ENDIF ;

: MASM-DISASM  ( ^code -- ^next )
        OperandCount OFF
        PerformDisAsm
        DisassembledInstruction
        2 SPACES  // 01/27/'97 modified
        DUP ShowPrefixes
        is-CALLF? IF
           ." CALL"
        ELSE is-JMPF? IF
           ." JMP"
        ELSE
           DUP ShowMemonic
        ENDIF ENDIF TAB
        ShowOperands ;
        
FORTH DEFINITIONS

20 VALUE #INST

: CFASM-LOOK    ( -- ) // default
      // display output with CPU80486.4TH syntax
        SPACEAPPEND ON SHOW-CODES ON
        ['] CF-ShowOperand IS ShowOperand
        ['] CF-DISASM      IS DISASM1  ;

CFASM-LOOK

: MASM-LOOK     ( -- )
      // display output with MASM syntax
        SPACEAPPEND OFF SHOW-CODES ON
        ['] MASM-ShowOperand IS ShowOperand
        ['] MASM-DISASM      IS  DISASM1 ;

: U     ( addr -- addr' )
        CR BASE @ >R HEX
        #INST 0 ?DO 
             DISASM1 CR NUF? ?LEAVE
        LOOP R> BASE ! ;

: U16   ( addr -- addr' )       
       // disassemble with 16-bit addressing mode
        USE@ >R USE16 U R> USE! ;
: U32   ( addr -- addr' )
       // disassemble with 32-bit addressing mode
        USE@ >R USE32 U R> USE! ;

ONLY FORTH ALSO DEFINITIONS

CR 
.( * 80486 Disassembler loaded * ) CR
.(    Example:  ' FLOAD U ) CR
.( Note : If you want the outputs looks like MASM syntax, use MASM-LOOK ; ) CR
.(        the default setting is CFASM-LOOK ,that is, CPU80486.4TH syntax.) CR

