// Common Forth  Chinese System Support  
//
//    Eten Version
//
//						Written by  : Luke Lee
//						Version     : 1.8
//						Last update : 01/05/'96 V1.8
//						     update : 12/30/'95
//						     update : 12/29/'95 V1.7
//						     update : 12/25/'95	V1.6
//						     update : 12/22/'95	V1.5
//						     update : 12/18/'95	V1.2
//						     update : 12/15/'95	V1.0
//
// V1.5 : Chinese Font cache successfully work.
// V1.6 : Bug in ChineseEmit fixed.
// V1.7 : Apply GRAPHICS.4TH for standard.
// V1.8 : Modify for running Eten Chinese System .

// : statistics ;

#DEFINED statistics #IF
CR .( Loading FLOAT.4TH ...) 
NEEDS FLOAT.4TH
#ENDIF

CR .( Loading GRAPHICS.4TH ...)
NEEDS  GRAPHICS.4TH

FORTH DEFINITIONS // ///////////////////////////////////////////////////////
// ////////////////////////// //
//  User Controlled Flags :   //
// ////////////////////////// //

FALSE VALUE  PreReadFonts?    // Cache enabled, pre-read not very necessary
TRUE  VALUE  ChooseBestFont?  // Chooese best font when OpenChinese
0     VALUE  FONTSIZE
32    VALUE  FONTTYPE	// A Character, R = Round, M = Ming ... 24x24 only

VOCABULARY ChineseSystem // ////////////////////////////////////////////////

ONLY GRAPHICS ALSO ChineseSystem ALSO DEFINITIONS

TRUE  VALUE  ErrMsgShow?

DEFER  <BEEP> 0 0 #PARMS
// ' BEEP IS <BEEP>
' NOOP IS <BEEP>

// Font file handles

0 VALUE HSTDFONT
0 VALUE HSPCFONT
0 VALUE HSPCFSUPP
0 VALUE HUSRFONT

CREATE NAME$STDFONT  $40 ALLOT
CREATE NAME$SPCFONT  $40 ALLOT
CREATE NAME$SPCFSUPP $40 ALLOT
CREATE NAME$USRFONT  $40 ALLOT

24 24 * 8 /  VALUE   |CharFontBuf|
CREATE (CharFontBuf) |CharFontBuf|  	 ALLOT
CREATE FailCharFont  |CharFontBuf|       ALLOT
CREATE UserCharFont  |CharFontBuf| CELL+ ALLOT

(CharFontBuf) VALUE CharFontPtr	// Important pointer for font operations

15 TO FONTSIZE
16 15 * 8 /  TO  |CharFontBuf|

0 VALUE PreReadStdFont?
0 VALUE PreReadSpcFont?
0 VALUE PreReadSpcFSupp?

: |PreReadStdFontBuf|	13094  |CharFontBuf| *  ; 0 1 #PARMS
: |PreReadSpcFontBuf|	408    |CharFontBuf| *  ; 0 1 #PARMS
: |PreReadSpcFSuppBuf|	408    |CharFontBuf| *  ; 0 1 #PARMS

NULL VALUE PreReadStdFontBuf	// run-time allocated font buffer
NULL VALUE PreReadSpcFontBuf
NULL VALUE PreReadSpcFSuppBuf

DEFER GetStdFont
DEFER GetSpcFont
DEFER GetSpcFSupp
DEFER GetUsrFont

// ////////////////////////// //
//  Big5 Code recognization   //
// ////////////////////////// //

// bit 0 : is big5 low byte.
// bit 1 : is big5 high byte.

1 256 ARRAY: []IsBig5Table

: Big5LowMatch	(( c -- T/F ))
      // between $81..$8D , $8E..$A0, $A1..$FE
	$81 $FE [...]  ;  1 1 #PARMS

: Big5HighMatch	(( c -- T/F ))
      // between $40..$7E , $A1..$FE
	DUP $40 $7E [...]
	SWAP $A1 $FE [...]  OR  ; 1 1 #PARMS

: InitIsBig5Table	(( -- ))
	$FF FOR 
  	    #I Big5LowMatch  $01 (( 00000001 )) AND
	    #I Big5HighMatch $02 (( 00000010 )) AND   OR
	    #I []IsBig5Table   C!
	NEXT ;

InitIsBig5Table

FORGET Big5LowMatch

: IsBig5Low	(( c -- T/F ))
	$FF AND []IsBig5Table   C@ $01 AND 0<> ; 1 1 #PARMS

: IsBig5High	(( c -- T/F ))
	$FF AND []IsBig5Table   C@ $02 AND 0<> ; 1 1 #PARMS

// ////////////////////////////////////////////////// //
// Serial Number = First * GAP + Second + SerialBase  //
// ////////////////////////////////////////////////// //

CELL 256  ARRAY: []LowBig5>First*GAP+SerialBase
1    256  ARRAY: []HighBig5>Second

$7E $40 - 1+		CONSTANT  GAP1
$FE $A1 - 1+ GAP1 +	CONSTANT  GAP

$8001 CONSTANT SerialBase0
$8400 CONSTANT SerialBase1
$8800 CONSTANT SerialBase2
$805F CONSTANT SerialBase3
$9D19 CONSTANT SerialBase4
$E000 CONSTANT SerialBase5	// user font 1
$E000 $311 + CONSTANT SerialBase6 // user font 2
$E000 $311 + $BA7 + CONSTANT SerialBase7  // user font 3

