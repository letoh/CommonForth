// Graphics facility for Borland C++
//
//						Version     : 1.0
// 						Written by  : Luke Lee
//						Last update : 02/08/'98

NEEDS INVOKEC.4TH

VOCABULARY GRAPHICS
GRAPHICS DEFINITIONS

// graphresult error return codes //
  0  CONSTANT  grOk                
 -1  CONSTANT  grNoInitGraph       
 -2  CONSTANT  grNotDetected       
 -3  CONSTANT  grFileNotFound      
 -4  CONSTANT  grInvalidDriver     
 -5  CONSTANT  grNoLoadMem         
 -6  CONSTANT  grNoScanMem         
 -7  CONSTANT  grNoFloodMem        
 -8  CONSTANT  grFontNotFound      
 -9  CONSTANT  grNoFontMem         
-10  CONSTANT  grInvalidMode       
-11  CONSTANT  grError             
-12  CONSTANT  grIOerror           
-13  CONSTANT  grInvalidFont       
-14  CONSTANT  grInvalidFontNum    
-18  CONSTANT  grInvalidVersion    

// define graphics drivers //
-1   CONSTANT  CURRENT_DRIVER 
 0   CONSTANT  DETECT
 1   CONSTANT  CGA
 2   CONSTANT  MCGA
 3   CONSTANT  EGA 
 4   CONSTANT  EGA64 
 5   CONSTANT  EGAMONO 
 6   CONSTANT  IBM8514
 7   CONSTANT  HERCMONO 
 8   CONSTANT  ATT400 
 9   CONSTANT  VGA 
10   CONSTANT  PC3270

// graphics modes for each driver //
 0   CONSTANT  CGAC0        // 320x200 palette 0; 1 page   
 1   CONSTANT  CGAC1        // 320x200 palette 1; 1 page   
 2   CONSTANT  CGAC2        // 320x200 palette 2: 1 page   
 3   CONSTANT  CGAC3        // 320x200 palette 3; 1 page   
 4   CONSTANT  CGAHI        // 640x200 1 page          
 0   CONSTANT  MCGAC0       // 320x200 palette 0; 1 page   
 1   CONSTANT  MCGAC1       // 320x200 palette 1; 1 page   
 2   CONSTANT  MCGAC2       // 320x200 palette 2; 1 page   
 3   CONSTANT  MCGAC3       // 320x200 palette 3; 1 page   
 4   CONSTANT  MCGAMED      // 640x200 1 page          
 5   CONSTANT  MCGAHI       // 640x480 1 page          
 0   CONSTANT  EGALO        // 640x200 16 color 4 pages    
 1   CONSTANT  EGAHI        // 640x350 16 color 2 pages    
 0   CONSTANT  EGA64LO      // 640x200 16 color 1 page     
 1   CONSTANT  EGA64HI      // 640x350 4 color  1 page     
 0   CONSTANT  EGAMONOHI    // 640x350 64K on card, 1 page - 256K on card, 4 pages 
 0   CONSTANT  HERCMONOHI   // 720x348 2 pages         
 0   CONSTANT  ATT400C0     // 320x200 palette 0; 1 page   
 1   CONSTANT  ATT400C1     // 320x200 palette 1; 1 page   
 2   CONSTANT  ATT400C2     // 320x200 palette 2; 1 page   
 3   CONSTANT  ATT400C3     // 320x200 palette 3; 1 page   
 4   CONSTANT  ATT400MED    // 640x200 1 page          
 5   CONSTANT  ATT400HI     // 640x400 1 page          
 0   CONSTANT  VGALO        // 640x200 16 color 4 pages    
 1   CONSTANT  VGAMED       // 640x350 16 color 2 pages    
 2   CONSTANT  VGAHI        // 640x480 16 color 1 page     
 0   CONSTANT  PC3270HI     // 720x350 1 page          
 0   CONSTANT  IBM8514LO    // 640x480 256 colors      
 1   CONSTANT  IBM8514HI    // 1024x768 256 colors

// define extended graphics drivers //
256  CONSTANT  DETECTX     
11   CONSTANT  VGA256      
12   CONSTANT  ATTDEB      
13   CONSTANT  TOSHIBA     
                
14   CONSTANT  SVGA16      
15   CONSTANT  SVGA256     
16   CONSTANT  SVGA32K     
17   CONSTANT  SVGA64K     
                
18   CONSTANT  VESA16      
19   CONSTANT  VESA256     
20   CONSTANT  VESA32K     
21   CONSTANT  VESA64K     
22   CONSTANT  VESA16M     
                
