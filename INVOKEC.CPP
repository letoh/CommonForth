/*
 *   Common Forth 386 and C(++) Library Functions Interface
 *
 *                                                  Version 2.3
 *                                                  Written by  : Luke Lee
 *                                                  	 update : 12/22/'95
 *                                                  	 update : 01/02/'96
 *                                                  	 update : 01/06/'96
 *                                                  Last update : 03/14/'96
 */

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

  void dbgmsg(char *format,...)
  {
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
 *       FORTH and C interface        *
\**************************************/

void break_mark(void) {
  // A NULL function for debuggers, such as PHARLAP DXDEBUG.
}

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
    if      ( isdigit(*chptr) )
       { return state_0_9a( ++chptr ); }
    else if ( is_dot(*chptr) )
       { return state_dot( ++chptr ); }
    else
       { return 0; }
}

int state_0_9a( char *chptr ) {
  loop_0_9a :
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
    if      ( isdigit(*chptr) )
       { return state_0_9c( ++chptr ); }
    else if ( is_P_N(*chptr) )
       { return state_P_Nb( ++chptr ); }
    else  
       { return 0; }
}

int state_P_Nb( char *chptr ) {
    if      ( isdigit(*chptr) )
       { return state_0_9c( ++chptr ); }
    else
       { return 0; }
}

int state_0_9c( char *chptr ) {
  loop_0_9c :
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

double itof( int i )    {       return (double)i;       }
int    ftoi( double f ) {       return (long)f;         }

int    fzgt( double f ) {       return f >  0.0;        }
int    fzge( double f ) {       return f >= 0.0;        }
int    fzle( double f ) {       return f <= 0.0;        }
int    fzlt( double f ) {       return f <  0.0;        }

double fneg( double f ) {       return -f;              }
double fabs( double f ) {	return (f<0.0) ? (-f) : f;  	}

int    fgt( double f1, double f2 ) {    return  f1 >  f2;       }
int    fge( double f1, double f2 ) {    return  f1 >= f2;       }
int    fle( double f1, double f2 ) {    return  f1 <= f2;       }
int    flt( double f1, double f2 ) {    return  f1 <  f2;       }       

double fadd( double f1, double f2 ) {   return  f1 + f2;        }
double fsub( double f1, double f2 ) {   return  f1 - f2;        }
double fmul( double f1, double f2 ) {   return  f1 * f2;        }
double fdiv( double f1, double f2 ) {   return  f1 / f2;        }
double fsubr( double f1, double f2 ) {  return  f2 - f1;        }
double fdivr( double f1, double f2 ) {  return  f2 / f1;        }

/****  interpret FORTH from C functions ****/

forth_interpreter_t *forth_interpreter;	// setup by establish_linkage()

int forth_interpret( char* forth, int length ) {
    return (*forth_interpreter)(forth,length);
}

#ifndef MINIMAL 

/****   <stdio.h> support  *****/
addr _stdin()   {  return (addr)stdin;  }
addr _stdout()  {  return (addr)stdout; }
addr _stderr()  {  return (addr)stderr; }

/*  <errno.h> support */
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
         curr_buf_size += 1024;
         if ( (linking_forth = (char*)realloc(linking_forth,curr_buf_size))
              ==NULL ) {
            fprintf( stderr, " * register_funcs : out of memory .\n" );
            fflush( stderr );
            return 0;
         }

     #if DEBUG
         else {
            printf( "***************************************************\n" );
            printf( "** reallocating linking_forth buffer successful. **\n" );
            printf( "***************************************************\n" );
            printf( "* (curr_buf_size,chars_count) = (%d,%d)\n",
                        curr_buf_size, chars_count );
         }
     #endif

      }
      chars_count += sprintf( linking_forth+chars_count,
                         "$%X $%X $%X C: %s\n", // "in out adr C: fnname"
                         currin, currout, currfn, currfname );

     #if DEBUG
      printf( "* (curr_buf_size,chars_count) = (%d,%d)\n",
               curr_buf_size, chars_count );
      printf( "$%X $%X $%X  C:  %s\n", currin, currout, currfn, currfname );
     #endif

      currin    = va_arg( fnp,int );
      if (currin != END) {
         currout   = va_arg( fnp,int );
         currfn    = va_arg( fnp,addr );
         currfname = va_arg( fnp,char* );
      }
    } // while 

  #if DEBUG
    printf( "* (curr_buf_size,chars_count) = (%d,%d)\n",
             curr_buf_size, chars_count );
    fflush( stdout );
  #endif        

  return 1;
} // register_funcs


