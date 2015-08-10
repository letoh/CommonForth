// Tower of hanoi                Written by : Luke Lee
// With stack parameter expression and local variables : 08/08/'92
// A demonstration for recursive program .

: TOWER-OF-HANOI-AUX0 (( source destination temp n -- ))   RECURSIVE
    DUP 0<> IF
       DUP 1 - >R 3 PICK 2 PICK 4 PICK R> TOWER-OF-HANOI-AUX0
       ." Move disc " DUP . ." FROM " 3 PICK EMIT ."  TO " 2 PICK EMIT
       ASCII . EMIT CR
       DUP 1 - >R 1 PICK 3 PICK 5 PICK R> TOWER-OF-HANOI-AUX0
    THEN 2DROP 2DROP ;

: TOWER-OF-HANOI0 (( N -- ))
    CR >R ASCII A ASCII C ASCII B R> TOWER-OF-HANOI-AUX0 ;

// Use Stack parameter expression

: TOWER-OF-HANOI-AUX (| source dest temp #discs -- |)   RECURSIVE
    #discs 0<> IF
        source temp dest #discs 1- TOWER-OF-HANOI-AUX
        ." Move disc " #discs . ." from " source EMIT ."  to " dest EMIT
        ASCII . EMIT CR
        temp dest source #discs 1- TOWER-OF-HANOI-AUX
    ENDIF ;

: TOWER-OF-HANOI (| #discs -- |)
    CR ASCII A ASCII C ASCII B #discs TOWER-OF-HANOI-AUX ;

CR 
.( Example : ) CR
.(      4 TOWER-OF-HANOI ) CR
