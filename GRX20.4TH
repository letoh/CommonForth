// Graphics Tools From GRX20.H for DJGPP

				// Version    :
				// Written by : Luke Lee
				// Last update : 10/21/'95

NEEDS INVOKEC.4TH
NEEDS DOSCMD.4TH

// WARNING @
// WARNING OFF

ALIGNMENT ON

VOCABULARY GRAPHICS

GRAPHICS ALSO DEFINITIONS

// ============= modes which clear the video memory =============
0   CONSTANT  GR_80_25_text   			// Extra parameters for GrSetMode:
1   CONSTANT  GR_default_text 
2   CONSTANT  GR_width_height_text 		// int w int h 
3   CONSTANT  GR_biggest_text 
4   CONSTANT  GR_320_200_graphics 
5   CONSTANT  GR_default_graphics 
6   CONSTANT  GR_width_height_graphics 		// int w int h 
7   CONSTANT  GR_biggest_noninterlaced_graphics 
8   CONSTANT  GR_biggest_graphics 
9   CONSTANT  GR_width_height_color_graphics 	// int w int h long nc 
10  CONSTANT  GR_width_height_color_text 	// int w int h long nc 
11  CONSTANT  GR_custom_graphics        // int w int h long nc int vx int vy 
// ==== equivalent modes which do not clear the video memory ==== 
12  CONSTANT  GR_NC_80_25_text 
13  CONSTANT  GR_NC_default_text 
14  CONSTANT  GR_NC_width_height_text 		// int w int h 
15  CONSTANT  GR_NC_biggest_text 
16  CONSTANT  GR_NC_320_200_graphics 
17  CONSTANT  GR_NC_default_graphics 
18  CONSTANT  GR_NC_width_height_graphics 	// int w int h 
19  CONSTANT  GR_NC_biggest_noninterlaced_graphics 
20  CONSTANT  GR_NC_biggest_graphics 
21  CONSTANT  GR_NC_width_height_color_graphics   // int w int h long nc 
22  CONSTANT  GR_NC_width_height_color_text 	// int w int h long nc 
23  CONSTANT  GR_NC_custom_graphics     // int w int h long nc int vx int vy 

//
// Available frame modes (video memory layouts) //
//

// ====== video frame buffer modes ====== 
0   CONSTANT  GR_frameUndef 		      // undefined 
1   CONSTANT  GR_frameText 		      // text modes 
2   CONSTANT  GR_frameHERC1 		      // Hercules mono 
3   CONSTANT  GR_frameEGAVGA1 		      // EGA VGA mono 
4   CONSTANT  GR_frameEGA4 		      // EGA 16 color 
5   CONSTANT  GR_frameSVGA4 		      // (Super) VGA 16 color 
6   CONSTANT  GR_frameSVGA8 		      // (Super) VGA 256 color 
7   CONSTANT  GR_frameVGA8X 		      // VGA 256 color mode X 
8   CONSTANT  GR_frameSVGA16 		      // Super VGA 32768/65536 color 
9   CONSTANT  GR_frameSVGA24 		      // Super VGA 16M color 
10  CONSTANT  GR_frameSVGA32L 		      // Super VGA 16M color padded #1 
11  CONSTANT  GR_frameSVGA32H 		      // Super VGA 16M color padded #2 
// ====== system RAM frame buffer modes ======
12  CONSTANT  GR_frameRAM1 		      // mono 
13  CONSTANT  GR_frameRAM4 		      // 16 color planar 
14  CONSTANT  GR_frameRAM8 		      // 256 color 
15  CONSTANT  GR_frameRAM16 		      // 32768/65536 color 
16  CONSTANT  GR_frameRAM24 		      // 16M color 
17  CONSTANT  GR_frameRAM32L 		      // 16M color padded #1 
18  CONSTANT  GR_frameRAM32H 		      // 16M color padded #2 
19  CONSTANT  GR_frameRAM3x8 		      // 16M color planar (image mode) 
// ====== markers for scanning modes ====== 
' GR_frameText    ALIAS  GR_firstTextFrameMode     
' GR_frameText    ALIAS  GR_lastTextFrameMode      
' GR_frameHERC1   ALIAS  GR_firstGraphicsFrameMode 
' GR_frameSVGA32H ALIAS  GR_lastGraphicsFrameMode  
' GR_frameRAM1    ALIAS  GR_firstRAMframeMode      
' GR_frameRAM3x8  ALIAS  GR_lastRAMframeMode	      

