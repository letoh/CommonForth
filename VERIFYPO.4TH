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

        AL              34 #                            ADC
        BH              34 #                            ADC
        SI              34 #                            ADC
        ESI             34 #                            ADC

        CH              34 #                            ADD
        SI              34 #                            ADD
        ESI             34 #                            ADD

        AX              1234 #                          ADC
        BP              1234 #                          ADC
        EAX             12345678 #                      ADC
        ESP             12345678 #                      ADC
        BYTE^ { EDX }   34 #                            ADC
        WORD^ { EDX }   1234 #                          ADC
        DWORD^ { EDX }  12341234 #                      ADC
        { EDX }         12341234 #                      ADC

        WORD^ { ESI EBX *8 + 1234432 + }     1234 #     ADC
        { ESI *4 EDX + 987655 - }   12344321 #          ADC
        SI              SP                              ADC
        EBP             ESI                             ADC
        EBP             EDX                             ADC
        { BP SI + }     EDX                             ADC
        { SI BP + }     EDX                             ADC
        { ESP EBP + }   EDX                             ADC
        { EBP EBP + }   EDX                             ADC
        { EBP *2 }      EDX                             ADC
        EDX             EBP                             ADC
        EDX             { BP SI + }                     ADC
        EDX             { SI BP + }                     ADC
        EDX             { ESP EBP + }                   ADC
        EDX             { EBP EBP + }                   ADC
        EDX             { EBP *2 }                      ADC
        AL              BYTE^ { ESI EDI + }             ADC
        BL              BYTE^ { ESI EDI + }             ADC
        DH              BYTE^ { ESI EDI + }             ADC
        BYTE^ { ESI EDI + }     AL                      ADC
        BYTE^ { ESI EDI + }     BL                      ADC
        BYTE^ { ESI EDI + }     DH                      ADC


        { EDI EBX *4 + 12345678 + }     9ABCDEF0 #      ADD

        WORD^ { ESI EBX *8 + 1234432 + }     1234 #     ADD
        { ESI *4 EDX + 987655 - }   12344321 #          ADD
        SI              SP                              ADD
        EBP             ESI                             ADD
        EBP             EDX                             ADD
        { BP SI + }     EDX                             ADD
        { SI BP + }     EDX                             ADD
        { ESP EBP + }   EDX                             ADD
        { EBP EBP + }   EDX                             ADD
        { EBP *2 }      EDX                             ADD
        EDX             EBP                             ADD
        EDX             { BP SI + }                     ADD
        EDX             { SI BP + }                     ADD
        EDX             { ESP EBP + }                   ADD
        EDX             { EBP EBP + }                   ADD
        EDX             { EBP *2 }                      ADD
        AL              BYTE^ { ESI EDI + }             ADD
        BL              BYTE^ { ESI EDI + }             ADD
        DH              BYTE^ { ESI EDI + }             ADD
        BYTE^ { ESI EDI + }     AL                      ADD
        BYTE^ { ESI EDI + }     BL                      ADD
        BYTE^ { ESI EDI + }     DH                      ADD

    CS: { EDI EBX *4 + 12345678 + }     ESP             ADD
    DS: { EDI EBX *4 + 12345678 + }     ESP             ADD
    ES: { EDI EBX *4 + 12345678 + }     ESP             ADD
    SS: { EDI EBX *4 + 12345678 + }     ESP             ADD
    FS: { EDI EBX *4 + 12345678 + }     ESP             ADD
    GS: { EDI EBX *4 + 12345678 + }     ESP             ADD

    { EDI EBX *4 + 12345678 + }  CS:    ESP             ADD
    { EDI EBX *4 + 12345678 + }  DS:    ESP             ADD
    { EDI EBX *4 + 12345678 + }  ES:    ESP             ADD
    { EDI EBX *4 + 12345678 + }  SS:    ESP             ADD
    { EDI EBX *4 + 12345678 + }  FS:    ESP             ADD
    { EDI EBX *4 + 12345678 + }  GS:    ESP             ADD

    { EDI EBX *4 + 12345678 + }         ESP    CS:      ADD
    { EDI EBX *4 + 12345678 + }         ESP    DS:      ADD
    { EDI EBX *4 + 12345678 + }         ESP    ES:      ADD
    { EDI EBX *4 + 12345678 + }         ESP    SS:      ADD
    { EDI EBX *4 + 12345678 + }         ESP    FS:      ADD
    { EDI EBX *4 + 12345678 + }         ESP    GS:      ADD

    CS:  ESP    { EDI EBX *4 + 12345678 + }             ADD
    DS:  ESP    { EDI EBX *4 + 12345678 + }             ADD
    ES:  ESP    { EDI EBX *4 + 12345678 + }             ADD
    SS:  ESP    { EDI EBX *4 + 12345678 + }             ADD
    FS:  ESP    { EDI EBX *4 + 12345678 + }             ADD
    GS:  ESP    { EDI EBX *4 + 12345678 + }             ADD

    ESP      CS:     { EDI EBX *4 + 12345678 + }        ADD
    ESP      DS:     { EDI EBX *4 + 12345678 + }        ADD
    ESP      ES:     { EDI EBX *4 + 12345678 + }        ADD
    ESP      SS:     { EDI EBX *4 + 12345678 + }        ADD
    ESP      FS:     { EDI EBX *4 + 12345678 + }        ADD
    ESP      GS:     { EDI EBX *4 + 12345678 + }        ADD

    ESP         { EDI EBX *4 + 12345678 + }  CS:        ADD
    ESP         { EDI EBX *4 + 12345678 + }  DS:        ADD
    ESP         { EDI EBX *4 + 12345678 + }  ES:        ADD
    ESP         { EDI EBX *4 + 12345678 + }  SS:        ADD
    ESP         { EDI EBX *4 + 12345678 + }  FS:        ADD
    ESP         { EDI EBX *4 + 12345678 + }  GS:        ADD

        WORD^ { ESI EBX *8 + 1234432 + }     1234 #     AND
        { ESI *4 EDX + 987655 - }   12344321 #          AND
        SI              SP                              AND
        EBP             ESI                             AND
        EBP             EDX                             AND
        { BP SI + }     EDX                             AND
        { SI BP + }     EDX                             AND
        { ESP EBP + }   EDX                             AND
        { EBP EBP + }   EDX                             AND
        { EBP *2 }      EDX                             AND
        EDX             EBP                             AND
        EDX             { BP SI + }                     AND
        EDX             { SI BP + }                     AND
        EDX             { ESP EBP + }                   AND
        EDX             { EBP EBP + }                   AND
        EDX             { EBP *2 }                      AND
        AL              BYTE^ { ESI EDI + }             AND
        BL              BYTE^ { ESI EDI + }             AND
        DH              BYTE^ { ESI EDI + }             AND
        BYTE^ { ESI EDI + }     AL                      AND
        BYTE^ { ESI EDI + }     BL                      AND
        BYTE^ { ESI EDI + }     DH                      AND

                                                        RET
