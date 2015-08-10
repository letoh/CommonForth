// This file describes the memory structure of Common Forth 1.7XX

					// Version 1.7
					// Last update : 02/18/'97

// 11/15/'96 : Put |DATA-STACK under |RETURN-STACK, so that nesting 
//             C/FORTH call will not cause 'Stack underflow !' error since
//             every nesting call switch data/return stack once.
// 02/09/'97 : Enlarge |FBUF-SAFETY|. Move constant BASE-ADDRESS to CF0.4TH .
// 02/18/'97 : STRUCT.4TH is modified for data alignments. No more padding 
//             field for data alignments.

: K     ( n -- nK ) 1024 * ; 1 1 #PARMS MACRO
: M     ( n -- nM ) [ 1024 K ] LITERAL * ; 1 1 #PARMS MACRO

4 M             CONSTANT        CF-MemorySpace

1024 CELL*      CONSTANT        |HASHTABLE| // Hash Table size
128 CELL*       CONSTANT        |USERS|     // user space size   128 vars
256 16 +        CONSTANT        |FBUF-SAFETY|
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

		8 K #TASKS *            FIELD: |RETURN-STACK
		32                      FIELD: |END-RETURN-STACK
		
		8 K #TASKS *            FIELD: |DATA-STACK
		32                      FIELD: |END-DATA-STACK
	;STRUCT
	// ----------------------------------------------------------- 

// --------------------------------------------------------------------------
STRUCT: CF-MemoryMap
	// --------------   Startup  Codes  Area  --------------------
	4 K   FIELD:   |STARTUP-CODES
	// --------------   Loader  Environment   -------------------- 
	STRUCT: LoaderEnviron
		WORD:  |ARGC
		WORD:  |ARGV
		WORD:  |ENVP
		WORD:  |C(++)Linking()          INVISIBLE
		WORD:  |C(++)EndLinking()       INVISIBLE
		WORD:  |C(++)FarPatch           INVISIBLE  // Not used yet.
	    // Only CS, DS and ES, SS are setup by loader, all other registers
	    // are saved by CF's initial codes. This data structure is 
	    // compatiable to DPMI funcion call $0300 .
            // With INVOKEC.4TH , C function SimulateRealModeInterrupt
		STRUCT: RegPair386:
			WORD: |EDI
			WORD: |ESI
			WORD: |EBP                      // MUST be restored
			WORD: |Reserved_zeros INVISIBLE
			WORD: |EBX
			WORD: |EDX
			WORD: |ECX
			WORD: |EAX
		       HWORD: |FLAGS
		       HWORD: |ES       // * setup by loader
		       HWORD: |DS       // * setup by loader
		       HWORD: |FS
		       HWORD: |GS
		       HWORD: |IP
		       HWORD: |CS       // * setup by loader
		       HWORD: |SP
		       HWORD: |SS       // * setup by loader
			WORD: |ESP                      // MUST be restored
		;STRUCT: |OriginalRegisters INVISIBLE // original reg. values
		256 FIELD: |LoadingInfo INVISIBLE
		// Conventional memory info : 07/10/'96..07/11/'96
		WORD:  |TransferBuf     // real mode transfer buffer address
		WORD:  |TransferSiz     // real mode transfer buffer size
		WORD:  |DOS-Selector    // real mode selector
	;STRUCT:        |INIT-ENVIRON
	// -------------   COLD Boot vector   ------------------------ 
	WORD:           |COLD-VECTOR
	// -------------   Code/Free/Head Space   --------------------
	CF-MemorySpace  SIZEOF |STARTUP-CODES -  SIZEOF LoaderEnviron -
			SIZEOF |COLD-VECTOR -    SIZEOF HighMemoryMap -
		FIELD:  |CODE&HEAD-SPACE
	// -------------  User areas/Buffers/Stacks  -----------------
	HighMemoryMap   |WORK-SPACE
;STRUCT
// --------------------------------------------------------------------------

BASE-ADDRESS |WORK-SPACE |END-FORTH-VOCTABLE  CONSTANT  HP0