//
// supported video adapter types
//

-1      CONSTANT         GR_UNKNOWN     // not known (before driver set)
0	CONSTANT	 GR_VGA		// VGA adapter 
1	CONSTANT	 GR_EGA		// EGA adapter 
2	CONSTANT	 GR_HERC	// Hercules mono adapter
3	CONSTANT	 GR_8514A	// 8514A or compatible 
4	CONSTANT	 GR_S3		// S3 graphics accelerator 

//
// The video driver descriptor structure
//
STRUCT: _GR_videoDriver
    WORD:  |*name' 		// driver name 
    WORD:  |adapter 	        // adapter type 
    WORD:  |*inherit 	        // inherit video modes from this 
    WORD:  |*modes 	        // table of supported modes 
    WORD:  |nmodes 		// number of modes 
    WORD:  |(*detect)()
    WORD:  |(*init)()
    WORD:  |(*reset)()
;STRUCT

//
// Video driver mode descriptor structure
//
STRUCT: _GR_videoMode
    BYTE:   |present		// is it really available? 
    BYTE:   |bpp		// log2 of # of colors 
    HWORD:  |width'
    HWORD:  |height'		// video mode geometry 
    HWORD:  |mode		// BIOS mode number (if any) 
    WORD:   |lineoffset		// scan line length 
    WORD:   |privdata		// driver can use it for anything 
    WORD:   |*extinfo	        // extra info (maybe shared) 
;STRUCT

//
// Video driver mode descriptor extension structure. This is a separate
// structure accessed via a pointer from the main mode descriptor. The
// reason for this is that frequently several modes can share the same
// extended info.
//
STRUCT: _GR_videoModeExt
    WORD:    |mode' 	        // frame driver for this video mode  
    WORD:    |*drv 	        // optional frame driver override  
    WORD:    |*frame 		// frame buffer address  
    3 FIELD: |cprec[3] 		// color component precisions  
    3 FIELD: |cpos[3] 		// color component bit positions  
    WORD:    |flags' 		// mode flag bits  see "grdriver.h"  
    WORD:    |(*setup)()
    WORD:    |(*setvsize)()
    WORD:    |(*scroll)()
    WORD:    |(*setbank)()
    WORD:    |(*setrwbanks)()
    WORD:    |(*loadcolor)()
;STRUCT

//
// The frame driver descriptor structure.
//
STRUCT: _GR_frameDriver
    WORD:  |mode''			// supported frame access mode 
    WORD:  |rmode			// matching RAM frame (if video) 
    WORD:  |is_video			// video RAM frame driver ? 
    WORD:  |row_align			// scan line size alignment 
    WORD:  |num_planes			// number of planes 
    WORD:  |bits_per_pixel		// bits per pixel 
    WORD:  |max_plane_size		// maximum plane size in bytes 
    WORD:  |(*init)()'
    WORD:  |(*readpixel)()
    // the order of the next three is kinda important!!! 
    WORD:  |(*drawpixel)()
    WORD:  |(*drawline)()
    WORD:  |(*drawhline)()
    WORD:  |(*drawvline)()
    WORD:  |(*drawblock)()
    WORD:  |(*drawbitmap)()
    WORD:  |(*drawpattern)()
    WORD:  |(*bitblt)()
    WORD:  |(*bltv2r)()
    WORD:  |(*bltr2v)()
;STRUCT

