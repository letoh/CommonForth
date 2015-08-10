// TURNKEY system saving : PharLap version
			// Written by : Luke Lee  01/25/'96 .. 01/28/'96
			// Version : 1.1
//      update : 01/30/'96
// Last update : 02/29/'96 : Add TurnkeySystemFiles, TurnkeySystemExisted? 
//                           and modify TurnKeyable? .

NEEDS RKSEARCH.4TH

FORTH DEFINITIONS

: FEXISTED?       (( $name -- T/F ))
	COUNT READ/ONLY OPEN TUCK IF HCLOSE ENDIF DROP ; 1 1 #PARMS

HIDDEN ALSO DEFINITIONS

: TurnkeySystemFiles    (( -- $name1 $name2 ))
//      $" GO32.EXE"     $" TURNKEY."   // GO32 version.
//      $" STUB386.EXE"  $" TURNKEY."   // Phar Lap RUN386 version 4.0
//	$" NUL"          $" CF.EXE"     // PMode/W version
	$" NUL"          $" TURNKEY.EXE"     // Borland C++ version
	; 0 2 #PARMS

CREATE TKEY_BUF1 40 ALLOT
CREATE TKEY_BUF2 40 ALLOT

DEFER MemAlloc  1 1 #PARMS      // as malloc()
DEFER MemFree   1 0 #PARMS      // as free()

: (Alloc)       (( size -- a/0 ))   // support stack-like memory manager only
	DUP 16 +  HP @ HERE -  <=  IF
	   DUP , RKMagic ,
	   HERE SWAP ALLOT
	ELSE
	   DROP 0
	ENDIF ; 1 1 #PARMS

: (Free)        (( addr -- ))   // cannot free memory blocks randomly
	DUP CELL- @ RKMagic = IF
	    >R R@ CELL- CELL- @
	    HERE R@ - = IF  // free only when size matched
			    // prevent accidental free
	       R@ CELL- CELL-  CP  !
	       0,0  HERE  2!
	    ENDIF
	    RDROP
	ELSE
	    DROP
	ENDIF ; 1 0 #PARMS

: InitMemMgr    (( -- ))
	" malloc" EXISTED?  " free" EXISTED?
	2DUP 0= SWAP 0= OR IF
	    2DROP ['] (Alloc) ['] (Free) 
	ENDIF 
	IS MemFree IS MemAlloc  ; 0 0 #PARMS
InitMemMgr

: NoExtension?  (( $name -- T/F ))
	COUNT 1- 0 MAX FOR 
	    DUP #I + C@ ASCII . <>
	    WHILE
	NEXT 
	      TRUE
	    ELSE
	      FALSE
	    THEN
	NIP ; 1 1 #PARMS
	
: TurnkeySystemExisted? (( -- T/F ))
	$" * Cannot TURNKEY without file : "
	TurnkeySystemFiles
	DUP FEXISTED? IF
	   SWAP DUP FEXISTED? IF     3DROP TRUE EXIT    ENDIF
	ENDIF
	NIP SWAP CR .$ .$ CR FALSE ; 0 1 #PARMS
	
: TurnKeyable?   (( $name -- T/F ))
	TurnkeySystemExisted? ANDTHEN
	DUP C@ 1 8 [...] ANDTHEN
	DUP NoExtension? THEN-AND NIP ; 1 1 #PARMS

CREATE OldFSaveName 20 ALLOT

36 BASE !
CREATE PatchMarker LUKECF , BINDCF ,    // MUST BE CONSISTENT WITH BIND.H
DECIMAL

: PatchSizeIntoTurnkey  (| $name | handle fsize mblk -- T/F |)
	0 TO handle  0 to mblk  TKEY_BUF1 OFF 
	TKEY_BUF1 $name COUNT $+ " .EXE" $+ COUNT READ/WRITE OPEN
	ANDTHEN // handle
	   to handle  SEEK_END 0 handle HSEEK
	ANDTHEN // fsize
	   to fsize  SEEK_SET 0 handle HSEEK
	ANDTHEN // 0
	   DROP  fsize MemAlloc DUP 0<>
	ANDTHEN // buf
	   to mblk  mblk fsize handle HREAD
	ANDTHEN // size
	   DROP  PatchMarker 8 mblk fsize RKSEARCH DUP -1 <>
	ANDTHEN // off
	   SEEK_SET SWAP handle HSEEK
	ANDTHEN // off
	   DROP TKEY_BUF1 8 ERASE fsize TKEY_BUF1 !
	   TKEY_BUF1 8 handle HWRITE
	ANDTHEN // 8
	   DROP " CF.IMG" mblk fsize RKSEARCH DUP -1 <>
	ANDTHEN // off
	   SEEK_SET SWAP handle HSEEK
	ANDTHEN // off
	   DROP " ________.___" handle HWRITE
	ANDTHEN // len
	   DROP " CF.HED" mblk fsize RKSEARCH DUP -1 <>
	ANDTHEN // off
	   SEEK_SET SWAP handle HSEEK
	ANDTHEN // off
	   DROP TKEY_BUF1 40 ERASE
	   TKEY_BUF1 $name COUNT $+ " .HED" $+ COUNT
	   12 MIN 12 MAX handle HWRITE // write 12 byte name
	THEN-AND NIP
	to T/F
	handle IF  handle HCLOSE T/F AND TO T/F  ENDIF
	mblk IF mblk MemFree ENDIF  ;

