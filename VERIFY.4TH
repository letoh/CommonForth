// Verify assembled codes

HEX
USE32
// A
CR .( VERIFY-A)

CODE: VERIFY-A
        AAA
        AAD
        AAM
        AAS

        ADC     AL              34 #
        ADC     BH              34 #
        ADC     SI              34 #
        ADC     ESI             34 #

        ADD     CH              34 #
        ADD     SI              34 #
        ADD     ESI             34 #

        ADC     AX              1234 #
        ADC     BP              1234 #
        ADC     EAX             12345678 #
        ADC     ESP             12345678 #
        ADC     BYTE^ { EDX }   34 #
        ADC     WORD^ { EDX }   1234 #
        ADC     DWORD^ { EDX }  12341234 #
        ADC     { EDX }         12341234 #

        ADC     WORD^ { ESI EBX *8 + 1234432 + }     1234 #
        ADC     { ESI *4 EDX + 987655 - }   12344321 #
        ADC     SI              SP
        ADC     EBP             ESI
        ADC     EBP             EDX
        ADC     { BP SI + }     EDX
        ADC     { SI BP + }     EDX
        ADC     { ESP EBP + }   EDX
        ADC     { EBP EBP + }   EDX
        ADC     { EBP *2 }      EDX
        ADC     EDX             EBP
        ADC     EDX             { BP SI + }
        ADC     EDX             { SI BP + }
        ADC     EDX             { ESP EBP + }
        ADC     EDX             { EBP EBP + }
        ADC     EDX             { EBP *2 }
        ADC     AL              BYTE^ { ESI EDI + }
        ADC     BL              BYTE^ { ESI EDI + }
        ADC     DH              BYTE^ { ESI EDI + }
        ADC     BYTE^ { ESI EDI + }     AL
        ADC     BYTE^ { ESI EDI + }     BL
        ADC     BYTE^ { ESI EDI + }     DH


        ADD     { EDI EBX *4 + 12345678 + }     9ABCDEF0 #

        ADD     WORD^ { ESI EBX *8 + 1234432 + }     1234 #
        ADD     { ESI *4 EDX + 987655 - }   12344321 #
        ADD     SI              SP
        ADD     EBP             ESI
        ADD     EBP             EDX
        ADD     { BP SI + }     EDX
        ADD     { SI BP + }     EDX
        ADD     { ESP EBP + }   EDX
        ADD     { EBP EBP + }   EDX
        ADD     { EBP *2 }      EDX
        ADD     EDX             EBP
        ADD     EDX             { BP SI + }
        ADD     EDX             { SI BP + }
        ADD     EDX             { ESP EBP + }
        ADD     EDX             { EBP EBP + }
        ADD     EDX             { EBP *2 }
        ADD     AL              BYTE^ { ESI EDI + }
        ADD     BL              BYTE^ { ESI EDI + }
        ADD     DH              BYTE^ { ESI EDI + }
        ADD     BYTE^ { ESI EDI + }     AL
        ADD     BYTE^ { ESI EDI + }     BL
        ADD     BYTE^ { ESI EDI + }     DH

        ADD     CS: { EDI EBX *4 + 12345678 + }     ESP
        ADD     DS: { EDI EBX *4 + 12345678 + }     ESP
        ADD     ES: { EDI EBX *4 + 12345678 + }     ESP
        ADD     SS: { EDI EBX *4 + 12345678 + }     ESP
        ADD     FS: { EDI EBX *4 + 12345678 + }     ESP
        ADD     GS: { EDI EBX *4 + 12345678 + }     ESP

        MOV     EAX     CS: { 12345678 }
        MOV     EAX     DS: { 12345678 }
        MOV     EAX     ES: { 12345678 }
        MOV     EAX     SS: { 12345678 }
        MOV     EAX     FS: { 12345678 }
        MOV     EAX     GS: { 12345678 }

        ADD     { EDI EBX *4 + 12345678 + }  CS:    ESP
        ADD     { EDI EBX *4 + 12345678 + }  DS:    ESP
        ADD     { EDI EBX *4 + 12345678 + }  ES:    ESP
        ADD     { EDI EBX *4 + 12345678 + }  SS:    ESP
        ADD     { EDI EBX *4 + 12345678 + }  FS:    ESP
        ADD     { EDI EBX *4 + 12345678 + }  GS:    ESP

        ADD     { EDI EBX *4 + 12345678 + }         ESP    CS:
        ADD     { EDI EBX *4 + 12345678 + }         ESP    DS:
        ADD     { EDI EBX *4 + 12345678 + }         ESP    ES:
        ADD     { EDI EBX *4 + 12345678 + }         ESP    SS:
        ADD     { EDI EBX *4 + 12345678 + }         ESP    FS:
        ADD     { EDI EBX *4 + 12345678 + }         ESP    GS:

        ADD     CS:  ESP    { EDI EBX *4 + 12345678 + }
        ADD     DS:  ESP    { EDI EBX *4 + 12345678 + }
        ADD     ES:  ESP    { EDI EBX *4 + 12345678 + }
        ADD     SS:  ESP    { EDI EBX *4 + 12345678 + }
        ADD     FS:  ESP    { EDI EBX *4 + 12345678 + }
        ADD     GS:  ESP    { EDI EBX *4 + 12345678 + }

        ADD     ESP      CS:     { EDI EBX *4 + 12345678 + }
        ADD     ESP      DS:     { EDI EBX *4 + 12345678 + }
        ADD     ESP      ES:     { EDI EBX *4 + 12345678 + }
        ADD     ESP      SS:     { EDI EBX *4 + 12345678 + }
        ADD     ESP      FS:     { EDI EBX *4 + 12345678 + }
        ADD     ESP      GS:     { EDI EBX *4 + 12345678 + }

        ADD     ESP         { EDI EBX *4 + 12345678 + }  CS:
        ADD     ESP         { EDI EBX *4 + 12345678 + }  DS:
        ADD     ESP         { EDI EBX *4 + 12345678 + }  ES:
        ADD     ESP         { EDI EBX *4 + 12345678 + }  SS:
        ADD     ESP         { EDI EBX *4 + 12345678 + }  FS:
        ADD     ESP         { EDI EBX *4 + 12345678 + }  GS:

        AND     WORD^ { ESI EBX *8 + 1234432 + }     1234 #
        AND     { ESI *4 EDX + 987655 - }   12344321 #
        AND     SI              SP
        AND     EBP             ESI
        AND     EBP             EDX
        AND     { BP SI + }     EDX
        AND     { SI BP + }     EDX
        AND     { ESP EBP + }   EDX
        AND     { EBP EBP + }   EDX
        AND     { EBP *2 }      EDX
        AND     EDX             EBP
        AND     EDX             { BP SI + }
        AND     EDX             { SI BP + }
        AND     EDX             { ESP EBP + }
        AND     EDX             { EBP EBP + }
        AND     EDX             { EBP *2 }
        AND     AL              BYTE^ { ESI EDI + }
        AND     BL              BYTE^ { ESI EDI + }
        AND     DH              BYTE^ { ESI EDI + }
        AND     BYTE^ { ESI EDI + }     AL
        AND     BYTE^ { ESI EDI + }     BL
        AND     BYTE^ { ESI EDI + }     DH

        RET