//
// driver and mode info structure
//
STRUCT: _GR_driverInfo
    WORD:  |*vdriver 	// the current video driver 
    WORD:  |*curmode 	// current video mode pointer 
    _GR_videoMode   |actmode 	// copy of above, resized if virtual
    _GR_frameDriver |fdriver 	// frame driver for the current context 
    _GR_frameDriver |sdriver 	// frame driver for the screen 
    _GR_frameDriver |tdriver 	// a dummy driver for text modes 
    WORD:  |mcode 	        // code for the current mode 
    WORD:  |deftw
    WORD:  |defth 	        // default text mode size 
    WORD:  |defgw
    WORD:  |defgh 	        // default graphics mode size 
    WORD:  |deftc
    WORD:  |defgc 	        // default text and graphics colors 
    WORD:  |vposx
    WORD:  |vposy 	        // current virtual viewport position 
    WORD:  |errsfatal 		// if set, exit upon errors 
    WORD:  |moderestore 	// restore startup video mode if set 
    WORD:  |splitbanks 		// indicates separate R/W banks 
    WORD:  |curbank 		// currently mapped bank 
    WORD:  |(*mdsethook)() 	// callback for mode set 
    WORD:  |(*setbank)()' 	// banking routine 
    WORD:  |(*setrwbanks)()'     // split banking routine 
;STRUCT

&GrDriverInfo CONSTANT *GrDriverInfo

// ==================================================================
//		FRAME BUFFER, CONTEXT AND CLIPPING STUFF	     
// ==================================================================

STRUCT: _GR_frame
    WORD:  |*gf_baseaddr[0]		// base address of display memory 
    WORD:  |*gf_baseaddr[1]		// base address of display memory 
    WORD:  |*gf_baseaddr[2]		// base address of display memory 
    WORD:  |*gf_baseaddr[3]		// base address of display memory 
   HWORD:  |gf_selector			// frame memory segment selector
    BYTE:  |gf_onscreen			// is it in video memory ?
    BYTE:  |gf_memflags			// memory allocation flags
    WORD:  |gf_lineoffset		// offset to next scan line in bytes 
    WORD:  |*gf_driver			// frame access functions
;STRUCT

STRUCT: _GR_context
    _GR_frame |gc_frame
    WORD:  |*gc_root			// context which owns frame buf
    WORD:  |gc_xmax			// max X coord (width  - 1) 
    WORD:  |gc_ymax			// max Y coord (height - 1) 
    WORD:  |gc_xoffset			// X offset from root's base 
    WORD:  |gc_yoffset			// Y offset from root's base 
    WORD:  |gc_xcliplo			// low X clipping limit 
    WORD:  |gc_ycliplo			// low Y clipping limit 
    WORD:  |gc_xcliphi			// high X clipping limit 
    WORD:  |gc_ycliphi			// high Y clipping limit 
    WORD:  |gc_usrxbase			// user window min X coordinate 
    WORD:  |gc_usrybase			// user window min Y coordinate 
    WORD:  |gc_usrwidth			// user window width 
    WORD:  |gc_usrheight		// user window height 
;STRUCT

STRUCT: _GR_contextInfo
    _GR_context current		// the current context
    _GR_context screen		// the screen context
;STRUCT
&GrContextInfo CONSTANT *GrContextInfo

' _GR_frameDriver  ALIAS  GrFrameDriver
' _GR_videoDriver  ALIAS  GrVideoDriver
' _GR_videoMode	   ALIAS  GrVideoMode
' _GR_videoModeExt ALIAS  GrVideoModeExt
' _GR_frame	   ALIAS  GrFrame
' _GR_context	   ALIAS  GrContext

// ================================================================== 
//			      COLOR STUFF			      
// ================================================================== 

// Flags to 'OR' to colors for various operations
HEX 

0	   CONSTANT	 GrWRITE	// write color 
1000000    CONSTANT	 GrXOR		// to "XOR" any color to the screen 
2000000    CONSTANT	 GrOR		// to "OR" to the screen 
3000000    CONSTANT	 GrAND		// to "AND" to the screen 
4000000    CONSTANT	 GrIMAGE	// BLIT: write, except given color
00FFFFFF   CONSTANT	 GrCVALUEMASK	// color value mask
FF000000   CONSTANT	 GrCMODEMASK	// color operation mask
GrXOR  	   CONSTANT	 GrNOCOLOR	// GrNOCOLOR is used for "no" color

//
// color system info structure
//

STRUCT: _GR_colorInfo_ctable    // color table for non-RGB modes 
	BYTE: ctable_r
        BYTE: ctable_g
        BYTE: ctable_b                  // loaded components 
        // r,g,b values are valid if set // can be changed by 'GrSetColor'
        BYTE: defined:1|writable:1|nused:6		// usage count
