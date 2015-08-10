// File operation examples :                 Written by : Luke Lee
//                                           Date : 11/21/'95

NEEDS SEE.4TH
NEEDS DOSCMD.4TH

// /////////////////////////////////////////////////////////////////////
// Example1 : Link two computer with RS-232, with remote control example
// /////////////////////////////////////////////////////////////////////

CREATE $COM          10 ALLOT   $COM         OFF
CREATE $ModeCommand  80 ALLOT   $ModeCommand OFF

1 CONSTANT COM1   2 CONSTANT COM2    3 CONSTANT COM3    4 CONSTANT COM4

0 CONSTANT NONE   1 CONSTANT EVEN   2 CONSTANT ODD

// : $+   (( target$ src len -- target$ ))
// Concat source string into a counted-string.
// Note that target$ buffer must be large enough.
//   target$ : counted string
//   src     : source string address ( not including the count byte )
//   len     : the length to concat

: +","  (( str -- str ))    // concat "," into string 'str'
        " ," $+   ; 1 1 #PARMS

// Example :
// COM2 2400 NONE 8 1 INITCOM
: INITCOM  (| COM# speed parity bits stop-bits -- |)
     // Initialize communication port with DOS "MODE" command.
        0 $ModeCommand C!   0 $COM C! // clear string length
        $COM " COM" $+   COM# <# # #>   $+  DROP
        $ModeCommand " MODE " $+   $COM COUNT   $+  +"," // MODE COM2,
        speed <# #S #>  $+ +","         // MODE COM2,2400,
        parity CASE
           NONE OF  " N"  ENDOF
           EVEN OF  " E"  ENDOF
           ODD  OF  " O"  ENDOF
           " ???"
        ENDCASE  $+ +","                // MODE COM2,2400,N,
        bits <# #S #>  $+  +","         // MODE COM2,2400,N,8,
        stop-bits <# #S #>  $+          // MODE COM2,2400,N,8,1
        $DOS ;

// : FOPEN (( stradr len mode -- handle True / err-code False ))
//        If file already exists, open it with 'mode'
//     otherwise create a new file .
// : HREAD (( buffer bytes handle -- bytes-read T / err-code F ))
// : HWRITE  (( buffer bytes handle -- bytes-written T / err-code F ))

VARIABLE CharBuf

: HGetChar (( handle -- char ))
        CharBuf 1 ROT HREAD IF
           DROP CharBuf C@
        ELSE
           CR ." Error reading file : " HERROR$ COUNT TYPE CR ABORT
        ENDIF ; 1 1 #PARMS

: HPutChar (( char handle -- ))
        SWAP CharBuf C!
        CharBuf 1 ROT HWRITE IF
           DROP
        ELSE
           CR ." Error writing file : " HERROR$ COUNT TYPE CR ABORT
        ENDIF ; 2 0 #PARMS

: LOCAL-ECHO    (( C -- ))
        CASE
           0                   OF      ENDOF // DO-NOTHING
           [ CTRL M ] LITERAL  OF  CR  ENDOF
           [ CTRL D ] LITERAL  OF ." * End transmission ." CR  ENDOF
           DUP EMIT     // default action
        ENDCASE PAUSE ; 1 0 #PARMS

: FailOpen      (( e $fname -- ))
        SWAP CR HERROR$ // convert error code into error message
        COUNT TYPE BEEP
        CR ." * Fail openning " COUNT TYPE ; 2 0 #PARMS

: FailOpenRead  (( e $fname -- ))
        FailOpen ."  for reading." CR ; 2 0 #PARMS

: FailOpenWrite (( e $fname -- ))
        FailOpen ."  for writing." CR ; 2 0 #PARMS

: SEND  (( -- ))
        $COM COUNT WRITE/ONLY FOPEN IF
            >R CR ." * RS-232 successfully openned for writing." CR
            BEGIN
               KEY  DUP R@ HPutChar (( to RS-232 ))
               DUP LOCAL-ECHO (( to Local Video ))
               [ CTRL D ] LITERAL  =
            UNTIL
            R> HCLOSE DROP
        ELSE
            $COM FailOpenWrite
        ENDIF ; 0 0 #PARMS

: RECV  (( -- ))
        $COM COUNT READ/ONLY FOPEN IF
            >R CR ." * RS-232 successfully openned for reading." CR
            BEGIN
               R@ HGetChar
               DUP LOCAL-ECHO
               [ CTRL D ] LITERAL =
            UNTIL
            R> HCLOSE DROP
        ELSE
            $COM FailOpenRead
        ENDIF ; 0 0 #PARMS

// Remote control : A control B
// Computer B : REMOTE-CONTROL
// Computer A : SEND
//    Thus any command enterred will executed under computer B
//    execute LOCAL-CONTROL will back to local .

0 VALUE RS232-READ      0 VALUE RS232-WRITE

VARIABLE OLD-'?KEY      VARIABLE OLD-'EMIT

: REMOTE-?KEY   (( -- C T  / -- F )
        RS232-READ HGetChar ?DUP 0<> ;

: REMOTE-EMIT   (( c -- ))
        RS232-WRITE HPutChar ; 1 0 #PARMS

: REMOTE-OPEN   (( -- ))
        $COM COUNT READ/ONLY FOPEN IF
            TO RS232-READ
            $COM COUNT WRITE/ONLY FOPEN IF
                TO RS232-WRITE
            ELSE
               $COM FailOpenWrite ABORT
            ENDIF
        ELSE
            $COM FailOpenRead ABORT
        ENDIF ;

: REMOTE-CONTROL        (( -- ))
        REMOTE-OPEN
        ['] REMOTE-?KEY '?KEY ! ;

: LOCAL-CONTROL    (( -- ))
        RS232-READ HCLOSE DROP
        RS232-WRITE HCLOSE DROP
        OLD-'?KEY @ '?KEY !
        OLD-'EMIT @ 'EMIT ! ;

'?KEY @ OLD-'?KEY !     'EMIT @ OLD-'EMIT !

// /////////////////////////////////////////////////////////////////////
// Example 2 : File copy wich C function call
// /////////////////////////////////////////////////////////////////////

: FCOPY (| | src dest buffer #bytes -- |)
     // Read GO32.EXE and write GO32.BIN
        fopen( Z$" GO32.EXE" , Z$" rb" ) to src
        src NULL = IF
            CR ." Fail openning GO32.EXE for read ." ABORT
        ENDIF
        fopen( Z$" GO32.BIN" , Z$" wb" ) to dest
        dest 0= IF
           fclose( src ); DROP
           CR ." Fail openning GO32.BIN for write ." ABORT
        ENDIF
        malloc( 8192 ) to buffer
        buffer NULL = IF
           fclose( src ); fclose( dest ); 2DROP
           CR ." Fail allocating 8k buffer ." ABORT
        ENDIF
        BEGIN
           fread( buffer , 1 , 8192 , src ) to #bytes
           fwrite( buffer , #bytes , 1 , dest ) DROP
           #bytes 8192 <
        UNTIL
        fclose( src ); fclose( dest ); 2DROP
        free( buffer )   ;

