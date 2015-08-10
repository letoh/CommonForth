// Vocabulary words for Common Forth                     Written by : Luke Lee

DECIMAL

: HASHTABLE>BODY (( htab -- vocbody )) 
  // convert hash-table to associate vocabulary
    1023 CELL* + @ ; 1 1 #PARMS

: VOCABULARY    (( -- ))
        CREATE
            HERE HP @ CELL- ! 
            HP @ 1024 CELL* - DUP HP !
            HERE SWAP , VOC-LINK DUP @ , !
            HP @ 1023 CELL* 0 FILL // initialize it
        DOES>
            @ CONTEXT ! ; 0 0 #PARMS

: DEFINITIONS   (( -- ))
        CONTEXT @ CURRENT ! ; 0 0 #PARMS

: ORDER         (( -- ))
        CR ." CONTEXT : " CONTEXT
        BEGIN
           DUP @ HASHTABLE>BODY BODY> >HEAD .ID SPACE
           CELL+ DUP @ 0 =
        UNTIL 
        DROP
        CR ." CURRENT : " CURRENT @ 
        HASHTABLE>BODY BODY> >HEAD .ID CR ; 0 0 #PARMS

16 CONSTANT #VOCS

: ONLY          (( -- ))
  // there is no ROOT vocabulary, so FORTH vocabulary is used .
        CONTEXT #VOCS CELL* 0 FILL 
        FORTH CONTEXT @ CONTEXT CELL+ ! ; 0 0 #PARMS

: ALSO          (( -- ))
        CURRENT CELL- CELL- CELL- @ 0= IF
           CONTEXT CONTEXT CELL+ #VOCS 2 - CELL* CMOVE> 
        ENDIF ; 0 0 #PARMS

: PREVIOUS      (( -- ))  // 4/16/'93
        CONTEXT CELL+ CELL+ @ 0<> IF
           CONTEXT CELL+ CONTEXT #VOCS 1- CELL* CMOVE 
        ENDIF ; 0 0 #PARMS

: .VOCS         (( -- ))
        CR VOC-LINK @ BEGIN
          DUP BODY> >HEAD .ID SPACE 
          CELL+ @
        DUP 0 = UNTIL DROP ; 0 0 #PARMS
        
: HASHTAB[]	(( table index -- head ))
        CELL* OVER + @ + ; 2 1 #PARMS