23   CONSTANT  ATI16       
24   CONSTANT  ATI256      
25   CONSTANT  ATI32K      
26   CONSTANT  COMPAQ      
27   CONSTANT  TSENG316    
28   CONSTANT  TSENG3256   
29   CONSTANT  TSENG416    
30   CONSTANT  TSENG4256   
31   CONSTANT  TSENG432K   
32   CONSTANT  GENOA5      
33   CONSTANT  GENOA6      
34   CONSTANT  OAK         
35   CONSTANT  PARADIS16   
36   CONSTANT  PARADIS256  
37   CONSTANT  TECMAR      
38   CONSTANT  TRIDENT16   
39   CONSTANT  TRIDENT256  
40   CONSTANT  VIDEO7      
41   CONSTANT  VIDEO7II    
     
42   CONSTANT  S3          
43   CONSTANT  ATIGUP      

// graphics modes for each driver //
 0   CONSTANT  RES640x350  
 1   CONSTANT  RES640x480  
 2   CONSTANT  RES800x600  
 3   CONSTANT  RES1024x768 
 4   CONSTANT  RES1280x1024


1    CONSTANT  CGA_LIGHTGREEN         // Palette C0 Color Names   //
2    CONSTANT  CGA_LIGHTRED       
3    CONSTANT  CGA_YELLOW         

1    CONSTANT  CGA_LIGHTCYAN          // Palette C1 Color Names   //
2    CONSTANT  CGA_LIGHTMAGENTA   
3    CONSTANT  CGA_WHITE          

1    CONSTANT  CGA_GREEN              // Palette C2 Color Names   //
2    CONSTANT  CGA_RED            
3    CONSTANT  CGA_BROWN          

1    CONSTANT  CGA_CYAN               // Palette C3 Color Names   //
2    CONSTANT  CGA_MAGENTA        
3    CONSTANT  CGA_LIGHTGRAY      


0    CONSTANT  EGA_BLACK               // dark colors //
1    CONSTANT  EGA_BLUE           
2    CONSTANT  EGA_GREEN          
3    CONSTANT  EGA_CYAN           
4    CONSTANT  EGA_RED            
5    CONSTANT  EGA_MAGENTA        
20   CONSTANT  EGA_BROWN          
 7   CONSTANT  EGA_LIGHTGRAY      
56   CONSTANT  EGA_DARKGRAY            // light colors //
57   CONSTANT  EGA_LIGHTBLUE      
58   CONSTANT  EGA_LIGHTGREEN     
59   CONSTANT  EGA_LIGHTCYAN      
60   CONSTANT  EGA_LIGHTRED       
61   CONSTANT  EGA_LIGHTMAGENTA   
62   CONSTANT  EGA_YELLOW         
63   CONSTANT  EGA_WHITE          


// Line styles for get/setlinestyle //
0    CONSTANT  SOLID_LINE   
1    CONSTANT  DOTTED_LINE  
2    CONSTANT  CENTER_LINE  
3    CONSTANT  DASHED_LINE  
4    CONSTANT  USERBIT_LINE    // User defined line style //


// Line widths for get/setlinestyle //
1    CONSTANT  NORM_WIDTH  
3    CONSTANT  THICK_WIDTH 

0    CONSTANT  DEFAULT_FONT           // 8x8 bit mapped font //
1    CONSTANT  TRIPLEX_FONT           // "Stroked" fonts //
2    CONSTANT  SMALL_FONT          
3    CONSTANT  SANS_SERIF_FONT     
4    CONSTANT  GOTHIC_FONT         
5    CONSTANT  SCRIPT_FONT         
6    CONSTANT  SIMPLEX_FONT        
7    CONSTANT  TRIPLEX_SCR_FONT    
8    CONSTANT  COMPLEX_FONT        
9    CONSTANT  EUROPEAN_FONT       
10   CONSTANT  BOLD_FONT           

0 CONSTANT   HORIZ_DIR     // left to right //
1 CONSTANT   VERT_DIR      // bottom to top //

0 CONSTANT   USER_CHAR_SIZE        // user-defined char size //

// Fill patterns for get/setfillstyle //
 0  CONSTANT    EMPTY_FILL     // fills area in background color //
 1  CONSTANT    SOLID_FILL     // fills area in solid fill color //
 2  CONSTANT    LINE_FILL      // --- fill //
 3  CONSTANT    LTSLASH_FILL       // /// fill //
 4  CONSTANT    SLASH_FILL     // /// fill with thick lines //
 5  CONSTANT    BKSLASH_FILL       // \\\ fill with thick lines //
 6  CONSTANT    LTBKSLASH_FILL     // \\\ fill //
 7  CONSTANT    HATCH_FILL     // light hatch fill //
 8  CONSTANT    XHATCH_FILL        // heavy cross hatch fill //
 9  CONSTANT    INTERLEAVE_FILL    // interleaving line fill //