: OpenReadFile  (| $fname -- T/F handle size |)
	0 to handle  0 to size
	   $fname COUNT READ/ONLY OPEN
	ANDTHEN  // fhandle
	   to handle  SEEK_END 0 handle HSEEK
	ANDTHEN  // fsize
	   to size SEEK_SET 0 handle HSEEK      // reset file pointer to start
	THEN-AND NIP  to T/F ;

: FMerge   (| $fname1 $fname2 $destfname | h1 h2 sz1 sz2 mem -- T/F |)
      // Merge fname1+fname2 into 'destfname', 
      // 'destname' must be a counted ASCIIZ string.
	0 to mem
	   $fname1 OpenReadFile to sz1 to h1 DUP      ANDTHEN // T
	   DROP $fname2 OpenReadFile to sz2 to h2 DUP ANDTHEN // T
	   DROP sz1 sz2 + MemAlloc DUP                ANDTHEN // mem
	   to mem 
	   mem sz1 h1 HREAD                           ANDTHEN // sz1
	   DUP sz1 =                                  ANDTHEN // sz1
	   mem +  sz2  h2  HREAD                      ANDTHEN // sz2
	   DUP sz2 =                                  ANDTHEN // sz2
	   h1 HCLOSE 0 to h1                          ANDTHEN // sz2 
	   h2 HCLOSE 0 to h2                          ANDTHEN // sz2
	   DROP 0  $destfname 1+ HCREATE              ANDTHEN // hnd
	   to h1
	   mem  sz1 sz2 +  h1  HWRITE                 ANDTHEN // siz
	   DUP sz1 sz2 + =                            ANDTHEN // siz
	   h1 HCLOSE 0 to h1
	THEN-AND NIP  to T/F
	h1 IF  h1 HCLOSE DROP  ENDIF    h2 IF  h2 HCLOSE DROP  ENDIF
	mem IF  mem MemFree  ENDIF  ;

VARIABLE TkeyQuiet      TkeyQuiet OFF

: TCR      (( -- ))       TkeyQuiet @ NOT IF  CR  ENDIF ; 0 0 #PARMS
: TKeyMsg  (( $str -- ))  TkeyQuiet @ NOT IF  COUNT TYPE  ENDIF ; 1 0 #PARMS

FORTH DEFINITIONS

: $TURNKEY      (| ca $name -- |)
	InitMemMgr
	$name TurnKeyable? IF
	    TCR $" * Copy Common Forth system ..." TKeyMsg
	    TKEY_BUF2 40 ERASE // for ASCIIZ strings
	    TurnkeySystemFiles
	    TKEY_BUF2 $name COUNT $+ " .EXE" $+  FMerge
	  ANDTHEN
	    TCR $" * Patching ..." TKeyMsg
	    $name PatchSizeIntoTurnkey
	  ANDTHEN
	    $"  successful." TKeyMsg TCR $" * Saving new system ..." TKeyMsg
	    FSAVENAME OldFSaveName 20 MOVE
	    FSAVENAME 20 ERASE
	    $name FSAVENAME OVER C@ 1+ MOVE
	    'BOOT @ >R  ca 'BOOT !
	    ['] FSAVE CATCH 0=
	    R> 'BOOT !  OldFSaveName FSAVENAME 20 MOVE
	  ANDTHEN
	    TCR $" * Binding turnkey system ..." TKeyMsg
	    TKEY_BUF2  TKEY_BUF1 40 ERASE TKEY_BUF1 $name COUNT $+ " .IMG" $+
	    TKEY_BUF2  FMerge
	  THEN-AND
	  IF $"  complete."  ELSE  $"  failed."  ENDIF TKeyMsg TCR
	ELSE
	    $name COUNT TYPE TRUE ABORT" : Cannot turnkey with this file."
	ENDIF ;

: TBYE  ['] QUIT >NAME $" QUIT" 5 COMP 0<> IF  BYE'  ELSE  .OK  ENDIF ;

: TURNKEY       (( ca -- ))
	TOKEN $TURNKEY ; 0 0 #PARMS

ONLY FORTH ALSO DEFINITIONS

