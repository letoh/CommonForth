/*
 *   Common Forth 386 and C(++) Library Functions Interface
 *
 *						    Version 2.4
 *						    Written by  : Luke Lee
 *						    	 update : 12/01/'95
 *						    	 update : 01/02/'96
 *						    	 update : 01/06/'96
 *						         update : 03/14/'96
 *						    Last update : 11/06/'96
 */

// 12/01 : redefine fnumber with a strict syntax check (finite state machine)

#include "invokec.h"

/** ANSI C standard library **/

#include <math.h>
#include <stdarg.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdio.h>
#include <setjmp.h>
#include <stddef.h>
#include <string.h>
#include <locale.h>
#include <signal.h>
#include <time.h>

/* many useful constants */
#include <float.h>
#include <limits.h>
#include <errno.h>

/** End ANSI C standard library **/

/* Debugging tools */

void dbgmsg(char *format,...) {
 #if DEBUG
    va_list argptr;

      va_start(argptr,format);
      fflush(stdout);
      vprintf(format,argptr);
      fflush(stdout);
      va_end(argptr);
 #endif
}


/**************************************\
 *       C and FORTH interface        *
\**************************************/

void break_mark(void) {
  // A NULL function for debuggers, such as PHARLAP DXDEBUG.
}

/* Note that this function will be patched after FLOAD INVOKEC.4TH */
void forth_pause(void) {                                // 11/06/'96
   return;        /* in case not patched yet */
   forth_pause(); /* will be patched later */
   return;
}

#if DEBUG
int pause_test_count = 0;                               // 11/06/'96
/* this function should be tested in a background task */
void pause_test(void) {
    for (int i=0;i<0x7FFFFFFF;i++) {
       forth_pause();
       pause_test_count++;
    }
}
int pause_count(void) { 
   return pause_test_count;
}
#endif

char *linking_forth;
int   curr_buf_size, chars_count;

// Finite state machine for recognizing valid floating point string :
// [+|-] { 0-9 } [.] { 0-9 } [E|e] [+|-] { 0-9 }

#define is_dot( c )	 ( (c)=='.' )
#define is_P_N( c )	 ( ((c)=='-') || ((c)=='+') )
#define is_Ee( c )	 ( (toupper(c))=='E' )
#define is_END( c )	 ( (c)=='\0' )

char *cstr0;
int cstr0len, *DPL;

int state_init( char* );
int state_P_Na( char* );
int state_0_9a( char* );
int state_dot ( char* );
int state_0_9b( char* );
int state_E   ( char* );
int state_P_Nb( char* );
int state_0_9c( char* );

int state_init( char *chptr ) {
//   dbgmsg( "<state_init>" );
    if      ( isdigit(*chptr) )
       { return state_0_9a( ++chptr ); }
    else if ( is_P_N(*chptr) )
       { return state_P_Na( ++chptr ); }
    else if ( is_dot(*chptr) )
       { return state_dot( ++chptr ); }
    else 
       { return 0; }
}

int state_P_Na( char *chptr ) {
//   dbgmsg( "<state_P_Na>" );
    if      ( isdigit(*chptr) )
       { return state_0_9a( ++chptr ); }
    else if ( is_dot(*chptr) )
       { return state_dot( ++chptr ); }
    else
       { return 0; }
}

int state_0_9a( char *chptr ) {
  loop_0_9a :
//   dbgmsg( "<state_0_9a>" );
    if      ( isdigit(*chptr) )
       { ++chptr; goto loop_0_9a; }
    else if ( is_dot(*chptr) )
       { return state_dot( ++chptr ); }
    else if ( is_Ee(*chptr) )
       { return state_E( ++chptr ); }
    else if ( is_END(*chptr) )
       { return 1; }
    else 
       { return 0; }
}

int state_dot( char *chptr ) {
//   dbgmsg( "<state_dot>" );
    *DPL = cstr0len - (int)(chptr-cstr0);  // Compute DPL position
    if      ( is_Ee(*chptr) )
       { return state_E( ++chptr ); }
    else if ( isdigit(*chptr) )
       { return state_0_9b( ++chptr ); }
    else if ( is_END(*chptr) )
       { return 1; }
    else
       { return 0; }
}

