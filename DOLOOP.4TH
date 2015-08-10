// DO LOOP in high level                         Written by Luke Lee

                // [ 07/20/'93 ] modified for Stack expression.
                // [ 04/24/'94 ] modified again for newer stack expression .
		// [ 11/27/'94 ] Add (+LOOP) and +LOOP .
		// [ 10/11/'95 ] Add #J and #K index.
		// [ 10/18/'95 ] Remove stkexpr check for LEAVE and ?LEAVE
		// [ 03/21/'96 ] Modify for DO..WHILE..LOOP..ELSE LEAVE..THEN
		//		 structure.

  // 03/21/'96 : As the introduction of DO..WHILE..LOOP..ELSE.....THEN
  //		 control structure, there is a very interesting usage
  //		 here, see TEST2 and TEST3 on the following. The behavior
  //		 are different between 'ELSE LEAVE' and 'ELSE 3RDROP'.
  //		 This is because the 'LEAVE' itself is a high level word
  //		 and 3RDROP will pop it's own return address and left
  //		 the DO..LOOP's leaving address on top of the return stack. 

FORTH DEFINITIONS

// : (DO)        (| limit init | retadr -- |)		   |	      |
//       R>    DUP CELL+ >> retadr     @ >R		   |   index  |
//       limit >R init >R				   |   limit  |
//       retadr >R ;					   | leaveadr |
//							   +----------+

: (DO)  (( limit init -- ))
        R> DUP @ >R CELL+ -ROT SWAP >R >R >R ; 2 0 #PARMS INVISIBLE

// : (?DO) (| limit init | retadr -- |)
//       limit init = IF
//         R> @ >R
//       ELSE
//          R>    DUP CELL+ >> retadr     @ >R
//          limit >R init >R
//          retadr >R
//       ENDIF ;

: (?DO) (( limit init -- ))
        2DUP = IF
           2DROP R> @ >R EXIT
        ELSE
           R> DUP @ >R CELL+ -ROT SWAP >R >R >R 
        ENDIF ; 2 0 #PARMS INVISIBLE

// : (LOOP) (| | retadr limit index -- |)
//       R> >> retadr
//       R> 1+ >> index      R@ >> limit     index >R
//       index limit = IF
//          RDROP RDROP
//       ELSE
//          retadr @ >R
//       ENDIF ;

: (LOOP)
        R>
        R> 1+   DUP R@ = IF // index = limit
           2DROP RDROP EXIT
        ELSE
           >R @ >R
        ENDIF ; 0 0 #PARMS INVISIBLE

: (+LOOP)    (( n -- ))
	R> SWAP
	R> +   DUP R@ >= IF
	   2DROP RDROP EXIT
	ELSE
	   >R @ >R
	ENDIF ; 1 0 #PARMS INVISIBLE

: (LEAVE)	// left 'leaving address' on top of return address
        3RDROP    ; 0 0 #PARMS INVISIBLE

: (?LEAVE)
	IF  3RDROP  ENDIF ; 1 0 #PARMS INVISIBLE

STACK-EXPRESSION ALSO DEFINITIONS 

: ?BUG3!        (( T/F -- ))
        IF CR ." Error : Stack not balance in DO ... LEAVE ... LOOP structure"
           CR (|ABORT|)
        ENDIF ; 1 0 #PARMS

FORTH DEFINITIONS

: #J	(( -- inner_loop_index ))
	RP@ [ 3 CELLS ] LITERAL + @ ; 0 1 #PARMS MACRO

: #K	(( -- third_loop_index ))
	RP@ [ 6 CELLS ] LITERAL + @ ; 0 1 #PARMS MACRO

: DO    // (( -- (|SP|)' HERE0 ))
        COMPILE (DO) 0 , (|SP|)@  HERE  ; IMMEDIATE 0 2 #PARMS

: ?DO   // (( -- (|SP|)' HERE0 ))
        COMPILE (?DO) 0 , (|SP|)@ HERE  ; IMMEDIATE 0 2 #PARMS

: xLOOP  (| (|SP|)' HERE0 x -- |)
	x IF   COMPILE (+LOOP)   ELSE   COMPILE (LOOP)   ENDIF
        StkExprUsed? IF
            (|SP|)' (|SP|) @ <> ?BUG3!
        ENDIF
	HERE0 ,    HERE  HERE0 CELL-  ! ; INVISIBLE

: LOOP	// (( (|SP|)' HERE0 -- ))
	FALSE xLOOP ; IMMEDIATE 2 0 #PARMS

: +LOOP // (( (|SP|)' HERE0 -- ))
	TRUE  xLOOP ; IMMEDIATE 2 0 #PARMS

: LEAVE // (( (|SP|)' HERE0 -- (|SP|)' HERE0 ))
        COMPILE (LEAVE) ; IMMEDIATE 2 2 #PARMS

: ?LEAVE // (( (|SP|)' HERE0 -- (|SP|)' HERE0 ))
        COMPILE (?LEAVE) ; IMMEDIATE 2 2 #PARMS

ONLY FORTH ALSO DEFINITIONS

COMMENT:
: TEST (| LIMIT INC -- |)
	LIMIT 0 ?DO 
	   #I . 
	INC +LOOP ;

// Compare the following two definitions !!! Very interesting !!!

: TEST2	(| LIMIT BREAK -- |)
	LIMIT 0 ?DO
	   #I BREAK <=
	   WHILE
	      #I .
	LOOP
	      ." --- Always comes here ---"
	   ELSE
	      LEAVE
	   THEN  ;

: TEST3	(| LIMIT BREAK -- |)
	LIMIT 0 ?DO
	   #I BREAK <=
	   WHILE
	      #I .
	LOOP
	      ." --- Only normal leave gets here ---"
	   ELSE
	      3RDROP
	   THEN  ;
CR
10 1 TEST CR
100 10 TEST CR
100 9 TEST CR

CR
15 10 TEST2 CR
15 50 TEST2 CR

CR
15 10 TEST3 CR
15 50 TEST3 CR

COMMENT;

