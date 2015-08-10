// Testing SEE
// //////////////////////////////////////////////////////////////////////////

NEEDS SEE.4TH

: PSEE ."   <Press any key to continue...>" KEY DROP SEE ;

CR
.( * Press any during SEE will pause, press <ENTER> again exits SEE. ) CR
.( * There are about 50 SEE below ... ) CR

PSEE (WORDS)
PSEE parse

PSEE |REFERENCE  // multiple DOES> also works
PSEE |IN-PARMS   // <<-- see the result of COMPILE and \ and compile,
PSEE DEFER      // CREATE ... DOES> words 
PSEE TASK:
PSEE <==>       // generalized "exchange"

PSEE LAST       // user variable
VARIABLE X 1234 X !     // global variable
PSEE X
4321 VALUE Y    // value
PSEE Y


: TEST1 CREATE DUP SWAP 10 ROT WORDS SEE 10 CONTEXT ; PSEE TEST1
: TEST2 1 2 3 4 5 6 7 8 9 ; PSEE TEST2
: TEST3 1 2 EXIT 3 4 5 ; PSEE TEST3

: TEST4 1 IF 2 ENDIF 3 ; PSEE TEST4
: TEST5 IF ENDIF ; PSEE TEST5
: TEST6 1 IF 2 IF 3 ENDIF 4 ENDIF 5 ; PSEE TEST6
: TEST7 IF IF ENDIF ENDIF ; PSEE TEST7
: TEST8 IF ELSE ENDIF ; PSEE TEST8
: TEST9 1 IF 2 ELSE 3 ENDIF 4 ; PSEE TEST9
: TEST10 1 IF  
	   2 IF 3 ELSE 4 ENDIF 5 
	 ELSE
	   6 
	 ENDIF 7 ; PSEE TEST10
: TEST11 1 IF 
	   2 
	 ELSE
	   3 IF 4 ELSE 5 ENDIF 6
	 ENDIF 7 ; PSEE TEST11
: TEST12 IF
	     IF ELSE ENDIF
	 ELSE
	     IF ELSE ENDIF
	 ENDIF ; PSEE TEST12

: TEST13 1 IF 2 BEGIN 3 UNTIL 4 ENDIF ; PSEE TEST13
: TEST14 IF ENDIF BEGIN UNTIL ; PSEE TEST14
: TEST15 0 IF 
	    1 BEGIN 
		2 
		WHILE 
		    3 
	    UNTIL 
		    4 
		ELSE 
		    5 
		THEN 
	    6
	 ENDIF 7 ; PSEE TEST15

: TEST16 1 BEGIN 2 AFT 3 THEN 4 UNTIL 5 ; PSEE TEST16
: TEST17 1 BEGIN 2 AFT 3 THEN 4 AGAIN 5 ; PSEE TEST17
: TEST18 1 FOR   2 AFT 3 THEN 4 NEXT 5 ; PSEE TEST18
: TEST19 1 FOR AFT 2 THEN 3 NEXT 4 ; PSEE TEST19

: TEST20 BEGIN AFT THEN UNTIL ; PSEE TEST20
: TEST21 BEGIN AFT THEN AGAIN ; PSEE TEST21
: TEST22  FOR AFT THEN NEXT ; PSEE TEST22
: TEST22.1 FOR AFT 1 >R 2 >R 3 R> 4 R> 5 THEN NEXT ; PSEE TEST22.1
: TEST22.2 FOR AFT 1 R> 2 R> 3 >R 4 >R 5 THEN NEXT ; PSEE TEST22.2
: TEST22.3 FOR     1 >R 2 >R 3 R> 4 R> 5      NEXT ; PSEE TEST22.3
: TEST22.4 FOR     1 R> 2 R> 3 >R 4 >R 5      NEXT ; PSEE TEST22.4
: TEST22.5 1- >R R@ + SWAP R@ + SWAP
	   [ 0 HERE ]
		OVER C@ OVER C! 1- SWAP 1- SWAP
	   NEXT 2DROP ; PSEE TEST22.5

: TEST23 1 BEGIN 2 WHILE 3 REPEAT 4 ; PSEE TEST23

CR 
.( "BEGIN .. WHILE .. REPEAT" is equivalent to "BEGIN .. WHILE .. AGAIN THEN" )
CR

