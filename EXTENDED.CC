/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
 *   Common Forth  386/486   Compiler Specific C(++) Language Extensions   *
 *									   *
 *  	 DJGPP on GO32 Version					   	   *
 *									   *
 *						Written by : Luke Lee	   *
 *						Date       : 12/11/'95	   *
 *						Version    : 1.0	   *
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
/* Note ! Not fully implemented */

#include <std.h>
#include <conio.h>
#include <process.h>
#include <io.h>
#include <fcntl.h>
#include <file.h>
#include <dos.h>
#include <go32.h>
#include <sys/stat.h>
#include <grx.h>
#include <mousex.h>


addr _stdaux()	{  return (addr)stdaux; }
addr _stdprn()	{  return (addr)stdprn; }


/****************************************************************\
 *  Function  : register_extended_funcs				*
\****************************************************************/

int register_extended_funcs( void ) 
{
  /*   #in     #out           fn addr             fn name
       ---------------------------------------------------------------- */
    if (register_funcs(    /***** <go32.h> *****/
	1,	0,	(addr)&_go32_want_ctrl_break,"_go32_want_ctrl_break",
	5,      0,	(addr)&movedata,	"movedata",
	0,      1,	(addr)&_go32_conventional_mem_selector,
					 "_go32_conventional_mem_sel",	END ))
    /* ---------------------------------------------------------------- */
    if (register_funcs(    /***** <stdio.h> *****/
	0,	1,	(addr)&_stdaux,		"stdaux",
	0,      1,	(addr)&_stdprn,		"stdprn",
	2,	1,	(addr)&fdopen,		"fdopen",
	1,	1,	(addr)&getw,		"getw",
	2,	1,	(addr)&putw,		"putw",			END ))
    /* ---------------------------------------------------------------- */
    if (register_funcs(	   /*****  <conio.h>  *****/
	0,      0,	(addr)&clreol,          "clreol",
	0,      0,      (addr)&clrscr,          "clrscr",
	0,      0,      (addr)&delline,         "delline",
	0,      0,      (addr)&insline,      	"insline",
					        
	2,      0,      (addr)&gotoxy,          "gotoxy",
	0,      1,      (addr)&wherex,          "wherex",
	0,      1,      (addr)&wherey,       	"wherey",
					        
	1,      1,      (addr)&putch,           "putch",
        0,      1,      (addr)&getch,           "getch",
        0,      1,      (addr)&getche,          "getche",
        1,      1,      (addr)&ungetch,         "ungetch",
        0,      1,      (addr)&kbhit,        	"kbhit",            
					        
	0,      0,      (addr)&lowvideo,        "lowvideo",
	0,      0,      (addr)&highvideo,       "highvideo",
	0,      0,      (addr)&normvideo,       "normvideo",
        1,      0,      (addr)&gettextinfo,  	"gettextinfo",      
					        
	5,      1,      (addr)&gettext,         "gettext",
	5,      1,      (addr)&puttext,         "puttext",
	6,      1,      (addr)&movetext,     	"movetext",
					        
	1,      0,      (addr)&textmode,        "textmode",
	1,      0,      (addr)&textattr,        "textattr",
	1,      0,      (addr)&textcolor,       "textcolor",
	1,      0,      (addr)&textbackground,	"textbackground",
	1,      0,      (addr)&window,       	"window",
					        
	1,	0,	(addr)&sound,		"sound",
					        
	1,      0,      (addr)&_setcursortype,  "_setcursortype",
					        
	0,      0,      (addr)&gppconio_init,   "gppconio_init",
	1,      1,      (addr)&cputs,           "cputs",
        1,      1,      (addr)&cgets,           "cgets",
      UNKNOWN,	1,      (addr)&cscanf,          "cscanf",
      UNKNOWN,	1,      (addr)&cprintf,      	"cprintf",		END ))
    /* ---------------------------------------------------------------- */
    if (register_funcs(   /*****  <math.h>  *****/
	     2,	     DOUBLE,	(addr)&pow10,		"pow10",
	     2,	     DOUBLE,	(addr)&pow2,		"pow2",		END ))
    /* ---------------------------------------------------------------- */
    if (register_funcs(   /*****  <stat.h>  *****/
	     2,      1,		(addr)&fstat,		"fstat", 
	     2,	     1,		(addr)&stat,		"stat",		END ))
    /* ---------------------------------------------------------------- */
    if (register_funcs(	   
	     1,	     1,         (addr)&putenv,	       	"putenv",

	     2,	     1,		(addr)&access,		"access",
	     2,	     1,		(addr)&chmod,		"chmod",
	     1,	     1,		(addr)&close,		"close",
	     2,	     1,		(addr)&creat,		"creat",
	     1,	     1,		(addr)&dup,		"dup",
	     2,	     1,		(addr)&dup2,		"dup2",
	     3,	     1,		(addr)&lseek,		"lseek",
	  UNKNOWN,   1,		(addr)&open,		"open",
	     3,	     1,		(addr)&read,		"read",
	     3,	     1,		(addr)&write,		"write",

	  UNKNOWN,   1,		(addr)&execl,		"execl",
	  UNKNOWN,   1,		(addr)&execle,		"execle",
	  UNKNOWN,   1,		(addr)&execlp,		"execlp",
	  UNKNOWN,   1, 	(addr)&execlpe,		"execlpe",
	     2,	     1,		(addr)&execv,		"execv",
	     3,      1,		(addr)&execve,		"execve",
	     2,      1,		(addr)&execvp,		"execvp",
	     3,      1,		(addr)&execvpe,		"execvpe",
	  UNKNOWN,   1,		(addr)&spawnl,		"spawnl",
	  UNKNOWN,   1,		(addr)&spawnle,		"spawnle",
	  UNKNOWN,   1,		(addr)&spawnlp,		"spawnlp",
	  UNKNOWN,   1,		(addr)&spawnlpe,	"spawnlpe",
	     3,      1,		(addr)&spawnv,		"spawnv",
	     4,      1,		(addr)&spawnve,		"spawnve",
	     3,      1,		(addr)&spawnvp,		"spawnvp",
	     4,      1,		(addr)&spawnvpe,	"spawnvpe",
	
	     1,	     1,		(addr)&chdir,		"chdir",
	     2,	     1,		(addr)&getcwd,		"getcwd",
	     2,	     1,		(addr)&mkdir,		"mkdir",
	     1,	     1,		(addr)&rmdir,		"rmdir",
	     1,	     1,		(addr)&unlink,		"unlink",

	     1,	     1,		(addr)&brk,		"brk",
	     1,	     1,		(addr)&sbrk,		"sbrk",

	     1,	     1,		(addr)&sleep,		"sleep",
	     0,      1,         (addr)&random,	       	"random",	END ))
    /* ---------------------------------------------------------------- */
    /*				Graphics				*/
    /* ---------------------------------------------------------------- */
    if (register_funcs(  /*****  <grx.h>  *****/
       //////////////////////////////////
       //   CONTEXT AND WINDOW STUFF   //
       //////////////////////////////////
	4,      0,      (addr)&GrSetMode,       "GrSetMode",
        4,      0,      (addr)&GrSetBIOSMode,   "GrSetBIOSMode",
        1,      0,      (addr)&GrSetModeHook,   "GrSetModeHook",
        0,      1,      (addr)&GrCurrentMode,   "GrCurrentMode",
        0,      1,      (addr)&GrAdapterType,   "GrAdapterType",
        0,      1,      (addr)&GrNumPlanes,     "GrNumPlanes",
        1,      1,      (addr)&GrLineOffset,    "GrLineOffset",
        2,      1,      (addr)&GrPlaneSize,     "GrPlaneSize",
        2,      1,      (addr)&GrContextSize,   "GrContextSize",

        4,      1,      (addr)&GrCreateContext, "GrCreateContext",
        6,      1,      (addr)&GrCreateSubContext, "GrCreateSubContext",
        1,      1,      (addr)&GrSaveContext,   "GrSaveContext",
        5,      0,      (addr)&GrResizeSubContext, "GrResizeSubContext",
        1,      0,      (addr)&GrSetContext,    "GrSetContext",
        1,      0,      (addr)&GrDestroyContext,   "GrDestroyContext",

        4,      0,      (addr)&GrSetClipBox,    "GrSetClipBox",         
        4,      0,      (addr)&GrGetClipBox,    "GrGetClipBox",         
        0,      0,      (addr)&GrResetClipBox,  "GrResetClipBox",

        0,      1,      (addr)&GrMaxX,          "GrMaxX",
        0,      1,      (addr)&GrMaxY,          "GrMaxY",
        0,      1,      (addr)&GrSizeX,         "GrSizeX",
        0,      1,      (addr)&GrSizeY,         "GrSizeY",
        0,      1,      (addr)&GrScreenX,       "GrScreenX",
        0,      1,      (addr)&GrScreenY,       "GrScreenY",	END ))
    if (register_funcs(
       /////////////////////
       //   COLOR STUFF   //
       /////////////////////
        0,      1,      (addr)&GrNumColors,     "GrNumColors",
        0,      1,      (addr)&GrNumFreeColors, "GrNumFreeColors",
        
        3,      1,      (addr)&GrAllocColor,    "GrAllocColor",
        0,      1,      (addr)&GrAllocCell,     "GrAllocCell",
        0,      1,      (addr)&GrBlack,         "GrBlack",
        0,      1,      (addr)&GrWhite,         "GrWhite",

        4,      0,      (addr)&GrQueryColor,    "GrQueryColor",
        1,      0,      (addr)&GrFreeColor,     "GrFreeColor",
        4,      0,      (addr)&GrSetColor,      "GrSetColor",
        0,      0,      (addr)&GrSetRGBcolorMode,  "GrSetRGBcolorMode",
        0,      0,      (addr)&GrResetColors,   "GrResetColors",
        0,      0,      (addr)&GrRefreshColors, "GrRefreshColors", END ))
    if (register_funcs(	
       /////////////////////////////	
       //   GRAPHICS PRIMITIVES	  //
       /////////////////////////////	
        1,      0,      (addr)&GrClearScreen,   "GrClearScreen",
        1,      0,      (addr)&GrClearContext,  "GrClearContext",
        1,      0,      (addr)&GrClearClipBox,  "GrClearClipBox",
        3,      0,      (addr)&GrPlot,          "GrPlot",
        5,      0,      (addr)&GrLine,          "GrLine",
        4,      0,      (addr)&GrHLine,         "GrHLine",
        4,      0,	(addr)&GrVLine,         "GrVLine",
        5,      0,      (addr)&GrBox,           "GrBox",
        5,      0,      (addr)&GrFilledBox,     "GrFilledBox",
        6,      0,      (addr)&GrFramedBox,     "GrFramedBox",
        4,      0,      (addr)&GrCircle,        "GrCircle",
        5,      0,      (addr)&GrEllipse,       "GrEllipse",
        6,      0,      (addr)&GrCircleArc,     "GrCircleArc",
        7,      0,      (addr)&GrEllipseArc,    "GrEllipseArc",
        4,      0,      (addr)&GrFilledCircle,  "GrFilledCircle",
        5,      0,      (addr)&GrFilledEllipse, "GrFilledEllipse",
        6,      0,   (addr)&GrFilledCircleArc,  "GrFilledCircleArc",
        7,      0,   (addr)&GrFilledEllipseArc, "GrFilledEllipseArc",
        6,      0,   (addr)&GrGetLastArcCoords, "GrGetLastArcCoords",
        3,      0,      (addr)&GrPolyLine,      "GrPolyLine",
        3,      0,      (addr)&GrPolygon,       "GrPolygon",
        3,      0,      (addr)&GrFilledConvexPolygon,   "GrFilledConvexPolygon",
        3,      0,      (addr)&GrFilledPolygon, "GrFilledPolygon",
        9,      0,      (addr)&GrBitBlt,        "GrBitBlt",
        2,      1,      (addr)&GrPixel,         "GrPixel",      END ))
    if (register_funcs(
       ///////////////////////////////////////////
       //    NON CLIPPING DRAWING PRIMITIVES	//
       ///////////////////////////////////////////
        3,      0,      (addr)&GrPlotNC,        "GrPlotNC",
	5,	0,	(addr)&GrLineNC,	"GrLineNC",	
	4,	0,	(addr)&GrHLineNC,	"GrHLineNC",
	4,	0,	(addr)&GrVLineNC,	"GrVLineNC",
	5,	0,	(addr)&GrBoxNC,		"GrBoxNC",
	5,	0,	(addr)&GrFilledBoxNC,	"GrFilledBoxNC",
	6,	0,	(addr)&GrFramedBoxNC,	"GrFramedBoxNC",
	9,	0,	(addr)&GrBitBltNC,	"GrBitBltNC",
	2,	1,	(addr)&GrPixelNC,	"GrPixelNC",	END ))
    if (register_funcs(
       ////////////////////////////////////////////////////	
       //    THICK AND DASHED LINE DRAWING PRIMITIVES	 //
       ////////////////////////////////////////////////////	
	5,	0,	(addr)&GrCustomLine,	"GrCustomLine",
	5,	0,	(addr)&GrCustomBox,	"GrCustomBox",
	4,	0,	(addr)&GrCustomCircle,	"GrCustomCircle",
	5,	0,	(addr)&GrCustomEllipse,	"GrCustomEllipse",
	6,	0,  (addr)&GrCustomCircleArc,	"GrCustomCircleArc",
	7,	0,  (addr)&GrCustomEllipseArc,	"GrCustomEllipseArc",
	3,	0,	(addr)&GrCustomPolyLine,"GrCustomPolyLine",
	3,	0,	(addr)&GrCustomPolygon,	"GrCustomPolygon", END ))
    if (register_funcs(	
       ////////////////////////////////////////////////////
       //    PATTERNED DRAWING AND FILLING PRIMITIVES    //
       ////////////////////////////////////////////////////
	4,	1,	(addr)&GrBuildPixmap,	"GrBuildPixmap",
	5,	1,   (addr)&GrBuildPixmapFromBits,  "GrBuildPixmapFromBits",
	1,	1,	(addr)&GrConvertToPixmap,	"GrConvertToPixmap",
	3,	1,	(addr)&GrLoadBitmap,	"GrLoadBitmap",
	2,	1,	(addr)&GrLoadPixmap,	"GrLoadPixmap",
	1,	1,	(addr)&GrLoadIcon,	"GrLoadIcon",
	
	1,	0,	(addr)&GrDestroyPattern, "GrDestroyPattern",
	
	5,	0,	(addr)&GrPatternedLine,	"GrPatternedLine",
	5,	0,	(addr)&GrPatternedBox,	"GrPatternedBox",
	4,	0,  (addr)&GrPatternedCircle,	"GrPatternedCircle",
	5,	0,  (addr)&GrPatternedEllipse,	"GrPatternedEllipse",
	6,	0,      (addr)&GrPatternedCircleArc,   "GrPatternedCircleArc",
	7,	0,  	(addr)&GrPatternedEllipseArc, "GrPatternedEllipseArc",
	3,	0,  (addr)&GrPatternedPolyLine,	"GrPatternedPolyLine",
	3,	0,  (addr)&GrPatternedPolygon,	"GrPatternedPolygon",

	3,	0,  (addr)&GrPatternFilledPlot,	"GrPatternFilledPlot",
	5,	0,  (addr)&GrPatternFilledLine,	"GrPatternFilledLine",
	5,	0,  (addr)&GrPatternFilledBox,	"GrPatternFilledBox",
	4,	0,	(addr)&GrPatternFilledCircle, "GrPatternFilledCircle",
	5,	0,  (addr)&GrPatternFilledEllipse,  "GrPatternFilledEllipse",
	6,	0, (addr)&GrPatternFilledCircleArc,"GrPatternFilledCircleArc",
	7,    0, (addr)&GrPatternFilledEllipseArc,"GrPatternFilledEllipseArc",
	3,0,(addr)&GrPatternFilledConvexPolygon,"GrPatternFilledConvexPolygon",
	3,	0,    (addr)&GrPatternFilledPolygon,  "GrPatternFilledPolygon",
       ////////////////////////////////////////
       //     FONTS AND TEXT PRIMITIVES      //
       ////////////////////////////////////////
	5,	1,	(addr)&GrFindBestFont,	"GrFindBestFont",
	1,	1,	(addr)&GrLoadFont,	"GrLoadFont",
	1,	1,	(addr)&GrLoadBIOSFont,	"GrLoadBIOSFont",
	1,	0,	(addr)&GrUnloadFont,	"GrUnloadFont",
	1,	0,	(addr)&GrSetFontPath,	"GrSetFontPath",

	4,	0,	(addr)&GrDrawChar,	"GrDrawChar",
	5,	0,	(addr)&GrDrawString,	"GrDrawString",
	5,	0,	(addr)&GrTextXY,	"GrTextXY",
	4,	0,	(addr)&GrDumpChar,	"GrDumpChar",
	5,	0,	(addr)&GrDumpText,	"GrDumpText",
	1,	0,	(addr)&GrDumpTextRegion,"GrDumpTextRegion",

	1,	1,	(addr)&GrFontHeight,	"GrFontHeight",
	1,	1,	(addr)&GrFontWidth,	"GrFontWidth",
	2,	1,	(addr)&GrCharWidth,	"GrCharWidth",
	2,	1,	(addr)&GrCharHeight,	"GrCharHeight",
	3,	1,	(addr)&GrStringWidth,	"GrStringWidth",
	3,	1,	(addr)&GrStringHeight,	"GrStringHeight",   END ))
    if (register_funcs(	
       //////////////////////////////////////////////
       //    DRAWING IN USER WINDOW COORDINATES    //
       //////////////////////////////////////////////
	4,	0,	(addr)&GrSetUserWindow, "GrSetUserWindow",
	4,	0,	(addr)&GrGetUserWindow, "GrGetUserWindow",
	2,	0,	(addr)&GrGetScreenCoord,"GrGetScreenCoord",
	2,	0,	(addr)&GrGetUserCoord,	"GrGetUserCoord",

	3,	0,	(addr)&GrUsrPlot,	"GrUsrPlot",
	5,	0,	(addr)&GrUsrLine,	"GrUsrLine",
	4,	0,	(addr)&GrUsrHLine,	"GrUsrHLine",
	4,	0,	(addr)&GrUsrVLine,	"GrUsrVLine",
	5,	0,	(addr)&GrUsrBox,	"GrUsrBox",
	5,	0,	(addr)&GrUsrFilledBox,	"GrUsrFilledBox",
	6,	0,	(addr)&GrUsrFramedBox,	"GrUsrFramedBox",
	4,	0,	(addr)&GrUsrCircle,	"GrUsrCircle",
	5,	0,	(addr)&GrUsrEllipse,	"GrUsrEllipse",
	6,	0,	(addr)&GrUsrCircleArc,	"GrUsrCircleArc",
	7,	0,	(addr)&GrUsrEllipseArc, "GrUsrEllipseArc",
	4,	0,   (addr)&GrUsrFilledCircle,	"GrUsrFilledCircle",
	5,	0,   (addr)&GrUsrFilledEllipse, "GrUsrFilledEllipse",
	6,	0,   (addr)&GrUsrFilledCircleArc,     "GrUsrFilledCircleArc",
	7,	0,   (addr)&GrUsrFilledEllipseArc,   "GrUsrFilledEllipseArc",
	3,	0,	(addr)&GrUsrPolyLine,	"GrUsrPolyLine",
	3,	0,	(addr)&GrUsrPolygon,	"GrUsrPolygon",
	3,	0,   (addr)&GrUsrFilledPolygon,	"GrUsrFilledPolygon",
	2,	1,	(addr)&GrUsrPixel,	"GrUsrPixel",
	5,	0,	(addr)&GrUsrCustomLine, "GrUsrCustomLine",
	5,	0,	(addr)&GrUsrCustomBox,	"GrUsrCustomBox",
	4,	0,	(addr)&GrUsrCustomCircle,	"GrUsrCustomCircle",
	5,	0,	(addr)&GrUsrCustomEllipse,	"GrUsrCustomEllipse",
	6,	0, (addr)&GrUsrCustomCircleArc, "GrUsrCustomCircleArc",
	7,	0, (addr)&GrUsrCustomEllipseArc, "GrUsrCustomEllipseArc",
	3,	0,   	(addr)&GrUsrCustomPolyLine,	"GrUsrCustomPolyLine",
	3,	0,	(addr)&GrUsrCustomPolygon,	"GrUsrCustomPolygon",

	5,	0,	(addr)&GrUsrPatternedLine,	"GrUsrPatternedLine",
	5,	0,	(addr)&GrUsrPatternedBox,	"GrUsrPatternedBox",
	4,	0,   (addr)&GrUsrPatternedCircle,    "GrUsrPatternedCircle",
	5,	0,   (addr)&GrUsrPatternedEllipse,   "GrUsrPatternedEllipse",
	6,	0, (addr)&GrUsrPatternedCircleArc, "GrUsrPatternedCircleArc",
	7,      0, (addr)&GrUsrPatternedEllipseArc, "GrUsrPatternedEllipseArc",
	3,	0,   (addr)&GrUsrPatternedPolyLine,  "GrUsrPatternedPolyLine",
	3,	0,   (addr)&GrUsrPatternedPolygon,    "GrUsrPatternedPolygon",

	3, 0, (addr)&GrUsrPatternFilledPlot, "GrUsrPatternFilledPlot",
	5, 0, (addr)&GrUsrPatternFilledLine, "GrUsrPatternFilledLine",
	5, 0, (addr)&GrUsrPatternFilledBox, "GrUsrPatternFilledBox",
	4, 0, (addr)&GrUsrPatternFilledCircle, "GrUsrPatternFilledCircle",
	5, 0, (addr)&GrUsrPatternFilledEllipse, "GrUsrPatternFilledEllipse",
	6, 0, (addr)&GrUsrPatternFilledCircleArc,"GrUsrPatternFilledCircleArc",
	7, 0, (addr)&GrUsrPatternFilledEllipseArc,
					        "GrUsrPatternFilledEllipseArc",
      /* Can't find these :	
	3, 0, (addr)&GrUsrFilledConvexPolygon,  "GrUsrFilledConvexPolygon",
  	3, 0, (addr)&GrUsrPatternFilledConvexPolygon,
					     "GrUsrPatternFilledConvexPolygon",
	3, 0, (addr)&GrUsrPatternFilledPolygon,  "GrUsrPatternFilledPolygon",
      */
	5, 	0,	(addr)&GrUsrFindBestFont, 	"GrUsrFindBestFont",
	4,	0,	(addr)&GrUsrDrawChar,		"GrUsrDrawChar",
	5,	0,	(addr)&GrUsrDrawString,		"GrUsrDrawString",
	5,	0,	(addr)&GrUsrTextXY,		"GrUsrTextXY",  END ))
    /* ---------------------------------------------------------------- */
    if (register_funcs(	/*****  <mousex.h>  *****/
	0,	1,	(addr)&getkey,			"getkey",
	0,	1,	(addr)&getxkey,			"getxkey",
	0,	1,	(addr)&getkbstat,		"getkbstat",
	6,	1,	(addr)&GrBuildCursor,		"GrBuildCursor",
	2,	1,	(addr)&GrLoadCursor,		"GrLoadCursor",
	1,	0,	(addr)&GrDestroyCursor,		"GrDestroyCursor",
	1,	0,	(addr)&GrDisplayCursor,		"GrDisplayCursor",
	1,	0,	(addr)&GrEraseCursor,		"GrEraseCursor",
	3,	0,	(addr)&GrMoveCursor,		"GrMoveCursor",
	0,	1,	(addr)&MouseDetect,		"MouseDetect",
	1,	0,	(addr)&MouseEventMode,		"MouseEventMode",
	0,	0,	(addr)&MouseInit,		"MouseInit",
	0,	0,	(addr)&MouseUnInit,		"MouseUnInit",
	1,	0,	(addr)&MouseSetSpeed,		"MouseSetSpeed",
	2,	0,	(addr)&MouseSetAccel,		"MouseSetAccel",
	4,	0,	(addr)&MouseSetLimits,		"MouseSetLimits",
	4,	0,	(addr)&MouseGetLimits,		"MouseGetLimits",
	2,	0,	(addr)&MouseWarp,		"MouseWarp",
	2,	0,	(addr)&MouseEventEnable,	"MouseEventEnable",
	2,	0,	(addr)&MouseGetEvent,		"MouseGetEvent",
	0,	1,	(addr)&MousePendingEvent,	"MousePendingEvent",
	0,	1,	(addr)&MouseGetCursor,		"MouseGetCursor",
	1,	0,	(addr)&MouseSetCursor,		"MouseSetCursor",
	2,	0,	(addr)&MouseSetColors,		"MouseSetColors",
     UNKNOWN,	0,	(addr)&MouseSetCursorMode,	"MouseSetCursorMode",
	0,	0,	(addr)&MouseDisplayCursor,	"MouseDisplayCursor",
	0,	0,	(addr)&MouseEraseCursor,	"MouseEraseCursor",
	5,	1,	(addr)&MouseBlock,		"MouseBlock",
	1,	0,	(addr)&MouseUnBlock,		"MouseUnBlock",
	0,	1,    (addr)&MouseCursorIsDisplayed,  "MouseCursorIsDisplayed"  
								      ,END ))
    /* ---------------------------------------------------------------- */
    {
       return (1==1);
    }

  return (1==0);
}

