CREATE SCALES 1 , 5 , 10 , 50 , 100 , 500 , 1000 , 5000 ,
CREATE ROMANS CHAR I , CHAR V ,
              CHAR X , CHAR L ,
              CHAR C , CHAR D ,
              CHAR M , CHAR ? ,

: SCALE[] (( I -- X ))
      CELL* SCALES + @ ; 1 1 #PARMS
: ROMAN[] (( I -- C ))
      CELL* ROMANS + @ ; 1 1 #PARMS

: (ROMAN) (| N I | R Q -- |) RECURSIVE
        I 0 >= IF
            N I SCALE[] /MOD => Q => R
            Q CASE
               9 OF I ROMAN[] EMIT I 2 + ROMAN[] EMIT ENDOF
               4 OF I ROMAN[] EMIT I 1+  ROMAN[] EMIT ENDOF
               5 /MOD IF I 1+ ROMAN[] EMIT ENDIF
               0 ?DO I ROMAN[] EMIT LOOP 0
            ENDCASE
            R I 2 - (ROMAN)
        ENDIF ;

: ROMAN (| N -- |)
        N 4000 < IF
           N 6 (ROMAN)
        ELSE
           ." OUT OF RANGE !"
        ENDIF ;