;STRUCT

STRUCT: _GR_colorInfo
    WORD: |ncolors		// number of colors 
    WORD: |nfree		// number of unallocated colors 
    WORD: |black		// the black color 
    WORD: |white		// the white color 
    WORD: |RGBmode		// set when RGB mode 
    WORD: |prec[r]		// color field precisions 
    WORD: |prec[g]		// color field precisions 
    WORD: |prec[b]		// color field precisions 
    WORD: |pos[r]		// color field positions 
    WORD: |pos[g]		// color field positions 
    WORD: |pos[b]		// color field positions 
    WORD: |mask[r]		// masks for significant bits 
    WORD: |mask[g]		// masks for significant bits 
    WORD: |mask[b]		// masks for significant bits 
    WORD: |round[r]		// add these for rounding 
    WORD: |round[g]		// add these for rounding 
    WORD: |round[b]		// add these for rounding 
    WORD: |shift[r]		// shifts for (un)packing color 
    WORD: |shift[g]		// shifts for (un)packing color 
    WORD: |shift[b]		// shifts for (un)packing color 
    WORD: |norm			// normalization for (un)packing 
    SIZEOF _GR_colorInfo_ctable 256 *
    FIELD: |ctable[]    // 256 cells
;STRUCT

&GrColorInfo CONSTANT *GrColorInfo

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

1000000	  CONSTANT   GR_MAX_POLYGON_POINTS
1024 5 +  CONSTANT   GR_MAX_ELLIPSE_POINTS
3600	  CONSTANT   GR_MAX_ANGLE_VALUE   
0	  CONSTANT   GR_ARC_STYLE_OPEN    
1	  CONSTANT   GR_ARC_STYLE_CLOSE1  
2	  CONSTANT   GR_ARC_STYLE_CLOSE2  

// ================================================================== 
//		     FONTS AND TEXT PRIMITIVES			      
// ================================================================== 

// * font structure - the part visible to the user.
// * for the internal stuff see "grxfont.h" and "grxfile.h"
// * BE CAREFUL when hacking it! TCC and GCC have to produce the
// * same alignments!!!!
//
// text drawing directions
// 
0		CONSTANT    GR_TEXT_RIGHT	// normal 
1		CONSTANT    GR_TEXT_DOWN	// downward 
2		CONSTANT    GR_TEXT_LEFT	// upside down, right to left
3		CONSTANT    GR_TEXT_UP		// upward 
GR_TEXT_RIGHT	CONSTANT    GR_TEXT_DEFAULT		
: GR_TEXT_IS_VERTICAL  ( d -- T/F ) 1 AND 0<> ; 0 1 #PARMS

// 
// text alignment options
// 
0		CONSTANT    GR_ALIGN_LEFT	// X only 
0		CONSTANT    GR_ALIGN_TOP	// Y only 
1		CONSTANT    GR_ALIGN_CENTER	// X, Y 
2		CONSTANT    GR_ALIGN_RIGHT	// X only 
2		CONSTANT    GR_ALIGN_BOTTOM	// Y only 
3		CONSTANT    GR_ALIGN_BASELINE	// Y only 
GR_ALIGN_LEFT	CONSTANT    GR_ALIGN_DEFAULT	

//
// character types in text strings
// 
0	CONSTANT	 GR_BYTE_TEXT		// one byte per character 
1	CONSTANT	 GR_WORD_TEXT		// two bytes per character 
2	CONSTANT	 GR_ATTR_TEXT		// chr w/ PC style attribute byte

//
// OR this to the foreground color value for underlined text when
// using GR_BYTE_TEXT or GR_WORD_TEXT modes.
// 
GrXOR 64 * (( << 6 ))	CONSTANT	 GR_UNDERLINE_TEXT

//
// Font conversion flags for 'GrLoadConvertedFont'. OR them as desired.
//
0     CONSTANT  GR_FONTCVT_NONE	        // no conversion 
1     CONSTANT  GR_FONTCVT_SKIPCHARS	// load only selected characters 
2     CONSTANT  GR_FONTCVT_RESIZE	// resize the font 
4     CONSTANT  GR_FONTCVT_ITALICIZE	// tilt font for "italic" look 
8     CONSTANT  GR_FONTCVT_BOLDIFY	// make a "bold"(er) font  
16    CONSTANT  GR_FONTCVT_FIXIFY	// convert prop. font to fixed wdt 
32    CONSTANT  GR_FONTCVT_PROPORTION	// convert fixed font to prop. wdt 

