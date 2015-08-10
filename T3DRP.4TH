NEEDS KEYTABLE.4TH
NEEDS TURNKEY.4TH
13 Keyboard! DROP  13 Keyboard! DROP
NEEDS 3DRP.4TH

SINGLE TEXT-MODE

: 3DR   GRAPHICS-MODE MULTI
	CLS 0 300 GMaxX GMaxY 0 0 GSetScrollRange
	21 121 519 259 G_BLUE GFillCRectangle
	BEGIN
	   GGetTextColor CLS
	   G_YELLOW G_DARKGRAY GSetTextColor
	   20 0 AT ."      ( Press <F10> to quit )     "
	   GSetTextColor
	   Job6
	AGAIN ;

: QUIT3DR ['] 3DR >NAME $" 3DR" 4 COMP 0=
	  IF  // Check if head file existed, for debugging turnkey system.
	      TEXT-MODE SINGLE CR ." * End of 3DR . ok" CR ABORT
	  ELSE
	      BYE
	  ENDIF ;

$4400 KEY: BYE
$7100 KEY: QUIT3DR

' 3DR TURNKEY 3DRP

3DR