: TEST24 BEGIN WHILE REPEAT ; PSEE TEST24
: TEST25 BEGIN WHILE AGAIN THEN ; PSEE TEST25 // Will be seen as BEGIN WHILE REPEAT
: TEST26 1 BEGIN 2 AFT 3 THEN 4 WHILE 5 REPEAT 6 ; PSEE TEST26
: TEST27 BEGIN AFT THEN WHILE REPEAT ; PSEE TEST27

: TEST28 TRUE ANDTHEN TRUE ANDTHEN FALSE THEN-AND ; PSEE TEST28


CR
.( * Multiple exit loops ...)
CR

: TEST29 // multiple exits
	1 
	BEGIN 
	   2 
	   WHILE
	      3
	      WHILE             
		 4
	UNTIL
		 5
	      ELSE
		 6
	      THEN
	      7
	   ELSE
	      8
	   THEN
	10 ; PSEE TEST29
: TEST30 BEGIN WHILE WHILE     WHILE     UNTIL
	       THEN  ELSE THEN ELSE THEN ; PSEE TEST30
: TEST31 BEGIN WHILE     WHILE WHILE WHILE     UNTIL 
	       ELSE THEN THEN  THEN  ELSE THEN ; PSEE TEST31
: TEST32 FOR 1 WHILE 2     WHILE 3     WHILE 4 NEXT
	     5 ELSE THEN 6 ELSE THEN 7 ELSE THEN 8 ; PSEE TEST32
: TEST33 BEGIN 
		WHILE 
			
	 WHILE
		
	 REPEAT
		THEN ; PSEE TEST33
: TEST34 BEGIN 
		WHILE 
			WHILE     
				WHILE     
	 AGAIN
				THEN    
			ELSE    
			THEN 
		ELSE 
		THEN ; PSEE TEST34

: TEST35 BEGIN WHILE     WHILE WHILE WHILE     AGAIN
	       ELSE THEN THEN  THEN  ELSE THEN ; PSEE TEST35

: TEST36 IF 
	    BEGIN 
		WHILE 
	    UNTIL 
		ELSE 
		THEN 
	 ENDIF ; PSEE TEST36
: TEST37 IF
	    1
	    BEGIN
		2
		WHILE
			3
			WHILE
				4
	    WHILE
		5
	    REPEAT
				6
			ELSE
				7
			THEN
			8
		ELSE
			9
		THEN
	    10
	 ENDIF ; PSEE TEST37

: TEST38 IF
	    BEGIN
		WHILE
			WHILE
	    WHILE
	    REPEAT
			ELSE
			THEN
		ELSE
		THEN
	 ENDIF ; PSEE TEST38

: TEST39 BEGIN 
		IF
			IF
				BEGIN 
					WHILE 
						WHILE     
							WHILE     
								WHILE
				AGAIN
								THEN
							ELSE
							THEN    
						ELSE    
						THEN 
					ELSE 
					THEN
			ENDIF
		ELSE
		ENDIF
	 WHILE
	 REPEAT ; PSEE TEST39

: TEST40 BEGIN 
	 WHILE
		IF
			IF
				BEGIN 
					WHILE 
						WHILE     
							WHILE     
				WHILE
				REPEAT
							THEN    
						ELSE    
						THEN 
					ELSE 
					THEN
			ENDIF
		ELSE
		ENDIF
	 REPEAT ; PSEE TEST40

.( * The following one is an illegal syntax, but it can be seen ... ) CR
: TEST41 AFT THEN ; PSEE TEST41 // This is an illegal syntax, but it can be seen.

.( * The followings are ambigious conditions; they are resolved by several ) CR
.(   tries of rediscompilations ... ) CR
.( [ SWAP -ROT == ROT SWAP ] ) CR
: TEST42
	TRUE IF WORDS ELSE DUP SWAP ENDIF
	BEGIN -ROT WHILE -ROT REPEAT ; PSEE TEST42

: TEST43
	TRUE FALSE 1 2 3
	SWAP BEGIN -ROT 1 2 3 4 UNTIL ; PSEE TEST43

: TEST44 
	IF
	    IF 
	       SWAP
	       BEGIN
		  -ROT
		  WHILE
		    SWAP
		    -ROT
	       UNTIL
		  THEN
	    ENDIF
	ELSE
	   1234
	ENDIF ; PSEE TEST44