//
// font structures
//
STRUCT: _GR_fontHeader 		// font descriptor 
    WORD:   |*name 		// font name 
    WORD:   |*family 		// font family name 
    BYTE:   |proportional 	// characters have varying width 
    BYTE:   |scalable 		// derived from a scalable font 
    BYTE:   |preloaded 		// set when linked into program 
    BYTE:   |modified 		// "tweaked" font (resized, etc..) 
    WORD:   |width 		// width (proportional=>average) 
    WORD:   |height 		// font height 
    WORD:   |baseline 		// baseline pixel pos (from top) 
    WORD:   |ulpos 		// underline pixel pos (from top) 
    WORD:   |ulheight 		// underline width 
    WORD:   |minchar 		// lowest character code in font 
    WORD:   |numchars 		// number of characters in font 
;STRUCT
' _GR_fontHeader ALIAS GrFontHeader

STRUCT: _GR_fontChrInfo         // character descriptor 
    WORD:   |width''	        // width of this character 
    WORD:   |offset	        // offset from start of bitmap 
;STRUCT
' _GR_fontChrInfo ALIAS GrFontChrInfo

STRUCT: _GR_font
    _GR_fontHeader  |h 		        // the font info structure 
    WORD:           |*bitmap 		// character bitmap array 
    WORD:           |*auxmap 		// map for rotated & underline chrs 
    WORD:           |minwidth 		// width of narrowest character 
    WORD:           |maxwidth 		// width of widest character 
    WORD:           |auxsize 		// allocated size of auxiliary map 
    WORD:           |auxnext 		// next free byte in auxiliary map 
    WORD:           |*auxoffs[0]        // offsets to completed aux chars 
    WORD:           |*auxoffs[1]        // offsets to completed aux chars 
    WORD:           |*auxoffs[2]        // offsets to completed aux chars 
    WORD:           |*auxoffs[3]        // offsets to completed aux chars 
    WORD:           |*auxoffs[4]        // offsets to completed aux chars 
    WORD:           |*auxoffs[5]        // offsets to completed aux chars 
    WORD:           |*auxoffs[6]        // offsets to completed aux chars 
    _GR_fontChrInfo |chrinfo[0]         // character info (not act. size) 
;STRUCT
' _GR_font ALIAS GrFont

STRUCT: _GR_fontEntry		        // info about available fonts 
    _GR_fontHeader  |H		        // the actual font info 
    WORD:           |*next	        // next in the linked list 
    BYTE:           |fname[0]		// path of the font file 
    3 FIELD:        |_GR_fontEntry_alignment
;STRUCT
' _GR_fontEntry ALIAS GrFontEntry

// text option structure - contains a font and the options specifying
// how to draw it. The text drawing functions expect a pointer to this.

UNION:   _GR_textColor  // text color union 
   WORD: |v             // color value for "direct" text 
   WORD: |*p            // color table for attribute text
;UNION
' _GR_textColor ALIAS GrTextColor
 
STRUCT: _GR_textOption                  // text drawing option structure
    WORD:    |*txo_font			// font to be used 
    _GR_textColor    |txo_fgcolor       // foreground color
    _GR_textColor    |txo_bgcolor       // background color
    BYTE:    |txo_chrtype		// character type (see above)
    BYTE:    |txo_direct		// direction (see above) 
    BYTE:    |txo_xalign		// X alignment (see above) 
    BYTE:    |txo_yalign		// Y alignment (see above) 
;STRUCT
' _GR_textOption ALIAS GrTextOption

// structure to define a rectangular text window (use fixed fonts only!!)

