// INFIX syntax demonstration :
					// Written by  : Luke Lee
					// Last update : 09/26/'95

// precedence :
//       1. ( )
//       2. **  F** 		 : exponential
//       3. +  -  NOT  ABS  FABS : uniary operators
//       4. *  /  MOD  F*  F/
//       5. +  -  F+  F-
//       6. >  <  >=  <=  =  <>
//       7. AND OR XOR
// 

: press	."  ... Press any key ..." KEY DROP ;

NEEDS SEE.4TH
NEEDS 387FLOAT.4TH
NEEDS INFIX.4TH
.( * Infix Grammar loaded ) press

.INFIX // show result

CLS // ----------------------------------------------------------------
.( "LineBuffer" is a string buffer for storing the preprocessing result. )
CR CR .( * 1. Interpreting mode : -----------------------) CR

10 VALUE X
20 VALUE Y

.( <( 1234 + 4312 * 12 / 5 MOD 6 - 882 * X / Y * ABS -1234 ) 
CHAR ) EMIT CHAR > EMIT
<( 1234 + 4312 * 12 / 5 MOD 6 - 882 * X / Y * ABS -1234 )>
.(  Execution Result = ) . CR CR

.( <( 413.123 F+ 4321.1234 F* 0.001 F- 123889.1233 F+ 1283990.6989 )
CHAR ) EMIT CHAR > EMIT
<( 413.123 F+ 4321.1234 F* 0.001 F- 123889.1233 F+ 1283990.6989 )>
.(  Execution Result = ) F. CR CR
press // ----------------------------------------------------------------

CR CR .( * 2. Compiling mode : --------------------------) CR

.( : TEST  <( 321 * 876 / X  > 5  AND  432 / Y * 987 < 12039 ) 
                                  CHAR ) EMIT CHAR > EMIT .(   ;) CR
: TEST  <( 321 * 876 / X  > 5  AND  432 / Y * 987 < 12039 )>   ;
SEE TEST
.(  Execution Result = ) TEST . CR
press // ----------------------------------------------------------------

CR CR .( * 3. Compiling mode with stack expression : ----) CR

: .TEST' 
	." : TEST' (| a b | c -- p |)" CR
	TAB ." <( a + b * 10 - 2 ** 6 )> to c" CR
	TAB ." <( c * X ** 2 + a * X * Y - Y ** 2 )> to p  ; // cX^2+aXY-Y^2" CR
	;

.TEST'
: TEST' (| a b | c -- p |)
	<( a + b * 10 - 2 ** 6 )> to c
	<( c * X ** 2 + a * X * Y - Y ** 2 )> to p  // cX^2+aXY-Y^2
	;

.( 9 7 TEST' Execution Result = ) 9 7 TEST' . CR

.INFIX	// stop displaying