;CODE

// B
CR .( VERIFY-B)

CODE: VERIFY-B
        BOUND   SI    WORD^ { ESP EBP + }
        BOUND   DI    WORD^ { SI BP + }
        BOUND   ECX   { ESI EBP *4 + 34 + }
        BOUND   ECX   { ESI *4 EBP + 12 + }
        BSF     DX    WORD^ { BX }
        BSF     ECX   { 1234 }
        BSF     ECX   { 12341234 }
        BSF     ESP   { ESI EDI + }
        BSR     DX    WORD^ { BX }
        BSR     ECX   { 1234 }
        BSR     ECX   { 12341234 }
        BSR     ESP   { ESI EDI + }
        BSWAP   EAX
        BSWAP   EDX
        BSWAP   ESI
        BSWAP   ESP
        BSWAP   DI
USE16
        BSWAP   EAX
        BSWAP   EDX
        BSWAP   ESI
        BSWAP   ESP
        BSWAP   DI
USE32
        BT      { 1234 }  ESI
        BT      DI        BX
        BT      BP        12 #
        BT      EAX       34 #
        RET
;CODE

// C
CR .( VERIFY-C)

CODE: VERIFY-C
     // near call
        CALL    ' VERIFY-B #
        CALL    { 1234 }
        CALL    { ESI EDI + }
        CALL    { ESI EDI + }
        CALL    EAX
        CALL    EBX
        CALL    ECX
        CALL    EDX
        CALL    { EAX }
        CALL    { EBX }
        CALL    { ECX }
        CALL    { EDX }
     // far call
        CALLF   { ESI EDI + }
        CALLF   1234 # 12344321 #

USE16
        CALLF   OS: 1234 # 4312 #
USE32

        CLTS

        CMP     AX              1234 #
        CMP     BP              1234 #
        CMP     EAX             12345678 #
        CMP     ESP             12345678 #
        CMP     AX              12 #
        CMP     BP              12 #
        CMP     EAX             12 #
        CMP     ESP             12 #
        CMP     BYTE^ { EDX }   34 #
        CMP     WORD^ { EDX }  1234 #
        CMP     DWORD^ { EDX }   12341234 #
        CMP     { EDX }         12341234 #
        CMP     WORD^ { ESI EBX *8 + 1234432 + }     1234 #
        CMP     { ESI *4 EDX + 987655 - }  12344321 #
        CMP     SI              SP
        CMP     EBP             ESI
        CMP     { BP SI + }     EDX
        CMP     { SI BP + }     EDX
        CMP     { ESP EBP + }   EDX
        CMP     { EBP EBP + }   EDX
        CMP     { EBP *2 }      EDX
        CMP     EDX             { BP SI + }
        CMP     EDX             { SI BP + }
        CMP     EDX             { ESP EBP + }
        CMP     EDX             { EBP EBP + }
        CMP     EDX             { EBP *2 }

        CMPXCHG     BYTE^ { ESI EDI + }     AL
        CMPXCHG     BYTE^ { SI BX + }       BL
        CMPXCHG     BYTE^ { BX DI + }       DH
        CMPXCHG     WORD^ { ESI EDI + }     AX
        CMPXCHG     WORD^ { SI BX + }       BX
        CMPXCHG     WORD^ { BX DI + }       DX
        CMPXCHG     DWORD^ { ESI EDI + }    EAX
        CMPXCHG     DWORD^ { SI BX + }      EBX
        CMPXCHG     DWORD^ { BX DI + }      EDX

        CBW
        CWDE
        CWD
        CDQ
        CMPSB
        CMPSW
        CMPSD
USE16
        CBW
        CWDE
        CWD
        CDQ
        CMPSB
        CMPSW
        CMPSD
USE32
        RET
        RET   12 #
;CODE


CR .( VERIFY-D)

CODE:  VERIFY-D
        DAA
        DAS
        DEC     EAX
        DEC     AX
        DEC     EBP
        DEC     BP
        DEC     CH
        DEC     DL
        DEC     BYTE^  { EDX ESI *4 + 21 + }
        DEC     WORD^ { EDX ESI *4 + 21 + }
        DEC     DWORD^  { EDX ESI *4 + 21 + }
        DIV     CL
        DIV     CX
        DIV     ESI
        DIV     EBP
        DIV     ESP
        DIV     BYTE^  { ESP EBP *4 + 1234 + }
        DIV     WORD^ { ESP EBP + 1234 + }
        DIV     DWORD^  { SI BP + 1234 + }
        RET