;CODE

// B
CR .( VERIFY-B)

CODE: VERIFY-B
        SI    WORD^ { ESP EBP + }       BOUND
        DI    WORD^ { SI BP + }         BOUND
        ECX   { ESI EBP *4 + 34 + }     BOUND
        ECX   { ESI *4 EBP + 12 + }     BOUND
        DX    WORD^ { BX }              BSF
        ECX   { 1234 }                  BSF
        ECX   { 12341234 }              BSF
        ESP   { ESI EDI + }             BSF
        DX    WORD^ { BX }              BSR
        ECX   { 1234 }                  BSR
        ECX   { 12341234 }              BSR
        ESP   { ESI EDI + }             BSR
        EAX                             BSWAP
        EDX                             BSWAP
        ESI                             BSWAP
        ESP                             BSWAP
        DI                              BSWAP
USE16
        EAX                             BSWAP
        EDX                             BSWAP
        ESI                             BSWAP
        ESP                             BSWAP
        DI                              BSWAP
USE32
        { 1234 }  ESI                   BT
        DI        BX                    BT
        BP        12 #                  BT
        EAX       34 #                  BT
                                        RET
;CODE

// C
CR .( VERIFY-C)

CODE: VERIFY-C
     // near call
        ' VERIFY-B #                                    CALL
        { 1234 }                                        CALL
        { ESI EDI + }                                   CALL
        { ESI EDI + }                                   CALL
        EAX                                             CALL
        EBX                                             CALL
        ECX                                             CALL
        EDX                                             CALL
        { EAX }                                         CALL
        { EBX }                                         CALL
        { ECX }                                         CALL
        { EDX }                                         CALL
     // far call
        { ESI EDI + }                                   CALLF
        1234 # 12344321 #                               CALLF

USE16
        OS: 1234 # 4312 #                               CALLF
USE32

                                                        CLTS

        AX              1234 #                          CMP
        BP              1234 #                          CMP
        EAX             12345678 #                      CMP
        ESP             12345678 #                      CMP
        AX              12 #                            CMP
        BP              12 #                            CMP
        EAX             12 #                            CMP
        ESP             12 #                            CMP
        BYTE^ { EDX }   34 #                            CMP
        WORD^ { EDX }  1234 #                           CMP
        DWORD^ { EDX }   12341234 #                     CMP
        { EDX }         12341234 #                      CMP
        WORD^ { ESI EBX *8 + 1234432 + }     1234 #     CMP
        { ESI *4 EDX + 987655 - }  12344321 #           CMP
        SI              SP                              CMP
        EBP             ESI                             CMP
        { BP SI + }     EDX                             CMP
        { SI BP + }     EDX                             CMP
        { ESP EBP + }   EDX                             CMP
        { EBP EBP + }   EDX                             CMP
        { EBP *2 }      EDX                             CMP
        EDX             { BP SI + }                     CMP
        EDX             { SI BP + }                     CMP
        EDX             { ESP EBP + }                   CMP
        EDX             { EBP EBP + }                   CMP
        EDX             { EBP *2 }                      CMP

        BYTE^ { ESI EDI + }     AL                      CMPXCHG
        BYTE^ { SI BX + }       BL                      CMPXCHG
        BYTE^ { BX DI + }       DH                      CMPXCHG
        WORD^ { ESI EDI + }     AX                      CMPXCHG
        WORD^ { SI BX + }       BX                      CMPXCHG
        WORD^ { BX DI + }       DX                      CMPXCHG
        DWORD^ { ESI EDI + }    EAX                     CMPXCHG
        DWORD^ { SI BX + }      EBX                     CMPXCHG
        DWORD^ { BX DI + }      EDX                     CMPXCHG

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
        12 #                                            RET
;CODE


CR .( VERIFY-D)

CODE:  VERIFY-D
                                        DAA
                                        DAS
        EAX                             DEC
        AX                              DEC
        EBP                             DEC
        BP                              DEC
        CH                              DEC
        DL                              DEC
        BYTE^  { EDX ESI *4 + 21 + }    DEC
        WORD^ { EDX ESI *4 + 21 + }     DEC
        DWORD^  { EDX ESI *4 + 21 + }   DEC
        CL                              DIV
        CX                              DIV
        ESI                             DIV
        EBP                             DIV
        ESP                             DIV
        BYTE^  { ESP EBP *4 + 1234 + }  DIV
        WORD^ { ESP EBP + 1234 + }      DIV
        DWORD^  { SI BP + 1234 + }      DIV
        RET
;CODE


CR .( VERIFY-E)

CODE: VERIFY-E
        1234 # 12 #             ENTER
        23 #   0 #              ENTER
        3412 # 1 #              ENTER
        RET
;CODE

CR .( VERIFY-F)