: LowBig5>First*GAP+SerialBase   (| low -- result |)
	low $A1 $A3 [...] IF
	    SerialBase1  $A1
	ELSE low $A4 $C6 [...] IF
	    SerialBase2  $A4
	ELSE low $C7 $C8 [...] IF
	    SerialBase3  $C7
	ELSE low $C9 $F9 [...] IF
	    SerialBase4  $C9
	ELSE low $FA $FE [...] IF
	    SerialBase5  $FA
	ELSE low $8E $A0 [...] IF
	    SerialBase6  $8E
	ELSE low $81 $8D [...] IF
	    SerialBase7  $81
	ELSE
	    0  low  // low - low = 0
	ENDIF ENDIF ENDIF ENDIF ENDIF ENDIF ENDIF
	low SWAP - GAP * +  to  result ;

: HighBig5>Second	(| high -- second |)
	high $40 $7E [...] IF
	   high $40 -
	ELSE high $A1 $FE [...] IF
	   high $A1 - GAP1 +
	ELSE
	   $FF
	ENDIF ENDIF
	to second ;

: InitConvertionTables	(( -- ))
	$FF  FOR
	  // Table   LowBig5>First*GAP+SerialBase
	    #I LowBig5>First*GAP+SerialBase  
	    #I []LowBig5>First*GAP+SerialBase  !
	  // Table   HighBig5>Second
	    #I HighBig5>Second   #I []HighBig5>Second   C!
	NEXT ; 0 0 #PARMS

InitConvertionTables
FORGET SerialBase0

: Normal(Big5>Serial)	(( b5high b5low -- serial ))
   // Serial Number = First * GAP + Second + SerialBase  //
	$FF AND []LowBig5>First*GAP+SerialBase @ // b5high first*gap+sbase
	SWAP $FF AND []HighBig5>Second C@   	 // first*gap+sbase second
	+	; 2 1 #PARMS 		    	 // first*gap+base+second

: Special(Big5>Serial)	(( b5high b5low -- serial ))
   // Big5 code = $C6 $A1 ... $C6 $FE , serial number = $8001 ... $805E
   	OVER $A1 $FE [...] IF
	   DROP $A1 - $8001 +
	ELSE
	   Normal(Big5>Serial)
	ENDIF ; 2 1 #PARMS

: Big5>Serial	(( b5high b5low -- serial ))
   // This word does not check whether b5high|b5low is a valid Big5 code
	DUP $C6 = IF
	    Special(Big5>Serial)
	ELSE
	    Normal(Big5>Serial)
	ENDIF ; 2 1 #PARMS

FORTH DEFINITIONS

: BIG5>SERIAL	(( b5high b5low -- serial ))
   // Check whether the enterred b5high|b5low is a valid Big5 code
	2DUP IsBig5Low SWAP IsBig5High AND IF
	   Big5>Serial
	ELSE
	   2DROP 0
	ENDIF ; 2 1 #PARMS

ChineseSystem DEFINITIONS

: []PreReadStdFontBuf	 (( index -- addr ))
	|CharFontBuf| * PreReadStdFontBuf +  ; 1 1 #PARMS
: []PreReadSpcFontBuf	 (( index -- addr ))
	|CharFontBuf| * PreReadSpcFontBuf +  ; 1 1 #PARMS
: []PreReadSpcFSuppBuf	 (( index -- addr ))
	|CharFontBuf| * PreReadSpcFSuppBuf +  ; 1 1 #PARMS

: FailOpenMsg	(( errno fname -- ))
	ErrMsgShow? IF
	   ." * Fail openning " COUNT TYPE ."  : " 
	   HERROR$ TYPE CR
	ENDIF  ; 2 0 #PARMS

: OpenStdFont	(| -- |)  RECURSIVE
	NAME$STDFONT COUNT READ/ONLY OPEN IF
	   TO HSTDFONT
	   PreReadStdFontBuf IF
	      PreReadStdFontBuf |PreReadStdFontBuf|  HSTDFONT  HREAD NIP
	   ELSE
	      FALSE
	   ENDIF
	   to PreReadStdFont?
    	ELSE
	   HSTDFONT -1 = IF
	      NAME$STDFONT 1 OVER +! FailOpenMsg
	   ELSE
	      DROP -1 NAME$STDFONT +! // decrease length by 1
	      -1 TO HSTDFONT // as a marker 
	      OpenStdFont
	   ENDIF
    	ENDIF ; 0 0 #PARMS

: OpenSpcFont	(| -- |)
	NAME$SPCFONT COUNT READ/ONLY OPEN IF
	   TO HSPCFONT  
	   PreReadSpcFontBuf IF
	      PreReadSpcFontBuf |PreReadSpcFontBuf|  HSPCFONT  HREAD NIP
	   ELSE
	      FALSE
	   ENDIF
	   to PreReadSpcFont?
    	ELSE
	   NAME$SPCFONT FailOpenMsg
    	ENDIF ;

: OpenSpcFSupp	(| -- |)
	NAME$SPCFSUPP COUNT READ/ONLY OPEN IF
	   TO HSPCFSUPP
	   PreReadSpcFSuppBuf IF
	      PreReadSpcFSuppBuf |PreReadSpcFSuppBuf|  HSPCFSUPP  HREAD NIP
	   ELSE
	      FALSE
	   ENDIF
	   to PreReadSpcFSupp?
    	ELSE  
	   NAME$SPCFSUPP FailOpenMsg
    	ENDIF ;

