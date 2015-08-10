// Head structure for CF 1.632
// Note that this head structure cannot be modified !

					// Written by : Luke Lee

1     CONSTANT IMMED 
2     CONSTANT COMPO
4     CONSTANT INVIS-MASK
$80   CONSTANT MACRO-MASK
$40   CONSTANT |HEAD|

STRUCT: HEAD:
     WORD:      |REFERENCE
     WORD:      |LINK
     WORD:      |SIZE
     WORD:      |USER-DEFINED
     2 FIELD:   |ATTRIBUTE
     1 FIELD:   |IN-PARMS
     1 FIELD:   |OUT-PARMS
     1 FIELD:   |NAME-LENGTH
     |HEAD| OFFSET |NAME-LENGTH 1+ - FIELD:   |NAME-STRING
;STRUCT

: >LINK         ( cfa -- lfa )
        >HEAD |LINK ; 1 1 #PARMS

: LINK>         ( lfa -- cfa )
        OFFSET |LINK LITERAL - @ ; 1 1 #PARMS

: N>LINK        ( nfa -- lfa )
        NAME> >LINK ; 1 1 #PARMS

: L>NAME        ( lfa -- nfa )
        LINK> >NAME ; 1 1 #PARMS

