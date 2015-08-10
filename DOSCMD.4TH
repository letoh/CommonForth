// Common used DOS commands                         Written by : Luke Lee
//                                                  V1.0   04/16/'94
//                               		    V1.1   04/23/'94
//						    V1.2   10/11/'95
//					            V1.3   10/25/'95
//					V1.4 Last update : 07/02/'96

NEEDS INVOKEC.4TH

ALSO HIDDEN ALSO DEFINITIONS

CREATE DOS-COMMAND$     256 ALLOT

FORTH DEFINITIONS

DEFER ShellToDosHook  0 0 #PARMS	// 10/21/'95
DEFER BackFromDosHook 0 0 #PARMS

' NOOP DUP  IS ShellToDosHook  IS BackFromDosHook

: ?(EXEC-ERR)   (( c -- ))
        ?DUP IF
             ."  <-- "
             CASE
                $1 OF ." Invalid function call" ENDOF
                $2 OF ." Cannot find executable file or invalid path" ENDOF
                $5 OF ." Execution refused" ENDOF
                $8 OF ." Not enough memory to load program" ENDOF
                $A OF ." Incorrect environment contents" ENDOF
                $B OF ." invalid .EXE file format" ENDOF
             ENDCASE
             ." . " ABORT
        ENDIF ; 1 0 #PARMS INVISIBLE

HIDDEN DEFINITIONS

: ($>command)   (| cmd-str -- |)
	cmd-str COUNT + 0 SWAP C!	// zero trailing
	ShellToDosHook
	DOS-COMMAND$ C@ 0= IF
           spawnl( P_WAIT , getenv( Z$" COMSPEC" ) , Z$" " , NULL )
	ELSE
	   system( DOS-COMMAND$ 1+ )
        ENDIF
	BackFromDosHook
	0<> IF
	    errno ?(EXEC-ERR)
	ENDIF  ;

: $dos	(( str -- ))
	0 DOS-COMMAND$ !
	DOS-COMMAND$ SWAP COUNT $+ ($>command) ; 1 0 #PARMS

FORTH DEFINITIONS

: DOS	(( -- ))
	0 DOS-COMMAND$ !
	$0A PARSE DOS-COMMAND$ PACK$
	($>command)  ; 0 0 #PARMS

: DOS"	(( -- ))
	\ $" COMPILE $dos ; 0 0 #PARMS IMMEDIATE

: $DOS	(( A -- ))  $dos ; 1 0 #PARMS

HIDDEN DEFINITIONS

: ($...$>command) (( cmdstr -- )TIB: cmdstr <str> ... <str> -- )
        CR 0 DOS-COMMAND$ !
	DOS-COMMAND$ SWAP COUNT $+ $0A WORD COUNT $+ 
	($>command) ; 1 0 #PARMS

: DOSCMD:       (( -- ))
        CREATE
           HERE 0 OVER !	// clear HERE
           LAST @ |NAME-LENGTH COUNT $+ "  " $+ 
	   COUNT 1+ ALLOT DROP
        DOES>
           ($...$>command) ;

: DOSCMDS:
        BEGIN
           >IN @ BL WORD SWAP >IN !
        C@ 0<> WHILE
           DOSCMD:
        REPEAT ;

FORTH DEFINITIONS

DOSCMDS: DIR COPY DEL XCOPY ECHO MD MKDIR RD RMDIR CD CHDIR MEM CHKDSK
DOSCMDS: TREE PATH RENAME REN MODE

ONLY FORTH ALSO DEFINITIONS

