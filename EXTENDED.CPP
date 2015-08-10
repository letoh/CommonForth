/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
 *   Common Forth  386/486   Compiler Specific C(++) Language Extensions   *
 *									   *
 *  	 Watcom C/C++ 10.5  Version					   *
 *									   *
 *					Written by  : Luke Lee	           *
 *					Date        : 01/01/'96 v1.0	   *
 *                                      Last update : 07/09/'96            *
 *					Version     : 1.01	           *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "invokec.h"

/* Standard Library */

#include <float.h>
#include <math.h>
#include <stdarg.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdio.h>
#include <limits.h>
#include <setjmp.h>
#include <stddef.h>
#include <string.h>
#include <errno.h>
#include <locale.h>
#include <signal.h>
#include <time.h>

/* Extension Library */
/* Note ! Not fully implemented yet */

#include <io.h>
#include <fcntl.h>
#include <dos.h>
#include <sys/stat.h>
#include <process.h>
#include <conio.h>
#include <i86.h>
#include <graph.h>

addr _stdaux()  {  return (addr)stdaux; }
addr _stdprn()  {  return (addr)stdprn; }

/* Graphics.4TH support functions :                   */
/*   Use C call C will be faster than FORTH call C .  */

void _GDrawCPoint( short color, short y, short x ) {
   register short old_color;
	old_color = _setcolor( color );
	_setpixel( x,y );
	_setcolor( old_color );
}
	
void _GDrawCLine( short color, short y1, short x1, short y0, short x0 ) {
   register short old_color;
	old_color = _setcolor( color );
	_moveto( x1,y1 ); _lineto( x0,y0 );
	_setcolor( old_color );
}

void _GDrawCRectangle( short color, short y1, short x1, short y0, short x0 ) {
   register short old_color;
	old_color = _setcolor( color );
	_rectangle( _GBORDER , x0 , y0 , x1 , y1 ) ;
	_setcolor( old_color );
}

void _GFillCRectangle( short color, short y1, short x1, short y0, short x0 ) {
   register short old_color;
	old_color = _setcolor( color );
	_rectangle( _GFILLINTERIOR , x0 , y0 , x1 , y1 ) ;
	_setcolor( old_color );
}

/****************************************************************\
 *  Function  : register_extended_funcs				*
\****************************************************************/

