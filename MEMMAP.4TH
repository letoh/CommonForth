// This file describes the memory structure of Common Forth 1.65

: K (( n -- nK )) 1024 * ; 1 1 #PARMS
: M (( n -- nM )) 1024 K * ; 1 1 #PARMS

$480000         CONSTANT        BASE-ADDRESS

4 M             CONSTANT        CF-MemorySpace

1024 CELL*      CONSTANT        |HASHTABLE| // Hash Table size
128 CELL*       CONSTANT        |USERS|     // user space size
256             CONSTANT        |FBUF-SAFETY|
64              CONSTANT        #TASKS
64              CONSTANT        #BUFFERS
	
	// ----------------------------------------------------------- 
	STRUCT: HighMemoryMap
		4 K                     FIELD: |FORTH-VOCTABLE
		16                      FIELD: |END-FORTH-VOCTABLE

		|USERS| #TASKS *        FIELD: |USER-AREA // support 64 tasks
		16                      FIELD: |END-USER-AREA

	     // There are 256 bytes safety margin between two buffers.
		4 K |FBUF-SAFETY| +     FIELD: |TERMINAL-INPUT-BUFFER
		#BUFFERS 1-  4 K |FBUF-SAFETY| +  *
					FIELD: |BUFFERS   // 63 other buffers
		32                      FIELD: |END-BUFFERS
		
		8 K #TASKS *            FIELD: |DATA-STACK
		32                      FIELD: |END-DATA-STACK

		8 K #TASKS *            FIELD: |RETURN-STACK
		16                      FIELD: |END-RETURN-STACK
	;STRUCT
	// ----------------------------------------------------------- 

// --------------------------------------------------------------------------
STRUCT: CF-MemoryMap
	4 K   FIELD:   |STARTUP-CODES
	// ----------------------------------------------------------- 
	STRUCT: LoaderEnviron
		WORD:  |ARGC
		WORD:  |ARGV
		WORD:  |ENVP
		WORD:  |C(++)Linking()          INVISIBLE
		WORD:  |C(++)EndLinking()       INVISIBLE
		WORD:  |C(++)FarPatch           INVISIBLE  // Not used yet.
	    // Only CS, DS and ES, SS are setup by loader, all other registers
	    // are saved by CF's initial codes.
		STRUCT: RegisterPair386 INVISIBLE
			WORD: |EAX      INVISIBLE // No need to restore
			WORD: |EBX      INVISIBLE // No need to restore
			WORD: |ECX      INVISIBLE // No need to restore
			WORD: |EDX      INVISIBLE // No need to restore
			WORD: |ESI      INVISIBLE 
			WORD: |EDI      INVISIBLE 
			WORD: |EBP      INVISIBLE // MUST be restored
			WORD: |ESP      INVISIBLE // MUST be restored
			WORD: |CS       INVISIBLE // * setup by loader
			WORD: |DS       INVISIBLE // * setup by loader
			WORD: |ES       INVISIBLE // * setup by loader
			WORD: |SS       INVISIBLE // * setup by loader
			WORD: |FS       INVISIBLE
			WORD: |GS       INVISIBLE
		;STRUCT: |OriginalRegisters INVISIBLE // original reg. values
		256 FIELD: |LoadingInfo INVISIBLE
	;STRUCT:        |INIT-ENVIRON
	// ----------------------------------------------------------- 
	WORD:           |COLD-VECTOR
	// -----------------------------------------------------------
	CF-MemorySpace  SIZEOF |STARTUP-CODES -  SIZEOF LoaderEnviron -
			SIZEOF |COLD-VECTOR -    SIZEOF HighMemoryMap -
		FIELD:  |CODE&HEAD-SPACE
	// -----------------------------------------------------------
	HighMemoryMap   |WORK-SPACE
;STRUCT
// --------------------------------------------------------------------------

BASE-ADDRESS |WORK-SPACE |END-FORTH-VOCTABLE  CONSTANT  HP0