int state_0_9b( char *chptr ) {
  loop_0_9b :
//   dbgmsg( "<state_0_9b>" );
    if      ( isdigit(*chptr) )
       { ++chptr; goto loop_0_9b; }
    else if ( is_Ee(*chptr) )
       { return state_E( ++chptr ); }
    else if ( is_END(*chptr) )
       { return 1; }
    else 
       { return 0; }
}

int state_E( char *chptr ) {
//   dbgmsg( "<state_E>" );
    if      ( isdigit(*chptr) )
       { return state_0_9c( ++chptr ); }
    else if ( is_P_N(*chptr) )
       { return state_P_Nb( ++chptr ); }
    else  
       { return 0; }
}

int state_P_Nb( char *chptr ) {
//   dbgmsg( "<state_P_Nb>" );
    if      ( isdigit(*chptr) )
       { return state_0_9c( ++chptr ); }
    else
       { return 0; }
}

int state_0_9c( char *chptr ) {
  loop_0_9c :
//   dbgmsg( "<state_0_9c>" );
    if      ( isdigit(*chptr) ) 
       { ++chptr; goto loop_0_9c; }
    else if ( is_END(*chptr) )
       { return 1; }
    else
       { return 0; }
}

double fnumber( char * cstr, int *dpl ) {
  // cstr is an counted ASCIIZ string.
  #define cstr_len (cstr[0])

    DPL = dpl ,  *DPL = 0;
    cstr0 = cstr+1,  cstr0len = cstr_len;

    if ( state_init(cstr0) )
       { return atof( cstr0 ); }
    else
       { *DPL = -1; return 0.0; }  /* 03/14/'96  add '*DPL = -1'  */

  #undef cstr_len
}

double itof( int i )	{ 	return (double)i;	}
int    ftoi( double f ) {	return (long)f;		}

int    fzgt( double f ) {	return f >  0.0;	}
int    fzge( double f ) {	return f >= 0.0;	}
int    fzle( double f ) {	return f <= 0.0;	}
int    fzlt( double f ) {	return f <  0.0;	}

double fneg( double f ) {	return -f;		}

int    fgt( double f1, double f2 ) { 	return	f1 >  f2;	}
int    fge( double f1, double f2 ) {	return	f1 >= f2;	}
int    fle( double f1, double f2 ) {	return  f1 <= f2;	}
int    flt( double f1, double f2 ) {	return  f1 <  f2;	}	

double fadd( double f1, double f2 ) {	return  f1 + f2;    	}
double fsub( double f1, double f2 ) {	return  f1 - f2;	}
double fmul( double f1, double f2 ) {	return  f1 * f2;    	}
double fdiv( double f1, double f2 ) {	return  f1 / f2;	}
double fsubr( double f1, double f2 ) {	return  f2 - f1;    	}
double fdivr( double f1, double f2 ) {	return  f2 / f1;    	}

/****  interpret FORTH from C functions ****/

static forth_interpreter_t *forth_interpreter=NULL; 
                                             // setup by establish_linkage()
                                             // and reconnect_linkage()

int forth_interpret( char* forth, int length ) {
    return (*forth_interpreter)(forth,length);
}

#ifndef MINIMAL

/****  <stdio.h> support  *****/

addr _stdin(void)   		{  return (addr)stdin;  }
addr _stdout(void)  		{  return (addr)stdout; }
addr _stderr(void)  		{  return (addr)stderr; }

int _getc(FILE *f)		{  return getc(f);     }
int _putc(int c,FILE *f)	{  return putc(c,f);   }
int _getchar(void)		{  return getchar();   }
int _putchar(int c)		{  return putchar(c);  }

int  _ferror(FILE *f)		{  return ferror(f);	}
int  _feof(FILE *f)		{  return feof(f);	}
void _clearerr(FILE *f)		{  clearerr(f);		}
int  _fgetpos(FILE *f,fpos_t *p) { return fgetpos(f,p); }
int  _fsetpos(FILE *f,fpos_t *p) { return fsetpos(f,p); }