CODE: VERIFY-F
                                                F2XM1
                                                FABS

        DWORD^  { ESI EDI *4 + }                FADD
        QWORD^ { ESI EDI *4 + }                 FADD
        WORD^ { ESI EDI *4 + }                  FIADD
        DWORD^  { ESI EDI *4 + }                FIADD
        DWORD^  { SI BP + 12 + }                FADD
        QWORD^ { SI BP + 12 + }                 FADD
        WORD^ { SI BP + 12 + }                  FIADD
        DWORD^  { SI BP + 12 + }                FIADD
        ST(2)   ST                              FADD
        ST(5)   ST                              FADD
        ST      ST(2)                           FADD
        ST      ST(5)                           FADD
                                                FADD
        ST(7)   ST                              FADDP
        ST(3)   ST                              FADDP

        TBYTE^ { BP SI + }                      FBLD
        TBYTE^ { EBP ESI *8 + 1234 + }          FBLD
        TBYTE^ { BX }                           FBLD
        TBYTE^ { EBX }                          FBLD

        TBYTE^ { BP SI + }                      FBSTP
        TBYTE^ { EBP ESI *8 + 1234 + }          FBSTP
        TBYTE^ { BX }                           FBSTP
        TBYTE^ { EBX }                          FBSTP

                                                FCHS
                                                FNCLEX

        DWORD^  { ESI EDI *4 + 1234 + }         FCOM
        QWORD^ { ESI EDI *4 + 1234 + }          FCOM
        ST(4)                                   FCOM
        ST(0)                                   FCOM
                                                FCOM

        DWORD^  { ESI EDI *4 + 1234 + }         FCOMP
        QWORD^ { ESI EDI *4 + 1234 + }          FCOMP
        ST(4)                                   FCOMP
        ST(0)                                   FCOMP
                                                FCOMP
                                                FCOMPP

                                                FCOS
                                                FDECSTP

        DWORD^  { ESI EDI *4 + }                FDIV
        QWORD^ { ESI EDI *4 + }                 FDIV
        WORD^ { ESI EDI *4 + }                  FIDIV
        DWORD^  { ESI EDI *4 + }                FIDIV
        DWORD^  { SI BP + 12 + }                FDIV
        QWORD^ { SI BP + 12 + }                 FDIV
        WORD^ { SI BP + 12 + }                  FIDIV
        DWORD^  { SI BP + 12 + }                FIDIV
        ST(2)   ST                              FDIV
        ST(5)   ST                              FDIV
        ST      ST(2)                           FDIV
        ST      ST(5)                           FDIV
                                                FDIV
        ST(7)   ST                              FDIVP
        ST(3)   ST                              FDIVP

        DWORD^  { ESI EDI *4 + }                FDIVR
        QWORD^ { ESI EDI *4 + }                 FDIVR
        WORD^ { ESI EDI *4 + }                  FIDIVR
        DWORD^  { ESI EDI *4 + }                FIDIVR
        DWORD^  { SI BP + 12 + }                FDIVR
        QWORD^ { SI BP + 12 + }                 FDIVR
        WORD^ { SI BP + 12 + }                  FIDIVR
        DWORD^  { SI BP + 12 + }                FIDIVR
        ST(2)   ST                              FDIVR
        ST(5)   ST                              FDIVR
        ST      ST(2)                           FDIVR
        ST      ST(5)                           FDIVR
                                                FDIVR
        ST(7)   ST                              FDIVRP
        ST(3)   ST                              FDIVRP

        ST                                      FFREE
        ST(1)                                   FFREE
        ST(7)                                   FFREE

        WORD^ { 2134 }                          FICOM
        DWORD^ { 2134 }                         FICOM
        WORD^ { 2134 }                          FICOMP
        DWORD^ { 2134 }                         FICOMP

        WORD^ { ESI EBP *2 + 1234 + }           FILD
        DWORD^  { ESI EBP *2 + 1234 + }         FILD
        QWORD^ { ESI EBP *2 + 1234 + }          FILD
                                                FINCSTP
                                                FNINIT

        WORD^ { ESI EBP *2 + 1234 + }           FIST
        DWORD^  { ESI EBP *2 + 1234 + }         FIST
        WORD^ { ESI EBP *2 + 1234 + }           FISTP
        DWORD^  { ESI EBP *2 + 1234 + }         FISTP
        QWORD^ { ESI EBP *2 + 1234 + }          FISTP

        DWORD^ { ESP EBP + }                    FLD
        QWORD^ { ESP EBP + }                    FLD
        TBYTE^ { ESP EBP + }                    FLD
        ST(2)                                   FLD
        ST                                      FLD
        ST(5)                                   FLD

                                                FLD1
                                                FLDL2T
                                                FLDL2E
                                                FLDPI
                                                FLDLG2
                                                FLDLN2
                                                FLDZ

        WORD^ { ESI EBP + }                     FLDCW
        TBYTE^ { EDX EAX + }                    FLDENV
        { EDX EAX + }                           FLDENV

        DWORD^  { ESI EDI *4 + }                FMUL
        QWORD^ { ESI EDI *4 + }                 FMUL
        WORD^ { ESI EDI *4 + }                  FIMUL
        DWORD^  { ESI EDI *4 + }                FIMUL
        DWORD^  { SI BP + 12 + }                FMUL
        QWORD^ { SI BP + 12 + }                 FMUL
        WORD^ { SI BP + 12 + }                  FIMUL
        DWORD^  { SI BP + 12 + }                FIMUL
        ST(2)   ST                              FMUL
        ST(5)   ST                              FMUL
        ST      ST(2)                           FMUL
        ST      ST(5)                           FMUL
                                                FMUL
        ST(7)   ST                              FMULP
        ST(3)   ST                              FMULP

                                                FNOP
                                                FPATAN

                                                FPREM
                                                FPREM1
                                                FPTAN
                                                FRNDINT
        { SI BP + }                             FRSTOR
        { ESI EBP + }                           FRSTOR
        { SI BP + }                             FNSAVE
        { ESI EBP + }                           FNSAVE
                                                FSCALE
                                                FSIN
                                                FSINCOS

                                                FSQRT
        { DWORD^ ESI }                          FST
        { QWORD^ EBP }                          FST
        ST(3)                                   FST
        { DWORD^ ESI }                          FSTP
        { QWORD^ EBP }                          FSTP
        ST(3)                                   FSTP
        { DWORD^ ESP }                          FSTP
        { TBYTE^ ESP }                          FSTP

        WORD^ { ESI ESP + }                     FNSTCW

        { EBP EDI + }                           FNSTENV

        AX                                      FNSTSW
        WORD^ { BX }                            FNSTSW

        DWORD^  { ESI EDI *4 + }                FSUB
        QWORD^ { ESI EDI *4 + }                 FSUB
        WORD^ { ESI EDI *4 + }                  FISUB
        DWORD^  { ESI EDI *4 + }                FISUB
        DWORD^  { SI BP + 12 + }                FSUB
        QWORD^ { SI BP + 12 + }                 FSUB
        WORD^ { SI BP + 12 + }                  FISUB
        DWORD^  { SI BP + 12 + }                FISUB
        ST(2)   ST                              FSUB
        ST(5)   ST                              FSUB
        ST      ST(2)                           FSUB
        ST      ST(5)                           FSUB
                                                FSUB
        ST(7)   ST                              FSUBP
        ST(3)   ST                              FSUBP

        DWORD^  { ESI EDI *4 + }                FSUBR
        QWORD^ { ESI EDI *4 + }                 FSUBR
        WORD^ { ESI EDI *4 + }                  FISUBR
        DWORD^  { ESI EDI *4 + }                FISUBR
        DWORD^  { SI BP + 12 + }                FSUBR
        QWORD^ { SI BP + 12 + }                 FSUBR
        WORD^ { SI BP + 12 + }                  FISUBR
        DWORD^  { SI BP + 12 + }                FISUBR
        ST(2)   ST                              FSUBR
        ST(5)   ST                              FSUBR
        ST      ST(2)                           FSUBR
        ST      ST(5)                           FSUBR
                                                FSUBR
        ST(7)   ST                              FSUBRP
        ST(3)   ST                              FSUBRP

                                                FTST
        ST(5)                                   FUCOM
                                                FUCOM
        ST(3)                                   FUCOMP
                                                FUCOMP
                                                FUCOMPP
                                                FWAIT
                                                FXAM
                                                FXCH
        ST(1)                                   FXCH
        ST(7)                                   FXCH
                                                FXTRACT
                                                FYL2X
                                                FYL2XP1

                        // Compound Instructions ( FWAIT + FNXXXX )
                                                FCLEX
                                                FINIT
        { ESI EBP + }                           FSAVE
        WORD^ { ESI ESP + }                     FSTCW
        { EBP EDI + }                           FSTENV
        AX                                      FSTSW
        WORD^ { BX }                            FSTSW

                                                RET
