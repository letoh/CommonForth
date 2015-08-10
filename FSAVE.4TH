// System Image Saving for Common Forth 1.66x and later
			// Written by : Luke Lee
                        // Last update : 03/04/'96
                        // Version : 2.1

// Turnkey system : just drop the created CF.HED . 
// From version 1.660, TURNKEY.4TH supported for this.
// Update history :
// ... 08/28/'96 : Not recorded.
// 01/29/'96 : Smaller image file, user area/data stack/return stack
//	       image size reduced . Thus needs MULTASK.4TH before FSAVE.4TH.
// 03/04/'96 : Modify go-saving, reset FSAVENAME length before performing
//	       save-system-image	

DECIMAL

HIDDEN DEFINITIONS

// System file format :   
//  | Header | Code-image | User-image | DStack-image | RStack-image |

STRUCT: SYSTEM-FILE-HEADER:     // including user space
        WORD:   |LOADER-ENV-ADDRESS
        WORD:   |CODE-SPACE-ADDRESS     // code space
        WORD:   |USER-SPACE-ADDRESS     // user space
        WORD:   |CODE-SPACE-SIZE
        WORD:   |USER-SPACE-SIZE
	WORD:	|DSTACK-ADDRESS
	WORD:	|DSTACK-SIZE
	WORD:	|RSTACK-ADDRESS
	WORD:	|RSTACK-SIZE
;STRUCT: SYSTEM-IMAGE-HEADER

// Head file format :   |Header|Head-image|

STRUCT: HEAD-FILE-HEADER:       // including vocabulary hash table
        WORD:   |HEAD-SPACE-ADDRESS
        WORD:   |HEAD-SPACE-SIZE
;STRUCT: HEAD-IMAGE-HEADER

: write-file (( buffer bytes handle -- ))
    DUP >R HWRITE IF 
        R> 2DROP
    ELSE 
        CR ." Error writing file : " HERROR$ TYPE ASCII . EMIT
        R> HCLOSE CR ABORT
    ENDIF ; 3 0 #PARMS

: save-system-image (( handle -- ))
    >R  
    BASE-ADDRESS                SYSTEM-IMAGE-HEADER |CODE-SPACE-ADDRESS   !
    HERE BASE-ADDRESS -         SYSTEM-IMAGE-HEADER |CODE-SPACE-SIZE      !
    BASE-ADDRESS |INIT-ENVIRON  SYSTEM-IMAGE-HEADER |LOADER-ENV-ADDRESS   !
    BASE-ADDRESS |WORK-SPACE |USER-AREA
    DUP                         SYSTEM-IMAGE-HEADER |USER-SPACE-ADDRESS   !
    ^TASK @ SWAP - |USERS| +    SYSTEM-IMAGE-HEADER |USER-SPACE-SIZE      !
    ^DSTACK @ USER|DSTACK| -	
    DUP				SYSTEM-IMAGE-HEADER |DSTACK-ADDRESS	  !
    SP0 @ SWAP -  		SYSTEM-IMAGE-HEADER |DSTACK-SIZE	  !
    ^RSTACK @ USER|RSTACK| -
    DUP				SYSTEM-IMAGE-HEADER |RSTACK-ADDRESS	  !
    RP0 @ SWAP -  		SYSTEM-IMAGE-HEADER |RSTACK-SIZE	  !

   // 1. Save header
    SYSTEM-IMAGE-HEADER   SIZEOF SYSTEM-IMAGE-HEADER LITERAL   R@  write-file
   // 2. Save code space
    BASE-ADDRESS   SYSTEM-IMAGE-HEADER |CODE-SPACE-SIZE @   R@  write-file
   // 3. Save user space
    SYSTEM-IMAGE-HEADER DUP |USER-SPACE-ADDRESS @   SWAP |USER-SPACE-SIZE @
    R@ write-file
   // 4. Save data stack
    SYSTEM-IMAGE-HEADER DUP |DSTACK-ADDRESS @   SWAP |DSTACK-SIZE @
    R@ write-file
   // 5. Save return stack
    SYSTEM-IMAGE-HEADER DUP |RSTACK-ADDRESS @   SWAP |RSTACK-SIZE @
    R@ write-file

    R> HCLOSE DROP ; 1 0 #PARMS

: save-head-image (( handle -- ))
    >R  
    HP @        HEAD-IMAGE-HEADER |HEAD-SPACE-ADDRESS   !
    BASE-ADDRESS |WORK-SPACE |END-FORTH-VOCTABLE   HP @  -
                HEAD-IMAGE-HEADER |HEAD-SPACE-SIZE      !
   // 1. Save header
    HEAD-IMAGE-HEADER  SIZEOF HEAD-IMAGE-HEADER LITERAL  R@ write-file
    HP @    HEAD-IMAGE-HEADER |HEAD-SPACE-SIZE @         R@ write-file
    R> HCLOSE DROP ; 1 0 #PARMS
        
: fail-open (( errcode str len -- ))
        CR ." Error: " ROT HERROR$ TYPE
        ." , fail openning file " TYPE SPACE ASCII . EMIT CR
        ABORT ; 3 0 #PARMS
        
CREATE FSAVENAME $," CF" 0 , 0 , 0 , 0 , 0 , // length > 20

: go-saving (( -- ))
	MULTI? >R SINGLE
        ONLY FORTH DEFINITIONS
        FSAVENAME C@ >R 
        0 FSAVENAME " .IMG" $+ 1+ HCREATE  IF
	   R@ FSAVENAME C! save-system-image
	ELSE
	   FSAVENAME COUNT fail-open 
	ENDIF
        0 FSAVENAME " .HED" $+ 1+ HCREATE
	IF save-head-image ELSE " CF.HED" fail-open ENDIF 
        R> FSAVENAME C!
	R> IF MULTI ENDIF ; 0 0 #PARMS

ALSO FORTH DEFINITIONS

: FSAVE (( -- ))  go-saving ; 0 0 #PARMS

' FSAVE ALIAS SAVE-SYSTEM

