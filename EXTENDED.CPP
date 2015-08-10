/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
 *   Common Forth  386/486   Compiler Specific C(++) Language Extensions   *
 *									   *
 *  	 Borland Version					   	   *
 *									   *
 *						Written by : Luke Lee	   *
 *                                              Date       : 02/09/'98     *
 *						Version    : 1.0	   *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "invokec.h"

#define CF_LINKBGI      	1
#define BGI_REGISTER_DRIVERS    0
#define BGI_REGISTER_FONTS      0

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

#include <conio.h>
#include <process.h>
#include <io.h>
#include <fcntl.h>
#include <dir.h>
#include <alloc.h>
#include <graphics.h>
#include <dos.h>
#include <sys/stat.h>

// addr _stdprn(void)  		{  return (addr)stdprn; }
// addr _stdaux(void)  		{  return (addr)stdaux; }

/****************************************************************\
 *  Function  : register_extended_funcs				*
\****************************************************************/
int bgidemo_main();

int register_extended_funcs( void ) 
{
  /*   #in     #out           fn addr             fn name
       ---------------------------------------------------------------- */
    if (register_funcs(    /***** <stdio.h> *****/
//        0,	1,	(addr)_stdprn,		"stdprn",
//        0,	1,	(addr)_stdaux,		"stdaux",
	2,	1,	(addr)fdopen,		"fdopen",
	1,	1,	(addr)getw,		"getw",
	2,	1,	(addr)putw,		"putw",			END ))
    /* ---------------------------------------------------------------- */
	 if (register_funcs(	   /*****  <conio.h>  *****/
	0,      0,	(addr)clreol,          "clreol",
	0,      0,      (addr)clrscr,          "clrscr",
	0,      0,      (addr)delline,         "delline",
	0,      0,      (addr)insline,      	"insline",
					        
	2,      0,      (addr)gotoxy,          "gotoxy",
	0,      1,      (addr)wherex,          "wherex",
	0,      1,      (addr)wherey,       	"wherey",
					        
	1,      1,      (addr)putch,           "putch",
        0,      1,      (addr)getch,           "getch",
	0,      1,      (addr)getche,          "getche",
        1,      1,      (addr)ungetch,         "ungetch",
        0,      1,      (addr)kbhit,        	"kbhit",            
					        
	0,      0,      (addr)lowvideo,        "lowvideo",
	0,      0,      (addr)highvideo,       "highvideo",
	0,      0,      (addr)normvideo,       "normvideo",
        1,      0,      (addr)gettextinfo,  	"gettextinfo",      
					        
	5,      1,      (addr)gettext,         "gettext",
	5,      1,      (addr)puttext,         "puttext",
	6,      1,      (addr)movetext,     	"movetext",

	1,      0,      (addr)textmode,        "textmode",
	1,      0,      (addr)textattr,        "textattr",
	1,      0,      (addr)textcolor,       "textcolor",
	1,      0,      (addr)textbackground,	"textbackground",
	1,      0,      (addr)window,       	"window",
						
//	1,	0,	(addr)sound,		"sound",
						
	1,      0,      (addr)_setcursortype,  "_setcursortype",
						
//	0,      0,      (addr)gppconio_init,   "gppconio_init",
	1,      1,      (addr)cputs,           "cputs",
	1,      1,      (addr)cgets,           "cgets",
      UNKNOWN,	1,      (addr)cscanf,          "cscanf",
      UNKNOWN,	1,      (addr)cprintf,      	"cprintf",		END ))
    /* ---------------------------------------------------------------- */
//    if (register_funcs(   /*****  <math.h>  *****/
//	     2,	     DOUBLE,	(addr)pow10,		"pow10",
//	     2,	     DOUBLE,	(addr)pow2,		"pow2",		END ))
    /* ---------------------------------------------------------------- */
    if (register_funcs(   /*****  <stat.h>  *****/
	     2,      1,		(addr)fstat,		"fstat", 
	     2,	     1,		(addr)stat,		"stat",		END ))
    /* ---------------------------------------------------------------- */
    if (register_funcs(	   
	     1,	     1,         (addr)putenv,	       	"putenv",

	     2,	     1,		(addr)access,		"access",
	     2,	     1,		(addr)chmod,		"chmod",
	     1,	     1,		(addr)close,		"close",
	     2,	     1,		(addr)creat,		"creat",
//	     1,	     1,		(addr)dup,		"dup",
//	     2,	     1,		(addr)dup2,		"dup2",
	     3,	     1,		(addr)lseek,		"lseek",
	  UNKNOWN,   1,		(addr)open,		"open",
	     3,	     1,		(addr)read,		"read",
	     3,	     1,		(addr)write,		"write",

	  UNKNOWN,   1,		(addr)execl,		"execl",
	  UNKNOWN,   1,		(addr)execle,		"execle",
	  UNKNOWN,   1,		(addr)execlp,		"execlp",
	  UNKNOWN,   1, 	(addr)execlpe,		"execlpe",
	     2,	     1,		(addr)execv,		"execv",
	     3,      1,		(addr)execve,		"execve",
	     2,      1,		(addr)execvp,		"execvp",
	     3,      1,		(addr)execvpe,		"execvpe",
	  UNKNOWN,   1,		(addr)spawnl,		"spawnl",
	  UNKNOWN,   1,		(addr)spawnle,		"spawnle",
	  UNKNOWN,   1,		(addr)spawnlp,		"spawnlp",
	  UNKNOWN,   1,		(addr)spawnlpe,	"spawnlpe",
	     3,      1,		(addr)spawnv,		"spawnv",
	     4,      1,		(addr)spawnve,		"spawnve",
	     3,      1,		(addr)spawnvp,		"spawnvp",
	     4,      1,		(addr)spawnvpe,	"spawnvpe",
	
	     1,	     1,		(addr)chdir,		"chdir",
	     2,	     1,		(addr)getcwd,		"getcwd",
	     2,	     1,		(addr)mkdir,		"mkdir",
	     1,	     1,		(addr)rmdir,		"rmdir",
	     1,	     1,		(addr)unlink,		"unlink",

//	     1,	     1,		(addr)brk,		"brk",
//	     1,	     1,		(addr)sbrk,		"sbrk",

//	     1,	     0,		(addr)sleep,		"sleep",
	     0,      1,         (addr)random,	       	"random",	END ))
    /* ---------------------------------------------------------------- */
    /*				Graphics				*/
    /* ---------------------------------------------------------------- */
#if  CF_LINKBGI
    if (register_funcs(    /***** <graphics.h> *****/
        5,      0,      (addr)arc,              "arc",
        4,      0,      (addr)bar,              "bar",
        6,      0,      (addr)bar3d,            "bar3d",
        3,      0,      (addr)circle,           "circle",
        0,      0,      (addr)cleardevice,      "cleardevice",
        0,      0,      (addr)clearviewport,    "clearviewport",
        0,      0,      (addr)closegraph,       "closegraph",
        2,      0,      (addr)detectgraph,      "detectgraph",
        2,      0,      (addr)drawpoly,         "drawpoly",
        6,      0,      (addr)ellipse,          "ellipse",
        4,      0,      (addr)fillellipse,      "fillellipse",
        2,      0,      (addr)fillpoly,         "fillpoly",
        3,      0,      (addr)floodfill,        "floodfill",
        1,      0,      (addr)getarccoords,     "getarccoords",
        2,      0,      (addr)getaspectratio,   "getaspectratio",
        0,      1,      (addr)getbkcolor,       "getbkcolor",
        0,      1,      (addr)getcolor,         "getcolor",
        0,      1,      (addr)getdefaultpalette,"getdefaultpalette",
        0,      1,      (addr)getdrivername,    "getdrivername",
        1,      0,      (addr)getfillpattern,   "getfillpattern",
        1,      0,      (addr)getfillsettings,  "getfillsettings",
        0,      1,      (addr)getgraphmode,     "getgraphmode",         END ))
    if (register_funcs(
        5,      0,      (addr)getimage,         "getimage",
        1,      0,      (addr)getlinesettings,  "getlinesettings",
        0,      1,      (addr)getmaxcolor,      "getmaxcolor",
        0,      1,      (addr)getmaxmode,       "getmaxmode",
        0,      1,      (addr)getmaxx,          "getmaxx",
        0,      1,      (addr)getmaxy,          "getmaxy",
        1,      1,      (addr)getmodename,      "getmodename",
        3,      0,      (addr)getmoderange,     "getmoderange",
        2,      1,      (addr)getpixel,         "getpixel",
        1,      0,      (addr)getpalette,       "getpalette",
        0,      1,      (addr)getpalettesize,   "getpalettesize",
        1,      0,      (addr)gettextsettings,  "gettextsettings",
        1,      0,      (addr)getviewsettings,  "getviewsettings",
        0,      1,      (addr)getx,             "getx",
        0,      1,      (addr)gety,             "gety",
        0,      0,      (addr)graphdefaults,    "graphdefaults",
        1,      1,      (addr)grapherrormsg,    "grapherrormsg",
        2,      0,      (addr)_graphfreemem,    "_graphfreemem",
        1,      1,      (addr)_graphgetmem,     "_graphgetmem",
        0,      1,      (addr)graphresult,      "graphresult",
        4,      1,      (addr)imagesize,        "imagesize",
        3,      0,      (addr)initgraph,        "initgraph",
        2,      1,      (addr)installuserdriver,"installuserdriver",
        1,      1,      (addr)installuserfont,  "installuserfont",
        4,      0,      (addr)line,             "line",
        2,      0,      (addr)linerel,          "linerel",
        2,      0,      (addr)lineto,           "lineto",
        2,      0,      (addr)moverel,          "moverel",
        2,      0,      (addr)moveto,           "moveto",
        1,      0,      (addr)outtext,          "outtext",
        3,      0,      (addr)outtextxy,        "outtextxy",
        5,      0,      (addr)pieslice,         "pieslice",
        4,      0,      (addr)putimage,         "putimage",
        3,      0,      (addr)putpixel,         "putpixel",
        4,      0,      (addr)rectangle,        "rectangle",
        0,      0,      (addr)restorecrtmode,   "restorecrtmode",       END ))
    if (register_funcs(
        6,      0,      (addr)sector,           "sector",
        1,      0,      (addr)setactivepage,    "setactivepage",
        1,      0,      (addr)setallpalette,    "setallpalette",
        2,      0,      (addr)setaspectratio,   "setaspectratio",
        1,      0,      (addr)setbkcolor,       "setbkcolor",
        1,      0,      (addr)setcolor,         "setcolor",
        2,      0,      (addr)setfillpattern,   "setfillpattern",
        2,      0,      (addr)setfillstyle,     "setfillstyle",
        1,      1,      (addr)setgraphbufsize,  "setgraphbufsize",
        1,      0,      (addr)setgraphmode,     "setgraphmode",
        3,      0,      (addr)setlinestyle,     "setlinestyle",
        2,      0,      (addr)setpalette,       "setpalette",
        4,      0,      (addr)setrgbpalette,    "setrgbpalette",
        2,      0,      (addr)settextjustify,   "settextjustify",
        3,      0,      (addr)settextstyle,     "settextstyle",
        4,      0,      (addr)setusercharsize,  "setusercharsize",
        5,      0,      (addr)setviewport,      "setviewport",
        1,      0,      (addr)setvisualpage,    "setvisualpage",
        1,      0,      (addr)setwritemode,     "setwritemode",
        1,      1,      (addr)textheight,       "textheight",
        1,      1,      (addr)textwidth,        "textwidth",
        // **** graphics drivers ****//
        1,      1,      (addr)registerbgidriver,"registerbgidriver",
        1,      1,      (addr)registerbgifont,  "registerbgifont",      END ))
    #if BGI_REGISTER_DRIVERS
    if (register_funcs(
	// !!   These "functions" are NOT user-callable,               !! //
	// !! they are there just so you can link in drivers and fonts !! //
	0,      0,      (addr)CGA_driver,       "CGA_driver",
	0,      0,      (addr)EGAVGA_driver,    "EGAVGA_driver",
	0,      0,      (addr)IBM8514_driver,   "IBM8514_driver",
	0,      0,      (addr)Herc_driver,      "Herc_driver",
	0,      0,      (addr)ATT_driver,       "ATT_driver",
	0,      0,      (addr)PC3270_driver,    "PC3270_driver",	END ))
    #endif
    #if BGI_REGISTER_FONTS
    if (register_funcs(
	0,      0,      (addr)triplex_font,     "triplex_font",
	0,      0,      (addr)small_font,       "small_font",
	0,      0,      (addr)sansserif_font,   "sansserif_font",
	0,      0,      (addr)gothic_font,      "gothic_font",          END ))
   #endif
#endif // CF_LINKBGI

    /* ---------------------------------------------------------------- */
    {
       return (1==1);
    }

  return (1==0);
}