;CODE


CR .( VERIFY-E)

CODE: VERIFY-E
        ENTER   1234 # 12 #
        ENTER   23 #   0 #
        ENTER   3412 # 1 #
        RET
;CODE

CR .( VERIFY-F)

CODE: VERIFY-F
        F2XM1
        FABS

        FADD    DWORD^  { ESI EDI *4 + }
        FADD    QWORD^ { ESI EDI *4 + }
        FIADD   WORD^ { ESI EDI *4 + }
        FIADD   DWORD^  { ESI EDI *4 + }
        FADD    DWORD^  { SI BP + 12 + }
        FADD    QWORD^ { SI BP + 12 + }
        FIADD   WORD^ { SI BP + 12 + }
        FIADD   DWORD^  { SI BP + 12 + }
        FADD    ST(2)   ST
        FADD    ST(5)   ST
        FADD    ST      ST(2)
        FADD    ST      ST(5)
        FADD
        FADDP   ST(7)   ST
        FADDP   ST(3)   ST

        FBLD    TBYTE^ { BP SI + }
        FBLD    TBYTE^ { EBP ESI *8 + 1234 + }
        FBLD    TBYTE^ { BX }
        FBLD    TBYTE^ { EBX }

        FBSTP   TBYTE^ { BP SI + }
        FBSTP   TBYTE^ { EBP ESI *8 + 1234 + }
        FBSTP   TBYTE^ { BX }
        FBSTP   TBYTE^ { EBX }

        FCHS
        FNCLEX

        FCOM    DWORD^  { ESI EDI *4 + 1234 + }
        FCOM    QWORD^ { ESI EDI *4 + 1234 + }
        FCOM    ST(4)
        FCOM    ST(0)
        FCOM

        FCOMP   DWORD^  { ESI EDI *4 + 1234 + }
        FCOMP   QWORD^ { ESI EDI *4 + 1234 + }
        FCOMP   ST(4)
        FCOMP   ST(0)
        FCOMP
        FCOMPP

        FCOS
        FDECSTP

        FDIV    DWORD^  { ESI EDI *4 + }
        FDIV    QWORD^ { ESI EDI *4 + }
        FIDIV   WORD^ { ESI EDI *4 + }
        FIDIV   DWORD^  { ESI EDI *4 + }
        FDIV    DWORD^  { SI BP + 12 + }
        FDIV    QWORD^ { SI BP + 12 + }
        FIDIV   WORD^ { SI BP + 12 + }
        FIDIV   DWORD^  { SI BP + 12 + }
        FDIV    ST(2)   ST
        FDIV    ST(5)   ST
        FDIV    ST      ST(2)
        FDIV    ST      ST(5)
        FDIV
        FDIVP   ST(7)   ST
        FDIVP   ST(3)   ST

        FDIVR   DWORD^  { ESI EDI *4 + }
        FDIVR   QWORD^ { ESI EDI *4 + }
        FIDIVR  WORD^ { ESI EDI *4 + }
        FIDIVR  DWORD^  { ESI EDI *4 + }
        FDIVR   DWORD^  { SI BP + 12 + }
        FDIVR   QWORD^ { SI BP + 12 + }
        FIDIVR  WORD^ { SI BP + 12 + }
        FIDIVR  DWORD^  { SI BP + 12 + }
        FDIVR   ST(2)   ST
        FDIVR   ST(5)   ST
        FDIVR   ST      ST(2)
        FDIVR   ST      ST(5)
        FDIVR
        FDIVRP  ST(7)   ST
        FDIVRP  ST(3)   ST

        FFREE   ST
        FFREE   ST(1)
        FFREE   ST(7)

        FICOM   WORD^ { 2134 }
        FICOM   DWORD^ { 2134 }
        FICOMP  WORD^ { 2134 }
        FICOMP  DWORD^ { 2134 }

        FILD    WORD^ { ESI EBP *2 + 1234 + }
        FILD    DWORD^  { ESI EBP *2 + 1234 + }
        FILD    QWORD^ { ESI EBP *2 + 1234 + }
        FINCSTP
        FNINIT

        FIST    WORD^ { ESI EBP *2 + 1234 + }
        FIST    DWORD^  { ESI EBP *2 + 1234 + }
        FISTP   WORD^ { ESI EBP *2 + 1234 + }
        FISTP   DWORD^  { ESI EBP *2 + 1234 + }
        FISTP   QWORD^ { ESI EBP *2 + 1234 + }

        FLD     DWORD^ { ESP EBP + }
        FLD     QWORD^ { ESP EBP + }
        FLD     TBYTE^ { ESP EBP + }
        FLD     ST(2)
        FLD     ST
        FLD     ST(5)

        FLD1
        FLDL2T
        FLDL2E
        FLDPI
        FLDLG2
        FLDLN2
        FLDZ

        FLDCW   WORD^ { ESI EBP + }
        FLDENV  TBYTE^ { EDX EAX + }
        FLDENV  { EDX EAX + }

        FMUL    DWORD^  { ESI EDI *4 + }
        FMUL    QWORD^ { ESI EDI *4 + }
        FIMUL   WORD^ { ESI EDI *4 + }
        FIMUL   DWORD^  { ESI EDI *4 + }
        FMUL    DWORD^  { SI BP + 12 + }
        FMUL    QWORD^ { SI BP + 12 + }
        FIMUL   WORD^ { SI BP + 12 + }
        FIMUL   DWORD^  { SI BP + 12 + }
        FMUL    ST(2)   ST
        FMUL    ST(5)   ST
        FMUL    ST      ST(2)
        FMUL    ST      ST(5)
        FMUL
        FMULP   ST(7)   ST
        FMULP   ST(3)   ST

        FNOP
        FPATAN

        FPREM
        FPREM1
        FPTAN
        FRNDINT
        FRSTOR  { SI BP + }
        FRSTOR  { ESI EBP + }
        FNSAVE  { SI BP + }
        FNSAVE  { ESI EBP + }
        FSCALE
        FSIN
        FSINCOS

        FSQRT
        FST     { DWORD^ ESI }
        FST     { QWORD^ EBP }
        FST     ST(3)
        FSTP    { DWORD^ ESI }
        FSTP    { QWORD^ EBP }
        FSTP    ST(3)
        FSTP    { DWORD^ ESP }
        FSTP    { TBYTE^ ESP }

        FNSTCW  WORD^ { ESI ESP + }

        FNSTENV { EBP EDI + }

        FNSTSW  AX
        FNSTSW  WORD^ { BX }

        FSUB    DWORD^  { ESI EDI *4 + }
        FSUB    QWORD^ { ESI EDI *4 + }
        FISUB   WORD^ { ESI EDI *4 + }
        FISUB   DWORD^  { ESI EDI *4 + }
        FSUB    DWORD^  { SI BP + 12 + }
        FSUB    QWORD^ { SI BP + 12 + }
        FISUB   WORD^ { SI BP + 12 + }
        FISUB   DWORD^  { SI BP + 12 + }
        FSUB    ST(2)   ST
        FSUB    ST(5)   ST
        FSUB    ST      ST(2)
        FSUB    ST      ST(5)
        FSUB
        FSUBP   ST(7)   ST
        FSUBP   ST(3)   ST

        FSUBR   DWORD^  { ESI EDI *4 + }
        FSUBR   QWORD^ { ESI EDI *4 + }
        FISUBR  WORD^ { ESI EDI *4 + }
        FISUBR  DWORD^  { ESI EDI *4 + }
        FSUBR   DWORD^  { SI BP + 12 + }
        FSUBR   QWORD^ { SI BP + 12 + }
        FISUBR  WORD^ { SI BP + 12 + }
        FISUBR  DWORD^  { SI BP + 12 + }
        FSUBR   ST(2)   ST
        FSUBR   ST(5)   ST
        FSUBR   ST      ST(2)
        FSUBR   ST      ST(5)
        FSUBR
        FSUBRP  ST(7)   ST
        FSUBRP  ST(3)   ST

        FTST
        FUCOM   ST(5)
        FUCOM
        FUCOMP  ST(3)
        FUCOMP
        FUCOMPP
        FWAIT
        FXAM
        FXCH
        FXCH    ST(1)
        FXCH    ST(7)
        FXTRACT
        FYL2X
        FYL2XP1

      // Compound Instructions ( FWAIT + FNXXXX )
        FCLEX
        FINIT
        FSAVE   { ESI EBP + }
        FSTCW   WORD^ { ESI ESP + }
        FSTENV  { EBP EDI + }
        FSTSW   AX
        FSTSW   WORD^ { BX }

        RET