/****************************************************************\
 *  Function  : establish_linkage				*
\****************************************************************/

int establish_linkage( int * string_length, 
		       forth_interpreter_t *interpreter ) {
 /* Establish linkage between C(++) and FORTH . */

    forth_interpreter = interpreter;
    linking_forth = (char*)malloc(curr_buf_size = 1024);
    chars_count   = 0;

    /*      #in     #out           fn addr             fn name
       ---------------------------------------------------------------- */
    if (register_funcs(    /* minimal linking set */
             0,      0,         (addr)&break_mark,      "break_mark",
             2,      DOUBLE,    (addr)&fnumber,         "fnumber",      
             1,      DOUBLE,    (addr)&itof,            "itof",
             2,      1,         (addr)&ftoi,            "ftoi", 
             2,      1,         (addr)&fzgt,            "f0>",
             2,      1,         (addr)&fzge,            "f0>=",
             2,      1,         (addr)&fzle,            "f0<=",
             2,      1,         (addr)&fzlt,            "f0<",
             2,      DOUBLE,    (addr)&fneg,            "fneg",         
             4,      1,         (addr)&fgt,             "f>",
             4,      1,         (addr)&fge,             "f>=",
             4,      1,         (addr)&fle,             "f<=",
             4,      1,         (addr)&flt,             "f<",
             4,      DOUBLE,    (addr)&fadd,            "f+",
             4,      DOUBLE,    (addr)&fsub,            "f-",   
             4,      DOUBLE,    (addr)&fsubr,           "rf-",
             4,      DOUBLE,    (addr)&fmul,            "f*",
             4,      DOUBLE,    (addr)&fdiv,            "f/",           
             4,      DOUBLE,    (addr)&fdivr,           "rf/", END  ))
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
	     1,	     1,         (addr)&getc,		"getc",
	     0,	     1,		(addr)&getchar,		"getchar",
             1,      1,         (addr)&gets,            "gets", 
	     2,	     1,         (addr)&putc,		"putc",
	     1,      1,  	(addr)&putchar,		"putchar",
             1,      1,         (addr)&puts,            "puts",
             2,      1,         (addr)&ungetc,          "ungetc",  END ))
    if (register_funcs(    /*  <stdio.h> continue  */
             4,      1,         (addr)&fread,           "fread",
             4,      1,         (addr)&fwrite,          "fwrite",
             3,      1,         (addr)&fseek,           "fseek",
             1,      1,         (addr)&ftell,           "ftell",
             1,      0,         (addr)&rewind,          "rewind",
	     2,	     1,		(addr)&fgetpos,		"fgetpos",
	     2,	     1,		(addr)&fsetpos,		"fsetpos",

	     1,	     0,		(addr)&clearerr,	"clearerr",
             1,      1,         (addr)&feof,            "feof",
             1,      1,         (addr)&ferror,          "ferror",
             1,      0,         (addr)&perror,          "perror",  END ))
    /* ---------------------------------------------------------------- */
    if (register_funcs(	   /***** <ctype.h> *****/
    	     1,	     1,		(addr)&isalnum,		"isalnum",
    	     1,	     1,		(addr)&isalpha,		"isalpha",
    	     1,	     1,		(addr)&iscntrl,		"iscntrl",
	     1,	     1,		(addr)&isdigit,		"isdigit",
	     1,	     1,		(addr)&isgraph,		"isgraph",
	     1,	     1,		(addr)&islower,		"islower",
	     1,      1,		(addr)&isprint,		"isprint",
	     1,      1,		(addr)&ispunct,		"ispunct",
	     1,      1,         (addr)&isspace,		"isspace",
	     1,	     1,		(addr)&isupper,		"isupper",
	     1,	     1,		(addr)&isxdigit,	"isxdigit",
    	     1,	     1,		(addr)&tolower,		"tolower",
    	     1,	     1,		(addr)&toupper,		"toupper", END  ))
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
    	     1,	     1,		(addr)&raise,		"raise",  END ))
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