: OpenUsrFont	(| -- |) RECURSIVE
	NAME$USRFONT COUNT READ/ONLY OPEN IF
	   TO HUSRFONT
    	ELSE
	   HUSRFONT -1 = IF
	      NAME$USRFONT 1 OVER +! FailOpenMsg
	   ELSE
	      DROP -1 NAME$USRFONT +! // decrease length by 1
	      -1 TO HUSRFONT // as a marker 
	      OpenUsrFont
	   ENDIF
    	ENDIF ;

: OpenFontFiles	(| -- |)
	OpenStdFont
	OpenSpcFont
	OpenSpcFSupp
	OpenUsrFont  ;

: InitFailCharFont	(( -- ))
	|CharFontBuf| 24 24 * 8 / = IF
	    FailCharFont	
	    |CharFontBuf| 6 / 1- FOR
	       $AAAA OVER H! 2 +
	       $55AA OVER H! 2 +
	       $5555 OVER H! 2 +
	    NEXT DROP
	ELSE
	    FailCharFont	
	    |CharFontBuf| 4 / 1- FOR
	       $AAAA OVER H! 2 +
	       $5555 OVER H! 2 +
	    NEXT DROP
	ENDIF ;

InitFailCharFont
FORGET InitFailCharFont

// ////////////////////////// //
//    Chinese Font Cache      //
// ////////////////////////// //

// If foreground/background colors change, there is at least
// |FontBitmap to use instead of HSEEK again.

// One cache per file :

// These value should always be power of 2
2048 VALUE STDFONTCache#    // 2048 for STDFONT
64   VALUE SPCFONTCache#    // 64   for SPCFONT
64   VALUE SPCFSUPPCache#   // 64   for SPCFSUPP
256  VALUE USRFONTCache#    // 256  for USRFONT

|CharFontBuf|  VALUE  |FontBitmap|
            0  VALUE  |FontImageSize|

0  VALUE  CurrCacheEntry^  // important pointer for cache operations
0  VALUE  CurrSerialNo	   // used only when cache miss ( for cache update )

STRUCT: ChineseFontCacheTag
    HWORD:   |SerialNo		// value 0 means invalid entry.
    WORD:    |ForeColor
    WORD:    |BackColor
;STRUCT

: |FontBitmap	(( CacheEntry -- Entry|FontBitmap ))
	SIZEOF ChineseFontCacheTag LITERAL  + ; 1 1 #PARMS
: |FontImage	(( CacheEntry -- Entry|FontImage ))
	SIZEOF ChineseFontCacheTag LITERAL + |FontBitmap| + ; 1 1 #PARMS
: |ChineseFontCacheEntry|	(( -- CacheEntrySize ))
	SIZEOF ChineseFontCacheTag LITERAL
	|FontBitmap| + |FontImageSize| +  ; 0 1 #PARMS

0 VALUE STDFONTCache
0 VALUE SPCFONTCache
0 VALUE SPCFSUPPCache
0 VALUE USRFONTCache

DEFER StdFontCacheHit?	(( b5h b5l serial -- b5h b5l T/F )) 3 3 #PARMS
DEFER SpcFontCacheHit?	(( b5h b5l serial -- b5h b5l T/F )) 3 3 #PARMS
DEFER SpcFSuppCacheHit?	(( b5h b5l serial -- b5h b5l T/F )) 3 3 #PARMS
DEFER UsrFontCacheHit?	(( b5h b5l serial -- b5h b5l T/F )) 3 3 #PARMS

0 VALUE Don'tCache
0 VALUE BitmapCacheHit?
0 VALUE ImageCacheHit?
0 VALUE FilePreRead? // This flag is different from PreReadFonts? since 
		     // some font-files might be failed to pre-read ( like
		     // malloc() failed ) .

// Hash functions should have the following prototype :
// xxxxHash (( b5h b5l serial -- b5h b5l key ))
// Since each font have it's own behavior, so their best hashing function
// should be different. For example, STDFONT might not need hash at all
// since chinese character reference is quite random itself. But HSRFONT
// reference are quite ordering.
// However, it seems that the average performance is quite good without 
// special hashing.

#DEFINED StdFontHash NOT #IF
: StdFontHash 	; IMMEDIATE  // currently no hasing
#ENDIF

#DEFINED SpcFontHash NOT #IF
: SpcFontHash	; IMMEDIATE  // currently no hasing
#ENDIF

#DEFINED SpcFSuppHash NOT #IF
: SpcFSuppHash	; IMMEDIATE  // currently no hasing
#ENDIF

#DEFINED UsrFontHash NOT #IF
: UsrFontHash	; IMMEDIATE  // currently no hasing
#ENDIF

: AlwaysCacheMiss	(( serial -- FALSE ))
	TRUE TO Don'tCache
	FALSE NIP 
	DUP DUP to ImageCacheHit?  to BitmapCacheHit? ; 1 1 #PARMS

