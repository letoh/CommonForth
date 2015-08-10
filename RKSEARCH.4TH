// Rabin-Karp Pattern Matching Algorithm 
					// Written by  : Luke Lee
					// Version     : 1.0
					// Last update : 01/28/'96


// ///////////////////////////////////////////////////////////////
COMMENT:  // Searching for best prime number for RKSEARCH

NODEBUG OFF

1 65536 ARRAY: []PRIME	// already initialized by zero

DEFER PrimeFound 1 0 #PARMS 
' DROP IS PrimeFound

: InitPrimeTable        (( -- ))
	65536 2 DO 
	   #I []PRIME C@ 0= IF   
	      #I PrimeFound
	      65536 #I ?DO
		 1  #I []PRIME  C!
	      #J +LOOP
              0 #I []PRIME C!
	   ENDIF
	LOOP ; 0 0 #PARMS

CR .( Initializeing Prime number table : ) CR
InitPrimeTable

: .PRIMES	(( -- ))
	CR ." * Prime numbers less than 65536 :" CR
        65536 FOR
           #I []PRIME C@ 0= IF #I 10 .R ENDIF
           NUF? NOT WHILE
        NEXT
           THEN RDROP
	CR ; 0 0 #PARMS

$FFFFFFFF U2/ U256/ CONSTANT  INITV

: SQRT  (( n1 -- n2 ) n2*n2 <= n1 )
        0 SWAP 0 
        DO
           1+ DUP 2* 1+ // (N+1)ý = Ný+2N+1
        +LOOP ; 1 1 #PARMS

: IsPrime?      (( n -- T/F ))
        TRUE SWAP 
        DUP SQRT 1+ 2 DO // T/F n
           #I []PRIME C@ 0= IF
              DUP #I MOD 0= IF  NIP FALSE SWAP LEAVE  ENDIF
           ENDIF
        LOOP
        DROP ; 1 1 #PARMS        

: BiggestMagic  (( -- n ))
        INITV FOR
           #I DUP IsPrime? NOT 
           WHILE
              DROP
        NEXT
           ELSE
              RDROP
           THEN  ; 0 1 #PARMS

BiggestMagic CONSTANT RKMagic
							       
;COMMENT // //////////////////////////////////////////////////////

FORTH DEFINITIONS

DEFER RKFilter  (( char -- char' ))  1 1 #PARMS

HIDDEN ALSO DEFINITIONS

8388593 CONSTANT RKMagic
' NOOP IS RKFilter
// : TextRKFilter   (( char -- char' ))
//       DUP BL < IF DROP BL ENDIF ; 1 1 #PARMS
: (dM)  (( plen -- dM ))  1 TUCK ?DO  256* RKMagic MOD  LOOP ; 1 1 #PARMS
: (h1/2)  (( pbuf/abuf plen -- h1/2 ))
        0 TUCK ?DO      // pbuf h1
            256* SWAP DUP 1+ -ROT // pbuf+1 h1*d pbuf
            C@ RKFilter + RKMagic MOD // pbuf+1 (h1*d+index(p[i])%q)
        LOOP 
        NIP ; 2 1 #PARMS

FORTH DEFINITIONS

: RKSEARCH      (| pbuf plen abuf alen | dM h1 endlen -- index_in_abuf |)
      // Find a pattern 'pbuf' 'plen' in 'abuf' 'alen'
        alen plen < IF 
            -1 to index_in_abuf 
        ELSE
            plen (dM) to dM
            pbuf plen (h1/2) to h1      // h1
            abuf plen (h1/2)            // h2
            -1                          // h2 -1
            alen plen - 1+ 0 DO
                DROP #I OVER h1 = IF    // h2 #I h2=h1
                    DUP abuf + pbuf plen COMP 0= ?LEAVE 
                ENDIF                   // h2 #I h2=h1
                DROP // [ RKMagic 256* ] LITERAL + // (h2+16*q-index(a[i])*dM) % q
                abuf #I + C@ RKFilter dM * - RKMagic MOD
                256* abuf #I plen + + C@    // ( h2*d+index(a[i+M]) ) % q
                RKFilter + RKMagic MOD
                -1                      // h2' -1
            LOOP
            NIP to index_in_abuf
        ENDIF ;

DEBUGGING? #IF
  CR .( Searching first appearance of 'PUSH-RESETTER' in HEAD space : ) CR
  ' PUSH-RESETTER >NAME COUNT HP @ HP0 OVER - RKSEARCH 
  HP @ + 1- COUNT TYPE CR
#ENDIF

ONLY FORTH ALSO DEFINITIONS

