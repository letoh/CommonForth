// Command input history recording, with a simple line editor

				      // Written by : Luke Lee
				      // Version 1.3
				      //      V1.1    [ 04/23/'94 ]
				      //              [ 05/15/'94 ]
				      // Last update  [ 10/18/'95 ]

HIDDEN ALSO DEFINITIONS

64    CONSTANT #max-history
84    CONSTANT cmd-length

cmd-length #max-history *   CONSTANT    |history|

CREATE  HISTORIES       |history|    ALLOT

HISTORIES   VALUE ^history    1  VALUE #history

FORTH DEFINITIONS

DEFER dokey 4 2 #PARMS

: CLEAR-KEYBUF (( -- ))
	HISTORIES |history| ERASE
	HISTORIES   => ^history    1 => #history        ; 0 0 #PARMS

CLEAR-KEYBUF

HIDDEN ALSO DEFINITIONS

FALSE VALUE is-insert?  // insert mode or replace mode

: EXTKEY:      (( N -- ))
	CREATE 256 * ,
	DOES> (( PFA -- V ))
	      @ ;

CTRL H  CONSTANT  ^h
CTRL I  CONSTANT  ^i
CTRL M  CONSTANT  ^m
CTRL [  CONSTANT  ESC

  82  EXTKEY: ins                83  EXTKEY: del
  71  EXTKEY: home               79  EXTKEY: end
  65  EXTKEY: f(7)               110 EXTKEY: alt-f7
  $44 EXTKEY: f(10)
  72  EXTKEY: up                 80  EXTKEY: down
  75  EXTKEY: left               77  EXTKEY: right
  115 EXTKEY: ctrl-left          116 EXTKEY: ctrl-right
  117 EXTKEY: ctrl-end

// 73  EXTKEY: pgup               81  EXTKEY: pgdn
// 119 EXTKEY: ctrl-home
// 132 EXTKEY: ctrl-pgup          118 EXTKEY: ctrl-pgdn

: his-limit      (( -- limit ))
	#history #max-history MIN cmd-length *  HISTORIES + ; 0 1 #PARMS

: ^history++    (( -- ))
	^history cmd-length +
	DUP  his-limit  >=  ?{  DROP HISTORIES  }?   
	=> ^history ; 0 0 #PARMS

: ^history--    (( -- ))
	^history cmd-length -
	DUP  HISTORIES  <  ?{  DROP his-limit cmd-length -  }?
	=> ^history ; 0 0 #PARMS

: clear-line    (( -- ))
	AT? NIP 0 SWAP 2DUP AT
	79 SPACES AT    ; 0 0 #PARMS

: reput-command (| buf #chars_got #max_got | -- #chars_got' #max_got' |)
	^history C@ DUP => #max_got' => #chars_got'
	^history 1+ buf #max_got' MOVE
	clear-line  buf #max_got' TYPE ;

: last-command (( buf #chars_got #max_got -- #chars_got' #max_got' ))
	^history-- reput-command ; 3 2 #PARMS

: next-command (( buf #chars_got #max_got -- #chars_got' #max_got' ))
	^history++ reput-command ; 3 2 #PARMS

: (slide)      (| buf #chars_got #max_got dir -- #chars_got' #max_got' |)
	#max_got #chars_got < ?{  #chars_got to #max_got  }?
	#chars_got dir + => #chars_got'    #max_got dir + => #max_got'
	buf #chars_got +   #max_got #chars_got -   2DUP TYPE
	buf #chars_got' +  SWAP 0 MAX MOVE  ;

: <slide<      (| buf #chars_got #max_got -- #chars_got' #max_got' |)
	BKSPC AT?
	buf #chars_got #max_got -1 (slide) => #max_got' => #chars_got'
	SPACE AT  ;

: >slide>       (| buf #chars_got #max_got -- #chars_got' #max_got' |)
	AT? 2DUP SWAP 1+ SWAP AT
	buf #chars_got #max_got 1 (slide) => #max_got' => #chars_got'
	AT  ;

: back-space   (| buf #chars_got #max_got -- #chars_got' #max_got' |)
	AT? DROP 0= ?{
	    #chars_got => #chars_got'   #max_got => #max_got'
	}{
	    buf #chars_got #max_got <slide< => #max_got' => #chars_got'
	}? ;

: refresh_cmd   (| buf #chars_got #max_got -- #chars_got' #max_got' |)
	buf #max_got 0 FILL
	0 => #chars_got' 0 => #max_got'
	clear-line ;

: left-one (| buf #chars_got #max_got -- #chars_got' #max_got' |)
	#chars_got 1- => #chars_got'
	AT? SWAP 1-
	#chars_got' 0< ?{    0 => #chars_got'   DROP 0   }?
	SWAP AT ;

: right-one (| buf #chars_got #max_got -- #chars_got' #max_got' |)
	#chars_got 1+ => #chars_got'
	AT? SWAP 1+
	#chars_got'   cmd-length    >=   ?{
	   cmd-length => #chars_got'          DROP cmd-length 1-
	}?
	SWAP AT 
	#chars_got'  #max_got  >  ?{  BL  buf #chars_got +  C!  }? ;

: left-1-word (| buf #chars_got #max_got | ^ch -- #chars_got' #max_got' |)
	#max_got => #max_got'
	buf #chars_got + => ^ch
	BEGIN  ^ch 1- => ^ch  ^ch C@ BL >  ^ch buf <=  OR  UNTIL // skip spaces
	BEGIN ^ch 1- C@ BL >  ^ch buf > AND
	WHILE ^ch 1- => ^ch   REPEAT // find space
	^ch buf - 0 MAX => #chars_got' 
	AT? NIP #chars_got' SWAP AT ;

: right-1-word (| buf #chars_got #max_got | ^ch lim -- #chars_got' #max_got' |)
	#max_got => #max_got'
	buf #chars_got + => ^ch   buf #max_got + => lim
	BEGIN  ^ch 1+ => ^ch  ^ch C@ BL >  ^ch lim >  OR  UNTIL // skip spaces
	BEGIN ^ch 1- C@ BL >   ^ch lim <= AND
	WHILE ^ch 1+ => ^ch   REPEAT // find space
	^ch buf - => #chars_got'
	AT? NIP #chars_got' SWAP AT ;

: inschar  (( buf #chars_got #max_got -- #chars_got' #max_got' )) // toggle mode
	ROT DROP  is-insert? NOT => is-insert?  ; 3 2 #PARMS

: delchar (| buf #chars_got #max_got -- #chars_got' #max_got' |)
	#chars_got #max_got < ?{
	    buf
	    buf #chars_got #max_got right-one
	    <slide<  => #max_got' => #chars_got'
	}{
	    #chars_got => #chars_got' #max_got => #max_got'
	}? ;

: goto-home (| buf #chars_got #max_got -- #chars_got' #max_got' |)
	0 => #chars_got'        #max_got => #max_got'
	AT? NIP 0 SWAP AT ;
	
: goto-end (| buf #chars_got #max_got -- #chars_got' #max_got' |)
	#max_got DUP => #chars_got' => #max_got'
	AT? NIP #max_got SWAP AT ;

: del-to-eol (| buf #chars_got #max_got | len -- #chars_got' #max_got' |)
	#max_got #chars_got - => len
	AT? len SPACES AT
	buf #chars_got + len 0 FILL
	#chars_got DUP => #chars_got' => #max_got' ;

: input-key    (| buf #chars_got #max_got key -- #chars_got' #max_got' |)
	key BL $FF WITHIN NOT ?{ BL => key }?
	#chars_got 1+ => #chars_got' #max_got => #max_got'
	is-insert? ?{
	   buf #chars_got #max_got >slide> => #max_got' DROP
	}?
	key   EMIT      key  buf #chars_got +  C!  ;

: .histories (| buf #chars_got #max_got | cnt dcnt -- #chars_got' #max_got' |)
	1 => cnt  1 => dcnt #chars_got => #chars_got'   #max_got => #max_got'
	^history
	BEGIN
	   cnt #max-history #history MIN <=   NUF? NOT  AND
	WHILE
	   ^history C@ 0<> ?{  
		." [ " dcnt . dcnt 1+ => dcnt ." ] " ^history COUNT TYPE CR
	   }?
	   ^history++
	   cnt 1+ => cnt
	REPEAT
	=> ^history
	buf #max_got TYPE AT? NIP #chars_got SWAP AT ;

0 VALUE Enterred?

: (dokey)    (| buf #chars_got #max_got key -- #chars_got' #max_got' |)
	buf #chars_got #max_got
	key CASE
	    ^h         OF   back-space             ENDOF
	    up         OF   last-command           ENDOF
	    down       OF   next-command           ENDOF
	    left       OF   left-one               ENDOF
	    right      OF   right-one              ENDOF
	    ctrl-left  OF   left-1-word            ENDOF
	    ctrl-right OF   right-1-word           ENDOF
	    ins        OF   inschar                ENDOF
	    del        OF   delchar                ENDOF
	    home       OF   goto-home              ENDOF
	    end        OF   goto-end               ENDOF
	    ctrl-end   OF   del-to-eol             ENDOF
	    f(7)       OF   .histories             ENDOF
	    f(10)      OF   ROT DROP (( nothing )) ENDOF        
	    alt-f7     OF   CLEAR-KEYBUF ROT DROP  ENDOF
	    ESC        OF   refresh_cmd            ENDOF
	    ^m         OF   TRUE => Enterred? ROT DROP ENDOF
	    input-key    0 (( for DROP ))
	ENDCASE
	=> #max_got' => #chars_got' ;

: $input  (| buf #max_chars | #max_got curr^history -- buf' #chars_got |)
	0 => #chars_got  0 => #max_got  buf => buf'
	^history => curr^history
	FALSE  =>  Enterred?
	BEGIN
	   Enterred? NOT  #max_got #max_chars <  AND
	WHILE
	   buf #chars_got #max_got KEY  dokey  => #max_got => #chars_got
	   #chars_got #max_got MAX => #max_got
	REPEAT
	AT? NIP #max_got 1+ 79 MIN SWAP AT
	curr^history => ^history
	#max_got => #chars_got
	#chars_got ?{   // non-zero input
	   #chars_got ^history C!    buf ^history 1+ #chars_got MOVE
	   #history 1+ => #history  ^history++
	}? ;

: keybufCONSOLE (| -- |)
	[ 'CONSOLE @ ] LITERAL EXECUTE
	I/O 2@ '?KEY ! 'EMIT !
	['] .OK 'PROMPT !  ['] EMIT 'ECHO !  ['] kTAP 'TAP !
	['] $input 'EXPECT ! ;

' (dokey) IS dokey

' keybufCONSOLE 'CONSOLE !      ' $input 'EXPECT !

ONLY FORTH ALSO DEFINITIONS