;CODE

CR .( VERIFY-I)

CODE: VERIFY-I
                                        HLT
        CH                              IDIV
        BYTE^ { ESI ESP + }             IDIV
        SI                              IDIV
        WORD^ { BP SI + }               IDIV
        ESI                             IDIV
        DWORD^ { EBP ESP + }            IDIV

        CH                              IMUL
        BYTE^ { ESI ESP + }             IMUL
        SI                              IMUL
        WORD^ { BP SI + }               IMUL
        ESI                             IMUL
        DWORD^ { EBP ESP + }            IMUL
        SI      DI                      ADD
        SI      DI                      IMUL
        ESI     EDI                     ADD
        ESI     EDI                     IMUL
        SI      WORD^ { ESP }           IMUL
        SP      BP      21 #            IMUL
        ESP     EBP     21 #            IMUL
        DI      DI      12 #            IMUL
        ESI     ESI     12 #            IMUL
        SP      BP      1221 #          IMUL
        ESP     EBP     1221 #          IMUL
        DI      DI      1212 #          IMUL
        ESI     ESI     1212 #          IMUL

        AL      12 #                    IN
        AX      12 #                    IN
        EAX     12 #                    IN
        AL      DX                      IN
        AX      DX                      IN
        EAX     DX                      IN

        SI                              INC
        ESP                             INC
        BYTE^ { EDI }                   INC
        WORD^ { ESP }                   INC
        DWORD^ { ESP }                  INC

                                        INSB
                                        INSW
                                        INSD

                                        INT3
        3 #                             INT
        10 #                            INT
        21 #                            INT
        FF #                            INT
                                        INTO

                                        INVD

        { ESI }                         INVLPG
        WORD^ { BX }                    INVLPG
        DWORD^ { BX }                   INVLPG
        TBYTE^ { EDI }                  INVLPG
        TBYTE^ { BX }                   INVLPG
        { EDI *4 ESP + 1234 + }         INVLPG

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
        ' TESTJMP #                     JMP
        ' .S #                          JMP
        { 1234 }                        JMP
        { ESI EDI + }                   JMP
        { ESI EDI + }                   JMP
        EAX                             JMP
        EBX                             JMP
        ECX                             JMP
        EDX                             JMP
        { EAX }                         JMP
        { EBX }                         JMP
        { ECX }                         JMP
        { EDX }                         JMP
      // Far jump
        { ESI EDI + }                   JMPF
        1234 # 4321 #                   JMPF
        1234 # 12344321 #               JMPF

USE16
        OS: 1234 # 4312 #               JMPF
USE32
        ' TESTJMP #                     JECXZ
        ' TESTJMP #                     JCXZ
        EAX     EBX                     CMP
     >  IF
                EAX     EBX     AND
     ELSE
                EAX     ECX     AND
     ENDIF
        NOP
        NOP
        NOP
     BEGIN
        EAX     { ESI ESP + 1234 + }    CMP
     <= WHILE
        EAX     ESI     ADD
     REPEAT
        NOP
        NOP
        NOP
     BEGIN
        EAX     { ESI }         ADD
        { ESI } EDX             CMP
     U> UNTIL
        NOP
        NOP
        NOP
     BEGIN
        ESI     EDI     ADD
        ESI     EDI     ADD
        ESI     EDI     ADD
     AGAIN
                                        RET