10  CONSTANT    WIDE_DOT_FILL      // Widely spaced dot fill //
11  CONSTANT    CLOSE_DOT_FILL     // Closely spaced dot fill //
12  CONSTANT    USER_FILL       // user defined fill //

// BitBlt operators for putimage //
 0  CONSTANT    COPY_PUT       // MOV //
 1  CONSTANT    XOR_PUT        // XOR //
 2  CONSTANT    OR_PUT         // OR  //
 3  CONSTANT    AND_PUT        // AND //
 4  CONSTANT    NOT_PUT         // NOT //

// Horizontal and vertical justification for settextjustify //
 0  CONSTANT    LEFT_TEXT
 1  CONSTANT    CENTER_TEXT
 2  CONSTANT    RIGHT_TEXT

 0  CONSTANT    BOTTOM_TEXT
     // CENTER_TEXT = 1  already defined above //
 2  CONSTANT    TOP_TEXT


15  CONSTANT  MAXCOLORS

STRUCT: palettetype
                  BYTE: |size
    MAXCOLORS 1+ FIELD: |colors[]
;STRUCT

STRUCT: linesettingstype
    WORD:       |linestyle
    WORD:       |upattern
    WORD:       |thickness
;STRUCT

STRUCT: textsettingstype
    WORD:       |font
    WORD:       |direction
    WORD:       |charsize
    WORD:       |horiz
    WORD:       |vert
;STRUCT

STRUCT: fillsettingstype
    WORD:       |pattern
    WORD:       |color
;STRUCT

STRUCT: pointtype
    WORD:       |x
    WORD:       |y
;STRUCT

STRUCT: viewporttype
    WORD:       |left
    WORD:       |top
    WORD:       |right 
    WORD:       |bottom
    WORD:       |clip
;STRUCT

WARNING @ WARNING OFF
STRUCT: arccoordstype
    WORD:       |x
    WORD:       |y
    WORD:       |xstart
    WORD:       |ystart
    WORD:       |xend
    WORD:       |yend
;STRUCT
WARNING !


GRAPHICS DEFINITIONS

// Translation to Common Forth Graphics Words ( Abstract Common Forth Concept )

XOR_PUT         CONSTANT  G_XOR_PUT
OR_PUT          CONSTANT  G_OR_PUT
AND_PUT         CONSTANT  G_AND_PUT
NOT_PUT         CONSTANT  G_NOT_PUT
COPY_PUT        CONSTANT  G_COPY_PUT

-1      CONSTANT   G320x200x16
-2      CONSTANT   G320x200x256
-3      CONSTANT   G640x480x16
-4      CONSTANT   G640x480x256
-5      CONSTANT   G800x600x16
-6      CONSTANT   G800x600x256
-7      CONSTANT   G1024x768x16
-8      CONSTANT   G1024x768x256
-1000   CONSTANT   G720x348x2     // For Hercules card

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

VARIABLE G_CurrentColor

: GSetColor	( color -- ) DUP setcolor G_CurrentColor ! ; 1 0 #PARMS
: GGetColor	( -- color ) G_CurrentColor @ ; 0 1 #PARMS

: GDrawPoint	    (| x y -- |)
	putpixel( x , y , G_CurrentColor @ ) ;

: GDrawLine      ( x0 y0 x1 y1 -- )
        SWAP 2SWAP SWAP line ; 4 0 #PARMS
	
: GDrawRectangle ( x0 y0 x1 y1 -- )
        SWAP 2SWAP SWAP rectangle ; 4 0 #PARMS

: GFillRectangle ( x0 y0 x1 y1 -- )
        SWAP 2SWAP SWAP bar ; 4 0 #PARMS

: GDrawCPoint	( x y color -- )
        -ROT SWAP putpixel
        ; 3 0 #PARMS

: GDrawCLine	( x0 y0 x1 y1 color -- )
        setcolor
        SWAP 2SWAP SWAP line
        G_CurrentColor @ setcolor ; 5 0 #PARMS

: GDrawCRectangle ( x0 y0 x1 y1 color -- )
        setcolor
        SWAP 2SWAP SWAP rectangle
        G_CurrentColor @ setcolor ; 5 0 #PARMS

: GFillCRectangle   ( x0 y0 x1 y1 color -- )
        DUP setcolor
        SOLID_FILL setfillstyle
        SWAP 2SWAP SWAP bar
        G_CurrentColor @ setcolor ; 5 0 #PARMS
	
