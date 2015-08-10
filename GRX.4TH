// Graphics Tools From GRX 1.03 for DJGPP 

				// Version    : 1.5
				// Written by : Luke Lee
				// Last update : 01/01/'96
				// 	update : 12/18/'95
				//      update : 10/21/'95

NEEDS INVOKEC.4TH

FORTH DEFINITIONS

VOCABULARY GRAPHICS

GRAPHICS ALSO DEFINITIONS

0	CONSTANT    GR_80_25_text
1	CONSTANT    GR_default_text
2	CONSTANT    GR_width_height_text
3	CONSTANT    GR_biggest_text
4	CONSTANT    GR_320_200_graphics
5	CONSTANT    GR_default_graphics
6	CONSTANT    GR_width_height_graphics
7	CONSTANT    GR_biggest_noninterlaced_graphics
8	CONSTANT    GR_biggest_graphics
9	CONSTANT    GR_width_height_color_graphics

// return values from 'GrAdapterType()'

0	CONSTANT	 GR_VGA			// VGA adapter 
1	CONSTANT	 GR_EGA			// EGA adapter 
2	CONSTANT	 GR_HERC		// Hercules mono adapter
3	CONSTANT	 GR_8514A		// 8514A or compatible 
4	CONSTANT	 GR_S3			// S3 graphics accelerator 

// ==================================================================
//			CONTEXT AND WINDOW STUFF		      
// ================================================================== 

STRUCT: GrContext
 
    STRUCT: GrVidRAM
    	WORD:  |*gc_baseaddr		// base address of display memory 
    	WORD:  |gc_frameaddr		// upper left corner coordinate 
    	WORD:  |gc_planeoffset		// offset to next color plane 
    	WORD:  |gc_lineoffset		// offset to next scan line in bytes 
    	BYTE:  |gc_onscreen		// is it in video memory ? 
    	BYTE:  |gc_memflags		// memory allocation flags
    ;STRUCT

    WORD:  |gc_xmax			// max X coord (width  - 1) 
    WORD:  |gc_ymax			// max Y coord (height - 1) 
    WORD:  |gc_xcliplo			// low X clipping limit 
    WORD:  |gc_ycliplo			// low Y clipping limit 
    WORD:  |gc_xcliphi			// high X clipping limit 
    WORD:  |gc_ycliphi			// high Y clipping limit 
    WORD:  |gc_usrxbase			// user window min X coordinate 
    WORD:  |gc_usrybase			// user window min Y coordinate 
    WORD:  |gc_usrwidth			// user window width 
    WORD:  |gc_usrheight		// user window height 
    WORD:  |gc_xoffset			// X offset from root's base 
    WORD:  |gc_yoffset			// Y offset from root's base 
    WORD:  |*gc_root			// context which owns frame buf
;STRUCT

// ================================================================== 
//			      COLOR STUFF			      
// ================================================================== 

// Flags to 'OR' to colors for various operations
HEX 

1000000    CONSTANT	 GrXOR		// to "XOR" any color to the screen 
2000000    CONSTANT	 GrOR		// to "OR" to the screen 
3000000    CONSTANT	 GrAND		// to "AND" to the screen 
0	   CONSTANT	 GrWRITE	// write color 
GrXOR  	   CONSTANT	 GrNOCOLOR	// GrNOCOLOR is used for "no" color 

DECIMAL

// ================================================================== 
//			 GRAPHICS PRIMITIVES			      
// ================================================================== 

// framed box colors
 
STRUCT: GrFBoxColors
    WORD:  |fbx_intcolor
    WORD:  |fbx_topcolor
    WORD:  |fbx_rightcolor
    WORD:  |fbx_bottomcolor
    WORD:  |fbx_leftcolor
;STRUCT

512	CONSTANT	 GR_MAX_POLY_VERTICES	

// ================================================================== 
//	      THICK AND DASHED LINE DRAWING PRIMITIVES		      
// ================================================================== 

// * custom line option structure
// *  zero or one dash pattern length means the line is continuous
// *  the dash pattern always begins with a drawn section
 