STRUCT: GrTextRegion 
    WORD:   |*txr_font			// font to be used 
    _GR_textColor |txr_fgcolor
    _GR_textColor |txr_bgcolor		// foreground, background
    WORD:   |*txr_buffer		// pointer to text buffer 
    WORD:   |*txr_backup		// optional backup buffer 
    WORD:   |txr_width			// width of area in chars 
    WORD:   |txr_height			// height of area in chars 
    WORD:   |txr_lineoffset		// offset in buffer(s) between lines 
    WORD:   |txr_xpos			// upper left corner X coordinate 
    WORD:   |txr_ypos			// upper left corner Y coordinate 
    BYTE:   |txr_chrtype		// character type (see above) 
    3 FIELD: |GrTextRegion_alignment
;STRUCT

// ================================================================== 
//	      THICK AND DASHED LINE DRAWING PRIMITIVES		      
// ================================================================== 

//  custom line option structure
//   zero or one dash pattern length means the line is continuous
//   the dash pattern always begins with a drawn section
 
STRUCT: GrLineOption
    WORD:  |lno_color			// color used to draw line 
    WORD:  |lno_width			// width of the line 
    WORD:  |lno_pattlen			// length of the dash pattern 
    WORD:  |*lno_dashpat		// draw/nodraw pattern 
;STRUCT

// ================================================================== 
//	       PATTERNED DRAWING AND FILLING PRIMITIVES		      
// ================================================================== 

// BITMAP: a mode independent way to specify a fill pattern of two
//   colors. It is always 8 pixels wide (1 byte per scan line), its
//   height is user-defined. SET THE TYPE FLAG TO ZERO!!!
 
STRUCT: _GR_bitmap
    WORD:  |bmp_ispixmap		// type flag for pattern union 
    WORD:  |bmp_height			// bitmap height 
    WORD:  |*bmp_data			// pointer to the bit pattern 
    WORD:  |bmp_fgcolor			// foreground color for fill 
    WORD:  |bmp_bgcolor			// background color for fill 
    WORD:  |bmp_memflags		// set if dynamically allocated 
;STRUCT
' _GR_bitmap ALIAS GrBitmap

// PIXMAP: a fill pattern stored in a layout identical to the video RAM
//   for filling using 'bitblt'-s. It is mode dependent, typically one
//   of the library functions is used to build it. KEEP THE TYPE FLAG
//   NONZERO!!!
 
STRUCT: _GR_pixmap
    WORD:     |pxp_ispixmap	// type flag for pattern union 
    WORD:     |pxp_width	// pixmap width (in pixels)  
    WORD:     |pxp_height	// pixmap height (in pixels) 
    WORD:     |pxp_oper		// bitblt mode (SET, OR, XOR, AND) 
    _GR_frame |pxp_source	// source context for fill 
;STRUCT
' _GR_pixmap ALIAS GrPixmap

//	
// Fill pattern union -- can either be a bitmap or a pixmap
//
UNION: _GR_pattern
    WORD:    |gp_ispixmap		// nonzero for pixmaps 
    GrBitmap |gp_bitmap			// fill bitmap 
    GrPixmap |gp_pixmap			// fill pixmap 
;UNION
' _GR_pattern ALIAS GrPattern
 
// Draw pattern for line drawings -- specifies both the:
//   (1) fill pattern, and the
//   (2) custom line drawing option
// 
STRUCT: GrLinePattern
    WORD:  |*lnp_pattern		// fill pattern 
    WORD:  |*lnp_option			// width + dash pattern 
;STRUCT

// ==================================================================
//		 MOUSE AND KEYBOARD INPUT UTILITIES		     
// ==================================================================
// mouse event flag bits
$001    CONSTANT  GR_M_MOTION
$002    CONSTANT  GR_M_LEFT_DOWN	
$004    CONSTANT  GR_M_LEFT_UP	        
$008    CONSTANT  GR_M_RIGHT_DOWN	
$010    CONSTANT  GR_M_RIGHT_UP	
$020    CONSTANT  GR_M_MIDDLE_DOWN     
$040    CONSTANT  GR_M_MIDDLE_UP	

GR_M_LEFT_DOWN GR_M_MIDDLE_DOWN OR GR_M_RIGHT_DOWN OR 
        CONSTANT GR_M_BUTTON_DOWN
GR_M_LEFT_UP   GR_M_MIDDLE_UP   OR GR_M_RIGHT_UP   OR 
        CONSTANT GR_M_BUTTON_UP	