;CODE

CR .( VERIFY-I)

CODE: VERIFY-I
        HLT
        IDIV    CH
        IDIV    BYTE^ { ESI ESP + }
        IDIV    SI
        IDIV    WORD^ { BP SI + }
        IDIV    ESI
        IDIV    DWORD^ { EBP ESP + }

        IMUL    CH
        IMUL    BYTE^ { ESI ESP + }
        IMUL    SI
        IMUL    WORD^ { BP SI + }
        IMUL    ESI
        IMUL    DWORD^ { EBP ESP + }
        ADD     SI      DI
        IMUL    SI      DI
        ADD     ESI     EDI
        IMUL    ESI     EDI
        IMUL    SI      WORD^ { ESP }
        IMUL    SP      BP      21 #
        IMUL    ESP     EBP     21 #
        IMUL    DI      DI      12 #
        IMUL    ESI     ESI     12 #
        IMUL    SP      BP      1221 #
        IMUL    ESP     EBP     1221 #
        IMUL    DI      DI      1212 #
        IMUL    ESI     ESI     1212 #

        IN      AL      12 #
        IN      AX      12 #
        IN      EAX     12 #
        IN      AL      DX
        IN      AX      DX
        IN      EAX     DX

        INC     SI
        INC     ESP
        INC     BYTE^ { EDI }
        INC     WORD^ { ESP }
        INC     DWORD^ { ESP }

        INSB
        INSW
        INSD

        INT3
        INT     3 #
        INT     10 #
        INT     21 #
        INT     FF #
        INTO

        INVD

        INVLPG  { ESI }
        INVLPG  WORD^ { BX }
        INVLPG  DWORD^ { BX }
        INVLPG  TBYTE^ { EDI }
        INVLPG  TBYTE^ { BX }
        INVLPG  { EDI *4 ESP + 1234 + }

        IRET
        IRETD

        RET
;CODE

CR .( VERIFY-J  )

: TESTJMP
        ."  FINISH JMP" CR ;