STRUCT: GrLineOption
    WORD:  |lno_color			// color used to draw line 
    WORD:  |lno_width			// width of the line 
    WORD:  |lno_pattlen			// length of the dash pattern 
    WORD:  |*lno_dashpat		// draw/nodraw pattern 
;STRUCT

// ================================================================== 
//	       PATTERNED DRAWING AND FILLING PRIMITIVES		      
// ================================================================== 

// * BITMAP: a mode independent way to specify a fill pattern of two
// *   colors. It is always 8 pixels wide (1 byte per scan line), its
// *   height is user-defined. SET THE TYPE FLAG TO ZERO!!!
 
STRUCT: GrBitmap
    WORD:  |bmp_ispixmap		// type flag for pattern union 
    WORD:  |bmp_height			// bitmap height 
    WORD:  |*bmp_data			// pointer to the bit pattern 
    WORD:  |bmp_fgcolor			// foreground color for fill 
    WORD:  |bmp_bgcolor			// background color for fill 
    WORD:  |bmp_memflags		// set if dynamically allocated 
;STRUCT

// * PIXMAP: a fill pattern stored in a layout identical to the video RAM
// *   for filling using 'bitblt'-s. It is mode dependent, typically one
// *   of the library functions is used to build it. KEEP THE TYPE FLAG
// *   NONZERO!!!
 
STRUCT: GrPixmap
    WORD:     |pxp_ispixmap	// type flag for pattern union 
    WORD:     |pxp_width	// pixmap width (in pixels)  
    WORD:     |pxp_height	// pixmap height (in pixels) 
    WORD:     |pxp_oper		// bitblt mode (SET, OR, XOR, AND) 
    GrVidRAM  |pxp_source	// source context for fill 
;STRUCT

// * Fill pattern union -- can either be a bitmap or a pixmap

UNION: GrPattern
	WORD:    |gp_ispixmap			// nonzero for pixmaps 
    	GrBitmap |gp_bitmap			// fill bitmap 
	GrPixmap |gp_pixmap			// fill pixmap 
;UNION

// * Draw pattern for line drawings -- specifies both the:
// *   (1) fill pattern, and the
// *   (2) custom line drawing option
 
STRUCT: GrLinePattern
    WORD:  |*lnp_pattern		// fill pattern 
    WORD:  |*lnp_option			// width + dash pattern 
;STRUCT

// ================================================================== 
//		     FONTS AND TEXT PRIMITIVES			      
// ================================================================== 

// * font structure - the part visible to the user.
// * for the internal stuff see "grxfont.h" and "grxfile.h"
// * BE CAREFUL when hacking it! TCC and GCC have to produce the
// * same alignments!!!!
 
16	CONSTANT   GR_NAMEWIDTH

STRUCT: GrFont
    HWORD:   |fnt_width			// width (average for proportional) 
    HWORD:   |fnt_height			// font height 
    HWORD:   |fnt_minchar		// lowest character code in font 
    HWORD:   |fnt_maxchar		// highest character code in font 
    HWORD:   |fnt_isfixed		// nonzero if fixed font 
    HWORD:   |fnt_internal		// nonzero if BIOS font 
    HWORD:   |fnt_baseline		// baseline from top of font 
    HWORD:   |fnt_undwidth		// underline width (at bottom) 
    GR_NAMEWIDTH FIELD:  |fnt_name[]	// font file name (w/o path) 
    GR_NAMEWIDTH FIELD:  |fnt_family[]	// font family name 
;STRUCT

// * text drawing directions
 
0		CONSTANT    GR_TEXT_RIGHT	// normal 
1		CONSTANT    GR_TEXT_DOWN	// downward 
2		CONSTANT    GR_TEXT_LEFT	// upside down, right to left
3		CONSTANT    GR_TEXT_UP		// upward 
GR_TEXT_RIGHT	CONSTANT    GR_TEXT_DEFAULT		

// * text alignment options
 
