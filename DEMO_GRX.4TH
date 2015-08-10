// DEMO_GRX.4TH   Simple Demonstration some GRX library GRAPHICS facility

					// Written by Luke Lee
					// Version 1.0
					// Date :  08/25/'95
					// Last update : 10/26/'95


NEEDS FLOAT.4TH

NEEDS GRAPHICS.4TH

ONLY GRAPHICS ALSO 
FORTH DEFINITIONS

: wait (| -- |)
	." ...press any key...(ESC quit)"
	KEY 27 = IF CR ."  QUIT" CR QUIT ENDIF ;

GrTextOption  TitleTextOpt
GrFBoxColors FrameBoxC

40 CONSTANT bwidth	// border width

0 DUP 2DUP VALUE x0 VALUE y0 VALUE x1 VALUE y1

: INITIALIZE	(| -- |)
	GRAPHICS-MODE
	G_PCTextOption  TitleTextOpt  SIZEOF GrTextOption LITERAL  MOVE
	2  TitleTextOpt |txo_xmag  !	// zoom 2 times
	2  TitleTextOpt |txo_ymag  !
	DARKGRAY   TitleTextOpt |txo_bgcolor |v   !
	YELLOW	   TitleTextOpt |txo_fgcolor |v   !  
	
	G_BLACK 	FrameBoxC |fbx_intcolor   !  
	G_LIGHTRED	FrameBoxC |fbx_topcolor   !  
	G_RED   	FrameBoxC |fbx_rightcolor   !  
	G_LIGHTRED 	FrameBoxC |fbx_bottomcolor   !  
	G_RED 		FrameBoxC |fbx_leftcolor   !

	GrMaxX bwidth - => x1   GrMaxY bwidth -  => y1
	GrFramedBoxNC( bwidth , bwidth , x1 , y1 , bwidth , FrameBoxC );
	bwidth => x0    bwidth GrFontHeight( TitleTextOpt ) + => y0
	GrBoxNC( x0 , y0 , x1 , y1 , GrWhite );
	x0 1+ y0 1+ x1 1- y1 1- 0 0 GSetScrollRange ;  

: TITLE	(| str$ len | x -- |)
	GrFilledBoxNC( bwidth , bwidth , GrMaxX bwidth - , y0 1- ,
		       GrBlack  );
	GrMaxX  GrStringWidth( str$ , len , TitleTextOpt )  -   2/ => x
	GrDrawString( str$ , len , x , bwidth , TitleTextOpt ); ;

: SCROLL-RANGE-DEMO	(| | fgcolor bgcolor -- |)
	"  GSetScrollRange Demonstration " TITLE 
	CR CR CR CR
	." [ Total " GrNumColors . ." colors for demonstration ]" CR CR
	." [ Demonstration for GSetScrollRange , also demonstrates "
	."  text colors ]" CR
	." [ Including foreground/background colors ]" CR 
	." ( Note that press <Enter> twice could stop WORDS )" CR CR CR
	." * About to WORDS ... "  wait
	WORDS

	GGetTextColor to bgcolor to fgcolor
	." * GScrolling OFF then WORDS again ..." wait
	LIGHTGRAY  GSetForeColor
	GScrolling OFF WORDS  GScrolling ON

	x0 1+ y0 200 + x1 1- y1 1- 0 0 GSetScrollRange
	LIGHTGREEN DARKGRAY  GSetTextColor
	CLS CR CR
	." * Smaller scroll range now ..." wait
	WORDS wait

	CLS CR ." * Hiding Cursor " 
	GCursorOFF wait
	CR ." * Reveal Cursor" GCursorON wait
	fgcolor bgcolor GSetTextColor

	x0 1+ y0 1+ x1 1- y1 1- 0 0 GSetScrollRange ;

: RandomPoint	(| -- x y |)
	random   x1 x0 - 1-    MOD  x0 + 1+ => x
	random   y1 y0 - 50 -  MOD  y0 + 50 + => y  ;

: RandomColor	(| -- color |)
	random   GrNumColors( )  MOD  =>  color  ;

: PIXEL-DEMO	(| | x y c -- |)
	"  GrPlot Demonstration " TITLE CLS
	CR CR ." * Press <Enter> twice for next demo ..." CR
	BEGIN
	   RandomPoint to y   to x	// 'to' is alias for '=>'
	   RandomColor to c
	   GrPlot( x , y , c )
	NUF? UNTIL ;

: LINE-DEMO (| | X Y X' Y' C -- |)
	"  GrLine Demonstration " TITLE CLS
	CR CR ." * Press <ENTER> twice for next demo ..." CR
	BEGIN
	   RandomPoint TO Y   TO X
	   RandomPoint TO Y'  TO X'
	   RandomColor to C
	   GrLine( X , Y , X' , Y' , C );
	NUF? UNTIL ;

: CIRCLE-DEMO (| | xc yc r color -- |)
	"  GrCircle Demonstration " TITLE CLS
	CR CR ." * Press <ENTER> twice for next demo ..." CR
	GrSetClipBox( x0 1+ , y0 1+ , x1 1- , y1 1- );
	BEGIN
	  RandomPoint to yc  to xc
	  RandomPoint NIP 2/ to r 
	  RandomColor to color
	  GrCircle( xc , yc , r , color );
	NUF? UNTIL 
	GrResetClipBox ;

: END-DEMO	(| -- |)
	"  That's all  " TITLE CLS CR CR CR wait TEXT-MODE ;

: DEMO	(| -- |)
	INITIALIZE
	SCROLL-RANGE-DEMO
	PIXEL-DEMO
	LINE-DEMO
	CIRCLE-DEMO
	END-DEMO ;

CR .( * Type DEMO for demonstrations . ) CR

