/*
 *   Common Forth 386 and C(++) Library Functions Interface
 *
 *                                                  Version 1.8
 *                                                  Written by  : Luke Lee
 *                                                       update : 07/15/'96
 *                                                  Last update : 11/15/'96
 */

// 11/15/'96 : add forth_pause() function from CF for DJGPP v1

#ifndef _invoke_c_header_
#define _invoke_c_header_


#define DEBUG   0

#define END		-1
#define UNKNOWN		0xFF00
#define FLOATING	0xF000
#define FLOAT		FLOATING+1
#define DOUBLE		FLOATING+2

typedef unsigned addr;
typedef int forth_interpreter_t( char *, int );

int register_funcs( int in1, int out1, addr func1, char* funcname1, ... );
extern int register_extended_funcs( void );	/* defined in extended.cc */
int forth_interpret( char *forth_words, int forth_words_length );
void forth_pause(void);  /* PAUSE in C, works only after FLOAD INVOKEC.4TH */

// int stack_call_forth( unsigned int data_stack[],  
//		      unsigned int *stack_pointer,
//		      char *forth_words,
//		      int  forth_words_length ); // not implemented yet

void end_linkage();
int  establish_linkage( int * string_length, 
		        forth_interpreter_t *interpreter );

/* Debugging tools */

void dbgmsg(char *format,...);

#endif	/* _invoke_c_header_ */