;CODE

CR .( VERIFY-L)

: TESTLABEL ;

CODE: VERIFY-L
                                                LAHF

        SP      WORD^ { BP SI + }               LAR
        ESP     DWORD^ { EBP ESI + }            LAR

        ' TESTLABEL #                           LOOP
        ' TESTLABEL #                           LOOPZ
        ' TESTLABEL #                           LOOPNZ

        ' TESTLABEL # AS:                       LOOP
        ' TESTLABEL # AS:                       LOOPZ
        ' TESTLABEL # AS:                       LOOPNZ

        ' TESTLABEL # OS:                       LOOP
        ' TESTLABEL # OS:                       LOOPZ
        ' TESTLABEL # OS:                       LOOPNZ

        ESI     BYTE^ { EBP ESP + 21 + }        LEA
        ESI     DWORD^ { EBP ESP + 21 + }       LEA
        ESI     WORD^ { SI 21 + }               LEA
        EBP     { 1234 }                        LEA
        SI      WORD^ { EBP ESP + 21 + }        LEA
        SI      DWORD^ { EBP ESI + }            LEA
        SI      TBYTE^ { SI }                   LEA
        BP      { 1234 }                        LEA

                                                LEAVE
        QWORD^ { EBP ESP + }                    LGDT
        QWORD^ { ESP ESI + }                    LIDT
        QWORD^ { BP SI + }                      LGDT
        QWORD^ { SI }                           LIDT

        BX      { SI BP + }                     LDS
        SI      { ESI EBP + }                   LDS
        DI      { 1234 }                        LDS
        EDI     { ESI EBP + }                   LDS
        ESP     { ESP 1234 + }                  LDS
        ESP     { 1234 }                        LDS

        BX      { SI BP + }                     LES
        SI      { ESI EBP + }                   LES
        DI      { 1234 }                        LES
        EDI     { ESI EBP + }                   LES
        ESP     { ESP 1234 + }                  LES
        ESP     { 1234 }                        LES

        BX      { SI BP + }                     LSS
        SI      { ESI EBP + }                   LSS
        DI      { 1234 }                        LSS
        EDI     { ESI EBP + }                   LSS
        ESP     { ESP 1234 + }                  LSS
        ESP     { 1234 }                        LSS

        BX      { SI BP + }                     LFS
        SI      { ESI EBP + }                   LFS
        DI      { 1234 }                        LFS
        EDI     { ESI EBP + }                   LFS
        ESP     { ESP 1234 + }                  LFS
        ESP     { 1234 }                        LFS

        BX      { SI BP + }                     LGS
        SI      { ESI EBP + }                   LGS
        DI      { 1234 }                        LGS
        EDI     { ESI EBP + }                   LGS
        ESP     { ESP 1234 + }                  LGS
        ESP     { 1234 }                        LGS


        SI                                      LLDT
        WORD^ { ESI EBP + }                     LLDT
        WORD^ { BP SI + }                       LLDT

        SI                                      LMSW
        WORD^ { ESI EBP + }                     LMSW
        WORD^ { BP SI + }                       LMSW

        LOCK:   ESI     DWORD^ { EBP }          ADD

                                                LODSB
                                                LODSW
                                                LODSD

        ESI             ESP                     LSL
        ESI     DWORD^ { EBX }                  LSL

        SI                                      LTR
        WORD^ { BX }                            LTR

                                                RET
;CODE

CR .( VERIFY-M)

CODE: VERIFY-M
             ESI        123 #           MOV
        LONG ESI        123 #           MOV
        DWORD^ { ESI }  1234 #          MOV

        BYTE^ { ESI }   DH              MOV
        WORD^ { ESP }   BX              MOV
        DWORD^ { EBP }  EBP             MOV

        DH      BYTE^ { ESI }           MOV
        BX      WORD^ { ESP }           MOV
        EBP     DWORD^ { EBP }          MOV

        BL      BYTE^ { 1234 }          MOV
        BX      WORD^ { 1234 }          MOV
        EBX     DWORD^ { 1234 }         MOV
        AL      BYTE^ { 1234 }          MOV
        AX      WORD^ { 1234 }          MOV
        EAX     DWORD^ { 1234 }         MOV

        BYTE^ { 1234 }  BL              MOV
        WORD^ { 1234 }  BX              MOV
        DWORD^ { 1234 } EBX             MOV
        BYTE^ { 1234 }  AL              MOV
        WORD^ { 1234 }  AX              MOV
        DWORD^ { 1234 } EAX             MOV

        BYTE^ { 1234123 }       BL      MOV
        WORD^ { 1234123 }       BX      MOV
        DWORD^ { 1234123 }      EBX     MOV
        BYTE^ { 1234123 }       AL      MOV
        WORD^ { 1234123 }       AX      MOV
        DWORD^ { 1234123 }      EAX     MOV

        DX      ES                      MOV
        DX      DS                      MOV
        SI      CS                      MOV
        BP      SS                      MOV
        DI      FS                      MOV
        SP      GS                      MOV

        ES      DX                      MOV
        DS      DX                      MOV
        CS      SI                      MOV
        SS      BP                      MOV
        FS      DI                      MOV
        GS      SP                      MOV

        AL      12 #                    MOV
        AX      123 #                   MOV
        EAX     1234 #                  MOV
        CL      12 #                    MOV
        CX      123 #                   MOV
        ECX     1234 #                  MOV

        BYTE^ { EBP ECX + }     12 #    MOV
        WORD^ { EBP ECX + }     123 #   MOV
        DWORD^ { EBP ECX + }    1234 #  MOV

        ESP             CR0             MOV
        ESP             CR2             MOV
        CR0             ESP             MOV
        CR2             ESP             MOV

        ESP             TR6             MOV
        ESP             TR7             MOV
        TR6             ESP             MOV
        TR7             ESP             MOV

        ESP             DR3             MOV
        ESP             DR7             MOV
        DR3             ESP             MOV
        DR7             ESP             MOV

                                        MOVSB
                                        MOVSW
                                        MOVSD

        DX      BYTE^ { ESP EBP + }     MOVSX
        EDX     BYTE^ { EBP ESP + }     MOVSX
        EDX     WORD^ { EBP ESP + }     MOVSX
        DX              AL              MOVSX
        EDX             AH              MOVSX
        EDX             SP              MOVSX
        EDX             DX              MOVSX

        DX      BYTE^ { ESP EBP + }     MOVZX
        EDX     BYTE^ { EBP ESP + }     MOVZX
        EDX     WORD^ { EBP ESP + }     MOVZX
        DX              AL              MOVZX
        EDX             AH              MOVZX
        EDX             SP              MOVZX
        EDX             DX              MOVZX


        CL                              MUL
        CX                              MUL
        ESI                             MUL
        EBP                             MUL
        ESP                             MUL
        BYTE^  { EBP *4 ESP + 1234 + }  MUL
        WORD^ { ESP EBP + 1234 + }      MUL
        DWORD^  { SI BP + 1234 + }      MUL

                                        RET
