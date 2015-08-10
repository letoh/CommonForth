// Data Structure Defining Tools                Written by : Luke Lee
// For Common Forth 1.63+                                [ 02/18/'97 ]

        // 2/14/'93 Add head-structure relative words
        // 2/23/'93 Modify 0 offset fields to immediate words, since there
        //          is no need to lay down codes at compile time to perform
        //          an 'Add zero to top of stack' action at run-time .
        // 7/29/'93 Add FILED-LABEL: .
	// 11/27/'94 Modify field words to immediate words.
	// 08/16/'95 Modify ;STRUCT: for defining nesting record field name,
	//	     FIELD-LABEL: is eliminated since it always create a
	//	     zero-sized field . 'HWORD:' also added.
	// 08/18/'95 Fix bug while the nested data structure is the first
	//	     field of it's parent structure .	
	// 08/22/'95 Add UNION definitions.
        // 02/18/'97 Add a variable ALIGNMENT.

// Syntax :
//	 STRUCT: ANOTHER-RECORD:
//		10 FIELD: |NAME
//		90 FIELD: |ADDRESS
//	 ;STRUCT
//
//       STRUCT: RECORD-NAME:
//           5 FIELD: 	|5-BYTES-FIELD
//           6 FIELD: 	|6-BYTES-FIELD
//           SIZEOF ANOTHER-RECORD: FIELD:	|BIG-FIELD1
//	     ANOTHER-RECORD:	|BIG-FIELD2
//
//           STRUCT: NESTING-RECORD:		// 08/16/'95
//               .....
//           ;STRUCT: 	|NESTING-RECORD   ... define a field name.
//
//           WORD:  	|4-BYTES-FIELD
//           2WORD: 	|8-BYTES-FIELD
//       ;STRUCT: RECORD-OBJECT		.... define a data object.
//
//  Note: SIZEOF can be applied to any symbols .
//       Ex :  ( 'ok' is the prompt of FORTH )
//               STRUCT: RECORD: ok
//                    4 FIELD: ^NEXT-RECORD ok
//                   11 FIELD: FILE-NAME ok
//               ;STRUCT ok
//               ok
//               RECORD: REC1 ok
//               ok
//               SIZEOF REC1 . 15 ok
//               SIZEOF RECORD: . 15 ok
//               SIZEOF FILE-NAME . 11 ok
//               : .RECORD-SIZE ok
//                       SIZEOF RECORD: LITERAL . ; ok
//               .RECORD-SIZE 15 ok
//
//  Note: 1. NO any two structures may have same field names.
//        2. No special order for defining any field.
//

: OFFSET: (( offset -- ))
        CREATE , 1 1 #PARMS
        DOES> @ + ; 1 0 #PARMS INVISIBLE

0     DUP  OFFSET: |REFERENCE		INVISIBLE
CELL+ DUP  OFFSET: |LINK		INVISIBLE
CELL+ DUP  OFFSET: |SIZE		INVISIBLE
CELL+ DUP  OFFSET: |USER-DEFINED	INVISIBLE
CELL+ DUP  OFFSET: |ATTRIBUTE		INVISIBLE
2 +   DUP  OFFSET: |IN-PARMS		INVISIBLE
1 +   DUP  OFFSET: |OUT-PARMS		INVISIBLE
1 +   DUP  OFFSET: |NAME-LENGTH		INVISIBLE
1 +        OFFSET: |NAME-STRING		INVISIBLE

: >BODY         (( cfa -- pfa ))
        1+ CELL+ ; 1 1 #PARMS

: BODY>         (( pfa -- cfa ))
        CELL- 1- ; 1 1 #PARMS

// Define 3 distinct constant
  CHAR S CHAR T CHAR R CHAR U 256* OR 256* OR 256* OR  
CONSTANT <STRUCT>		INVISIBLE	
  CHAR U CHAR N CHAR I CHAR O 256* OR 256* OR 256* OR		
CONSTANT <UNION>		INVISIBLE
  <STRUCT> <UNION> OR NEGATE
CONSTANT (DefineNotComplete)	INVISIBLE

VARIABLE CURR-STRUCT-SIZE 	INVISIBLE // current value is 0
VARIABLE CURR-UNION-MAX		INVISIBLE
VARIABLE STRUCT-NESTING-LEVEL	INVISIBLE
VARIABLE STRUCT/UNION?		INVISIBLE
VARIABLE ALIGNMENT              
VARIABLE FIELD-UNIT             INVISIBLE       // unit size of current field
ALIGNMENT ON        // DEFAULT
1 FIELD-UNIT !

2VARIABLE STRUCT/UNION-RESETTER	INVISIBLE

: STRUCT/UNION-RESET	( -- )
        ALIGNMENT ON    1 FIELD-UNIT !
	0 DUP 2DUP CURR-STRUCT-SIZE ! STRUCT/UNION? !
	CURR-UNION-MAX ! STRUCT-NESTING-LEVEL ! 
	STRUCT/UNION-RESETTER POP-RESETTER  ; 0 0 #PARMS INVISIBLE