/****  <ctype.h> support  ****/

int _isalnum(int c)	{  return isalnum(c);	}
int _isalpha(int c)	{  return isalpha(c);	}
int _iscntrl(int c)	{  return iscntrl(c);	}
int _isdigit(int c)	{  return isdigit(c);	}
int _isgraph(int c)	{  return isgraph(c);	}
int _islower(int c)	{  return islower(c);	}
int _isprint(int c)	{  return isprint(c);	}
int _ispunct(int c)	{  return ispunct(c);	}
int _isspace(int c)	{  return isspace(c);	}
int _isupper(int c)	{  return isupper(c);	}
int _isxdigit(int c)	{  return isxdigit(c);	}
int _tolower(int c)	{  return tolower(c);	}
int _toupper(int c)	{  return toupper(c);	}

/****  <errno.h> support  ****/
int  _errno()           {  return errno;        }

/****  <time.h> support ****/
int __sizeof_tm()	{ return sizeof(struct tm); }

#endif /* MINIMAL */

/****************************************************************\
 *  Function  : register_funcs					*
\****************************************************************/

int register_funcs( int in1, int out1, addr func1, char* funcname1, ... ) 
{
  va_list fnp;
  int     currfn,currin,currout;
  char*   currfname;

    va_start( fnp,funcname1 );

    currin = in1; currout = out1; currfn = func1; currfname = funcname1;

    while (currin != END) {

      if ( (chars_count+256) > curr_buf_size ) {
	 curr_buf_size += 512;
	 if ( (linking_forth = (char*)realloc(linking_forth,curr_buf_size))
	      ==NULL )
	    return 0;

     #if DEBUG
	 else {
	    printf( "***************************************************\n\r" );
	    printf( "** reallocating linking_forth buffer successful. **\n\r" );
	    printf( "***************************************************\n\r" );
            printf( "* (curr_buf_size,chars_count) = (%d,%d)\n\r",
	       		curr_buf_size, chars_count );
	 }
     #endif

      }
      chars_count += sprintf( linking_forth+chars_count,
			 "$%X $%X $%X C: %s\n", // "in out adr C: fnname"
			 currin, currout, currfn, currfname );

     #if DEBUG
      printf( "* (curr_buf_size,chars_count) = (%d,%d)\n\r",
	       curr_buf_size, chars_count );
      printf( "$%X $%X $%X  C:  %s\n\r", currin, currout, currfn, currfname );
     #endif

      currin    = va_arg( fnp,int );
      if (currin != END) {
	 currout   = va_arg( fnp,int );
	 currfn    = va_arg( fnp,addr );
	 currfname = va_arg( fnp,char* );
      }
    } // while 

  #if DEBUG
    printf( "* (curr_buf_size,chars_count) = (%d,%d)\n\r",
	     curr_buf_size, chars_count );
  #endif	

  return 1;
} /*  register_funcs  */

/****************************************************************\
 *  Function  : reconnect_linkage				*
\****************************************************************/

void reconnect_linkage( forth_interpreter_t *interpreter ) {
   // This function is used for turnkey systems which had already
   // built its linkage, but lost some variable after reboot
   forth_interpreter = interpreter;
}

/****************************************************************\
 *  Function  : establish_linkage				*
\****************************************************************/