;CODE

CR .( VERIFY-N)

CODE: VERIFY-N
        EAX                     NEG
        ESP                     NEG
        BYTE^ { EBX }           NEG
        CH                      NEG
        WORD^ { EBX }           NEG
        DWORD^ { EBX }          NEG

        EAX                     NOT
        ESP                     NOT
        BYTE^ { EBX }           NOT
        CH                      NOT
        WORD^ { EBX }           NOT
        DWORD^ { EBX }          NOT

                                NOP
                                RET
;CODE

CR .( VERIFY-O)

CODE: VERIFY-O
        AL              34 #                            OR
        BH              34 #                            OR
        SI              34 #                            OR
        ESI             34 #                            OR

        AX              1234 #                          OR
        BP              1234 #                          OR
        EAX             12345678 #                      OR
        ESP             12345678 #                      OR
        BYTE^ { EDX }   34 #                            OR
        WORD^ { EDX }   1234 #                          OR
        DWORD^ { EDX }  12341234 #                      OR
        { EDX }         12341234 #                      OR

        WORD^ { ESI EBX *8 + 1234432 + }     1234 #     OR
        { ESI *4 EDX + 987655 - }   12344321 #          OR
        SI              SP                              OR
        EBP             ESI                             OR
        EBP             EDX                             OR
        { BP SI + }     EDX                             OR
        { SI BP + }     EDX                             OR
        { ESP EBP + }   EDX                             OR
        { EBP EBP + }   EDX                             OR
        { EBP *2 }      EDX                             OR
        EDX             EBP                             OR
        EDX             { BP SI + }                     OR
        EDX             { SI BP + }                     OR
        EDX             { ESP EBP + }                   OR
        EDX             { EBP EBP + }                   OR
        EDX             { EBP *2 }                      OR

        23 #            AL                              OUT
        23 #            AX                              OUT
        23 #            EAX                             OUT
        DX              AL                              OUT
        DX              AX                              OUT
        DX              EAX                             OUT

                                                        OUTSB
                                                        OUTSW
                                                        OUTSD
                                                        RET
;CODE

CR .( VERIFY-P)

CODE: VERIFY-P
        WORD^ { ESP ESI + }                             POP
        DWORD^ { ESP ESI + }                            POP
        BP                                              POP
        CX                                              POP
        EBP                                             POP
        ECX                                             POP
        DS                                              POP
        ES                                              POP
        SS                                              POP
        FS                                              POP
        GS                                              POP

                                                        POPA
                                                        POPAD

                                                        POPF
                                                        POPFD

        WORD^ { ESP ESI + }                             PUSH
        DWORD^ { ESP ESI + }                            PUSH
        12 #                                            PUSH
        1234 #                                          PUSH
   USE16
        OS: 1234 #                                      PUSH
   USE32
        12344312 #                                      PUSH
  // Note that in USE16 segment, if the immediate value is greater than
  // $FFFF, only the lower 16bits will be pushed in. If you want to push
  // a 32-bit immediate integer, write :
  //         USE32   OS: $12344321 # PUSH    USE16
        BP                                              PUSH
        CX                                              PUSH
        EBP                                             PUSH
        ECX                                             PUSH
        CS                                              PUSH
        DS                                              PUSH
        ES                                              PUSH
        SS                                              PUSH
        FS                                              PUSH
        GS                                              PUSH

                                                        PUSHA
                                                        PUSHAD

                                                        PUSHF
                                                        PUSHFD
                                                        RET
;CODE

CR .( VERIFY-R)

