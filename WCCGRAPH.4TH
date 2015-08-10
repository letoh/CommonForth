// Graphics facility for Watcom C/C++ 10.5
//
//						Version     : 1.0
// 						Written by  : Luke Lee
//						Last update : 10/22/'95

NEEDS INVOKEC.4TH

C++ DEFINITIONS

// ' _setwritemode   ALIAS _setplotaction      // for compatibility
// ' _getwritemode   ALIAS _getplotaction
// ' _setwritemode(  ALIAS _setplotaction(
// ' _getwritemode(  ALIAS _getplotaction(

// ' _getlogcoord    ALIAS _getviewcoord        // for compatibility 
// ' _setlogorg      ALIAS _setvieworg
// ' _getlogcoord(   ALIAS _getviewcoord(
// ' _setlogorg(     ALIAS _setvieworg(

VOCABULARY GRAPHICS
GRAPHICS DEFINITIONS

STRUCT: xycoord			// structure for pixel position 
	HWORD:   |xcoord
	HWORD:   |ycoord
;STRUCT

STRUCT: _wxycoord               // structure for window position
    2WORD: |wx
    2WORD: |wy
;STRUCT

STRUCT: rccoord                 // structure for text position  
	HWORD:   |row
	HWORD:   |col
;STRUCT

STRUCT: videoconfig             // structure for _getvideoconfig 
	HWORD:   |numxpixels
	HWORD:   |numypixels
	HWORD:   |numtextcols
	HWORD:   |numtextrows
	HWORD:   |numcolors
	HWORD:   |bitsperpixel
	HWORD:   |numvideopages
	HWORD:   |mode
	HWORD:   |adapter
	HWORD:   |monitor
	HWORD:   |memory
;STRUCT

STRUCT: textsettings            // structure for _gettextsettings 
	HWORD:   |basevectorx
	HWORD:   |basevectory
	HWORD:   |txpath
	HWORD:   |height
	HWORD:   |width
	HWORD:   |spacing
	HWORD:   |horizalign
	HWORD:   |vertalign
;STRUCT

STRUCT: _fontinfo               // structure for _getfontinfo 
	HWORD:   |type
	HWORD:   |ascent
	HWORD:   |pixwidth
	HWORD:   |pixheight
	HWORD:   |avgwidth
     81 FIELD: 	 |filename[]
     32 FIELD:   |facename[]
;STRUCT

-3        CONSTANT    _MAXRESMODE     // graphics mode with highest res. 
-2        CONSTANT    _MAXCOLORMODE   // graphics mode with most colours 
-1        CONSTANT    _DEFAULTMODE    // restore screen to original mode 
0         CONSTANT    _TEXTBW40       // 40 x 25 text, 16 grey           
1         CONSTANT    _TEXTC40        // 40 x 25 text, 16/8 color        
2         CONSTANT    _TEXTBW80       // 80 x 25 text, 16 grey           
3         CONSTANT    _TEXTC80        // 80 x 25 text, 16/8 color        
4         CONSTANT    _MRES4COLOR     // 320 x 200, 4 color              
5         CONSTANT    _MRESNOCOLOR    // 320 x 200, 4 grey               
6         CONSTANT    _HRESBW         // 640 x 200, BW                   
7         CONSTANT    _TEXTMONO       // 80 x 25 text, BW                
11        CONSTANT    _HERCMONO       // 720 x 350, BW                   
13        CONSTANT    _MRES16COLOR    // 320 x 200, 16 color             
14        CONSTANT    _HRES16COLOR    // 640 x 200, 16 color             
15        CONSTANT    _ERESNOCOLOR    // 640 x 350, BW                   
16        CONSTANT    _ERESCOLOR      // 640 x 350, 4 or 16 color        
17        CONSTANT    _VRES2COLOR     // 640 x 480, BW                   
18        CONSTANT    _VRES16COLOR    // 640 x 480, 16 color             
19        CONSTANT    _MRES256COLOR   // 320 x 200, 256 color            
$100      CONSTANT    _URES256COLOR   // 640 x 400, 256 color            
$101      CONSTANT    _VRES256COLOR   // 640 x 480, 256 color            
$102      CONSTANT    _SVRES16COLOR   // 800 x 600, 16 color             
$103      CONSTANT    _SVRES256COLOR  // 800 x 600, 256 color            
$104      CONSTANT    _XRES16COLOR    // 1024 x 768, 16 color            
$105      CONSTANT    _XRES256COLOR   // 1024 x 768, 256 color           
	  
-1  	  CONSTANT    _NODISPLAY          // no display device            
0   	  CONSTANT    _UNKNOWN            // unknown adapter/monitor type 
1   	  CONSTANT    _MDPA               // monochrome display/printer adapter 
2   	  CONSTANT    _CGA                // colour/graphics monitor adapter    
3   	  CONSTANT    _HERCULES           // Hercules monochrome adapter card   
4   	  CONSTANT    _MCGA               // PS/2 Model 30 monitor              
5   	  CONSTANT    _EGA                // enhanced graphics adapter          
6   	  CONSTANT    _VGA                // vector graphics array              
7   	  CONSTANT    _SVGA               // super VGA                          
_HERCULES CONSTANT    _HGC            