: GImageSize	    ( x0 y0 x1 y1 -- n )
	SWAP 2SWAP SWAP imagesize ; 4 1 #PARMS

: GGetImage      (| left top right bottom *image -- |)
	getimage( left , top , right , bottom , *image )  ;

: GPutImage      (| left top *image op -- |)
	putimage( left , top , *image , op )  ;

0 VALUE (MoveImageBuf) INVISIBLE

: GMoveImage	 (( destX destY srcX0 srcY0 srcX1 srcY1 -- ))  // optional
	(MoveImageBuf) IF
	   (MoveImageBuf) GGetImage
	   (MoveImageBuf) G_COPY_PUT GPutImage
	ELSE
	   6DROP 
	ENDIF ; 6 0 #PARMS

// Read Graphics region/size
: GSizeX  ( -- SizeX )  getmaxx 1+ ; 0 1 #PARMS
: GSizeY  ( -- SizeY )  getmaxy 1+ ; 0 1 #PARMS
	
' getmaxx ALIAS GMaxX	  ( -- MaxX )
' getmaxy ALIAS GMaxY	  ( -- MaxY )

VARIABLE INIT_BGI_MODE
VARIABLE INIT_BGI_DRV

: GInitialize	 (| video_mode #columns #rows -- |)
        DETECT     INIT_BGI_DRV  !
        video_mode INIT_BGI_MODE !
        initgraph( INIT_BGI_DRV , INIT_BGI_MODE , Z$" " );
        graphresult grOk = IF
            setcolor( G_LIGHTGRAY ); G_LIGHTGRAY G_CurrentColor !
            setbkcolor( G_BLACK );
            setfillstyle( SOLID_FILL , G_LIGHTGRAY );
            settextstyle( DEFAULT_FONT , HORIZ_DIR , 1 );
            settextjustify( LEFT_TEXT , TOP_TEXT );
	    0 0 GMaxX GMaxY GImageSize malloc TO (MoveImageBuf)
	ELSE
	    CR ." * GInitialize failed ." ABORT
	ENDIF ;

COMMENT: -------------------------------------------------------------------
// This word fails in my system, which means BGI32 for Borland C++ 4.X is not
// compatiable to newer hardwares.
: GInitialize	 (| video_mode #columns #rows -- |)
        video_mode CASE
            G320x200x16    OF   VGA256      0               ENDOF
            G640x480x16    OF   VESA16      RES640x480      ENDOF
            G800x600x16    OF   VESA16      RES800x600      ENDOF
            G1024x768x16   OF   VESA16      RES1024x768     ENDOF
            G320x200x256   OF   VGA256      0               ENDOF
            G640x480x256   OF   VESA256     RES640x480      ENDOF
            G800x600x256   OF   VESA256     RES800x600      ENDOF
            G1024x768x256  OF   VESA256     RES1024x768     ENDOF
            G720x348x2     OF   HERCMONO    HERCMONOHI      ENDOF
            DETECT  0
        ENDCASE
        INIT_BGI_MODE !  INIT_BGI_DRV  !
        detectgraph( INIT_BGI_DRV , INIT_BGI_MODE );
        graphresult grOk = IF
            initgraph( INIT_BGI_DRV , INIT_BGI_MODE , Z$" " );
            graphresult grOk = IF
                setcolor( G_LIGHTGRAY ); G_LIGHTGRAY G_CurrentColor !
                setbkcolor( G_BLACK );
                setfillstyle( SOLID_FILL , G_LIGHTGRAY );
                settextstyle( DEFAULT_FONT , HORIZ_DIR , 1 );
                settextjustify( LEFT_TEXT , TOP_TEXT );
	        0 0 GMaxX GMaxY GImageSize malloc TO (MoveImageBuf)
            ELSE
	        CR ." * GInitialize failed ." ABORT 
	    ENDIF
        ELSE
	    CR ." * GInitialize failed ." ABORT 
        ENDIF   ;
;COMMENT

: GUninitialize  (| -- |)	// back to text mode
	(MoveImageBuf) IF  (MoveImageBuf) free 0 TO (MoveImageBuf)  ENDIF
	closegraph ;

TRUE VALUE GUseDefaultFont?
CREATE GOutCharBuffer 0 C, 0 ,
: GOutChar  ( x y ch -- )
        GOutCharBuffer C!
        SWAP GOutCharBuffer -ROT outtextxy ; 3 0 #PARMS

G_LIGHTGRAY VALUE GCurrForegroundColor INVISIBLE
G_BLACK     VALUE GCurrBackgroundColor INVISIBLE

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