: FontCacheHit?	(( serial' entry -- T/F ))
	DUP to CurrCacheEntry^  FALSE to Don'tCache
	|SerialNo H@ = DUP IF // TRUE
	   DUP to BitmapCacheHit?
	   CurrCacheEntry^
	   DUP |ForeColor @ GGetForeColor = ANDTHEN
	   DUP |BackColor @ GGetBackColor = THEN-AND to ImageCacheHit? 
	   DROP
	ELSE // FALSE
	   DUP to ImageCacheHit?   DUP to BitmapCacheHit?
	ENDIF ; 2 1 #PARMS

#DEFINED statistics #IF
  0 VALUE StdRefs   0 VALUE StdBmpHits	 0 VALUE StdImgHits
  0 VALUE SpcRefs   0 VALUE SpcBmpHits	 0 VALUE SpcImgHits
  0 VALUE SpcFRefs  0 VALUE SpcFBmpHits	 0 VALUE SpcFImgHits
  0 VALUE UsrRefs   0 VALUE UsrBmpHits	 0 VALUE UsrImgHits
#ENDIF

// Return TRUE if only BitmapCacheHit?

: (StdFontCacheHit?)	(( b5h b5l serial -- b5h b5l T/F ))
    #DEFINED statistics #IF  StdRefs 1+ to StdRefs   #ENDIF
	DUP StdFontHash
	STDFONTCache# 1- AND |ChineseFontCacheEntry| * STDFONTCache +
	FontCacheHit? 
    #DEFINED statistics #IF
       BitmapCacheHit? IF  StdBmpHits 1+ to StdBmpHits  ENDIF 
       ImageCacheHit? IF  StdImgHits 1+ to StdImgHits  ENDIF
    #ENDIF  ; 3 3 #PARMS

: (SpcFontCacheHit?)	(( b5h b5l serial -- b5h b5l T/F ))
    #DEFINED statistics #IF  SpcRefs 1+ to SpcRefs  #ENDIF
	DUP SpcFontHash
	SPCFONTCache# 1- AND |ChineseFontCacheEntry| * SPCFONTCache +
	FontCacheHit? 
    #DEFINED statistics #IF
       BitmapCacheHit? IF  SpcBmpHits 1+ to SpcBmpHits  ENDIF 
       ImageCacheHit? IF  SpcImgHits 1+ to SpcImgHits  ENDIF
    #ENDIF  ; 3 3 #PARMS

: (SpcFSuppCacheHit?)	(( b5h b5l serial -- b5h b5l T/F ))
    #DEFINED statistics #IF  SpcFRefs 1+ to SpcFRefs  #ENDIF
	DUP SpcFSuppHash
	SPCFSUPPCache# 1- AND |ChineseFontCacheEntry| * SPCFSUPPCache +
	FontCacheHit? 
    #DEFINED statistics #IF
       BitmapCacheHit? IF  SpcFBmpHits 1+ to SpcFBmpHits  ENDIF 
       ImageCacheHit? IF  SpcFImgHits 1+ to SpcFImgHits  ENDIF
    #ENDIF  ; 3 3 #PARMS

: (UsrFontCacheHit?)	(( b5h b5l serial -- b5h b5l T/F ))
    #DEFINED statistics #IF  UsrRefs 1+ to UsrRefs   #ENDIF
	DUP UsrFontHash
	USRFONTCache# 1- AND |ChineseFontCacheEntry| * USRFONTCache +
	FontCacheHit? 
    #DEFINED statistics #IF
       BitmapCacheHit? IF  UsrBmpHits 1+ to UsrBmpHits  ENDIF 
       ImageCacheHit? IF  UsrImgHits 1+ to UsrImgHits  ENDIF
    #ENDIF  ; 3 3 #PARMS

: >>>BitmapCache	(( -- ))
	Don'tCache IF EXIT ENDIF
	CurrSerialNo   CurrCacheEntry^ |SerialNo   H!
	CharFontPtr  CurrCacheEntry^ |FontBitmap  |FontBitmap|  CMOVE
	; 0 0 #PARMS

: >>>ImageCache	 	(( x0 y0 x1 y1 -- ))
	Don'tCache IF 4DROP EXIT ENDIF
	CurrCacheEntry^ |FontImage  GGetImage
	CurrCacheEntry^
//	CurrSerialNo OVER |SerialNo H!  ... done by >>>BitmapCache
	GGetForeColor OVER |ForeColor !
	GGetBackColor SWAP |BackColor !  ; 4 0 #PARMS

: BitmapCache>>>	(( -- ))
	CurrCacheEntry^ |FontBitmap  to  CharFontPtr  ; 0 0 #PARMS

: ImageCache>>>	 (( x y -- ))
	CurrCacheEntry^ |FontImage  G_COPY_PUT  GPutImage ; 2 0 #PARMS

FORTH DEFINITIONS

: OpenChineseCache	(( -- ))
	STDFONTCache  IF ['] (StdFontCacheHit?) ELSE ['] AlwaysCacheMiss ENDIF
	  IS StdFontCacheHit?
	SPCFONTCache  IF ['] (SpcFontCacheHit?) ELSE ['] AlwaysCacheMiss ENDIF
	  IS SpcFontCacheHit?
	SPCFSUPPCache IF ['] (SpcFSuppCacheHit?) ELSE ['] AlwaysCacheMiss ENDIF
	  IS SpcFSuppCacheHit?
	USRFONTCache  IF ['] (UsrFontCacheHit?) ELSE ['] AlwaysCacheMiss ENDIF
	  IS UsrFontCacheHit?  ; 0 0 #PARMS

: CloseChineseCache
	['] AlwaysCacheMiss IS StdFontCacheHit?
	['] AlwaysCacheMiss IS SpcFontCacheHit?
	['] AlwaysCacheMiss IS SpcFSuppCacheHit?
	['] AlwaysCacheMiss IS UsrFontCacheHit?  ; 0 0 #PARMS

ChineseSystem DEFINITIONS

: InitChineseFontCache	(( -- ))
	FONTSIZE 15 = IF
   	   1 1 16 15 GImageSize  to  |FontImageSize|
	ELSE
   	   1 1 24 24 GImageSize  to  |FontImageSize|
	ENDIF
	|CharFontBuf| TO |FontBitmap|

	|ChineseFontCacheEntry|
	DUP STDFONTCache# *  malloc  DUP to  STDFONTCache
	IF DUP STDFONTCache# * STDFONTCache SWAP $FF FILL ENDIF
	DUP SPCFONTCache# *    malloc  DUP to  SPCFONTCache
	IF DUP SPCFONTCache# * SPCFONTCache SWAP $FF FILL ENDIF
	DUP SPCFSUPPCache# *    malloc  DUP to  SPCFSUPPCache
	IF DUP SPCFSUPPCache# * SPCFSUPPCache SWAP $FF FILL ENDIF
	DUP USRFONTCache# *    malloc  DUP to  USRFONTCache
	IF DUP USRFONTCache# * USRFONTCache SWAP $FF FILL ENDIF
	DROP

	OpenChineseCache 

	; 0 0 #PARMS

// /////////////////////////////// //
//    Chinese Font File Read       //
// /////////////////////////////// //

: PointToStdFont	(( serial -- ))
	TRUE TO FilePreRead?
	$8800 - []PreReadStdFontBuf  TO  CharFontPtr	; 1 0 #PARMS

: PointToSpcFont	(( serial -- ))
	TRUE TO FilePreRead?
	$8400 - []PreReadSpcFontBuf  TO  CharFontPtr	; 1 0 #PARMS

: PointToSpcFSupp	(( serial -- ))
	TRUE TO FilePreRead?
	$8001 - []PreReadSpcFSuppBuf  TO  CharFontPtr	; 1 0 #PARMS

: ReadFontFile	(( handle -- ))
	(CharFontBuf) TO CharFontPtr	// default font buffer
	CharFontPtr |CharFontBuf| ROT HREAD NIP NOT IF
	   FailCharFont to CharFontPtr <BEEP>
	ENDIF ; 1 0 #PARMS

: SeekAndReadStdFont	(( serial -- ))
	FALSE TO FilePreRead?
	FailCharFont	to CharFontPtr
	$8800 - |CharFontBuf| *    SEEK_SET SWAP HSTDFONT  HSEEK
	NIP NOT IF <BEEP> EXIT ENDIF
	HSTDFONT   ReadFontFile ; 1 0 #PARMS

: SeekAndReadSpcFont	(( serial -- ))
	FALSE TO FilePreRead?
	FailCharFont	to CharFontPtr
	$8400 - |CharFontBuf| *    SEEK_SET SWAP HSPCFONT  HSEEK
	NIP NOT IF <BEEP> EXIT ENDIF
	HSPCFONT   ReadFontFile ; 1 0 #PARMS

: SeekAndReadSpcFSupp	(( serial -- ))
	FALSE TO FilePreRead?
	FailCharFont	to CharFontPtr
	$8001 - |CharFontBuf| *    SEEK_SET SWAP HSPCFSUPP  HSEEK
	NIP NOT IF <BEEP> EXIT ENDIF
	HSPCFSUPP  ReadFontFile ; 1 0 #PARMS

: SeekAndReadUsrFont	(( serial -- ))
	FALSE TO FilePreRead?
	FailCharFont	to CharFontPtr
	DUP
	$E000 - |CharFontBuf| CELL+ * 256 +
	SEEK_SET SWAP HUSRFONT HSEEK  NIP NOT IF <BEEP> EXIT ENDIF
	UserCharFont TO CharFontPtr	// default font buffer
	CharFontPtr |CharFontBuf| CELL+ HUSRFONT HREAD NIP NOT
	SWAP  CharFontPtr 2 + H@  <>   OR
	IF
    	   FailCharFont to CharFontPtr <BEEP>
	ELSE
	   CharFontPtr CELL+ to CharFontPtr
	ENDIF ; 1 0 #PARMS

#DEFINED statistics #IF

  0 VALUE TotalReference
  0 VALUE BitmapHits
  0 VALUE ImageHits
  FORTH DEFINITIONS
  : RESTAT
  	0 TO StdRefs   0 TO StdBmpHits	 0 TO StdImgHits
  	0 TO SpcRefs   0 TO SpcBmpHits	 0 TO SpcImgHits
  	0 TO SpcFRefs  0 TO SpcFBmpHits	 0 TO SpcFImgHits
  	0 TO UsrRefs   0 TO UsrBmpHits	 0 TO UsrImgHits
	0 TO TotalReference  0 TO BitmapHits  0 TO ImageHits  ;
  : CACHE/STAT
	CR ." Total bitmap hit ratio = " 
	BitmapHits S>F TotalReference S>F 0.0001 F+ F/ 100.0 F* 2 4 F.R
	." % ; Total image hit ratio = "
	ImageHits S>F TotalReference S>F 0.0001 F+ F/ 100.0 F* 2 4 F.R ." %"
	CR ." STDFONT bitmap hit ratio = " 
	StdBmpHits S>F StdRefs S>F 0.0001 F+ F/ 100.0 F* 2 4 F.R
	." % ; image hit ratio = "
	StdImgHits S>F StdRefs S>F 0.0001 F+ F/ 100.0 F* 2 4 F.R ." %"
	CR ." SPCFONT bitmap hit ratio = " 
	SpcBmpHits S>F SpcRefs S>F 0.0001 F+ F/ 100.0 F* 2 4 F.R
	." % ; image hit ratio = "
	SpcImgHits S>F SpcRefs S>F 0.0001 F+ F/ 100.0 F* 2 4 F.R ." %"
	CR ." SPCFSUPP bitmap hit ratio = " 
	SpcFBmpHits S>F SpcFRefs S>F 0.0001 F+ F/ 100.0 F* 2 4 F.R
	." % ; image hit ratio = "
	SpcFImgHits S>F SpcFRefs S>F 0.0001 F+ F/ 100.0 F* 2 4 F.R ." %"
	CR ." USRFONT bitmap hit ratio = " 
	UsrBmpHits S>F UsrRefs S>F 0.0001 F+ F/ 100.0 F* 2 4 F.R
	." % ; image hit ratio = "
	UsrImgHits S>F UsrRefs S>F 0.0001 F+ F/ 100.0 F* 2 4 F.R  ." %" CR  ;
  	
  ChineseSystem DEFINITIONS

#ENDIF // statistics

: GetFont	(( b5high b5low -- ))
    #DEFINED statistics #IF
      TotalReference 1+ TO TotalReference
    #ENDIF
	2DUP Big5>Serial
	DUP $8800 $BB25  [...] IF
	   DUP StdFontCacheHit?  NOT 
	   IF DUP to CurrSerialNo GetStdFont 2DROP EXIT ENDIF
	ELSE DUP $8400 $8597 [...] IF
	   DUP SpcFontCacheHit?  
	   NOT IF DUP to CurrSerialNo GetSpcFont 2DROP EXIT ENDIF
	ELSE DUP $8001 $816D [...] IF
	   DUP SpcFSuppCacheHit? 
	   NOT IF DUP to CurrSerialNo GetSpcFSupp 2DROP EXIT ENDIF
	ELSE DUP $E000 $FFFF [...] IF
	   DUP UsrFontCacheHit?  
	   NOT IF DUP to CurrSerialNo GetUsrFont 2DROP EXIT ENDIF
	ELSE
	   FailCharFont to CharFontPtr
	ENDIF ENDIF ENDIF ENDIF
	3DROP
    #DEFINED statistics #IF
      BitmapCacheHit? IF  BitmapHits 1+ TO BitmapHits  ENDIF
      ImageCacheHit? IF  ImageHits 1+ TO ImageHits  ENDIF
    #ENDIF
	; 2 0 #PARMS

: DrawChinese15  (| b5high b5low | x0 x y -- |)
	MULTI? SINGLE // prevent re-enter while cache refreshing
	G_HideCursor AT? GCursor>Coord to y to x0
	b5high b5low GetFont
	ImageCacheHit? IF
	    x0 y ImageCache>>>
	ELSE
	    BitmapCacheHit? IF  BitmapCache>>>  ELSE  >>>BitmapCache  ENDIF
	    CharFontPtr
	    14 FOR  // 15 1-
	       x0 to x
	       DUP   // //////  C@ 256* OVER 1+ C@ OR  // 16_points
	       H@ [  $86 C, $C4 C,  ] // machine code : XCHG  AH  AL
	       $8000   // a bit-mask	     S:	16_points mask
	       15 FOR
	          2DUP AND IF  x y GGetForeColor GDrawCPoint
	          ELSE	       x y GGetBackColor GDrawCPoint	ENDIF
	          2/    // shift bit mask
	          x 1+  to  x
	       NEXT
	       2DROP
	       1+ 1+  y 1+ to y
	    NEXT
	    DROP
	    x0 y 15 -  x 1- y 1-  >>>ImageCache
	ENDIF
	IF MULTI ENDIF ;

: DrawChinese24  (| b5high b5low | x0 y0 x y -- |)
	MULTI? SINGLE // prevent re-enter while cache refreshing
	G_HideCursor AT? GCursor>Coord (( col_x row_y -- x y )) to y0 to x0
	b5high b5low GetFont
	ImageCacheHit? IF
	    x0 y0 ImageCache>>>
	ELSE
	    BitmapCacheHit? IF  BitmapCache>>>  ELSE  >>>BitmapCache  ENDIF
	    y0 to y
	    CharFontPtr
	    23  FOR  // 24 1-
	       x0 to x
	       DUP // //C@ 256* OVER 1+ C@ OR 256* OVER 2 + C@ OR // 24_points
	       @ 256*  [  $0F C, $C8 C,  ] // machine code : BSWAP  EAX
	       $800000   // a bit-mask	     S:	24_points mask
	       23 FOR
	          2DUP AND IF  x y GGetForeColor GDrawCPoint
	          ELSE	       x y GGetBackColor GDrawCPoint	ENDIF
	          2/    // shift bit mask
	          x 1+  to  x
	       NEXT
	       2DROP
	       1+ 1+ 1+   y 1+ to y
	    NEXT
	    DROP
	    x0 y0 OVER 23 + OVER 23 + >>>ImageCache
	ENDIF
	IF MULTI ENDIF  ;

: DefaultDrawASCII  (( c -- ))
	DEFERS GDrawASCII  ;  1 0 #PARMS

VARIABLE 'ASCII-CONSOLE		'CONSOLE @  'ASCII-CONSOLE  !
VARIABLE 'ASCII-EMIT		'EMIT @     'ASCII-EMIT	    !

DEFER DrawChinese  (( b5lo b5hi -- )) 2 0 #PARMS

: ASCII_Emit	(( c -- ))
	'ASCII-EMIT @EXECUTE ; 1 0 #PARMS

: Big5Emit	(( b5high b5low -- ))
	AT? DROP GSizeColumn 1- >= IF
	   ASCII_Emit ASCII_Emit
	ELSE
	   DrawChinese  2 GCursor+!
	ENDIF  ; 2 0 #PARMS

0   VALUE LastBig5
0   VALUE CheckBig5High

: ChineseEMIT		(( C -- ))
	CheckBig5High IF
	   DUP IsBig5High IF
	       LastBig5  Big5Emit
	       FALSE to CheckBig5High EXIT
	   ELSE
	       LastBig5 ASCII_Emit
	   ENDIF
	ENDIF

	DUP IsBig5Low IF
	   TRUE to CheckBig5High	
	   to LastBig5 EXIT 
	ELSE
	   FALSE to CheckBig5High    // bug fixed here. 12/25/'95
	   ASCII_Emit
	ENDIF  ; 1 0 #PARMS

// Vectorred word are leading by a '^' character.
// ^ EMIT -> BIOSEMIT
//        -> GASCIIEmit  ->^ GDrawASCII -> G_DrawChar
//				      ( -> DrawASCII8x14 )
//				      (	-> DrawASCII16x24 )
//        -> ChineseEmit -> Big5Emit    ->^ DrawChinese -> DrawChinese15
//						        -> DrawChinese24
//			 -> GASCIIEmit  ->^ GDrawASCII  -> G_DrawChar
//						      ( -> DrawASCII8x14 )
//						      ( -> DrawASCII16x24 )

: ChineseConsole	(( -- ))
	'ASCII-CONSOLE @EXECUTE
	['] ChineseEMIT 'EMIT ! ; 0 0 #PARMS

FALSE   VALUE (ChineseNow?)
FALSE	VALUE (ChineseOpened?)

CREATE DefaultET3Path  $," C:\ET3"
CREATE TMPBUF  4 ALLOT

: InitFileNames  (| | et3path et3pathlen -- |)
	getenv( Z$" ET3" ) to et3path
	et3path 0= IF
	   DefaultET3Path COUNT to et3pathlen  to et3path
	ELSE
	   strlen( et3path )  to et3pathlen
	ENDIF
	FONTSIZE 15 = IF  BL TO FONTTYPE  ENDIF
	FONTTYPE TMPBUF C! // R = round, M = ming ...

	NAME$STDFONT  OFF  	NAME$SPCFONT  OFF
	NAME$SPCFSUPP OFF  	NAME$USRFONT  OFF

	NAME$STDFONT et3path et3pathlen $+ " \STDFONT." $+ 
	FONTSIZE <# # # #> $+ TMPBUF 1 $+ DROP

	NAME$SPCFONT et3path et3pathlen $+ " \SPCFONT." $+ 
	FONTSIZE <# # # #> $+ DROP

	NAME$SPCFSUPP et3path et3pathlen $+ " \SPCFSUPP." $+ 
	FONTSIZE <# # # #> $+ DROP

	FONTTYPE BL = IF  ASCII M TMPBUF C!  ENDIF
	NAME$USRFONT et3path et3pathlen $+ " \USRFONT." $+ 
	FONTSIZE <# # # #> $+ TMPBUF 1 $+ DROP ;

// ((    EBP EDI ESI EDX ECX EBX EAX int#   
//   -- EBP EDI ESI EDX ECX EBX EAX flag ))

: Eten?		(( -- T/F ))
	// Check whether it is in ETEN chinese system now.
	// EBP EDI ESI EDX ECX EBX EAX	  int#/flag
	    0  0   2DUP    2DUP    $9100  $10  trap
					  DROP
				   $9100 <> >R
	    6DROP R> ; 0 1 #PARMS

: EtenChineseMode?	(( -- T/F ))
	// Check whether Eten is now in ASCII mode or Chinese mode.
	// EBP EDI ESI EDX ECX EBX EAX	  int#/flag
	    0  0   2DUP    2DUP    $9100  $10  trap
					  DROP
				   $9100 <> >R
			   2DROP
			>R
	    3DROP R> R> IF
		$8000 AND 0=
	    ELSE
		DROP FALSE
	    ENDIF ; 0 1 #PARMS

: Eten>Chinese  (( -- ))
	// Switch ETEN into Chinese display mode.
	// EBP EDI ESI EDX ECX EBX EAX	  int#/flag
	    0  0   2DUP    2DUP    $8042  $10  trap
	    8DROP ; 0 0 #PARMS

: Eten>English  (( -- ))
	// Switch ETEN into English display mode.
	// EBP EDI ESI EDX ECX EBX EAX	  int#/flag
	    0  0   2DUP    2DUP    $8041  $10  trap
	    8DROP ; 0 0 #PARMS

FORTH DEFINITIONS // ///////////////////////////////////////////////////////

: ChineseNow?  (( -- T/F ))   // make (ChineseNow?) a read/only value
	(ChineseNow?)  ;  0 1 #PARMS
: ChineseOpened? (( -- T/F ))   // make (ChineseOpened?) a read/only value
	(ChineseOpened?)  ; 0 1 #PARMS

: CHINESE	(( -- ))
	ChineseOpened? IF
	   ChineseNow? NOT IF
	       GraphicsMode? NOT IF  GRAPHICS-MODE  ENDIF
	       'EMIT @     'ASCII-EMIT	  !
	       'CONSOLE @  'ASCII-CONSOLE !
	       ['] ChineseConsole 'CONSOLE !
	       TRUE TO (ChineseNow?)
	       CONSOLE
	   ENDIF
	ELSE
	   CR ." * Execute 'OpenChinese' first ." CR BEEP ABORT
	ENDIF ; 0 0 #PARMS

: ENGLISH	(( -- ))
	ChineseNow? IF
	    'ASCII-CONSOLE @  'CONSOLE !
//	    'ASCII-EMIT @     'EMIT !
	    FALSE TO (ChineseNow?)
	    CONSOLE
	ENDIF ; 0 0 #PARMS

: OpenChinese	(( -- ))  // For Turnkey Systems.
	(ChineseOpened?) NOT IF
	   GraphicsMode? NOT IF  GRAPHICS-MODE  ENDIF
	   ChooseBestFont? FONTSIZE DUP 15 <> SWAP 24 <> AND  OR
	   IF
	      GMaxX  24 40 *  <  IF
	          15 TO FONTSIZE   BL TO FONTTYPE
	      ELSE
	          24 TO FONTSIZE
	      ENDIF
	   ENDIF

	   FONTSIZE 24 = IF
	       24 24 * 8 / TO  |CharFontBuf|
	   ELSE
	       15 16 * 8 / TO  |CharFontBuf|
	   ENDIF
	   InitFileNames
	   PreReadFonts? IF
	      |PreReadStdFontBuf|  16 +  malloc  TO  PreReadStdFontBuf
	      |PreReadSpcFontBuf|  16 +  malloc  TO  PreReadSpcFontBuf
	      |PreReadSpcFSuppBuf| 16 +  malloc  TO  PreReadSpcFSuppBuf
	   ENDIF

	   FONTSIZE 15 = 
	   IF  ['] DrawChinese15   ELSE   ['] DrawChinese24  ENDIF 
	   to DrawChinese

	   InitChineseFontCache

	   OpenFontFiles

           PreReadStdFont?
	   IF  ['] PointToStdFont   ELSE   ['] SeekAndReadStdFont   ENDIF
	   to GetStdFont
     	   PreReadSpcFont? 
	   IF  ['] PointToSpcFont   ELSE   ['] SeekAndReadSpcFont   ENDIF
	   to GetSpcFont
     	   PreReadSpcFSupp? 
	   IF  ['] PointToSpcFSupp  ELSE   ['] SeekAndReadSpcFSupp  ENDIF
	   to GetSpcFSupp
	   ['] SeekAndReadUsrFont  to  GetUsrFont

	   TRUE to (ChineseOpened?)
	ENDIF
	CHINESE ;

: CloseChinese	(( -- ))	// Do this before FSAVE
	ENGLISH
	(ChineseOpened?) IF
	   CloseChineseCache
	   STDFONTCache	  IF  STDFONTCache free  0 TO STDFONTCache   ENDIF
	   SPCFONTCache	  IF  SPCFONTCache free  0 TO SPCFONTCache   ENDIF
	   SPCFSUPPCache  IF  SPCFSUPPCache free 0 TO SPCFSUPPCache  ENDIF
	   USRFONTCache	  IF  USRFONTCache free  0 TO USRFONTCache   ENDIF
	   PreReadStdFont?  IF  PreReadStdFontBuf  free  ENDIF
	   PreReadSpcFont?  IF  PreReadSpcFontBuf  free  ENDIF
	   PreReadSpcFSupp? IF  PreReadSpcFSuppBuf free  ENDIF
	   FALSE TO PreReadStdFont?	0 TO PreReadStdFontBuf 
	   FALSE TO PreReadSpcFont?  	0 TO PreReadSpcFontBuf 
	   FALSE TO PreReadSpcFSupp?	0 TO PreReadSpcFSuppBuf
	   HSTDFONT  IF  HSTDFONT  HCLOSE DROP  ENDIF   0 TO HSTDFONT
	   HSPCFONT  IF  HSPCFONT  HCLOSE DROP  ENDIF   0 TO HSPCFONT
	   HSPCFSUPP IF  HSPCFSUPP HCLOSE DROP  ENDIF   0 TO HSPCFSUPP
	   HUSRFONT  IF  HUSRFONT  HCLOSE DROP  ENDIF   0 TO HUSRFONT
	   FALSE TO (ChineseOpened?)
	ENDIF ; 0 0 #PARMS

ChineseSystem DEFINITIONS // ////////////////////////////////////////////////

0 VALUE ChineseBeforeTextMode?
0 VALUE ChineseBeforeDos?
0 VALUE EtenChineseBeforeGraphics?

: ChineseToTextMode	 (( -- ))
	DEFERS HOOK-TEXTMODE
	ChineseNow? to ChineseBeforeTextMode?
	CloseChinese 
	; 0 0 #PARMS

: TextModeToChinese	(( -- ))
	DEFERS TEXTMODE-HOOK
	EtenChineseBeforeGraphics? IF  Eten>Chinese  ENDIF ; 0 0 #PARMS

: ChineseToGraphicsMode	 (( -- ))
	EtenChineseMode? DUP to EtenChineseBeforeGraphics?
	IF  Eten>English  ENDIF
	DEFERS HOOK-GRAPHICSMODE ; 0 0 #PARMS

: GraphicsModeToChinese  (( -- ))
	DEFERS GRAPHICSMODE-HOOK
	ChineseBeforeTextMode? IF OpenChinese ENDIF ; 0 0 #PARMS

' ChineseToTextMode     IS HOOK-TEXTMODE
' TextModeToChinese	IS TEXTMODE-HOOK
' ChineseToGraphicsMode	IS HOOK-GRAPHICSMODE
' GraphicsModeToChinese IS GRAPHICSMODE-HOOK

OpenChinese 
CR .( þ CHINESE.4TH loaded, Chinese opened þ ) CR

ONLY GRAPHICS ALSO FORTH ALSO DEFINITIONS

// FLOAD .\SAMPLES\DUMPFILE.4TH	  // a simple testing file.