GR_M_BUTTON_UP GR_M_BUTTON_DOWN OR 
        CONSTANT GR_M_BUTTON_CHANGE  

// mouse button index bits
1       CONSTANT  GR_M_LEFT	    
2       CONSTANT  GR_M_RIGHT	    
4       CONSTANT  GR_M_MIDDLE	    

$080	CONSTANT  GR_M_KEYPRESS	        // other event flag bits 
$100    CONSTANT  GR_M_POLL	    
$200    CONSTANT  GR_M_NOPAINT	    
GR_M_MOTION  GR_M_KEYPRESS OR GR_M_BUTTON_DOWN OR GR_M_BUTTON_UP OR
        CONSTANT  GR_M_EVENT	    

$01	CONSTANT  GR_KB_RIGHTSHIFT      // Keybd states: right shift key depressed 
$02	CONSTANT  GR_KB_LEFTSHIFT	// left shift key depressed 
$04	CONSTANT  GR_KB_CTRL	        // CTRL depressed 
$08	CONSTANT  GR_KB_ALT	        // ALT depressed 
$10	CONSTANT  GR_KB_SCROLLOCK	// SCROLL LOCK active 
$20	CONSTANT  GR_KB_NUMLOCK	        // NUM LOCK active 
$40	CONSTANT  GR_KB_CAPSLOCK	// CAPS LOCK active 
$80	CONSTANT  GR_KB_INSERT	        // INSERT state active 
GR_KB_LEFTSHIFT  GR_KB_RIGHTSHIFT OR   
        CONSTANT  GR_KB_SHIFT	    

0	CONSTANT  GR_M_CUR_NORMAL       // MOUSE CURSOR modes: just the cursor 
1	CONSTANT  GR_M_CUR_RUBBER	// rectangular rubber band (XOR-d to the screen) 
2	CONSTANT  GR_M_CUR_LINE	        // line attached to the cursor 
3	CONSTANT  GR_M_CUR_BOX	        // rectangular box dragged by the cursor 
                 
128	CONSTANT  GR_M_QUEUE_SIZE	// default queue size 

STRUCT: _GR_mouseEvent 			// mouse event buffer structure 
    WORD: |flags 			// event type flags (see above)
    WORD: |x
    WORD: |y 				// mouse coordinates
    WORD: |buttons 			// mouse button state
    WORD: |key 				// key code from keyboard
    WORD: |kbstat 			// keybd status (ALT, CTRL, etc..)
    WORD: |dtime 			// time since last event (msec)
;STRUCT
' _GR_mouseEvent ALIAS GrMouseEvent

//
//  mouse status information
//
STRUCT: _GR_mouseInfo
    WORD:  |(*block)()          // mouse block function */
    WORD:  |(*unblock)()	// mouse unblock function */
    WORD:  |(*uninit)()		// mouse cleanupt function */
    WORD:  |*cursor 		// the mouse cursor */
    WORD:  |*queue 		// queue of pending input events */
    WORD:  |msstatus 		// -1:missing, 0:unknown, 1:present, 2:initted */
    WORD:  |displayed 		// cursor is (generally) drawn */
    WORD:  |blockflag 		// cursor temp. erase/block flag */
    WORD:  |docheck 		// need to check before gr. op. to screen */
    WORD:  |cursmode 		// mouse cursor draw mode */
    WORD:  |x1 
    WORD:  |y1 
    WORD:  |x2 
    WORD:  |y2 			// auxiliary params for some cursor draw modes */
    WORD:  |curscolor 		// color for some cursor draw modes */
    WORD:  |owncursor 		// auto generated cursor */
    WORD:  |xpos
    WORD:  |ypos 		// current mouse position */
    WORD:  |xmin
    WORD:  |xmax 		// mouse movement X coordinate limits */
    WORD:  |ymin
    WORD:  |ymax 		// mouse movement Y coordinate limits */
    WORD:  |spmult
    WORD:  |spdiv 		// mouse cursor speed factors */
    WORD:  |thresh
    WORD:  |accel 		// mouse acceleration parameters */
    WORD:  |moved 		// mouse cursor movement flag */
    WORD:  |qsize 		// max size of the queue */
    WORD:  |qlength 		// current # of items in the queue */
    WORD:  |qread 		// read pointer for the queue */
    WORD:  |qwrite 		// write pointer for the queue */