0		CONSTANT    GR_ALIGN_LEFT	// X only 
0		CONSTANT    GR_ALIGN_TOP	// Y only 
1		CONSTANT    GR_ALIGN_CENTER	// X, Y 
2		CONSTANT    GR_ALIGN_RIGHT	// X only 
2		CONSTANT    GR_ALIGN_BOTTOM	// Y only 
3		CONSTANT    GR_ALIGN_BASELINE	// Y only 
GR_ALIGN_LEFT	CONSTANT    GR_ALIGN_DEFAULT	

// * character types in text strings
 
0	CONSTANT	 GR_BYTE_TEXT		// one byte per character 
1	CONSTANT	 GR_WORD_TEXT		// two bytes per character 
2	CONSTANT	 GR_ATTR_TEXT		// chr w/ PC style attribute byte

// * OR this to the foreground color value for underlined text when
// * using GR_BYTE_TEXT or GR_WORD_TEXT modes.
 
GrXOR 64 * (( << 6 ))	CONSTANT	 GR_UNDERLINE_TEXT

// * text option structure - contains a font and the options specifying
// * how to draw it. The text drawing functions expect a pointer to this.
 
STRUCT: GrTextOption
    WORD:    |*txo_font			// font to be used 
    WORD:    |txo_xmag			// X magnification 

    WORD:    |txo_ymag			// Y magnification 
   // foreground, background 
    UNION:   (fg/bgcolor):
	WORD: |v			// color when no attributes
	WORD: |*p
    ;UNION: 	  |txo_fgcolor
    (fg/bgcolor): |txo_bgcolor

    BYTE:    |txo_direct		// direction (see above) 
    BYTE:    |txo_xalign		// X alignment (see above) 
    BYTE:    |txo_yalign		// Y alignment (see above) 
    BYTE:    |txo_chrtype		// character type (see above)
;STRUCT

// * structure to define a rectangular text window (use fixed fonts only!!)

STRUCT: GrTextRegion 
    WORD:   |*txr_font			// font to be used 
    WORD:   |*txr_buffer		// pointer to text buffer 
    WORD:   |*txr_backup		// optional backup buffer 
    WORD:   |txr_xpos			// upper left corner X coordinate 
    WORD:   |txr_ypos			// upper left corner Y coordinate 
    WORD:   |txr_width			// width of area in chars 
    WORD:   |txr_height			// height of area in chars 
    WORD:   |txr_lineoffset		// offset in buffer(s) between lines 

    (fg/bgcolor): |txr_fgcolor
    (fg/bgcolor): |txr_bgcolor		// foreground, background

    BYTE:    |txr_chrtype		// character type (see above) 
;STRUCT

// //////////////////////////////////////////////////////////////////////////
//    Implement  Standard  Graphics  Interface
// //////////////////////////////////////////////////////////////////////////

GRAPHICS DEFINITIONS

GrTextOption G_PCTextOption	// GRX default text option

0  	CONSTANT	G_BLACK       
1  	CONSTANT 	G_BLUE        
2  	CONSTANT 	G_GREEN       
3  	CONSTANT 	G_CYAN        
4  	CONSTANT 	G_RED         
5  	CONSTANT 	G_MAGENTA     
6  	CONSTANT 	G_BROWN       
7  	CONSTANT 	G_LIGHTGRAY   
8  	CONSTANT 	G_DARKGRAY    
9  	CONSTANT 	G_LIGHTBLUE   
10 	CONSTANT 	G_LIGHTGREEN  
11 	CONSTANT 	G_LIGHTCYAN   
12 	CONSTANT 	G_LIGHTRED    
13 	CONSTANT 	G_LIGHTMAGENTA
14 	CONSTANT 	G_YELLOW      
15 	CONSTANT 	G_WHITE	      

// // Constants for GInitialize
-1    CONSTANT   G320x200x16		
-2    CONSTANT   G320x200x256
-3    CONSTANT   G640x480x16
-4    CONSTANT   G640x480x256
-5    CONSTANT   G800x600x16		
-6    CONSTANT   G800x600x256
-7    CONSTANT   G1024x768x16	
-8    CONSTANT   G1024x768x256

