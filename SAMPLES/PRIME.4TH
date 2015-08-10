
1 65536 ARRAY: []PRIME	// already initialized by zero

: .PRIMES	(( -- ))
	CR ." * Prime numbers less than 65536 : " CR
	65536 2 DO 
	   #I []PRIME C@ 0= IF   
	      #I 8 .R
	      65536 #I DO
		 1  #I []PRIME  C!
	      #J +LOOP
	   ENDIF
	   NUF? ?LEAVE
	LOOP 
	CR ;
