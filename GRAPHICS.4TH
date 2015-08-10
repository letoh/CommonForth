//
//  Standard Graphics Interface ( Prelimilary Release )
//
//    This interface defines only minium set for graphics and text.
//    Follow this standard interface and your program will run under
//    other versions of loaders ( like Watcom , DJGPP 2.0 ... even Windows ) 
//    without many modifications ( Abstract Common Forth concept )
//    ... even with no modification at all.
//
//						Written by  : Luke Lee
//						Version     : 1.2
//						Last update : 02/14/'97
//						     update : 04/16/'96
//						     update : 01/04/'96
//  [02/14/'97] : Add DJGPP_V2 version.

CR .( * Loading INVOKEC.4TH and DOSCMD.4TH ...)
NEEDS INVOKEC.4TH
NEEDS DOSCMD.4TH
.( ... Loaded ) CR

#DEFINED DJGPP_V2 #IF
 .( * Loading GRX20.4TH ...)
 NEEDS GRX20.4TH
#ELSE #DEFINED DJGPP_GO32 #IF
 .( * Loading GRX.4TH ...)
 NEEDS GRX.4TH
#ELSE #DEFINED WATCOM_C/C++ #IF
 .( * Loading WCCGRAPH.4TH ...)
 NEEDS WCCGRAPH.4TH
#ELSE
 .( * No suitable graphics interface implemented.) BEEP CR ABORT
#ENDIF #ENDIF #ENDIF
.( ... Loaded ) CR

// ////////////////////////////////////////////////////////////////////// //
//   Before FLOADing this file (GRAPHICS.4TH), the following interface 	  //
//   words MUST be defined for correctly operation under GRAPHICS-MODE	  //
//   Vocabulary 'GRAPHICS' should be defined also			  //
// ////////////////////////////////////////////////////////////////////// //

WARNING OFF

GRAPHICS ALSO DEFINITIONS

.( * Loading FONTDATA.4TH, take a while ...)
NEEDS FONTDATA.4TH
.( ... Loaded ) CR

COMMENT: // //////////////////////////////////////////////// //

 þ All the words listed below should be implemented before this 
   file (GRAPHICS.4TH) is FLOADed. 
 þ For a complete definition of this graphics interface, please
   reference to MANUAL.CF .

// 16 Color Constants :
  G_BLACK
  G_BLUE   
  G_GREEN   
  G_CYAN   
  G_RED   
  G_MAGENTA   
  G_BROWN   
  G_LIGHTGRAY   
  G_DARKGRAY   
  G_LIGHTBLUE   
  G_LIGHTGREEN   
  G_LIGHTCYAN   
  G_LIGHTRED   
  G_LIGHTMAGENTA   
  G_YELLOW   
  G_WHITE

// Constants for GInitialize :
  G320x200x16		G320x200x256
  G640x480x16		G640x480x256
  G800x600x16		G800x600x256
  G1024x768x16		G1024x768x256

// Constants for GPutImage operation :
  G_XOR_PUT
  G_OR_PUT
  G_AND_PUT
  G_COPY_PUT
  G_NOT_PUT	( optional )

