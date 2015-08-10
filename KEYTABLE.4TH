// Key Mapping Table :
				// Written by  : Luke Lee on 01/16/'96
				// Version     : 1.0
				// Last update : 01/21/'96
				// 	update : 01/16/'96

// 01/21/'96 : (1) Add LastKey. (2) Modify Tabled?KEY to THROW error out.

HIDDEN ALSO DEFINITIONS

NIL VALUE CurrentKeyTable^
31  CONSTANT KeyTableItems	// a prime number closest to 32

STRUCT: KeyItem:
	HWORD: |KeyValue
	BYTE:  |KeyActive
	BYTE:  |NestingAllowed
	WORD:  |KeyAction
	WORD:  |NextKeyItem
;STRUCT

: []KeyTable  (( keyvalue -- []keytable ))
	KeyTableItems MOD SIZEOF KeyItem: LITERAL * 
	CurrentKeyTable^ +  ; 1 1 #PARMS

: AddKeyItem	(| nestable action keyvalue | olditem newitem -- |)
      // Note that this word will do ALLOT .
	keyvalue []KeyTable  to  olditem
	olditem |KeyValue H@ 0<> IF
	   HERE to newitem
	   newitem SIZEOF KeyItem: LITERAL DUP ALLOT ERASE
	   olditem newitem SIZEOF KeyItem: LITERAL MOVE
	   newitem  olditem |NextKeyItem  !
	ENDIF
	keyvalue  olditem |KeyValue   	   H!
	nestable  olditem |NestingAllowed  C! 
	action    olditem |KeyAction   	    ! ;

: GetAction	(| keyvalue -- thisitem action |)
	0 to action
	keyvalue []KeyTable to thisitem
	BEGIN
	   thisitem |KeyValue H@ keyvalue <>
	   WHILE
	      thisitem |NextKeyItem @ 0<>
	WHILE
	   thisitem |NextKeyItem @  to  thisitem
	REPEAT
	   ELSE
	      thisitem |KeyAction @ to action
	      thisitem |NestingAllowed C@ 0= IF
		 thisitem |KeyActive C@ 0<> IF  0 to action   ENDIF
	      ENDIF
	   THEN ;

: MarkActive	(( item -- ))	|KeyActive 1 SWAP C! ; 1 0 #PARMS

: MarkInactive	(( item -- ))	|KeyActive 0 SWAP C! ; 1 0 #PARMS

FORTH DEFINITIONS

: KEYTABLE:	(( -- )TIB: <name> )
	CREATE KeyTableItems SIZEOF KeyItem: LITERAL *
	    HERE OVER ALLOT OVER ERASE
	    LAST @ |SIZE !  ; 0 0 #PARMS
KEYTABLE: RootKeyTable

: SetKeyTable	(( keytable -- ))	to CurrentKeyTable^ ; 1 0 #PARMS
RootKeyTable SetKeyTable

: GetKeyTable	(( -- keytable ))	CurrentKeyTable^ ; 0 1 #PARMS

: NESTKEY:  (( key_value -- )TIB: action )
	1 SWAP ' SWAP AddKeyItem ; 1 0 #PARMS

: KEY:	(( key_value -- )TIB: action )
	0 SWAP ' SWAP AddKeyItem  ; 1 0 #PARMS

0 VALUE LastKey

HIDDEN DEFINITIONS

: Tabled?KEY	(( -- c T / F ))
	?BIOSKEY DUP IF // c T 
	   OVER to LastKey
	   OVER GetAction DUP 0<> IF // c T itm a
	      2SWAP 2DROP SWAP
	      DUP >R MarkActive
	      FALSE SWAP CATCH
	      R> MarkInactive
	      ?DUP IF  THROW  ENDIF
	   ELSE
	      2DROP
	   ENDIF
	ENDIF ;

: Tabled?KEY_CONSOLE	(( -- ))
	[ 'CONSOLE @ ] LITERAL EXECUTE
	['] Tabled?KEY  '?KEY  !  ; 0 0 #PARMS

' Tabled?KEY  	     '?KEY    !
' Tabled?KEY_CONSOLE 'CONSOLE !

ONLY FORTH ALSO DEFINITIONS

COMMENT:
NODEBUG @ NOT #IF

FLOAD DUMPFILE.4TH

: HELP BEEP " DUMPFILE MANUAL.DOC" TRANSLATE DROP CR ;

$3B00 KEY: HELP		// F1
$3C00 NESTKEY: HELP	// F2

#ENDIF
;COMMENT
