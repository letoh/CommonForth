NEEDS KEYTABLE.4TH
NEEDS TURNKEY.4TH
BL Keyboard! DROP
NEEDS GRAPHICS.4TH
SINGLE
NEEDS 3DR.4TH

SINGLE TEXT-MODE

: 3DR   GRAPHICS-MODE MULTI
	CLS 0 300 GMaxX GMaxY 0 0 GSetScrollRange
	30 130 610 256 G_BLUE GFillCRectangle
	BEGIN CLS ." * Press <F10> to quit ..." Job7 AGAIN ;

: QUIT3DR ['] 3DR >NAME $" 3DR" 4 COMP 0= 
	  IF    // Check if head file existed, for debugging turnkey system.
	      TEXT-MODE SINGLE CR ." * End of 3DR . ok" CR ABORT
	  ELSE
	      BYE
	  ENDIF ;

$4400 KEY: BYE
$7100 KEY: QUIT3DR

' 3DR TURNKEY 3DR

3DR