// Flag for using GRAPHICS.4TH default font or not .
  GUseDefaultFont? ( a VALUE )

 : GInitialize     ( video_mode #columns #rows -- )
 : GUninitialize   ( -- )	// back to text mode	
// There are two set of drawing words, one is color parameterred.
 : GSetColor	   ( color -- )
 : GGetColor	   ( -- color )
 : GDrawPoint      ( x y -- )
 : GDrawLine       ( x0 y0 x1 y1 -- )
 : GDrawRectangle  ( x0 y0 x1 y1 -- )
 : GFillRectangle  ( x0 y0 x1 y1 -- )
// Color parameterred :
 : GDrawCPoint     ( x y color -- )
 : GDrawCLine      ( x0 y0 x1 y1 color -- )
 : GDrawCRectangle ( x0 y0 x1 y1 color -- )
 : GFillCRectangle ( x0 y0 x1 y1 color -- )

 : GImageSize	   ( x0 y0 x1 y1 -- n )
 : GGetImage       ( left top right bottom *image -- )
 : GPutImage       ( left top *image op -- ) MUST have XOR-put !!
 : GMoveImage	   ( destX destY srcX0 srcY0 srcX1 srcY1 -- )  // optional
 
// Read Graphics region/size :
 : GSizeX	   ( -- SizeX )
 : GSizeY	   ( -- SizeY )
 : GMaxX	   ( -- MaxX )  which is (GSizeX - 1)
 : GMaxY	   ( -- MaxY )  which is (GSizeY - 1)

 : GOutChar	   ( x0 y0 ch -- )
 
// Text colors :
 : GGetForeColor   ( -- fgcolor )
 : GGetBackColor   ( -- bgcolor )
 : GGetTextColor   ( -- fgcolor bgcolor )
 : GSetForeColor   ( fgcolor -- ) 
 : GSetBackColor   ( bgcolor -- ) 
 : GSetTextColor   ( fgcolor bgcolor -- )

;COMMENT // //////////////////////////////////////////////// //

G640x480x256 VALUE  GDefaultMode
0  	     VALUE  GCurrentMode        // default text-mode

ONLY GRAPHICS ALSO HIDDEN ALSO DEFINITIONS

// ////////////////////////////////////////////// //
//          Graphics Mode Screen I/O		  //
// ////////////////////////////////////////////// //

FALSE  VALUE  GModeNow?

80 VALUE G_Max#column	// X
30 VALUE G_Max#row	// Y

0  VALUE G_cell_width
0  VALUE G_cell_height

0 VALUE cursor-location	// cursor location

0 VALUE G_ScrollX0
0 VALUE G_ScrollY0
0 VALUE G_ScrollX1
0 VALUE G_ScrollY1

0    VALUE  G_CursorStatus
0    VALUE  G_CursorScanStart	// cursor scanline
0    VALUE  G_CursorScanEnd

GRAPHICS DEFINITIONS

DEFER GDrawASCII 1 0 #PARMS

: GraphicsMode?	(( -- T/F ))	// Read-only interface for GModeNow?
	GModeNow? ; 0 1 #PARMS

: GCursor>Coord	(( col_x row_y -- x y ))
	G_cell_height * G_ScrollY0 + SWAP
	G_cell_width * G_ScrollX0 + SWAP ; 2 2 #PARMS

// Text region size read
: GSizeColumn	G_Max#column	; 0 1 #PARMS // X
: GSizeRow	G_Max#row	; 0 1 #PARMS // Y
: GMaxColumn	G_Max#column 1- ; 0 1 #PARMS 
: GMaxRow	G_Max#row 1- 	; 0 1 #PARMS

// ////////////////////////////////// //
//    ASCII Character Drawing 	      //
// ////////////////////////////////// //

HIDDEN DEFINITIONS

STRUCT: ASCIIFontCacheTag
    WORD:    |ascForeColor
    WORD:    |ascBackColor
;STRUCT

: []AsciiFontBuf14	(( c -- addr ))   // resident fonts
	14 *  ASCIIFonts8x14 +  ; 1 1 #PARMS
: []AsciiFontBuf24	(( c -- addr ))
	48 *  ASCIIFonts16x24 + ; 1 1 #PARMS

CREATE DummyPlace   24 16 * CELLS  ALLOT

0  VALUE  |ASCIIBitmap|
0  VALUE  |ASCIIimageSize|
0  VALUE  ASCFONTCache
0  VALUE  ASCIICacheEntry^ 
DEFER ASCFontCacheHit? (( c -- T/F )) 1 1 #PARMS

: |ASCIIimage	(( CacheEntry -- Entry|FontBitmap ))
	SIZEOF ASCIIFontCacheTag LITERAL  + ; 1 1 #PARMS
: |ASCIIFontCacheEntry|	(( -- CacheEntrySize ))
	SIZEOF ASCIIFontCacheTag LITERAL |ASCIIimageSize| +  ; 0 1 #PARMS

: (AlwaysMiss)	(( ascii -- FALSE ))
	DummyPlace TO ASCIICacheEntry^
	DROP FALSE  ; 1 1 #PARMS

: (ASCFontCacheHit?)	(( c -- T/F ))
	|ASCIIFontCacheEntry| * ASCFONTCache + DUP to ASCIICacheEntry^
	DUP |ascForeColor @ GGetForeColor =  ANDTHEN
	DUP |ascBackColor @ GGetBackColor =  THEN-AND NIP ; 1 1 #PARMS

: >>>ASCIIimageCache	(( x0 y0 x1 y1 -- ))
	ASCIICacheEntry^ |ASCIIimage GGetImage
	ASCIICacheEntry^
	GGetForeColor OVER |ascForeColor !
	GGetBackColor SWAP |ascBackColor !  ; 4 0 #PARMS

: ASCIIimageCache>>>	 (( x y -- ))
	ASCIICacheEntry^ |ASCIIimage  G_COPY_PUT  GPutImage ; 2 0 #PARMS

: OpenASCIICache  (| -- |)
	|ASCIIFontCacheEntry| 256 * DUP malloc DUP to ASCFONTCache
	IF  ASCFONTCache OVER 0 FILL  ENDIF  DROP
	ASCFONTCache  IF ['] (ASCFontCacheHit?) ELSE ['] (AlwaysMiss) ENDIF
	IS ASCFontCacheHit?  ;

: CloseASCIICache  (( -- ))
	ASCFONTCache IF  ASCFONTCache free  0 TO ASCFONTCache  ENDIF
	['] (AlwaysMiss) IS ASCFontCacheHit?  ; 0 0 #PARMS

: DrawASCII8x14	(| char | x0 x y -- |)
	AT? GCursor>Coord (( col_x row_y -- x y )) to y to x0
	char ASCFontCacheHit? IF  x0 y ASCIIimageCache>>>  EXIT  ENDIF
	MULTI? SINGLE
	char []AsciiFontBuf14
	13  FOR  (( 14 1- )) 
	   x0 to x
	   DUP C@ $80   // buf 8p mask
	   7 FOR
	      2DUP AND IF  x y GGetForeColor GDrawCPoint
	      ELSE	   x y GGetBackColor GDrawCPoint	ENDIF
	      2/   x 1+ to x
	   NEXT
	   2DROP
	   1+   y 1+ to y
	NEXT  DROP
	x0 y 14 - x 1- y 1- >>>ASCIIimageCache
	IF MULTI ENDIF ;

: DrawASCII16x24    (| char | x0 x y -- |)
	AT? GCursor>Coord (( col_x row_y -- x y )) to y to x0
	char ASCFontCacheHit? IF  x0 y ASCIIimageCache>>>  EXIT  ENDIF
	MULTI? SINGLE
	char []AsciiFontBuf24
	23 FOR  // 24 1-
	   x0 to x
	   DUP   // //////  C@ 256* OVER 1+ C@ OR  // 16_points
	   H@ [  $86 C, $C4 C,  ] // machine code : XCHG  AH  AL
	   $8000   // a bit-mask	     S:	16_points mask
	   15 FOR
	      2DUP AND IF  x y GGetForeColor GDrawCPoint
	      ELSE	   x y GGetBackColor GDrawCPoint	ENDIF
	      2/    // shift bit mask
	      x 1+  to  x
	   NEXT
	   2DROP
	   1+ 1+  y 1+ to y
	NEXT  DROP
	x0 y 24 - x 1- y 1- >>>ASCIIimageCache
	IF MULTI ENDIF ;

HIDDEN DEFINITIONS

// //////////////////////////// //
//    Cursor emulation task 	//
// ////////////////////////////	//

0 VALUE G_NormCursorImageBuf
0 VALUE G_HalfCursorImageBuf
0 VALUE G_BigCursorImageBuf
0 VALUE G_CursorImageBuf	// a pointer to previous three

: G_AT?	(( -- col_x row_y ))
	cursor-location  G_Max#column /MOD ; 0 2 #PARMS

: G_ToggleCursor  (| | x y -- |)
	G_CursorStatus NOT => G_CursorStatus
	G_AT? GCursor>Coord to y to x
	x  y G_CursorScanStart +   G_CursorImageBuf  G_XOR_PUT GPutImage ;

GRAPHICS DEFINITIONS 

: G_HideCursor	(( -- ))
	G_CursorStatus IF  G_ToggleCursor  ENDIF  ; 0 0 #PARMS

: GGetImage  G_HideCursor GGetImage  ;  5 0 #PARMS
: GPutImage  G_HideCursor GPutImage  ;  4 0 #PARMS
#DEFINED GMoveImage #IF
: GMoveImage G_HideCursor GMoveImage ;  6 0 #PARMS
#ENDIF

HIDDEN DEFINITIONS

BACKGROUND: GCursorTask  (( -- ))
        BEGIN
	    4 TICKS
	    GModeNow? IF   G_ToggleCursor   ENDIF
        AGAIN ;

GRAPHICS DEFINITIONS

: GCursorOFF	G_HideCursor GCursorTask SLEEP ; 0 0 #PARMS
: GCursorON	GCursorTask WAKE ; 0 0 #PARMS
: GCursorState	(( -- T/F ))
		GCursorTask TASK-STATE LOCAL @ TASK-AWAKE = ; 0 1 #PARMS

: warp-cursor	(( loc -- loc' ))
	G_Max#column G_Max#row * MOD ; 1 1 #PARMS

GRAPHICS DEFINITIONS

VARIABLE GScrolling  

#DEFINED GMoveImage #IF
 GScrolling ON
#ELSE
 GScrolling OFF
#ENDIF

: G_ScrollUp	(( -- ))
    #DEFINED GMoveImage #IF
    	G_HideCursor  
	G_ScrollX0  G_ScrollY0  
	G_ScrollX0  G_ScrollY0 G_cell_height +  G_ScrollX1  G_ScrollY1
	GMoveImage
	G_ScrollX0   G_ScrollY1 G_cell_height - 1+   G_ScrollX1   G_ScrollY1
	GGetBackColor GFillCRectangle
    #ENDIF
	; 0 0 #PARMS

: G_ScrollDown	(( -- ))
    #DEFINED GMoveImage #IF
	G_HideCursor
	G_ScrollX0  G_ScrollY0 G_cell_height +
	G_ScrollX0  G_ScrollY0  G_ScrollX1 G_ScrollY1 G_cell_height - 
	GMoveImage
	G_ScrollX0  G_ScrollY0   G_ScrollX1 G_ScrollY0 G_cell_height + 1- 
	GGetBackColor GFillCRectangle
    #ENDIF
	; 0 0 #PARMS

: ?scroll	(( loc -- loc' ))
	GScrolling @ IF
	   G_Max#column G_Max#row * 2DUP >= IF
	       NIP G_Max#column -
	       G_ScrollUp
	   ELSE
	       DROP
	   ENDIF
	ELSE
	   warp-cursor
	ENDIF ; 1 1 #PARMS INVISIBLE
        
: G_DrawChar	(( ch -- )) // draw character at current cursor location
	G_AT? GCursor>Coord ROT  GOutChar ; 1 0 #PARMS

: G_AT	(( col_x row_y -- ))
	G_HideCursor
	G_Max#column * + warp-cursor => cursor-location   ; 2 0 #PARMS

: GASCIIEmit	(( ch -- ))
	G_HideCursor
	CASE
	   $07 OF  BEEP			  	  ENDOF
	   $08 OF  AT? SWAP 1- 0 MAX SWAP
		   2DUP AT  BL GDrawASCII  AT	  ENDOF
	   $09 OF  TAB				  ENDOF
	   $0A OF  cursor-location G_Max#column +
		   ?scroll => cursor-location     ENDOF	 // LF
	   $0D OF  cursor-location G_Max#column
		   TUCK / * => cursor-location    ENDOF	 // CR
	  // Default :
		DUP GDrawASCII
		cursor-location 1+  ?scroll  => cursor-location
	ENDCASE ; 1 0 #PARMS

HIDDEN DEFINITIONS

VARIABLE textCONSOLE
'CONSOLE @ textCONSOLE !

GRAPHICS DEFINITIONS

: G_CONSOLE     (( -- ))
	G_HideCursor
	textCONSOLE @EXECUTE
        GUseDefaultFont? IF
	   |ASCIIBitmap| [ 14 8 * 8 / ] LITERAL = 
	   IF  ['] DrawASCII8x14  ELSE  ['] DrawASCII16x24  ENDIF
	ELSE
	   ['] G_DrawChar
	ENDIF
	IS GDrawASCII
	['] G_AT 'AT !		['] G_AT? 'AT? !
        ['] GASCIIEmit 'EMIT !  ; 0 0 #PARMS

: G_NormCursor	(( -- ))
	G_HideCursor
	G_cell_height 2 3 */  => G_CursorScanStart
	G_cell_height 4 5 */  => G_CursorScanEnd
	G_NormCursorImageBuf to G_CursorImageBuf  ; 0 0 #PARMS

: G_BigCursor	(( -- ))
	G_HideCursor
	0 => G_CursorScanStart
	G_cell_height => G_CursorScanEnd 
	G_BigCursorImageBuf to G_CursorImageBuf	  ; 0 0 #PARMS

: G_HalfCursor	(( -- ))
	G_HideCursor
	G_cell_height 2/  =>  G_CursorScanStart
	G_cell_height 1-  =>  G_CursorScanEnd 
	G_HalfCursorImageBuf to G_CursorImageBuf  ; 0 0 #PARMS

: GWouldScroll?	(( +value -- T/F ))
	DUP 0> ANDTHEN
	GScrolling @ ANDTHEN
	DUP cursor-location +  G_Max#column G_Max#row *  >=
	THEN-AND NIP ; 1 1 #PARMS

: GCursor++	(( -- ))
	G_HideCursor cursor-location 1+ ?scroll to cursor-location 
	; 0 0 #PARMS

: GCursor+!	(( n -- ))
	G_HideCursor cursor-location +  ?scroll to cursor-location 
	; 1 0 #PARMS

: GCursor--	(( -- ))
	G_HideCursor cursor-location 1- warp-cursor to cursor-location 
	; 0 0 #PARMS

: GCursor-!	(( n -- ))
	G_HideCursor cursor-location -  warp-cursor to cursor-location
	; 1 0 #PARMS

: GCursor@	(( -- loc ))
	cursor-location ; 0 1 #PARMS

: GCursor!	(( n -- ))
	G_HideCursor warp-cursor to cursor-location ; 1 0 #PARMS

: GResetTextI/O  (| -- |)
        0 => cursor-location
	G_ScrollX1 G_ScrollX0 - 1+  G_Max#column  /  =>  G_cell_width
        G_ScrollY1 G_ScrollY0 - 1+  G_Max#row     /  =>  G_cell_height
	G_HideCursor G_NormCursor
        G_LIGHTGRAY    G_BLACK	GSetTextColor
	GModeNow? NOT IF
           ['] G_CONSOLE 'CONSOLE !  CONSOLE
	ENDIF ;

: GGetScrollRange  (( -- X0 Y0 X1 Y1 #col #row ))
	G_ScrollX0  G_ScrollY0  G_ScrollX1 G_ScrollY1
	G_Max#column  G_Max#row ; 0 6 #PARMS

: GSetScrollRange  (| X0 Y0 X1 Y1 #col #row | fgcolor bgcolor -- |)
     // if '#col' or '#row' less than zero, use current cell-size
	X1 X0 >  ANDTHEN  Y1 Y0 > ANDTHEN 
	X1 GMaxX <= ANDTHEN  Y1 GMaxY <=  THEN-AND IF
	   X0 => G_ScrollX0  Y0 => G_ScrollY0
	   X1 => G_ScrollX1  Y1 => G_ScrollY1
	   #col 0> IF
	       #col  
	   ELSE  
	       G_ScrollX1 G_ScrollX0 - 1+ G_cell_width /  
	   ENDIF  => G_Max#column
	   #row 0> IF  
	       #row
	   ELSE
	       G_ScrollY1 G_ScrollY0 - 1+ G_cell_height /  
	   ENDIF  => G_Max#row
	   GGetTextColor to bgcolor to fgcolor
	   GResetTextI/O
	   fgcolor bgcolor OR 0<> IF  fgcolor bgcolor GSetTextColor  ENDIF
	ELSE
	   ." * GSetScrollRange : Invalid scroll range" CR ABORT
	ENDIF ;

FORTH DEFINITIONS

DEFER HOOK-GRAPHICSMODE	0 0 #PARMS // Hook to enter GRAPHICS-MODE
DEFER GRAPHICSMODE-HOOK	0 0 #PARMS // Hook to leave GRAPHICS-MODE
DEFER HOOK-TEXTMODE	0 0 #PARMS // Hook to enter TEXT-MODE
DEFER TEXTMODE-HOOK	0 0 #PARMS // Hook to leave TEXT-MODE

' NOOP DUP 2DUP IS HOOK-GRAPHICSMODE  IS GRAPHICSMODE-HOOK
		IS HOOK-TEXTMODE      IS TEXTMODE-HOOK

: CLS	(( -- ))
	GModeNow? IF
	   G_HideCursor
	   G_ScrollX0 G_ScrollY0 G_ScrollX1 G_ScrollY1 GGetBackColor 
	   GFillCRectangle 0 0 AT
	ELSE
	   CLS	// old CLS
	ENDIF ; 0 0 #PARMS

: GRAPHICS-MODE	(| -- |)
	GCurrentMode GDefaultMode =  IF
	   0 0 GMaxX GMaxY 0 0 GSetScrollRange CLS EXIT   
	ENDIF
	HOOK-GRAPHICSMODE
	GDefaultMode to GCurrentMode
	GDefaultMode 80 30 GInitialize
	GDefaultMode G1024x768x16 =  GDefaultMode G1024x768x256  =  OR
	IF
	   1 1 16 24 GImageSize  to  |ASCIIimageSize|
	   24 16 * 8 /  to |ASCIIBitmap|
	ELSE
	   1 1 8  14 GImageSize  to  |ASCIIimageSize|
	   14 8 * 8 /  to |ASCIIBitmap|
	ENDIF
	GUseDefaultFont? IF  OpenASCIICache  ENDIF
	GMaxX 320 > IF
           0  0  GMaxX  GMaxY  80  30  GSetScrollRange
	ELSE
           0  0  GMaxX  GMaxY  40  14  GSetScrollRange
	ENDIF
	0  0  G_cell_width G_cell_height G_WHITE GFillCRectangle
	0 DUP  G_cell_width  G_CursorScanEnd G_CursorScanStart -
	2DUP 0 DUP 2SWAP GImageSize malloc DUP  to  G_NormCursorImageBuf
	DUP IF   GGetImage
        ELSE     5DROP TRUE ABORT" * No memory for graphics cursor !" 
        ENDIF
	0 DUP  G_cell_width  G_cell_height 2/
	2DUP 0 DUP 2SWAP GImageSize malloc DUP
        DUP 0= IF  DROP G_NormCursorImageBuf  ENDIF  to  G_HalfCursorImageBuf
	DUP IF  GGetImage  ELSE  5DROP  ENDIF
	0 DUP G_cell_width  G_cell_height
	2DUP 0 DUP 2SWAP GImageSize malloc DUP
        DUP 0= IF  DROP G_NormCursorImageBuf  ENDIF  to  G_BigCursorImageBuf
	DUP IF  GGetImage  ELSE  5DROP  ENDIF
	0 0 GMaxX GMaxY G_BLACK GFillCRectangle
	G_NormCursor
	TRUE => GModeNow? 
	GRAPHICSMODE-HOOK 
        ;

: TEXT-MODE	(| -- |)
	GModeNow? NOT IF  CLS EXIT  ENDIF
	HOOK-TEXTMODE
	0 0 GMaxX GMaxY G_BLACK GFillCRectangle
	G_NormCursorImageBuf IF  G_NormCursorImageBuf free  ENDIF
	0 to G_NormCursorImageBuf
	G_HalfCursorImageBuf IF	 G_HalfCursorImageBuf free  ENDIF
	0 to G_HalfCursorImageBuf
	G_BigCursorImageBuf  IF	 G_BigCursorImageBuf  free  ENDIF
	0 to G_BigCursorImageBuf
	CloseASCIICache
	GUninitialize
	0 to GCurrentMode
	FALSE => GModeNow?
        textCONSOLE @ 'CONSOLE !
        CONSOLE 
	TEXTMODE-HOOK ;

: VIDEO-MODE	(| -- |)
	GDefaultMode IF  GRAPHICS-MODE  ELSE  TEXT-MODE  ENDIF ;

HIDDEN DEFINITIONS

0 VALUE G_CursorType

#EXISTED (dokey) #IF

: G_SetCursorShape
	G_CursorType IF   G_HalfCursor   ELSE  G_NormCursor  ENDIF ; 0 0 #PARMS

: G_CursorChangeShape
	G_CursorType NOT => G_CursorType
	G_SetCursorShape ; 0 0 #PARMS

is-insert? #IF  G_CursorChangeShape  #ENDIF

: G_(dokey)	(( buf #chars_got #max_got key -- #chars_got' #max_got' ))
	DUP ins = IF
	   G_CursorChangeShape
	ENDIF
	DEFERS dokey ; 4 2 #PARMS

' G_(dokey) IS dokey

#ENDIF
			
: BYE-RESTORE	(( -- ))
	[ BYEFUNC^ @ ] LITERAL EXECUTE
	GModeNow? IF  TEXT-MODE  ENDIF ; 0 0 #PARMS

' BYE-RESTORE BYEFUNC^ !

GCursorTask WAKE MULTI

GRAPHICS DEFINITIONS

STRUCT: GTextInfo:
	  WORD: |InfoSaved?		INVIS	// INVISIBLE
	  WORD: |GModeNow?		INVIS
	  WORD: |G_Max#column		INVIS
	  WORD: |G_Max#row		INVIS
   	  WORD: |G_cell_width		INVIS
	  WORD: |G_cell_height		INVIS
	  WORD: |cursor-location	INVIS
	  WORD: |G_ScrollX0		INVIS
   	  WORD:	|G_ScrollY0		INVIS
	  WORD:	|G_ScrollX1		INVIS
	  WORD:	|G_ScrollY1		INVIS
	  WORD:	|G_CursorScanStart	INVIS
	  WORD:	|G_CursorScanEnd	INVIS
	  WORD: |G_CursorType		INVIS
	  WORD: |GCursorState		INVIS
	  WORD: |GScrolling		INVIS
	  WORD: |GForeColor		INVIS
	  WORD: |GBackColor		INVIS
;STRUCT

: GSaveTextInfo	(( GTextInfo -- ))	RECURSIVE
	G_HideCursor >R
	['] GSaveTextInfo     R@ |InfoSaved? !	// a special flag for checking
	GModeNow?	      R@ |GModeNow?		!
	G_Max#column	      R@ |G_Max#column		!
	G_Max#row	      R@ |G_Max#row		!
	G_cell_width	      R@ |G_cell_width		!
	G_cell_height	      R@ |G_cell_height		!
	cursor-location	      R@ |cursor-location	!
	G_ScrollX0	      R@ |G_ScrollX0		!
	G_ScrollY0	      R@ |G_ScrollY0		!
	G_ScrollX1	      R@ |G_ScrollX1		!
	G_ScrollY1	      R@ |G_ScrollY1		!
	G_CursorScanStart     R@ |G_CursorScanStart	!
	G_CursorScanEnd	      R@ |G_CursorScanEnd	!
	G_CursorType	      R@ |G_CursorType		!
	GCursorState	      R@ |GCursorState		!
	GScrolling @	      R@ |GScrolling		!
	GGetForeColor	      R@ |GForeColor		!
	GGetBackColor	      R@ |GBackColor		!
	RDROP ; 1 0 #PARMS
	
: GRestoreTextInfo	(( GTextInfo -- ))
	G_HideCursor >R 
	R@ |InfoSaved? @ ['] GSaveTextInfo = IF // valid info.
	   R@ |GModeNow? @ GModeNow? NOT AND IF  GRAPHICS-MODE  ENDIF
	   R@ |G_Max#column 	  @ to G_Max#column
	   R@ |G_Max#row 	  @ to G_Max#row
	   R@ |G_cell_width	  @ to G_cell_width
	   R@ |G_cell_height	  @ to G_cell_height
	   R@ |cursor-location	  @ GCursor!
	   R@ |G_ScrollX0	  @ to G_ScrollX0
	   R@ |G_ScrollY0	  @ to G_ScrollY0
	   R@ |G_ScrollX1	  @ to G_ScrollX1
	   R@ |G_ScrollY1	  @ to G_ScrollY1
	   R@ |G_CursorScanStart  @ to G_CursorScanStart
	   R@ |G_CursorScanEnd	  @ to G_CursorScanEnd
	   R@ |G_CursorType	  @ to G_CursorType
	   R@ |GCursorState	  @ IF  GCursorON  ELSE  GCursorOFF  ENDIF
	   R@ |GScrolling	  @ GScrolling !
	   R@ |GForeColor @  R@ |GBackColor @	GSetTextColor
	ELSE
	   ." Not a valid GTextInfo" CR BEEP
	ENDIF RDROP ; 1 0 #PARMS

HIDDEN DEFINITIONS

GTextInfo: GShellToDosTextInfo

0 VALUE GIsMulti?

: GShellToDOS 	(( -- ))
	MULTI? to GIsMulti? SINGLE
	GShellToDosTextInfo GSaveTextInfo
	GModeNow? IF TEXT-MODE ENDIF
	DEFERS ShellToDosHook ; 0 0 #PARMS

: GBackFromDOS	(( -- ))
	DEFERS BackFromDosHook
	GShellToDosTextInfo |GModeNow? @ IF  
	   ." ... Press any key to continue ..." CR KEY DROP
	ENDIF
	GShellToDosTextInfo GRestoreTextInfo
	GIsMulti? IF MULTI ENDIF ; 0 0 #PARMS

' GShellToDOS  IS ShellToDosHook
' GBackFromDOS IS BackFromDosHook

WARNING ON

ONLY GRAPHICS ALSO FORTH DEFINITIONS

   .( -----------------------------------------------------------------------)
CR .( þ Standard Graphics Interface 1.0 Loaded þ )
CR .( ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ )
CR .(   1. Use 'GRAPHICS-MODE' to enter graphics mode, and use 'TEXT-MODE')
CR .(      to switch back to text mode. )
CR .(   2. All other graphics words are defined in the 'GRAPHICS' vocabulary.)
CR .( -----------------------------------------------------------------------)
CR