CODE: VERIFY-R
        CL                              RCL
        BH                              RCL
        BYTE^ { EBP }                   RCL
        CL      CL                      RCL
        BH      CL                      RCL
        BYTE^ { ESP EBP + }     CL      RCL

        BX                              RCL
        WORD^ { BX }                    RCL
        BX      CL                      RCL
        WORD^ { EAX }   CL              RCL

        ESI                             RCL
        DWORD^ { ESI }                  RCL
        ESI     CL                      RCL
        DWORD^ { ESI ECX + }    CL      RCL

        CL                              RCR
        BH                              RCR
        BYTE^ { EBP }                   RCR
        CL      CL                      RCR
        BH      CL                      RCR
        BYTE^ { ESP EBP + }     CL      RCR

        BX                              RCR
        WORD^ { BX }                    RCR
        BX      CL                      RCR
        WORD^ { EAX }   CL              RCR

        ESI                             RCR
        DWORD^ { ESI }                  RCR
        ESI     CL                      RCR
        DWORD^ { ESI ECX + }    CL      RCR

        CL                              ROL
        BH                              ROL
        BYTE^ { EBP }                   ROL
        CL      CL                      ROL
        BH      CL                      ROL
        BYTE^ { ESP EBP + }     CL      ROL

        BX                              ROL
        WORD^ { BX }                    ROL
        BX      CL                      ROL
        WORD^ { EAX }   CL              ROL

        ESI                             ROL
        DWORD^ { ESI }                  ROL
        ESI     CL                      ROL
        DWORD^ { ESI ECX + }    CL      ROL

        CL                              ROR
        BH                              ROR
        BYTE^ { EBP }                   ROR
        CL      CL                      ROR
        BH      CL                      ROR
        BYTE^ { ESP EBP + }     CL      ROR

        BX                              ROR
        WORD^ { BX }                    ROR
        BX      CL                      ROR
        WORD^ { EAX }   CL              ROR

        ESI                             ROR
        DWORD^ { ESI }                  ROR
        ESI     CL                      ROR
        DWORD^ { ESI ECX + }    CL      ROR

        1234 #                          RET
                                        RET
        1234 #                          RETF
                                        RETF
;CODE

CR .( VERIFY-S)

CODE: VERIFY-S
                                                        SAHF
        CL                                              SAL
        BH                                              SAL
        BYTE^ { EBP }                                   SAL
        CL      CL                                      SAL
        BH      CL                                      SAL
        BYTE^ { ESP EBP + }     CL                      SAL

        BX                                              SAL
        WORD^ { BX }                                    SAL
        BX      CL                                      SAL
        WORD^ { EAX }   CL                              SAL

        ESI                                             SAL
        DWORD^ { ESI }                                  SAL
        ESI     CL                                      SAL
        DWORD^ { ESI ECX + }    CL                      SAL

        CL                                              SAR
        BH                                              SAR
        BYTE^ { EBP }                                   SAR
        CL      CL                                      SAR
        BH      CL                                      SAR
        BYTE^ { ESP EBP + }     CL                      SAR

        BX                                              SAR
        WORD^ { BX }                                    SAR
        BX      CL                                      SAR
        WORD^ { EAX }   CL                              SAR

        ESI                                             SAR
        DWORD^ { ESI }                                  SAR
        ESI     CL                                      SAR
        DWORD^ { ESI ECX + }    CL                      SAR

        CL                                              SHR
        BH                                              SHR
        BYTE^ { EBP }                                   SHR
        CL      CL                                      SHR
        BH      CL                                      SHR
        BYTE^ { ESP EBP + }     CL                      SHR

        BX                                              SHR
        WORD^ { BX }                                    SHR
        BX      CL                                      SHR
        WORD^ { EAX }   CL                              SHR

        ESI                                             SHR
        DWORD^ { ESI }                                  SHR
        ESI     CL                                      SHR
        DWORD^ { ESI ECX + }    CL                      SHR

        AL              34 #                            SBB
        BH              34 #                            SBB
        SI              34 #                            SBB
        ESI             34 #                            SBB

        CH              34 #                            SBB
        SI              34 #                            SBB
        ESI             34 #                            SBB

        AX              1234 #                          SBB
        BP              1234 #                          SBB
        EAX             12345678 #                      SBB
        ESP             12345678 #                      SBB
        BYTE^ { EDX }   34 #                            SBB
        WORD^ { EDX }   1234 #                          SBB
        DWORD^ { EDX }  12341234 #                      SBB
        { EDX }         12341234 #                      SBB

        WORD^ { ESI EBX *8 + 1234432 + }     1234 #     SBB
        { ESI *4 EDX + 987655 - }   12344321 #          SBB
        SI              SP                              SBB
        EBP             ESI                             SBB
        EBP             EDX                             SBB
        { BP SI + }     EDX                             SBB
        { SI BP + }     EDX                             SBB
        { ESP EBP + }   EDX                             SBB
        { EBP EBP + }   EDX                             SBB
        { EBP *2 }      EDX                             SBB
        EDX             EBP                             SBB
        EDX             { BP SI + }                     SBB
        EDX             { SI BP + }                     SBB
        EDX             { ESP EBP + }                   SBB
        EDX             { EBP EBP + }                   SBB
        EDX             { EBP *2 }                      SBB

        { EDI EBX *4 + 12345678 + }     9ABCDEF0 #      SBB

                                                        SCASB
                                                        SCASW
                                                        SCASD

        BYTE^ { EBX *4 ESP + 1234 + }                   SETA
        CH                                              SETA
        BYTE^ { EBX *4 ESP + 1234 + }                   SETAE
        CH                                              SETAE

        BYTE^ { EBX *4 ESP + 1234 + }                   SETB
        CH                                              SETB
        BYTE^ { EBX *4 ESP + 1234 + }                   SETBE
        CH                                              SETBE

        BYTE^ { EBX *4 ESP + 1234 + }                   SETG
        CH                                              SETG
        BYTE^ { EBX *4 ESP + 1234 + }                   SETGE
        CH                                              SETGE

        BYTE^ { EBX *4 ESP + 1234 + }                   SETL
        CH                                              SETL
        BYTE^ { EBX *4 ESP + 1234 + }                   SETLE
        CH                                              SETLE

        BYTE^ { EBX *4 ESP + 1234 + }                   SETZ
        CH                                              SETZ

        BYTE^ { EBX *4 ESP + 1234 + }                   SETNC
        CH                                              SETNC

        BYTE^ { EBX *4 ESP + 1234 + }                   SETNZ
        CH                                              SETNZ

        { BX 1234 + }                                   SGDT
        { EBX 1234 + }                                  SGDT

        { BX 1234 + }                                   SIDT
        { EBX 1234 + }                                  SIDT

        SI              BP              12 #            SHLD
        ESI             EBP             12 #            SHLD
        WORD^ { BX }    BX              12 #            SHLD
        DWORD^ { EBX }  EBX             12 #            SHLD
        SI              BP              CL              SHLD
        ESI             EBP             CL              SHLD
        WORD^ { BX }    BX              CL              SHLD
        DWORD^ { EBX }  EBX             CL              SHLD

        SI              BP              12 #            SHRD
        ESI             EBP             12 #            SHRD
        WORD^ { BX }    BX              12 #            SHRD
        DWORD^ { EBX }  EBX             12 #            SHRD
        SI              BP              CL              SHRD
        ESI             EBP             CL              SHRD
        WORD^ { BX }    BX              CL              SHRD
        DWORD^ { EBX }  EBX             CL              SHRD

        SI                                              SLDT
        WORD^ { SI }                                    SLDT

        SI                                              SMSW
        WORD^ { SI }                                    SMSW

                                                        STC
                                                        STD
                                                        STI

                                                        STOSB
                                                        STOSW
                                                        STOSD

        SI                                              STR
        WORD^ { SI }                                    STR

        AL              34 #                            SUB
        BH              34 #                            SUB
        SI              34 #                            SUB
        ESI             34 #                            SUB

        CH              34 #                            SUB
        SI              34 #                            SUB
        ESI             34 #                            SUB

        AX              1234 #                          SUB
        BP              1234 #                          SUB
        EAX             12345678 #                      SUB
        ESP             12345678 #                      SUB
        BYTE^ { EDX }   34 #                            SUB
        WORD^ { EDX }   1234 #                          SUB
        DWORD^ { EDX }  12341234 #                      SUB
        { EDX }         12341234 #                      SUB

        WORD^ { ESI EBX *8 + 1234432 + }     1234 #     SUB
        { ESI *4 EDX + 987655 - }   12344321 #          SUB
        SI              SP                              SUB
        EBP             ESI                             SUB
        EBP             EDX                             SUB
        { BP SI + }     EDX                             SUB
        { SI BP + }     EDX                             SUB
        { ESP EBP + }   EDX                             SUB
        { EBP EBP + }   EDX                             SUB
        { EBP *2 }      EDX                             SUB
        EDX             EBP                             SUB
        EDX             { BP SI + }                     SUB
        EDX             { SI BP + }                     SUB
        EDX             { ESP EBP + }                   SUB
        EDX             { EBP EBP + }                   SUB
        EDX             { EBP *2 }                      SUB

        { EDI EBX *4 + 12345678 + }     9ABCDEF0 #      SUB

                                                        RET