: DO-ALIGNMENT          ( -- )
        // for 16-bit/32-bit/64-bit alignments
        ALIGNMENT @ NOT IF EXIT ENDIF
        FIELD-UNIT @
        DUP CELL = IF
            CURR-STRUCT-SIZE DUP @ 3 + [ 3 NOT ] LITERAL AND SWAP !
        ELSE 
        DUP 2 = IF
            CURR-STRUCT-SIZE DUP @ 1+  [ 1 NOT ] LITERAL AND SWAP !
        ENDIF ENDIF DROP ; NOPARM INVISIBLE

: FIELDS:  ( #field -- )  RECURSIVE // not recursive call,just reveals it
     // Field size is decided by current FIELD-UNIT
     CREATE  IMMEDIATE 1 1 #PARMS
        DO-ALIGNMENT
        ['] FIELDS: LAST @ |USER-DEFINED ! // for type-checking by 'OFFSET'
        FIELD-UNIT @ *          // (field-size * FIELD-UNIT)
        DUP LAST @ |SIZE !

	STRUCT/UNION? @
	DUP <STRUCT> = IF
           DROP 
           CURR-STRUCT-SIZE @ DUP ,
	   SWAP CURR-STRUCT-SIZE +!
	ELSE <UNION> = IF
	   0 DUP ,  // offset should always be zero
	   SWAP CURR-UNION-MAX @ MAX CURR-UNION-MAX !
	ELSE
	   DROP CR ." * FIELDS: Not defining in STRUCT: or UNION: ." CR ABORT
	ENDIF ENDIF

    	0 = IF // offset is zero, compile nothing into code space
    DOES> DROP
    	ELSE
    DOES> @ STATE @ IF 
	      \ LITERAL COMPILE +
	  ELSE
	      +
	  ENDIF
    	ENDIF  ;       1 0 #PARMS

: FIELD:        ( field-size -- )
        FIELD-UNIT @  1 FIELD-UNIT !
        SWAP FIELDS:
        FIELD-UNIT ! ; 1 0 #PARMS

: (Complete?)	(( size -- ))
	(DefineNotComplete) = IF
	    STRUCT/UNION-RESET
	    CR ." * Structure/Union not completely defined. " CR 
	    ABORT
	ENDIF ; 1 0 #PARMS INVISIBLE

: (STRUCT/UNION)DOES	(( pfa -- ))
	@  DUP (Complete?)
	STRUCT-NESTING-LEVEL @ 1 >= IF // create a field
	   FIELD:
	ELSE  // create a named data structure object
           CREATE
              0 1 #PARMS
              DUP ALLOT LAST @ |SIZE !
	ENDIF ; 1 0 #PARMS INVISIBLE

: STRUCT:  (( -- <last-type> LAST-SIZE head pfa ))
     CREATE
        0 0 #PARMS
	['] STRUCT/UNION-RESET STRUCT/UNION-RESETTER  PUSH-RESETTER
	STRUCT/UNION? @		<STRUCT>  STRUCT/UNION?  !
        CURR-STRUCT-SIZE @      0 CURR-STRUCT-SIZE !
	1 STRUCT-NESTING-LEVEL +!
        LAST @ HERE (DefineNotComplete) ,
     DOES>
	(STRUCT/UNION)DOES   ; 0 4 #PARMS

: UNION:   (( -- <last-type> LAST-union-SIZE head pfa ))
     CREATE
	0 0 #PARMS	
	['] STRUCT/UNION-RESET STRUCT/UNION-RESETTER  PUSH-RESETTER
	STRUCT/UNION? @		<UNION>	STRUCT/UNION? !
	CURR-UNION-MAX @	0 CURR-UNION-MAX !
	1 STRUCT-NESTING-LEVEL +!
	LAST @ HERE (DefineNotComplete) ,
     DOES>
	(STRUCT/UNION)DOES   ; 0 4 #PARMS

: ;STRUCT	( <last-type> LAST-SIZE head pfa -- )
     STRUCT/UNION? @ <STRUCT> <> IF
	RDROP 2DROP STRUCT/UNION-RESET
	CR ." * ;STRUCT : Not defining STRUCT: ." CR ABORT
     ENDIF
     CURR-STRUCT-SIZE @ SWAP !	// save it to pfa
     CURR-STRUCT-SIZE @ SWAP |SIZE  !	// save it to head|size
     SWAP STRUCT/UNION? !

     STRUCT/UNION? @ <UNION> = IF // parent is UNION:, must be nesting
	 CURR-STRUCT-SIZE @   CURR-UNION-MAX @  MAX    CURR-UNION-MAX  !
     ELSE
     	 STRUCT-NESTING-LEVEL @ 1 > IF // nesting defining STRUCT:
     	     CURR-STRUCT-SIZE @ +
     	 ENDIF
     ENDIF
     CURR-STRUCT-SIZE !
     -1 STRUCT-NESTING-LEVEL +!
     STRUCT-NESTING-LEVEL @ 0= IF  STRUCT/UNION-RESETTER POP-RESETTER  ENDIF
     ; 4 0 #PARMS

: ;UNION	( <last-type> LAST-union-SIZE head pfa -- )
     STRUCT/UNION? @ <UNION> <> IF
	RDROP 2DROP STRUCT/UNION-RESET
	CR ." * ;UNION : Not defining UNION: ." CR ABORT
     ENDIF
     CURR-UNION-MAX @ SWAP !	// save it to pfa
     CURR-UNION-MAX @ SWAP |SIZE  !	// save it to head|size
     SWAP STRUCT/UNION? !

     STRUCT/UNION? @ <STRUCT> = IF // parent is STRUCT:, nesting def. 
	CURR-UNION-MAX @  CURR-STRUCT-SIZE +!
     ELSE
	STRUCT-NESTING-LEVEL @ 1 > IF // nesting defining UNION:
	   CURR-UNION-MAX @  MAX   // compare with LAST-union-SIZE, pick max
	ENDIF
     ENDIF
     CURR-UNION-MAX  !
     -1 STRUCT-NESTING-LEVEL +!
     STRUCT-NESTING-LEVEL @ 0= IF  STRUCT/UNION-RESETTER POP-RESETTER  ENDIF
     ; 4 0 #PARMS

: ;STRUCT:	(( <last-type> LAST-SIZE head pfa -- ))
     STRUCT-NESTING-LEVEL @ 1 > IF
	 CURR-STRUCT-SIZE @ >R
	 ;STRUCT
	 R> 
	 STRUCT/UNION? @ <STRUCT> = IF
	    DUP NEGATE CURR-STRUCT-SIZE +! // adjust size back for FIELD:
	 ENDIF
	 FIELD:
     ELSE
         OVER |REFERENCE @ >R
         ;STRUCT
         R> EXECUTE  // in fact, this line can be eliminated since 
		     // there is no other thing to do after "R> EXECUTE"
		     // , so the cfa ">R" will be executed on "EXIT" laied 
		     // by ";" .
     ENDIF ; 4 0 #PARMS

: ;UNION:	(( <last-type> LAST-union-SIZE head pfa -- ))
     STRUCT-NESTING-LEVEL @ 1 > IF
	 CURR-UNION-MAX @ >R
	 ;UNION
	 R>
	 STRUCT/UNION? @ <STRUCT> = IF 
	     DUP NEGATE CURR-STRUCT-SIZE +! // adjust size back for FIELD: 
	 ENDIF
	 FIELD:
     ELSE
         OVER |REFERENCE @ >R
         ;UNION
         R> EXECUTE
     ENDIF ; 4 0 #PARMS

: SWAP-INTO     ( value addr -- value' )
        // Swap 'value' into addr, return original content of addr
        SWAP OVER @ -ROT SWAP ! ; 2 1 #PARMS

: BYTE:   ( -- )        1 FIELD: ; 0 0 #PARMS
: BYTES:  ( #bytes -- ) FIELD:   ; 1 0 #PARMS

: HWORD:  ( -- )
          CELL 2/ FIELD-UNIT SWAP-INTO
          1 FIELDS:
          FIELD-UNIT !  ; 0 0 #PARMS
: HWORDS: ( #half-words -- )
          CELL 2/ FIELD-UNIT SWAP-INTO
          SWAP FIELDS:
          FIELD-UNIT !  ; 1 0 #PARMS

: WORD:   ( -- )
          CELL FIELD-UNIT SWAP-INTO
          1 FIELDS:
          FIELD-UNIT !  ; 0 0 #PARMS
: WORDS:  ( #words -- )
          CELL FIELD-UNIT SWAP-INTO
          SWAP FIELDS:
          FIELD-UNIT !  ; 1 0 #PARMS

: 2WORD:  ( -- )
          2 CELL* FIELD-UNIT SWAP-INTO
          1 FIELDS:
          FIELD-UNIT !  ; 0 0 #PARMS
: 2WORDS: ( #dwords -- )
          2 CELL* FIELD-UNIT SWAP-INTO
          SWAP FIELDS:
          FIELD-UNIT !  ; 1 0 #PARMS

: SIZEOF  ( -- SIZE )
     ' >HEAD |SIZE @ ; IMMEDIATE 0 1 #PARMS

: OFFSET  ( -- OFFSET )
     ' DUP >HEAD |USER-DEFINED @   ['] FIELDS: = NOT  IF
        CR ." * OFFSET must be applied on words defined by FIELDS: ." CR ABORT
     ENDIF
     >BODY @ ; IMMEDIATE 0 1 #PARMS