1    CONSTANT    _MONO              // regular monochrome 
2    CONSTANT    _COLOR             // regular color      
3    CONSTANT    _ENHANCED          // enhanced color     
5    CONSTANT    _ANALOGMONO        // analog monochrome  
6    CONSTANT    _ANALOGCOLOR       // analog color       

0     CONSTANT    _GROK                    // no error                     
-1    CONSTANT    _GRERROR                 // graphics error               
-2    CONSTANT    _GRMODENOTSUPPORTED      // video mode not supported     
-3    CONSTANT    _GRNOTINPROPERMODE       // function n/a in this mode    
-4    CONSTANT    _GRINVALIDPARAMETER      // invalid parameter(s)         
-5    CONSTANT    _GRINSUFFICIENTMEMORY    // out of memory                
-6    CONSTANT    _GRFONTFILENOTFOUND      // can't open font file         
-7    CONSTANT    _GRINVALIDFONTFILE       // font file has invalid format 
1     CONSTANT    _GRNOOUTPUT              // nothing was done             
2     CONSTANT    _GRCLIPPED               // output clipped               


// Colors for background

$000000     CONSTANT    _BLACK
$2A0000     CONSTANT    _BLUE           
$002A00     CONSTANT    _GREEN          
$2A2A00     CONSTANT    _CYAN           
$00002A     CONSTANT    _RED            
$2A002A     CONSTANT    _MAGENTA        
$00152A     CONSTANT    _BROWN          
$2A2A2A     CONSTANT    _WHITE          
$151515     CONSTANT    _GRAY           
$3F1515     CONSTANT    _LIGHTBLUE      
$153F15     CONSTANT    _LIGHTGREEN     
$3F3F15     CONSTANT    _LIGHTCYAN      
$15153F     CONSTANT    _LIGHTRED       
$3F153F     CONSTANT    _LIGHTMAGENTA   
$153F3F     CONSTANT    _YELLOW         
$3F3F3F     CONSTANT    _BRIGHTWHITE    
_YELLOW     CONSTANT    _LIGHTYELLOW


// plotting action 
0 	CONSTANT	_GOR
1	CONSTANT	_GAND 
2	CONSTANT	_GPRESET 
3	CONSTANT	_GPSET 
4	CONSTANT	_GXOR

0	CONSTANT	_GCLEARSCREEN
1	CONSTANT	_GVIEWPORT      
2	CONSTANT	_GWINDOW        

2	CONSTANT	_GBORDER        
3	CONSTANT	_GFILLINTERIOR

// cursor display 
0	CONSTANT	_GCURSOROFF
1	CONSTANT	_GCURSORON

// text wrapping 
0	CONSTANT	_GWRAPOFF 
1	CONSTANT	_GWRAPON

// horizontal alignment
0	CONSTANT	_NORMAL 
1	CONSTANT	_LEFT 
2	CONSTANT	_CENTER 
3	CONSTANT	_RIGHT

// vertical alignment 
1	CONSTANT	_TOP 
2	CONSTANT	_CAP 
3	CONSTANT	_HALF 
4	CONSTANT	_BASE
5	CONSTANT	_BOTTOM

// text path 
0	CONSTANT	_PATH_RIGHT
1	CONSTANT	_PATH_LEFT
2	CONSTANT	_PATH_UP 
3	CONSTANT	_PATH_DOWN

// Text Manipulation Functions 
1      CONSTANT    _GSCROLLUP      
-1     CONSTANT    _GSCROLLDOWN    
-1     CONSTANT    _MAXTEXTROWS    

videoconfig GCurrVideoConfig
CREATE OutCharBuf 0 , 0 ,	// only 2 bytes needed in fact.

GRAPHICS DEFINITIONS

// Translation to Common Forth Graphics Words ( Abstract Common Forth Concept )

_GXOR     CONSTANT  G_XOR_PUT
_GOR	  CONSTANT  G_OR_PUT
_GAND     CONSTANT  G_AND_PUT
_GPRESET  CONSTANT  G_NOT_PUT
_GPSET    CONSTANT  G_COPY_PUT

_MRES16COLOR    CONSTANT   G320x200x16
_MRES256COLOR   CONSTANT   G320x200x256
_VRES16COLOR    CONSTANT   G640x480x16
_VRES256COLOR   CONSTANT   G640x480x256
_SVRES16COLOR   CONSTANT   G800x600x16
_SVRES256COLOR  CONSTANT   G800x600x256
_XRES16COLOR    CONSTANT   G1024x768x16
_XRES256COLOR   CONSTANT   G1024x768x256

 0   CONSTANT   G_BLACK
 1   CONSTANT   G_BLUE
 2   CONSTANT   G_GREEN
 3   CONSTANT   G_CYAN
 4   CONSTANT   G_RED
 5   CONSTANT   G_MAGENTA
 6   CONSTANT   G_BROWN
 7   CONSTANT   G_LIGHTGRAY
 8   CONSTANT   G_DARKGRAY
 9   CONSTANT   G_LIGHTBLUE