;CODE

CR .( VERIFY-T )

CODE: VERIFY-T
        AL      23 #            TEST
        AX      123 #           TEST
        EAX     314 #           TEST
        BL      23 #            TEST
        BX      123 #           TEST
        EBX     314 #           TEST
        BL      CL              TEST
        BX      CX              TEST
        EBX     EDX             TEST
        BYTE^ { BX }    CL      TEST
        WORD^ { BX }    CX      TEST
        DWORD^ { EBX }  EDX     TEST
                                RET
;CODE


CR .( VERIFY-V )

CODE: VERIFY-V
        WORD^ { EBP }           VERR
        DI                      VERR
        WORD^ { EBP }           VERW
        DI                      VERW
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

        CL              DH                              XADD
        BYTE^ { BX }    CH                              XADD
        BX              SP                              XADD
        WORD^ { EBP }   SP                              XADD
        EBX             ESP                             XADD
        DWORD^ { EBP }  ESP                             XADD

                                                        XLAT

        AL              34 #                            XOR
        BH              34 #                            XOR
        SI              34 #                            XOR
        ESI             34 #                            XOR

        CH              34 #                            XOR
        SI              34 #                            XOR
        ESI             34 #                            XOR

        AX              1234 #                          XOR
        BP              1234 #                          XOR
        EAX             12345678 #                      XOR
        ESP             12345678 #                      XOR
        BYTE^ { EDX }   34 #                            XOR
        WORD^ { EDX }   1234 #                          XOR
        DWORD^ { EDX }  12341234 #                      XOR
        { EDX }         12341234 #                      XOR

        WORD^ { ESI EBX *8 + 1234432 + }     1234 #     XOR
        { ESI *4 EDX + 987655 - }   12344321 #          XOR
        SI              SP                              XOR
        EBP             ESI                             XOR
        EBP             EDX                             XOR
        { BP SI + }     EDX                             XOR
        { SI BP + }     EDX                             XOR
        { ESP EBP + }   EDX                             XOR
        { EBP EBP + }   EDX                             XOR
        { EBP *2 }      EDX                             XOR
        EDX             EBP                             XOR
        EDX             { BP SI + }                     XOR
        EDX             { SI BP + }                     XOR
        EDX             { ESP EBP + }                   XOR
        EDX             { EBP EBP + }                   XOR
        EDX             { EBP *2 }                      XOR

        { EDI EBX *4 + 12345678 + }     9ABCDEF0 #      XOR

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

        L1:     JMP     // No '#' when labels are used
                NOP
        L1:     JZ
        L2:     JZ
        L3:     JZ
        L4:     JZ
        L5:     JZ
                NOP
  @@ L1:
        L2:     JMP
                NOP
        L1:     J<=
        L2:     J<=
        L3:     J<=
        L4:     J<=
        L5:     J<=
                NOP
  @@ L2:
        L3:     JMP
                NOP
        L1:     JU<
        L2:     JU<
        L3:     JU<
        L4:     JU<
        L5:     JU<
                NOP
  @@ L3:
        L4:     JMP
        L1:     JECXZ   // JECXZ and JCXZ could handle 8-bit offset only
        L2:     JECXZ
        L3:     JECXZ
        L4:     JNZ
                NOP
  @@ L5:
                NOP
                NOP
                NOP
        L5:     LOOP    // but backward LOOPxx instructions are legal
        L5:     LOOPNZ
        L5:     LOOPZ
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