// Constants for GPutImage operation :
GrXOR	    CONSTANT	   G_XOR_PUT     // to "XOR" any color to the screen
GrOR	    CONSTANT	   G_OR_PUT      // to "OR" to the screen 
GrAND	    CONSTANT	   G_AND_PUT     // to "AND" to the screen 
GrWRITE	    CONSTANT	   G_COPY_PUT    // write color 
// -12345678   CONSTANT	   G_NOT_PUT	 // implemented with XOR

FALSE  VALUE  GUseDefaultFont?

: GInitialize    (| video_mode #columns #rows | width height colors -- |)
	video_mode CASE
	   G320x200x16	 OF  320  to width 200 to height 16 to colors   ENDOF
 	   G320x200x256  OF  320  to width 200 to height 256 to colors  ENDOF
	   G640x480x16	 OF  640  to width 480 to height 16 to colors   ENDOF
	   G640x480x256  OF  640  to width 480 to height 256 to colors  ENDOF
	   G800x600x16	 OF  800  to width 600 to height 16 to colors   ENDOF
	   G800x600x256	 OF  800  to width 600 to height 256 to colors  ENDOF
	   G1024x768x16	 OF  1024 to width 768 to height 16 to colors   ENDOF
	   G1024x768x256 OF  1024 to width 768 to height 256 to colors  ENDOF
	   ." * GInitialize : Invalid video mode " DUP . ." ." BEEP CR ABORT
	ENDCASE
	GrSetMode( GR_width_height_color_graphics , width , height , colors );
        G_PCTextOption SIZEOF GrTextOption LITERAL ERASE
	getenv( Z$" GRXFONT" ) 0= IF
	   GrSetFontPath( Z$" .\FONTS" );
	ELSE
	   GrSetFontPath( getenv( Z$" GRXFONT" ) );
	ENDIF
        GrFindBestFont( width #columns / , height #rows / , 1 ,
                        Z$" pc*" , G_PCTextOption )
	0=  ORELSE width 1024 =  ELSE-OR  to GUseDefaultFont?
	GrSetContext( NULL );
	; 3 0 #PARMS

: GUninitialize  (( -- ))	// back to text mode
	GrBlack GrClearScreen
	GrSetMode( GR_80_25_text , 0 , 0 , 0 )	; 0 0 #PARMS
 
: GOutChar	(| X0 Y0 char -- |) // draw character at (X0,Y0)
	GrDrawChar( char , X0 , Y0 , G_PCTextOption ) ;

G_WHITE VALUE GCurrentColor INVISIBLE

: GSetColor	(( color -- ))	to GCurrentColor ; 1 0 #PARMS
: GGetColor	(( -- color ))	GCurrentColor ; 0 1 #PARMS
: GDrawPoint         (| x y -- |)
	GrPlotNC( x , y , GCurrentColor )  ;
: GDrawLine          (| x0 y0 x1 y1 -- |)
	GrLineNC( x0 , y0 , x1 , y1 , GCurrentColor )  ;
: GDrawRectangle     (| x0 y0 x1 y1 -- |)
	GrBoxNC( x1 , y1 , x0 , y0 , GCurrentColor )  ;
: GFillRectangle     (| x0 y0 x1 y1 -- |)
	GrFilledBoxNC( x1 , y1 , x0 , y0 , GCurrentColor ) ;

// Color parameterred :

: GDrawCPoint	(( x y color -- ))
      // GrPlotNC( x , y , color ) ;
	-ROT SWAP GrPlotNC ; 3 0 #PARMS
: GDrawCLine	(| x0 y0 x1 y1 color -- |)
	GrLineNC( x0 , y0 , x1 , y1 , color ) ;
: GDrawCRectangle (| x0 y0 x1 y1 color -- |)
	GrBoxNC( x0 , y0 , x1 , y1 , color ) ;
: GFillCRectangle  (| x0 y0 x1 y1 color -- |)
	GrFilledBoxNC( x0 , y0 , x1 , y1 , color ) ;

: GImageSize	  (( x0 y0 x1 y1 -- n ))
	ROT - ABS 1+   -ROT - ABS 1+  GrContextSize
	SIZEOF GrContext LITERAL +  ; 4 1 #PARMS

: GGetImage	(| left top right bottom *image -- |)
	GrCreateContext( right left - 1+ , bottom top - 1+ ,
			 *image SIZEOF GrContext LITERAL + , *image ); DROP
	GrBitBlt( *image , 0 , 0 , NULL , left , top , right , bottom ,
		  GrWRITE );
	;

// GrContext _OP_NOT_SaveContext
// GrContext _OP_NOT_Context

: GPutImage	(| left top *image op -- |)
   // 	op G_NOT_PUT <> IF
	   GrBitBlt( NULL , left , top , *image , 0 , 0 , 
		     *image |gc_xmax @ , *image |gc_ymax @ , op )  ;
   // 	ELSE
   // 	   GrSaveContext( _OP_NOT_SaveContext ) DROP
   // 	   GrCreateContext( *image |gc_xmax @ 1+ , *image |gc_ymax @ 1+ ,
   // 	   		    NULL , _OP_NOT_Context ) 0= IF  EXIT  ENDIF
   // 	   GrSetContext( _OP_NOT_Context );
   // 	 // XOR with WHITE
   // 	   GrFilledBox( 0 , 0 , *image |gc_xmax @ , *image |gc_ymax @ ,
   // 	   		GrWhite );
   // 	   GrBitBlt( _OP_NOT_Context , 0 , 0 , *image , 0 , 0 ,
   // 	   	     *image |gc_xmax @ , *image |gc_ymax @ , GrXOR );
   // 	   GrBitBlt( NULL , left , top , _OP_NOT_Context , 0 , 0 ,
   // 	   	     *image |gc_xmax @ , *image |gc_ymax @ , GrWRITE );
   // 	   GrSetContext( _OP_NOT_SaveContext );
   // 	   GrDestroyContext( _OP_NOT_Context );
   // 	ENDIF ;

: GMoveImage	(| destX destY srcX0 srcY0 srcX1 srcY1 -- |)
	GrBitBltNC( NULL , destX , destY ,
		    NULL , srcX0 , srcY0 , srcX1 , srcY1 , GrWRITE ) ;

// Graphics region size read
: GSizeX	GrSizeX		; 0 1 #PARMS
: GSizeY	GrSizeY		; 0 1 #PARMS
: GMaxX		GrMaxX		; 0 1 #PARMS
: GMaxY		GrMaxY		; 0 1 #PARMS

// GGet____Color is much more frequently used than GSet____Color, 
// so make them macros

: GGetForeColor (( -- fgcolor )) 
	[ G_PCTextOption |txo_fgcolor |v ] LITERAL @  ; 0 1 #PARMS MACRO

: GGetBackColor (( -- bgcolor )) 
	[ G_PCTextOption |txo_bgcolor |v ] LITERAL @  ; 0 1 #PARMS MACRO

: GGetTextColor  (( -- fgcolor bgcolor ))
	[ G_PCTextOption |txo_fgcolor |v ] LITERAL @
	[ G_PCTextOption |txo_bgcolor |v ] LITERAL @  ; 0 2 #PARMS MACRO

: GSetForeColor (( fgcolor -- )) 
	[ G_PCTextOption |txo_fgcolor |v ] LITERAL !  ; 1 0 #PARMS MACRO

: GSetBackColor (( bgcolor -- )) 
	[ G_PCTextOption |txo_bgcolor |v ] LITERAL !  ; 1 0 #PARMS MACRO

: GSetTextColor	(( fgcolor bgcolor -- ))
	[ G_PCTextOption |txo_bgcolor |v ] LITERAL !  
	[ G_PCTextOption |txo_fgcolor |v ] LITERAL !  ; 2 0 #PARMS

ONLY FORTH ALSO DEFINITIONS