;STRUCT
&GrMouseInfo CONSTANT *GrMouseInfo

// //////////////////////////////////////////////////////////////////////////
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

// //////////////////////////////////////////////////////////////////////////
//    Implement  Standard  Graphics  Interface
// \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

GRAPHICS DEFINITIONS

GrTextOption G_PCTextOption	// GRX20.4th default text option

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
        DROP
        G_PCTextOption SIZEOF GrTextOption LITERAL ERASE
	getenv( Z$" GRXFONT" ) 0= IF
	   GrSetFontPath( Z$" .\FONTS" );
	ELSE
	   GrSetFontPath( getenv( Z$" GRXFONT" ) );
	ENDIF

        G_PCTextOption SIZEOF G_PCTextOption LITERAL ERASE
	&GrDefaultFont G_PCTextOption |*txo_font   !
	GR_ALIGN_LEFT  G_PCTextOption |txo_xalign  C!
	GR_ALIGN_TOP   G_PCTextOption |txo_yalign  C!
	GR_TEXT_RIGHT  G_PCTextOption |txo_direct  C!
        LIGHTGRAY      G_PCTextOption |txo_fgcolor |v   !
        GrBlack        G_PCTextOption |txo_bgcolor |v   !

	width 1024 =  to GUseDefaultFont?
	GrSetContext( NULL );
	; 3 0 #PARMS

: GUninitialize  (| -- |)	        // back to text mode
	GrBlack GrClearScreen
	GrSetMode( GR_80_25_text , 0 , 0 , 0 ) DROP  ;
 
: GOutChar	(| X0 Y0 char -- |) // draw character at (X0,Y0)
	GrDrawChar( char , X0 , Y0 , G_PCTextOption ) ;

G_WHITE VALUE GCurrentColor INVISIBLE

: GSetColor	( color -- )	to GCurrentColor ; 1 0 #PARMS
: GGetColor	( -- color )	GCurrentColor ; 0 1 #PARMS
: GDrawPoint         (| x y -- |)
	GrPlotNC( x , y , GCurrentColor )  ;
: GDrawLine          (| x0 y0 x1 y1 -- |)
	GrLineNC( x0 , y0 , x1 , y1 , GCurrentColor )  ;
: GDrawRectangle     (| x0 y0 x1 y1 -- |)
	GrBoxNC( x1 , y1 , x0 , y0 , GCurrentColor )  ;
: GFillRectangle     (| x0 y0 x1 y1 -- |)
	GrFilledBox( x1 , y1 , x0 , y0 , GCurrentColor ) ;

// Color parameterred :

: GDrawCPoint	( x y color -- )
      // GrPlotNC( x , y , color ) ;
	-ROT SWAP GrPlotNC ; 3 0 #PARMS
: GDrawCLine	(| x0 y0 x1 y1 color -- |)
	GrLineNC( x0 , y0 , x1 , y1 , color ) ;
: GDrawCRectangle (| x0 y0 x1 y1 color -- |)
	GrBoxNC( x0 , y0 , x1 , y1 , color ) ;
: GFillCRectangle  (| x0 y0 x1 y1 color -- |)
	GrFilledBox( x0 , y0 , x1 , y1 , color ) ;

: IMAGE_CONTEXT_SIZE    // ((((sizeof(GrContext)+15)&~15)+4)
        [ SIZEOF GrContext 15 + 15 NOT AND 4 + ] LITERAL ; 0 1 #PARMS MACRO

: GImageSize	  ( x0 y0 x1 y1 -- n )
	ROT - ABS 1+   -ROT - ABS 1+  GrContextSize
	IMAGE_CONTEXT_SIZE +  ; 4 1 #PARMS

: GGetImage	(| left top right bottom *image -- |)
        _GGetImage( left , top , right , bottom , *image ) ;

: GPutImage	(| left top *image op -- |)
        _GPutImage( left , top , *image , op ) ;

: GMoveImage	(| destX destY srcX0 srcY0 srcX1 srcY1 -- |)
        GrSetContext( NULL );
	GrBitBlt( NULL , destX , destY ,
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