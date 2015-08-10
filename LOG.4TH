// LOG.4TH        11/20/1995  by Sam Chen for Common Forth 1.642
              //  07/30/'96   modified by Luke Lee.

// To log FORTH words:  NEEDS LOG.4TH   LOGTO WORDS.LOG   FORTH WORDS   LOGEND

NEEDS GRAPHICS.4TH  // Compatiable with GRAPHICS

ONLY HIDDEN ALSO DEFINITIONS

CREATE Buf   200 ALLOT   HERE VALUE Lmt   Buf VALUE Out   0 VALUE Hnd

FALSE    VALUE Logging?
' ABORT  VALUE OrigEmit
FALSE    VALUE LogPause?

: LogDmp (( -- ))  Buf   Out Buf -   Hnd   write-file   Buf IS Out ;

: LogEmt (( c -- ))
        LogPause? NOT IF
           DUP Out C!   Out 1+ IS Out   Out Lmt =
           IF   LogDmp   THEN
        ENDIF
        OrigEmit EXECUTE ;

: LOG-GRAPHICS
        Logging? IF  OrigEmit 'EMIT !  ENDIF
        DEFERS HOOK-GRAPHICSMODE ;

' LOG-GRAPHICS IS HOOK-GRAPHICSMODE

: GRAPHICS-LOG
        DEFERS GRAPHICSMODE-HOOK
        Logging? IF  
           'EMIT @  to  OrigEmit
           ['] LogEmt  'EMIT !  
        ENDIF ;

' GRAPHICS-LOG IS GRAPHICSMODE-HOOK

: LOG-TEXTMODE
        Logging? IF  OrigEmit 'EMIT !  ENDIF
        DEFERS HOOK-TEXTMODE ;

' LOG-TEXTMODE IS HOOK-TEXTMODE
        
: TEXTMODE-LOG
        DEFERS TEXTMODE-HOOK
        Logging? IF         
           'EMIT @  to  OrigEmit
           ['] LogEmt  'EMIT !  
        ENDIF ;

' TEXTMODE-LOG IS TEXTMODE-HOOK
'EMIT @ to OrigEmit
        
FORTH DEFINITIONS

: LOGPAUSE      (( -- ))        TRUE to LogPause? ;     // PAUSE logging
: LOGCONTI      (( -- ))        FALSE to LogPause? ;    // Continue logging

: LOGTO (( <FILE> -- ))
        Logging? ABORT" LOG : Already logging ."
        0   TOKEN 1+   HCREATE   0=
        IF   ." Can't create log file, error code " . ABORT   THEN
        IS Hnd   Buf IS Out
        TRUE to Logging?
        LOGCONTI
        'EMIT @ to OrigEmit    ['] LogEmt 'EMIT ! ;

: LOGEND (( -- )) 
        Logging? NOT ABORT" LOG : Not logging ."
        FALSE to Logging?
        Out Buf >   IF   LogDmp   THEN
        Hnd HCLOSE   0= ABORT" Can't close log file"   OrigEmit 'EMIT ! ;

HIDDEN DEFINITIONS

: LOGBYE  (( -- ))
        Logging? IF LOGEND ENDIF 
        [ BYEFUNC^ @ ] LITERAL EXECUTE ;

' LOGBYE BYEFUNC^ !

: LOG_CONSOLE
	'EMIT @ >R
	[ 'CONSOLE @ ] LITERAL EXECUTE
	R> 'EMIT !  ;

' LOG_CONSOLE 'CONSOLE !

ONLY FORTH ALSO DEFINITIONS