10   CONSTANT   G_LIGHTGREEN
11   CONSTANT   G_LIGHTCYAN
12   CONSTANT   G_LIGHTRED
13   CONSTANT   G_LIGHTMAGENTA
14   CONSTANT   G_YELLOW
15   CONSTANT   G_WHITE

: GSetColor	(( color -- ))  _setcolor DROP ; 1 0 #PARMS
: GGetColor	(( -- color ))  _getcolor ; 0 1 #PARMS

: GDrawPoint	    (( x y -- ))
	SWAP _setpixel DROP ; 3 0 #PARMS

: GDrawLine      (( x0 y0 x1 y1 -- ))
	SWAP _moveto SWAP _lineto DROP ; 5 0 #PARMS
	
: GDrawRectangle (| x0 y0 x1 y1 -- |)
	_rectangle( _GBORDER , x0 , y0 , x1 , y1 ) DROP ;

: GFillRectangle (| x0 y0 x1 y1 -- |)
	_rectangle( _GFILLINTERIOR , x0 , y0 , x1 , y1 ) DROP ;

: GDrawCPoint	(( x y color -- ))  _GDrawCPoint ; 3 0 #PARMS
: GDrawCLine	(( x0 y0 x1 y1 color -- )) _GDrawCLine ; 5 0 #PARMS
: GDrawCRectangle (( x0 y0 x1 y1 color -- ))  _GDrawCRectangle ; 5 0 #PARMS
: GFillCRectangle (( x0 y0 x1 y1 color -- ))  _GFillCRectangle ; 5 0 #PARMS
	
: GImageSize	    (( x0 y0 x1 y1 -- n ))
	SWAP 2SWAP SWAP _imagesize ; 4 1 #PARMS

: GGetImage      (| left top right bottom *image -- |)
	_getimage( left , top , right , bottom , *image )  ;

: GPutImage      (| left top *image op -- |)
	_putimage( left , top , *image , op )  ;

0 VALUE (MoveImageBuf) INVISIBLE

: GMoveImage	 (( destX destY srcX0 srcY0 srcX1 srcY1 -- ))  // optional
	(MoveImageBuf) IF
	   (MoveImageBuf) GGetImage
	   (MoveImageBuf) G_COPY_PUT GPutImage
	ELSE
	   6DROP 
	ENDIF ; 6 0 #PARMS

// Read Graphics region/size
: GSizeX  (( -- SizeX )) 
	[ GCurrVideoConfig |numxpixels ] LITERAL H@ ; 0 1 #PARMS MACRO
: GSizeY  (( -- SizeY ))
	[ GCurrVideoConfig |numypixels ] LITERAL H@ ; 0 1 #PARMS MACRO
: GMaxX	  (( -- MaxX ))
	[ GCurrVideoConfig |numxpixels ] LITERAL H@ 1- ; 0 1 #PARMS MACRO
: GMaxY	  (( -- MaxY ))
	[ GCurrVideoConfig |numypixels ] LITERAL H@ 1- ; 0 1 #PARMS MACRO

: GInitialize	 (| video_mode #columns #rows -- |)
	_setvideomode( video_mode ) 0<> IF
	    _getvideoconfig( GCurrVideoConfig ) DROP
	    _setcharsize( GSizeY #columns / , GSizeX #rows / )
	    0 0 GMaxX GMaxY GImageSize malloc TO (MoveImageBuf)
	ELSE
	    CR ." * GInitialize failed ." ABORT
	ENDIF ;

: GUninitialize  (| -- |)	// back to text mode
	(MoveImageBuf) IF  (MoveImageBuf) free 0 TO (MoveImageBuf)  ENDIF
	_setvideomode( _DEFAULTMODE ) DROP ;

TRUE VALUE GUseDefaultFont?

: GOutChar	(( x0 y0 ch -- ))
	OutCharBuf C! SWAP _moveto
	_outgtext( OutCharBuf ) ;

G_LIGHTGRAY VALUE GCurrForegroundColor INVISIBLE
0           VALUE GCurrBackgroundColor INVISIBLE

: GGetForeColor  (( -- fgcolor ))
	GCurrForegroundColor ; 0 1 #PARMS
: GGetBackColor  (( -- bgcolor ))
	GCurrBackgroundColor ; 0 1 #PARMS
: GGetTextColor  (( -- fgcolor bgcolor ))
	GCurrForegroundColor GCurrBackgroundColor  ; 0 2 #PARMS
: GSetForeColor	 (( fgcolor -- ))
	to GCurrForegroundColor  ; 1 0 #PARMS
: GSetBackColor	 (( bkcolor -- ))
	to GCurrBackgroundColor	 ; 1 0 #PARMS
: GSetTextColor  (( fgcolor bgcolor -- ))
	to GCurrBackgroundColor to GCurrForegroundColor  ; 2 0 #PARMS
	
ONLY FORTH ALSO DEFINITIONS

