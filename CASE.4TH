// CASE ... OF ... ENDOF ... ENDCASE control structure           Luke Lee.

//  Implement this control structure by IF ... ELSE ... ENDIF

: CASE
        -1 ; IMMEDIATE

: OF
        COMPILE OVER COMPILE = \ IF COMPILE DROP ; IMMEDIATE

: ENDOF
        \ ELSE ; IMMEDIATE

: ENDCASE
        COMPILE DROP
        BEGIN DUP -1 <> WHILE \ ENDIF REPEAT DROP ; IMMEDIATE

// Note that ENDCASE will compile a DROP.