int establish_linkage( int * string_length, 
		       forth_interpreter_t *interpreter ) {
 /* Establish linkage between C(++) and FORTH . */

    forth_interpreter = interpreter;
    linking_forth = (char*)malloc(curr_buf_size = 512);
    chars_count   = 0;

    /*      #in     #out           fn addr             fn name
       ---------------------------------------------------------------- */
    if (register_funcs(	   /*****  minimal linking set  *****/
             1,      0,         (addr)&reconnect_linkage,"reconnect_linkage",
             0,      0,         (addr)&break_mark,      "break_mark",
             0,      0,         (addr)&forth_pause,     "forth_pause",
          #if DEBUG
             0,      0,         (addr)&pause_test,      "pause_test",
             0,      1,         (addr)&pause_count,     "pause_count",
          #endif
	     2,	     DOUBLE,	(addr)&fnumber,		"fnumber",	
	     1,	     DOUBLE,	(addr)&itof,		"itof",
	     2,	     1,		(addr)&ftoi,		"ftoi",	
	     2,	     1,		(addr)&fzgt,		"f0>",
	     2,	     1,		(addr)&fzge,		"f0>=",
	     2,	     1,		(addr)&fzle,		"f0<=",
	     2,	     1,		(addr)&fzlt,		"f0<",
	     2,	     DOUBLE,	(addr)&fneg,		"fneg",		
	     4,	     1,		(addr)&fgt,		"f>",
	     4,	     1,		(addr)&fge,		"f>=",
	     4,	     1,		(addr)&fle,		"f<=",
	     4,	     1,		(addr)&flt,		"f<",
	     4,	     DOUBLE,	(addr)&fadd,		"f+",
	     4,	     DOUBLE,	(addr)&fsub,		"f-",	
	     4,	     DOUBLE,	(addr)&fsubr,		"rf-",
	     4,	     DOUBLE,	(addr)&fmul,		"f*",
	     4,	     DOUBLE,	(addr)&fdiv,		"f/",		
	     4,	     DOUBLE,	(addr)&fdivr,		"rf/",	 END ))
    /* ---------------------------------------------------------------- */

  #ifndef  MINIMAL

    if (register_funcs(    /***** <stdio.h> *****/
             0,      1,         (addr)&_stdin,          "stdin",
             0,      1,         (addr)&_stdout,         "stdout",
             0,      1,         (addr)&_stderr,         "stderr",

             2,      1,         (addr)&fopen,           "fopen",
             3,      1,         (addr)&freopen,         "freopen",
             1,      1,         (addr)&fflush,          "fflush",
             1,      1,         (addr)&fclose,          "fclose",

             1,      1,         (addr)&remove,          "remove",
	     2,	     1,		(addr)&rename,		"rename",
             0,      1,         (addr)&tmpfile,         "tmpfile",
	     1,	     1,         (addr)&tmpnam,		"tmpnam",

             4,      1,         (addr)&setvbuf,         "setvbuf",
             2,      0,         (addr)&setbuf,          "setbuf",  END ))
    if (register_funcs(    /*  <stdio.h> continue  */
          UNKNOWN,   1,         (addr)&fprintf,         "fprintf",
          UNKNOWN,   1,         (addr)&printf,          "printf",
          UNKNOWN,   1,         (addr)&sprintf,         "sprintf", 
             2,      1,         (addr)&vprintf,         "vprintf",
             3,      1,         (addr)&vfprintf,        "vfprintf",
             3,      1,         (addr)&vsprintf,        "vsprintf",             

          UNKNOWN,   1,         (addr)&fscanf,          "fscanf",
          UNKNOWN,   1,         (addr)&scanf,           "scanf",
          UNKNOWN,   1,         (addr)&sscanf,          "sscanf",  END ))
    if (register_funcs(    /*  <stdio.h> continue  */
	     1,      1,		(addr)&fgetc,		"fgetc",
             3,      1,         (addr)&fgets,           "fgets",
	     2,	     1,		(addr)&fputc,		"fputc",	
             2,      1,         (addr)&fputs,           "fputs",
	     1,	     1,         (addr)&_getc,		"getc",
	     0,	     1,		(addr)&_getchar,	"getchar",
             1,      1,         (addr)&gets,            "gets", 
	     2,	     1,         (addr)&_putc,		"putc",
	     1,      1,  	(addr)&_putchar,	"putchar",
             1,      1,         (addr)&puts,            "puts",
             2,      1,         (addr)&ungetc,          "ungetc",  END ))
    if (register_funcs(    /*  <stdio.h> continue  */
             4,      1,         (addr)&fread,           "fread",
             4,      1,         (addr)&fwrite,          "fwrite",
             3,      1,         (addr)&fseek,           "fseek",
             1,      1,         (addr)&ftell,           "ftell",
             1,      0,         (addr)&rewind,          "rewind",
	     2,	     1,		(addr)&_fgetpos,	"fgetpos",
	     2,	     1,		(addr)&_fsetpos,	"fsetpos",

	     1,	     0,		(addr)&_clearerr,	"clearerr",
             1,      1,         (addr)&_feof,           "feof",
             1,      1,         (addr)&_ferror,         "ferror",
             1,      0,         (addr)&perror,          "perror",  END ))
    /* ---------------------------------------------------------------- */
    if (register_funcs(	   /***** <ctype.h> *****/
    	     1,	     1,		(addr)&_isalnum,	"isalnum",
    	     1,	     1,		(addr)&_isalpha,	"isalpha",
    	     1,	     1,		(addr)&_iscntrl,	"iscntrl",
	     1,	     1,		(addr)&_isdigit,	"isdigit",
	     1,	     1,		(addr)&_isgraph,	"isgraph",
	     1,	     1,		(addr)&_islower,	"islower",
	     1,      1,		(addr)&_isprint,	"isprint",
	     1,      1,		(addr)&_ispunct,	"ispunct",
	     1,      1,         (addr)&_isspace,	"isspace",
	     1,	     1,		(addr)&_isupper,	"isupper",
	     1,	     1,		(addr)&_isxdigit,	"isxdigit",
    	     1,	     1,		(addr)&_tolower,	"tolower",
    	     1,	     1,		(addr)&_toupper,	"toupper", END  ))
    /* ---------------------------------------------------------------- */
    if (register_funcs(	   /*****  <string.h>  *****/
    	     2,	     1,		(addr)&strcpy,		"strcpy",
	     3,	     1,		(addr)&strncpy,		"strncpy",
	     2,      1,		(addr)&strcat,		"strcat",
	     3,      1,		(addr)&strncat,		"strncat",
	     2,	     1,		(addr)&strcmp,		"strcmp",
	     3,	     1,		(addr)&strncmp,		"strncmp",
	     2,	     1,		(addr)&strchr,		"strchr",
	     2,	     1,		(addr)&strrchr,		"strrchr",
	     2,	     1,		(addr)&strspn,		"strspn",
	     2,	     1,		(addr)&strcspn,		"strcspn",
	     2,	     1,		(addr)&strpbrk,		"strpbrk",
	     2,	     1,		(addr)&strstr,		"strstr",
	     1,	     1,		(addr)&strlen,		"strlen",
	     1,	     1,		(addr)&strerror,	"strerror",
	     2,	     1,		(addr)&strtok,		"strtok",  
	     3,	     1,		(addr)&memcpy,		"memcpy",
	     3,	     1,		(addr)&memmove,		"memmove",
	     3,	     1,		(addr)&memcmp,		"memcmp",
	     3,	     1,		(addr)&memchr,		"memchr",
	     3,	     1,		(addr)&memset,		"memset",  END ))
    /* ---------------------------------------------------------------- */
    if (register_funcs(    /***** <math.h> *****/
             2,      DOUBLE,    (addr)&sin,             "sin",
             2,      DOUBLE,    (addr)&cos,             "cos",
             2,      DOUBLE,    (addr)&tan,             "tan",
             2,      DOUBLE,    (addr)&asin,            "asin",
             2,      DOUBLE,    (addr)&acos,            "acos",
             2,      DOUBLE,    (addr)&atan,            "atan",
             4,      DOUBLE,    (addr)&atan2,            "atan2",
             2,      DOUBLE,    (addr)&sinh,            "sinh",
             2,      DOUBLE,    (addr)&cosh,            "cosh",
             2,      DOUBLE,    (addr)&tanh,            "tanh", 
             2,      DOUBLE,    (addr)&exp,             "exp",
             2,      DOUBLE,    (addr)&log,             "log",
             2,      DOUBLE,    (addr)&log10,           "log10",
             2,      DOUBLE,    (addr)&log2,            "log2",
             4,      DOUBLE,    (addr)&pow,             "pow",
             2,      DOUBLE,    (addr)&sqrt,            "sqrt",
             2,      DOUBLE,    (addr)&ceil,            "ceil",
             2,      DOUBLE,    (addr)&floor,           "floor",
             2,      DOUBLE,    (addr)&fabs,            "fabs",
	     3,	     DOUBLE,	(addr)&ldexp,		"ldexp",
	     3,	     DOUBLE,	(addr)&frexp,		"frexp",
	     3,	     DOUBLE,	(addr)&modf,		"modf",
             4,      DOUBLE,    (addr)&fmod,            "fmod",   END ))
    /* ---------------------------------------------------------------- */
    if (register_funcs(	  /*****  <stdlib.h>  *****/
             1,      DOUBLE,    (addr)&atof,            "atof",
             1,      1,         (addr)&atoi,            "atoi",
	     1,	     1,		(addr)&atol,		"atol",
             2,      DOUBLE,    (addr)&strtod,          "strtod",
	     3,	     1,		(addr)&strtol,		"strtol",
	     3,	     1,		(addr)&strtoul,		"strtoul",
	     0,	     1,		(addr)&rand,		"rand",
	     1,	     0,		(addr)&srand,		"srand",
	     2,	     1,		(addr)&calloc,		"calloc",
	     1,	     1,		(addr)&malloc,		"malloc",	
             2,      1,         (addr)&realloc,         "realloc",
             1,      0,         (addr)&free,            "free",
	     0,	     0,		(addr)&abort,		"abort",
// 	     1,	     0,		(addr)&exit,		"exit",
	     1,	     1,		(addr)&atexit,		"atexit",
             1,      1,         (addr)&system,          "system",
             1,      1,         (addr)&getenv,          "getenv",
	     5,	     1,		(addr)&bsearch,		"bsearch",
	     4,	     0,		(addr)&qsort,		"qsort",
	     1,	     1,		(addr)&abs,		"abs",
	     1,	     1,		(addr)&labs,		"labs",	  END ))
    /* ---------------------------------------------------------------- */
    if (register_funcs(	   /*****  <signal.h>  *****/
    	     2,	     1,		(addr)&signal,		"signal",
//    	     1,	     1,		(addr)&raise,		"raise",  
	     								END ))
    /* ---------------------------------------------------------------- */
    if (register_funcs(	   /*****  <time.h>  *****/
             0,      1,         (addr)&clock,           "clock",
             1,      1,         (addr)&time,            "time",
	     2,	     DOUBLE,	(addr)&difftime,	"difftime",
	     1,	     1,		(addr)&mktime,		"mktime",
	     1,	     1,		(addr)&asctime,		"asctime",
	     1,	     1,		(addr)&ctime,		"ctime",
	     1,	     1,		(addr)&gmtime,		"gmtime",
	     1,	     1,		(addr)&localtime,	"localtime",
	     4,	     1,		(addr)&strftime,	"strftime", 
	     0,	     1,		(addr)&__sizeof_tm,     "__sizeof_tm", END ))
    /* ---------------------------------------------------------------- */
    if (register_funcs(    /*****  <errno.h>  *****/
             0,      1,         (addr)&_errno,          "errno",   END ))
    /* ---------------------------------------------------------------- */
    if (register_funcs(
             2,      1,   (addr)&forth_interpret, "forth_interpret",   END ))
    /* ---------------------------------------------------------------- */
    if ( register_extended_funcs() )
    /* ---------------------------------------------------------------- */

 #endif  /* end #ifdef MINIMAL */

    {
      #if DEBUG
        printf( " string_length's address = %d" , (unsigned)string_length );
	fflush( stdout );
      #endif
       (*string_length) = chars_count;
       return (int)linking_forth;
    }

  return 0;
} /* establish_linkage */


/****************************************************************\
 *  Function  : end_linkage   					*
\****************************************************************/

void end_linkage() 
{
    free(linking_forth);
} 

