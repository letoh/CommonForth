// Testing C routines

: wait  (| -- |) ." ...... Press any key to continue" KEY DROP CR ;

CR 
.( * First, "NEEDS FLOAT.4TH"  which will  "FLOAD INVOKEC.4TH" ) CR
.(   If you want 387FLOAT.4TH to be used instead of FLOAT.4TH, FLOAD it ) CR
.(   before you FLOAD DEMO_C.4TH . ) CR

NEEDS FLOAT.4TH 
NEEDS DOSCMD.4TH

gppconio_init   // initialization

CR wait
CR
.( * Now do some testing ...) CR

.( 1. Testing 'clrscr' ) wait
clrscr

.( 2. Testing 'gotoxy' ) wait
1 1 gotoxy
highvideo

.( 3. Testing 'cprintf' ) wait
: TEST
        4312234  1234  Z$" Testing cprintf... 1234=%d, 4312234=%d"
        cprintf 4DROP CR ;
TEST

.( 4. Testing 'system' ... ) CR

YELLOW BLINK OR textcolor
CR .( * Enter 'EXIT' to return to CF ...) CR
normvideo

DOS

WHITE textcolor

.( 5. Generating 100 random numbers with 'random' ) wait

: TEST-RND      (| -- |)
        100 0 DO
           random 1000 MOD . TAB
        LOOP ;
TEST-RND

CR .( 5. Testing floating point ... ) wait
.S
: TESTF
        ."   * Testing 'atof' and 'cprintf' ..." CR
        Z$" 1234.4321123" atof
        Z$" 1234.4321123 = %20.10f" cprintf CR 4DROP ;
TESTF

CR wait CLS

.( 6 . Now, the most fasinating feature of this package ....) BEEP
CR .( * Now, demonstrating infix C++ functions ...) CR wait
.( * See the source codes for the following : )

: test1 (( -- ))
  cprintf( Z$" %f" , atof( Z$" 1234.4312" ) ); 4DROP ;

CR test1 CR wait

: test2 (| a b -- |)
  cprintf( Z$" 1234.4321 = %f, (a,b) = (%d,%d)." ,
           atof( Z$" 1234.4321" ) , a , b ); DROP ;
CR 1 2 test2 CR wait

CREATE screen-buffer 80 25 * 2 * ALLOT
: test3 (| -- |)
        gettext( 1 , 1 , 80 , 25 , screen-buffer ); DROP
        TEST-RND TEST-RND CR ."  About to restore original screen ..." wait
        puttext( 1 , 1 , 80 , 25 , screen-buffer ); DROP ;
test3 wait



: TEST1 (( -- ))
        cprintf( Z$" %f" , atof( Z$" 1234.4312" ) ); 4DROP ;
CR TEST1 wait

: TEST2 (| a b -- |)
        cprintf( Z$" 1234.4321 = %f, (a,b) = (%d,%d)." ,
                 atof( Z$" 1234.4321" ) , a , b ); 
        DROP ;
CR 1 2 TEST2 wait

normvideo

CREATE strbuf1  40 ALLOT
CREATE strbuf2  40 ALLOT

: TEST3 (| -- |)
        cprintf( Z$" Depper nesting function : asin(0.5) = %f " ,
               atof(
                   sprintf( strbuf1 , Z$" %f" ,
                          asin(
                              atof( Z$" 0.5" )
                              )
                          )
                   DROP strbuf1 )
               ); DROP ;
                
CR TEST3 CR
.( The return value of 'asin' should be : ) 0.5 FASIN F. CR wait

PI SQRT(2) F* FCONSTANT X       // SQRT(2)*PI

: TEST4 (| -- |)
        ." * Floating package test ..." CR
        ." * 23.4324 7.43223  F** = " 23.4324 7.43223 F** F. CR
        cprintf( Z$" * pow(23.4324,7.43223) = %12.10f" , 
                 pow( 23.4324 , 7.43223 ) ); DROP CR
        ." * sin(asin(0.1234)) =" 0.1234 FSIN FASIN F. 
        cprintf( Z$"  = %12.10f" , sin( asin( 0.1234 ) ) ); DROP CR
        ." * X = " X F. CR
        ." * log(X) = " X FLOG F. CR
        ." *  ln(X) = " X FLN  F. CR
        ." *  lg(X) = " X FLG  F. CR
        ." * exp(X) = " X FEXP F. CR ;
CR TEST4 CR