.( ' TESTJMP = ) ' TESTJMP .
CODE: VERIFY-J
      // Near jump
        JMP     ' TESTJMP #
        JMP     ' .S #
        JMP     { 1234 }
        JMP     { ESI EDI + }
        JMP     { ESI EDI + }
        JMP     EAX
        JMP     EBX
        JMP     ECX
        JMP     EDX
        JMP     { EAX }
        JMP     { EBX }
        JMP     { ECX }
        JMP     { EDX }
      // Far jump
        JMPF    { ESI EDI + }
        JMPF    1234 # 4321 #
        JMPF    1234 # 12344321 #

USE16
        JMPF    OS: 1234 # 4312 #
USE32
        JECXZ   ' TESTJMP #
        JCXZ    ' TESTJMP #
        CMP     EAX     EBX

     >  IF
        AND     EAX     EBX
     ELSE
        AND     EAX     ECX
     ENDIF

        NOP
        NOP
        NOP

     BEGIN
        CMP     EAX     { ESI ESP + 1234 + }
     <= WHILE
        ADD     EAX     ESI
     REPEAT

        NOP
        NOP
        NOP

     BEGIN
        ADD     EAX     { ESI }
        CMP     { ESI } EDX
     U> UNTIL

        NOP
        NOP
        NOP

     BEGIN
        ADD     ESI     EDI
        ADD     ESI     EDI
        ADD     ESI     EDI
     AGAIN

        RET
;CODE

CR .( VERIFY-L)

: TESTLABEL ;

CODE: VERIFY-L
        LAHF

        LAR     SP      WORD^ { BP SI + }
        LAR     ESP     DWORD^ { EBP ESI + }

        LOOP    ' TESTLABEL #
        LOOPZ   ' TESTLABEL #
        LOOPNZ  ' TESTLABEL #

        LOOP    ' TESTLABEL # AS:
        LOOPZ   ' TESTLABEL # AS:
        LOOPNZ  ' TESTLABEL # AS:

        LOOP    ' TESTLABEL # OS:
        LOOPZ   ' TESTLABEL # OS:
        LOOPNZ  ' TESTLABEL # OS:

        LEA     ESI     BYTE^ { EBP ESP + 21 + }
        LEA     ESI     DWORD^ { EBP ESP + 21 + }
        LEA     ESI     WORD^ { SI 21 + }
        LEA     EBP     { 1234 }
        LEA     SI      WORD^ { EBP ESP + 21 + }
        LEA     SI      DWORD^ { EBP ESI + }
        LEA     SI      TBYTE^ { SI }
        LEA     BP      { 1234 }

        LEAVE
        LGDT    QWORD^ { EBP ESP + }
        LIDT    QWORD^ { ESP ESI + }
        LGDT    QWORD^ { BP SI + }
        LIDT    QWORD^ { SI }

        LDS     BX      { SI BP + }
        LDS     SI      { ESI EBP + }
        LDS     DI      { 1234 }
        LDS     EDI     { ESI EBP + }
        LDS     ESP     { ESP 1234 + }
        LDS     ESP     { 1234 }

        LES     BX      { SI BP + }
        LES     SI      { ESI EBP + }
        LES     DI      { 1234 }
        LES     EDI     { ESI EBP + }
        LES     ESP     { ESP 1234 + }
        LES     ESP     { 1234 }

        LSS     BX      { SI BP + }
        LSS     SI      { ESI EBP + }
        LSS     DI      { 1234 }
        LSS     EDI     { ESI EBP + }
        LSS     ESP     { ESP 1234 + }
        LSS     ESP     { 1234 }

        LFS     BX      { SI BP + }
        LFS     SI      { ESI EBP + }
        LFS     DI      { 1234 }
        LFS     EDI     { ESI EBP + }
        LFS     ESP     { ESP 1234 + }
        LFS     ESP     { 1234 }

        LGS     BX      { SI BP + }
        LGS     SI      { ESI EBP + }
        LGS     DI      { 1234 }
        LGS     EDI     { ESI EBP + }
        LGS     ESP     { ESP 1234 + }
        LGS     ESP     { 1234 }


        LLDT    SI
        LLDT    WORD^ { ESI EBP + }
        LLDT    WORD^ { BP SI + }

        LMSW    SI
        LMSW    WORD^ { ESI EBP + }
        LMSW    WORD^ { BP SI + }

        ADD     LOCK:   ESI     DWORD^ { EBP }

        LODSB
        LODSW
        LODSD

        LSL     ESI             ESP
        LSL     ESI     DWORD^ { EBX }

        LTR     SI
        LTR     WORD^ { BX }

        RET
;CODE

CR .( VERIFY-M)

CODE: VERIFY-M
        MOV     ESI        123 #
        MOV     LONG ESI        123 #
        MOV     DWORD^ { ESI }  1234 #

        MOV     BYTE^ { ESI }   DH
        MOV     WORD^ { ESP }   BX
        MOV     DWORD^ { EBP }  EBP

        MOV     DH      BYTE^ { ESI }
        MOV     BX      WORD^ { ESP }
        MOV     EBP     DWORD^ { EBP }

        MOV     BL      BYTE^ { 1234 }
        MOV     BX      WORD^ { 1234 }
        MOV     EBX     DWORD^ { 1234 }
        MOV     AL      BYTE^ { 1234 }
        MOV     AX      WORD^ { 1234 }
        MOV     EAX     DWORD^ { 1234 }

        MOV     BYTE^ { 1234 }  BL
        MOV     WORD^ { 1234 }  BX
        MOV     DWORD^ { 1234 } EBX
        MOV     BYTE^ { 1234 }  AL
        MOV     WORD^ { 1234 }  AX
        MOV     DWORD^ { 1234 } EAX

        MOV     BYTE^ { 1234123 }       BL
        MOV     WORD^ { 1234123 }       BX
        MOV     DWORD^ { 1234123 }      EBX
        MOV     BYTE^ { 1234123 }       AL
        MOV     WORD^ { 1234123 }       AX
        MOV     DWORD^ { 1234123 }      EAX

        MOV     DX      ES
        MOV     DX      DS
        MOV     SI      CS
        MOV     BP      SS
        MOV     DI      FS
        MOV     SP      GS

        MOV     ES      DX
        MOV     DS      DX
        MOV     CS      SI
        MOV     SS      BP
        MOV     FS      DI
        MOV     GS      SP

        MOV     AL      12 #
        MOV     AX      123 #
        MOV     EAX     1234 #
        MOV     CL      12 #
        MOV     CX      123 #
        MOV     ECX     1234 #

        MOV     BYTE^ { EBP ECX + }     12 #
        MOV     WORD^ { EBP ECX + }     123 #
        MOV     DWORD^ { EBP ECX + }    1234 #

        MOV     ESP             CR0
        MOV     ESP             CR2
        MOV     CR0             ESP
        MOV     CR2             ESP

        MOV     ESP             TR6
        MOV     ESP             TR7
        MOV     TR6             ESP
        MOV     TR7             ESP

        MOV     ESP             DR3
        MOV     ESP             DR7
        MOV     DR3             ESP
        MOV     DR7             ESP

        MOVSB
        MOVSW
        MOVSD

        MOVSX   DX      BYTE^ { ESP EBP + }
        MOVSX   EDX     BYTE^ { EBP ESP + }
        MOVSX   EDX     WORD^ { EBP ESP + }
        MOVSX   DX              AL
        MOVSX   EDX             AH
        MOVSX   EDX             SP
        MOVSX   EDX             DX

        MOVZX   DX      BYTE^ { ESP EBP + }
        MOVZX   EDX     BYTE^ { EBP ESP + }
        MOVZX   EDX     WORD^ { EBP ESP + }
        MOVZX   DX              AL
        MOVZX   EDX             AH
        MOVZX   EDX             SP
        MOVZX   EDX             DX


        MUL     CL
        MUL     CX
        MUL     ESI
        MUL     EBP
        MUL     ESP
        MUL     BYTE^  { EBP *4 ESP + 1234 + }
        MUL     WORD^ { ESP EBP + 1234 + }
        MUL     DWORD^  { SI BP + 1234 + }

RET
;CODE

CR .( VERIFY-N)

CODE: VERIFY-N
        NEG     EAX
        NEG     ESP
        NEG     BYTE^ { EBX }
        NEG     CH
        NEG     WORD^ { EBX }
        NEG     DWORD^ { EBX }

        NOT     EAX
        NOT     ESP
        NOT     BYTE^ { EBX }
        NOT     CH
        NOT     WORD^ { EBX }
        NOT     DWORD^ { EBX }

        NOP
        RET
;CODE

CR .( VERIFY-O)

CODE: VERIFY-O
        OR      AL              34 #
        OR      BH              34 #
        OR      SI              34 #
        OR      ESI             34 #

        OR      AX              1234 #
        OR      BP              1234 #
        OR      EAX             12345678 #
        OR      ESP             12345678 #
        OR      BYTE^ { EDX }   34 #
        OR      WORD^ { EDX }   1234 #
        OR      DWORD^ { EDX }  12341234 #
        OR      { EDX }         12341234 #

        OR      WORD^ { ESI EBX *8 + 1234432 + }     1234 #
        OR      { ESI *4 EDX + 987655 - }   12344321 #
        OR      SI              SP
        OR      EBP             ESI
        OR      EBP             EDX
        OR      { BP SI + }     EDX
        OR      { SI BP + }     EDX
        OR      { ESP EBP + }   EDX
        OR      { EBP EBP + }   EDX
        OR      { EBP *2 }      EDX
        OR      EDX             EBP
        OR      EDX             { BP SI + }
        OR      EDX             { SI BP + }
        OR      EDX             { ESP EBP + }
        OR      EDX             { EBP EBP + }
        OR      EDX             { EBP *2 }

        OUT     23 #            AL
        OUT     23 #            AX
        OUT     23 #            EAX
        OUT     DX              AL
        OUT     DX              AX
        OUT     DX              EAX

        OUTSB
        OUTSW
        OUTSD
        RET
;CODE

CR .( VERIFY-P)

CODE: VERIFY-P
        POP     WORD^ { ESP ESI + }
        POP     DWORD^ { ESP ESI + }
        POP     BP
        POP     CX
        POP     EBP
        POP     ECX
        POP     DS
        POP     ES
        POP     SS
        POP     FS
        POP     GS

        POPA
        POPAD

        POPF
        POPFD

        PUSH    WORD^ { ESP ESI + }
        PUSH    DWORD^ { ESP ESI + }
        PUSH    12 #
        PUSH    1234 #
   USE16
        PUSH    OS: 1234 #
   USE32
        PUSH    12344312 #
  // Note that in USE16 segment, if the immediate value is greater than
  // $FFFF, only the lower 16bits will be pushed in. If you want to push
  // a 32-bit immediate integer, write :
  //         USE32   OS: $12344321 # PUSH    USE16
        PUSH    BP
        PUSH    CX
        PUSH    EBP
        PUSH    ECX
        PUSH    CS
        PUSH    DS
        PUSH    ES
        PUSH    SS
        PUSH    FS
        PUSH    GS

        PUSHA
        PUSHAD

        PUSHF
        PUSHFD
        RET
;CODE

CR .( VERIFY-R)

CODE: VERIFY-R
        RCL     CL
        RCL     BH
        RCL     BYTE^ { EBP }
        RCL     CL      CL
        RCL     BH      CL
        RCL     BYTE^ { ESP EBP + }     CL

        RCL     BX
        RCL     WORD^ { BX }
        RCL     BX      CL
        RCL     WORD^ { EAX }   CL

        RCL     ESI
        RCL     DWORD^ { ESI }
        RCL     ESI     CL
        RCL     DWORD^ { ESI ECX + }    CL

        RCR     CL
        RCR     BH
        RCR     BYTE^ { EBP }
        RCR     CL      CL
        RCR     BH      CL
        RCR     BYTE^ { ESP EBP + }     CL

        RCR     BX
        RCR     WORD^ { BX }
        RCR     BX      CL
        RCR     WORD^ { EAX }   CL

        RCR     ESI
        RCR     DWORD^ { ESI }
        RCR     ESI     CL
        RCR     DWORD^ { ESI ECX + }    CL

        ROL     CL
        ROL     BH
        ROL     BYTE^ { EBP }
        ROL     CL      CL
        ROL     BH      CL
        ROL     BYTE^ { ESP EBP + }     CL

        ROL     BX
        ROL     WORD^ { BX }
        ROL     BX      CL
        ROL     WORD^ { EAX }   CL

        ROL     ESI
        ROL     DWORD^ { ESI }
        ROL     ESI     CL
        ROL     DWORD^ { ESI ECX + }    CL

        ROR     CL
        ROR     BH
        ROR     BYTE^ { EBP }
        ROR     CL      CL
        ROR     BH      CL
        ROR     BYTE^ { ESP EBP + }     CL

        ROR     BX
        ROR     WORD^ { BX }
        ROR     BX      CL
        ROR     WORD^ { EAX }   CL

        ROR     ESI
        ROR     DWORD^ { ESI }
        ROR     ESI     CL
        ROR     DWORD^ { ESI ECX + }    CL

        RET     1234 #
        RET
        RETF    1234 #
        RETF
;CODE

CR .( VERIFY-S)

CODE: VERIFY-S
        SAHF
        SAL     CL
        SAL     BH
        SAL     BYTE^ { EBP }
        SAL     CL      CL
        SAL     BH      CL
        SAL     BYTE^ { ESP EBP + }     CL

        SAL     BX
        SAL     WORD^ { BX }
        SAL     BX      CL
        SAL     WORD^ { EAX }   CL

        SAL     ESI
        SAL     DWORD^ { ESI }
        SAL     ESI     CL
        SAL     DWORD^ { ESI ECX + }    CL

        SAR     CL
        SAR     BH
        SAR     BYTE^ { EBP }
        SAR     CL      CL
        SAR     BH      CL
        SAR     BYTE^ { ESP EBP + }     CL

        SAR     BX
        SAR     WORD^ { BX }
        SAR     BX      CL
        SAR     WORD^ { EAX }   CL

        SAR     ESI
        SAR     DWORD^ { ESI }
        SAR     ESI     CL
        SAR     DWORD^ { ESI ECX + }    CL

        SHR     CL
        SHR     BH
        SHR     BYTE^ { EBP }
        SHR     CL      CL
        SHR     BH      CL
        SHR     BYTE^ { ESP EBP + }     CL

        SHR     BX
        SHR     WORD^ { BX }
        SHR     BX      CL
        SHR     WORD^ { EAX }   CL

        SHR     ESI
        SHR     DWORD^ { ESI }
        SHR     ESI     CL
        SHR     DWORD^ { ESI ECX + }    CL

        SBB     AL              34 #
        SBB     BH              34 #
        SBB     SI              34 #
        SBB     ESI             34 #

        SBB     CH              34 #
        SBB     SI              34 #
        SBB     ESI             34 #

        SBB     AX              1234 #
        SBB     BP              1234 #
        SBB     EAX             12345678 #
        SBB     ESP             12345678 #
        SBB     BYTE^ { EDX }   34 #
        SBB     WORD^ { EDX }   1234 #
        SBB     DWORD^ { EDX }  12341234 #
        SBB     { EDX }         12341234 #

        SBB     WORD^ { ESI EBX *8 + 1234432 + }     1234 #
        SBB     { ESI *4 EDX + 987655 - }   12344321 #
        SBB     SI              SP
        SBB     EBP             ESI
        SBB     EBP             EDX
        SBB     { BP SI + }     EDX
        SBB     { SI BP + }     EDX
        SBB     { ESP EBP + }   EDX
        SBB     { EBP EBP + }   EDX
        SBB     { EBP *2 }      EDX
        SBB     EDX             EBP
        SBB     EDX             { BP SI + }
        SBB     EDX             { SI BP + }
        SBB     EDX             { ESP EBP + }
        SBB     EDX             { EBP EBP + }
        SBB     EDX             { EBP *2 }

        SBB     { EDI EBX *4 + 12345678 + }     9ABCDEF0 #

        SCASB
        SCASW
        SCASD

        SETA    BYTE^ { EBX *4 ESP + 1234 + }
        SETA    CH
        SETAE   BYTE^ { EBX *4 ESP + 1234 + }
        SETAE   CH

        SETB    BYTE^ { EBX *4 ESP + 1234 + }
        SETB    CH
        SETBE   BYTE^ { EBX *4 ESP + 1234 + }
        SETBE   CH

        SETG    BYTE^ { EBX *4 ESP + 1234 + }
        SETG    CH
        SETGE   BYTE^ { EBX *4 ESP + 1234 + }
        SETGE   CH

        SETL    BYTE^ { EBX *4 ESP + 1234 + }
        SETL    CH
        SETLE   BYTE^ { EBX *4 ESP + 1234 + }
        SETLE   CH

        SETZ    BYTE^ { EBX *4 ESP + 1234 + }
        SETZ    CH

        SETNC   BYTE^ { EBX *4 ESP + 1234 + }
        SETNC   CH

        SETNZ   BYTE^ { EBX *4 ESP + 1234 + }
        SETNZ   CH

        SGDT    { BX 1234 + }
        SGDT    { EBX 1234 + }

        SIDT    { BX 1234 + }
        SIDT    { EBX 1234 + }

        SHLD    SI              BP              12 #
        SHLD    ESI             EBP             12 #
        SHLD    WORD^ { BX }    BX              12 #
        SHLD    DWORD^ { EBX }  EBX             12 #
        SHLD    SI              BP              CL
        SHLD    ESI             EBP             CL
        SHLD    WORD^ { BX }    BX              CL
        SHLD    DWORD^ { EBX }  EBX             CL

        SHRD    SI              BP              12 #
        SHRD    ESI             EBP             12 #
        SHRD    WORD^ { BX }    BX              12 #
        SHRD    DWORD^ { EBX }  EBX             12 #
        SHRD    SI              BP              CL
        SHRD    ESI             EBP             CL
        SHRD    WORD^ { BX }    BX              CL
        SHRD    DWORD^ { EBX }  EBX             CL

        SLDT    SI
        SLDT    WORD^ { SI }

        SMSW    SI
        SMSW    WORD^ { SI }

        STC
        STD
        STI

        STOSB
        STOSW
        STOSD

        STR     SI
        STR     WORD^ { SI }

        SUB     AL              34 #
        SUB     BH              34 #
        SUB     SI              34 #
        SUB     ESI             34 #

        SUB     CH              34 #
        SUB     SI              34 #
        SUB     ESI             34 #

        SUB     AX              1234 #
        SUB     BP              1234 #
        SUB     EAX             12345678 #
        SUB     ESP             12345678 #
        SUB     BYTE^ { EDX }   34 #
        SUB     WORD^ { EDX }   1234 #
        SUB     DWORD^ { EDX }  12341234 #
        SUB     { EDX }         12341234 #

        SUB     WORD^ { ESI EBX *8 + 1234432 + }     1234 #
        SUB     { ESI *4 EDX + 987655 - }   12344321 #
        SUB     SI              SP
        SUB     EBP             ESI
        SUB     EBP             EDX
        SUB     { BP SI + }     EDX
        SUB     { SI BP + }     EDX
        SUB     { ESP EBP + }   EDX
        SUB     { EBP EBP + }   EDX
        SUB     { EBP *2 }      EDX
        SUB     EDX             EBP
        SUB     EDX             { BP SI + }
        SUB     EDX             { SI BP + }
        SUB     EDX             { ESP EBP + }
        SUB     EDX             { EBP EBP + }
        SUB     EDX             { EBP *2 }

        SUB     { EDI EBX *4 + 12345678 + }     9ABCDEF0 #

        RET
;CODE

CR .( VERIFY-T )

CODE: VERIFY-T
        TEST    AL      23 #
        TEST    AX      123 #
        TEST    EAX     314 #
        TEST    BL      23 #
        TEST    BX      123 #
        TEST    EBX     314 #
        TEST    BL      CL
        TEST    BX      CX
        TEST    EBX     EDX
        TEST    BYTE^ { BX }    CL
        TEST    WORD^ { BX }    CX
        TEST    DWORD^ { EBX }  EDX
        RET
;CODE


CR .( VERIFY-V )

CODE: VERIFY-V
        VERR    WORD^ { EBP }
        VERR    DI
        VERW    WORD^ { EBP }
        VERW    DI
        RET
;CODE

CR .( VERIFY-W )

CODE: VERIFY-W
        WAIT
        WBINVD
        RET
;CODE

CR .( VERIFY-X )

CODE: VERIFY-X

        XADD    CL              DH
        XADD    BYTE^ { BX }    CH
        XADD    BX              SP
        XADD    WORD^ { EBP }   SP
        XADD    EBX             ESP
        XADD    DWORD^ { EBP }  ESP

        XLAT

        XOR     AL              34 #
        XOR     BH              34 #
        XOR     SI              34 #
        XOR     ESI             34 #

        XOR     CH              34 #
        XOR     SI              34 #
        XOR     ESI             34 #

        XOR     AX              1234 #
        XOR     BP              1234 #
        XOR     EAX             12345678 #
        XOR     ESP             12345678 #
        XOR     BYTE^ { EDX }   34 #
        XOR     WORD^ { EDX }   1234 #
        XOR     DWORD^ { EDX }  12341234 #
        XOR     { EDX }         12341234 #

        XOR     WORD^ { ESI EBX *8 + 1234432 + }     1234 #
        XOR     { ESI *4 EDX + 987655 - }   12344321 #
        XOR     SI              SP
        XOR     EBP             ESI
        XOR     EBP             EDX
        XOR     { BP SI + }     EDX
        XOR     { SI BP + }     EDX
        XOR     { ESP EBP + }   EDX
        XOR     { EBP EBP + }   EDX
        XOR     { EBP *2 }      EDX
        XOR     EDX             EBP
        XOR     EDX             { BP SI + }
        XOR     EDX             { SI BP + }
        XOR     EDX             { ESP EBP + }
        XOR     EDX             { EBP EBP + }
        XOR     EDX             { EBP *2 }

        XOR     { EDI EBX *4 + 12345678 + }     9ABCDEF0 #

        RET
;CODE

CR .( Verify Miscellaneous Facilities ) CR

.( 1. LONG option ) CR
CODE: VERIFY-LONG
        BEGIN
            NOP
            NOP
            NOP
        LONG AGAIN
        RET
;CODE

.( 2. Verify Global Labels and forward label reference ) CR

// Only JXX and CALL could use labels, LOOPXX has only 8 bits offset, cannot
// use global labels.

LABELS: L1: L2: L3: L4: L5:

CODE: VERIFY-LABEL
       // L1:    LOOP  .... this results an error, you cannot use global-label
                     // to perform an forward LOOPXX instruction
        JMP     L1:    // No '#' when labels are used
        NOP
        JZ      L1:
        JZ      L2:
        JZ      L3:
        JZ      L4:
        JZ      L5:
        NOP
        NOP
        JNS     L1:
        NOP
        NOP
  @@ L1:
        NOP
        JMP     L2:
        NOP
        J<=     L1:
        J<=     L2:
        J<=     L3:
        J<=     L4:
        J<=     L5:
        NOP
  @@ L2:
        JMP     L3:
        NOP
        JU<     L1:
        JU<     L2:
        JU<     L3:
        JU<     L4:
        JU<     L5:
        NOP
  @@ L3:
        JMP     L4:
        JECXZ   L1:     // JECXZ and JCXZ could handle 8-bit offset only
        JECXZ   L2:
        JECXZ   L3:
        JNZ     L4:
        NOP
  @@ L5:
        NOP
        NOP
        NOP
        LOOP    L5:     // but backward LOOPxx instructions are legal
        LOOPNZ  L5:
        LOOPZ   L5:
;CODE

: .SUCCESSFULLY
   BLIND-LABEL: L5:
   @@ L5:
        ." successfully ." ;

CODE: TEST-L5
        L5: CALL
        RET
;CODE

: LABEL-TEST
    @@ L4:
        CR ." * Label testing " TEST-L5 CR ;

LABEL-TEST