int register_extended_funcs( void ) 
{
    /* ---------------------------------------------------------------- */
    if (register_funcs(	   // stdio.h //
             0,      1,         (addr)&_stdaux,         "stdaux",
             0,      1,         (addr)&_stdprn,         "stdprn",
             2,      1,         (addr)&fdopen,          "fdopen",  END ))
    /* ---------------------------------------------------------------- */
    if (register_funcs(	   // conio.h //
	     1,      1,         (addr)&putch,           "putch",
             0,      1,         (addr)&getch,           "getch",
             0,      1,         (addr)&getche,          "getche",
             1,      1,         (addr)&ungetch,         "ungetch",
             0,      1,         (addr)&kbhit,           "kbhit",            

	     1,      1,         (addr)&cputs,           "cputs",
             1,      1,         (addr)&cgets,           "cgets",
           UNKNOWN,  1,         (addr)&cscanf,          "cscanf",
	   UNKNOWN,  1,         (addr)&cprintf,         "cprintf", END ))
    /* ---------------------------------------------------------------- */
    if (register_funcs(	   // math.h //
             2,      DOUBLE,    (addr)&acosh,           "acosh",
             2,      DOUBLE,    (addr)&asinh,           "asinh",
             2,      DOUBLE,    (addr)&atanh,           "atanh",   END ))
    /* ---------------------------------------------------------------- */
    if (register_funcs(	   // stdlib.h //
             1,      1,         (addr)&putenv,          "putenv",

             2,      1,         (addr)&access,          "access",
             2,      1,         (addr)&chmod,           "chmod",
             1,      1,         (addr)&close,           "close",
             2,      1,         (addr)&creat,           "creat",
             1,      1,         (addr)&dup,             "dup",
             2,      1,         (addr)&dup2,            "dup2",
             3,      1,         (addr)&lseek,           "lseek",
          UNKNOWN,   1,         (addr)&open,            "open",
             3,      1,         (addr)&read,            "read",
             3,      1,         (addr)&write,           "write",

          UNKNOWN,   1,         (addr)&spawnl,          "spawnl",
          UNKNOWN,   1,         (addr)&spawnle,         "spawnle",
          UNKNOWN,   1,         (addr)&spawnlp,         "spawnlp",
          UNKNOWN,   1,         (addr)&spawnlpe,        "spawnlpe",
             3,      1,         (addr)&spawnv,          "spawnv",
             4,      1,         (addr)&spawnve,         "spawnve",
             3,      1,         (addr)&spawnvp,         "spawnvp",
             4,      1,         (addr)&spawnvpe,        "spawnvpe",
        
             1,      1,         (addr)&unlink,          "unlink",

             1,      1,         (addr)&sbrk,            "sbrk",

             1,      1,         (addr)&sleep,           "sleep",   END ))
    /* ---------------------------------------------------------------- */
    if (register_funcs( // stat.h //
             2,      1,         (addr)&fstat,           "fstat", 
             2,      1,         (addr)&stat,            "stat",    END ))
    /* ---------------------------------------------------------------- */
    if (register_funcs(  /***** <i86.h> *****/
    	     1,	     0,		(addr)&sound,		"sound",
	     0,	     0,		(addr)&nosound,		"nosound", END ))
    /* ---------------------------------------------------------------- */
    if (register_funcs(  /***** <dos.h> *****/
             2,      1,         (addr)&_dos_allocmem,   "_dos_allocmem",
             1,      1,         (addr)&_dos_freemem,    "_dos_freemem", END ))
    /* ---------------------------------------------------------------- */
    if (register_funcs(  /***** <graph.h>  *****/
      /* GRAPHICS.4TH support functions */
        3,	0,	(addr)&_GDrawCPoint,		"_GDrawCPoint",
	5,	0,	(addr)&_GDrawCLine,		"_GDrawCLine",
	5,	0,	(addr)&_GDrawCRectangle,	"_GDrawCRectangle",
	5,	0,	(addr)&_GFillCRectangle,	"_GFillCRectangle",END))
    if (register_funcs(
      /* Video Setup and Query Functions */
	1,	1,	(addr)&_setvideomode,		"_setvideomode",
	2,	1,	(addr)&_setvideomoderows,	"_setvideomoderows",
	1,	1,	(addr)&_getvideoconfig,		"_getvideoconfig",
	0,	1,	(addr)&_grstatus,		"_grstatus",
	1,	1,	(addr)&_setactivepage,		"_setactivepage",
	0,	1,	(addr)&_getactivepage,		"_getactivepage",
	1,	1,	(addr)&_setvisualpage,		"_setvisualpage",
	0,	1,	(addr)&_getvisualpage,		"_getvisualpage", END ))
    if (register_funcs(
      /* Colour Setting and Query Functions */
	1,	1,	(addr)&_setcolor,		"_setcolor",
	0,	1,	(addr)&_getcolor,		"_getcolor",
	1,	1,	(addr)&_setbkcolor,		"_setbkcolor",
	0,	1,	(addr)&_getbkcolor,		"_getbkcolor",
	2,	1,	(addr)&_remappalette,		"_remappalette",
	1,	1,	(addr)&_remapallpalette,	"_remapallpalette",
	1,	1,	(addr)&_selectpalette,		"_selectpalette", END ))
    if (register_funcs(
      /* Shape and Curve Drawing Functions */
      	2,	1,	(addr)&_lineto,			"_lineto",
	4,	1,	(addr)&_lineto_w,		"_lineto_w",
	5,	1,	(addr)&_rectangle,		"_rectangle",
	9,	1,	(addr)&_rectangle_w,		"_rectangle_w",
	3,	1,	(addr)&_rectangle_wxy,		"_rectangle_wxy",
	8,	1,	(addr)&_arc,			"_arc",
	16,	1,	(addr)&_arc_w,			"_arc_w",
	4,	1,	(addr)&_arc_wxy,		"_arc_wxy",
	5,	1,	(addr)&_ellipse,		"_ellipse",
	9,	1,	(addr)&_ellipse_w,		"_ellipse_w",
	3,	1,	(addr)&_ellipse_wxy,		"_ellipse_wxy",
	9,	1,	(addr)&_pie,			"_pie",
	17,	1,	(addr)&_pie_w,			"_pie_w",
	4,	1,	(addr)&_pie_wxy,		"_pie_wxy",
	3,	1,	(addr)&_polygon,		"_polygon",
	3,	1,	(addr)&_polygon_w,		"_polygon_w",
	3,	1,	(addr)&_polygon_wxy,		"_polygon_wxy",
	3,	1,	(addr)&_floodfill,		"_floodfill",
	5,	1,	(addr)&_floodfill_w,		"_floodfill_w",
	2,	1,	(addr)&_setpixel,		"_setpixel",
	4,	1,	(addr)&_setpixel_w,		"_setpixel_w",
	2,	1,	(addr)&_getpixel,		"_getpixel",
	4,	1,	(addr)&_getpixel_w,		"_getpixel_w",
	3,	1,	(addr)&_getarcinfo,		"_getarcinfo",    END ))
    if (register_funcs(
      /* Output Determination Functions */
	1,	0,	(addr)&_setfillmask,		"_setfillmask",
	1,	1,	(addr)&_getfillmask,		"_getfillmask",
	1,	0,	(addr)&_setlinestyle,		"_setlinestyle",
	0,	1,	(addr)&_getlinestyle,		"_getlinestyle",
	1,	1,	(addr)&_setplotaction,		"_setplotaction",
	0,	1,	(addr)&_getplotaction,		"_getplotaction", END ))
    if (register_funcs(
      /* Screen Manipulation Functions */
	1,	0,	(addr)&_clearscreen,		"_clearscreen",
	4,	0,	(addr)&_setviewport,		"_setviewport",
	4,	0,	(addr)&_setcliprgn,		"_setcliprgn",
	4,	0,	(addr)&_getcliprgn,		"_getcliprgn",
	1,	1,	(addr)&_displaycursor,		"_displaycursor",
	1,	1,	(addr)&_wrapon,			"_wrapon",
	9,	1,	(addr)&_setwindow,		"_setwindow",	  END ))
    if (register_funcs(
      /* Graphics Text Manipulation Functions and Constants */
      	1,	1,	(addr)&_gettextsettings,	"_gettextsettings",
	5,	0,	(addr)&_gettextextent,		"_gettextextent",
	2,	0,	(addr)&_setcharsize,		"_setcharsize",
	4,	0,	(addr)&_setcharsize_w,		"_setcharsize_w",
	2,	0,	(addr)&_settextalign,		"_settextalign",
	1,	0,	(addr)&_settextpath,		"_settextpath",
	2,	0,	(addr)&_settextorient,		"_settextorient",
	1,	0,	(addr)&_setcharspacing,		"_setcharspacing",
	2,	0,	(addr)&_setcharspacing_w,	"_setcharspacing_w",
	3,	1,	(addr)&_grtext,			"_grtext",
	5,	1,	(addr)&_grtext_w,		"_grtext_w",	  END ))
    if (register_funcs(
      /* Text Manipulation Functions */
	4,	0,	(addr)&_settextwindow,		"_settextwindow",
	1,	0,	(addr)&_outtext,		"_outtext",
	1,	1,	(addr)&_settextcolor,		"_settextcolor",
	0,	1,	(addr)&_gettextcolor,		"_gettextcolor",
	1,	0,	(addr)&_scrolltextwindow,	"_scrolltextwindow",
	4,	0,	(addr)&_gettextwindow,		"_gettextwindow",
	0,	1,	(addr)&_gettextcursor,		"_gettextcursor",
	1,	1,	(addr)&_settextcursor,		"_settextcursor",
	2,	0,	(addr)&_outmem,			"_outmem",
	1,	1,	(addr)&_settextrows,		"_settextrows",	  END ))
    if (register_funcs(
      /* Image Manipulation Functions */
      	5,	0,	(addr)&_getimage,		"_getimage",
	9,	0,	(addr)&_getimage_w,		"_getimage_w",
	3,	0,	(addr)&_getimage_wxy,		"_getimage_wxy",
	4,	0,	(addr)&_putimage,		"_putimage",
	6,	0,	(addr)&_putimage_w,		"_putimage_w",
	4,	1,	(addr)&_imagesize,		"_imagesize",
	8,	1,	(addr)&_imagesize_w,		"_imagesize_w",
	2,	1,	(addr)&_imagesize_wxy,		"_imagesize_wxy", END ))
    if (register_funcs(
      /* Font Manipulation Functions */
      	1,	1,	(addr)&_registerfonts,		"_registerfonts",
	0,	0,	(addr)&_unregisterfonts,	"_unregisterfonts",
	1,	1,	(addr)&_setfont,		"_setfont",
	1,	1,	(addr)&_getfontinfo,		"_getfontinfo",
	1,	0,	(addr)&_outgtext,		"_outgtext",
	1,	1,	(addr)&_getgtextextent,		"_getgtextextent",END ))
    if (register_funcs(
      /* Functions that returns data structure, currently do not handle  */
      /* its return value.						 */
      /* Position Determination Functions */
     // struct xycoord _FAR     _getcurrentposition( void );
     // struct _wxycoord _FAR   _getcurrentposition_w( void );
     // struct xycoord _FAR     _getviewcoord( short, short );
     // struct xycoord _FAR     _getviewcoord_w( double, double );
     // struct xycoord _FAR     _getviewcoord_wxy( struct _wxycoord _FAR * );
     // struct xycoord _FAR     _getphyscoord( short, short );
     // struct _wxycoord _FAR   _getwindowcoord( short, short );
	// struct xycoord _FAR     _setvieworg( short, short );
	2,	0,	(addr)&_setvieworg,	"_setvieworg",
	// struct xycoord _FAR     _moveto( short, short );
	2,	0,	(addr)&_moveto,		"_moveto",
	// struct _wxycoord _FAR   _moveto_w( double, double );
	4,	0,	(addr)&_moveto_w,	"_moveto_w",
	// struct rccoord _FAR     _settextposition( short, short );
	2,	0,	(addr)&_settextposition, "_settextposition",
     // struct rccoord _FAR     _gettextposition( void );
	// struct xycoord _FAR     _setgtextvector( short, short );
	2,	0,	(addr)&_setgtextvector,	"_setgtextvector",
     // struct xycoord _FAR     _getgtextvector( void );
	END ))
    /* ---------------------------------------------------------------- */
    {
       return (1==1);
    }

  return (1==0);
}


