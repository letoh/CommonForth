254 CONSTANT WHITE
32  CONSTANT BLACK
: ADDRESS1  2047 AND PAD + ;
: ADDRESS2  ADDRESS1 2048 + ;
: NEIGHBORS
        2048 0
        DO  I 1+ ADDRESS1 C@
            I 1- ADDRESS1 C@ +
            I 79 + ADDRESS1 C@ +
            I 79 - ADDRESS1 C@ +
            I 80 + ADDRESS1 C@ +
            I 80 - ADDRESS1 C@ +
            I 81 + ADDRESS1 C@ +
            I 81 - ADDRESS1 C@ +
            I ADDRESS1 C@
            IF DUP 2 = SWAP 3 = OR
               IF 1 ELSE 0 THEN
            ELSE
               3 =
               IF 1 ELSE 0 THEN
            THEN
            I ADDRESS2 C!
        LOOP ;
: REFRESH
        PAD 2048 + PAD 2048 MOVE ;

: DISPLAY
        0 0 AT
        PAD 1920 0
        DO
                DUP C@ IF WHITE ELSE BLACK THEN EMIT
                1+
        LOOP    DROP ;
: INIT-MAP
        2048 0
        DO      DUP C@ 1 AND
                IF 1 ELSE 0 THEN
                I ADDRESS1 C!
                1+
        LOOP DROP ;
: GENERATIONS (( N -- ))
        0 DO 
             NEIGHBORS REFRESH DISPLAY 
             AT?
             60 24 AT I .
             AT 
             NUF? ?LEAVE           
          LOOP  ;

// 13244 INIT-MAP
// 1500 GENERATIONS

