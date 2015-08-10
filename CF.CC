/*
 *   Common Forth Loader                      Version 2.8
 *					       01/29/'96
 *                                  Written in GNU C++ for PC (DJGPP)
 *                                          Author : Luke Lee
 */

#include <std.h>
#include <stdlib.h>
#include <stdio.h>
#include <go32.h>

#include "bind.h"
#include "invokec.h"

#define PAGE_ALIGNMENT  ((unsigned)0xFFFFFFFF-4095)

/* Error codes */

#define NOT_ENOUGH_MEMORY       1
#define FAIL_OPENNING_FILE      2
#define FAIL_READING_FILE       3
#define FAIL_WRITING_FILE       4
#define SYSTEM_INCONSISTENT     5

/*
 * Associate Files and Turnkey System 
 */

unsigned int turnkey_mark[2] = { LUKECF,BINDCF };
char *image_name    = "CF.IMG      ";
char *head_name     = "CF.HED      ";

typedef int CommonForthV16x();

struct loader_environ {
   addr argc;		// setup by cf.cc
   addr argv;		// setup by cf.cc
   addr envp;		// setup by cf.cc
   addr cxxlinking;	// setup by cf.cc
   addr cxxendlinking;	// setup by cf.cc
   addr cxxfarpatch;	// setup by cf.cc
   struct register_pair_386 {
      unsigned int eax;
      unsigned int ebx;
      unsigned int ecx;
      unsigned int edx;
      unsigned int esi;
      unsigned int edi;
      unsigned int ebp;
      unsigned int esp;
      unsigned int cs;	// setup by cf.cc
      unsigned int ds;  // setup by cf.cc
      unsigned int es;	// setup by cf.cc
      unsigned int ss;	// setup by cf.cc
      unsigned int fs;
      unsigned int gs;
   } original_registers;
   char loadinginfo[256];
} init_environ;

struct system_file_header {
   unsigned int loader_env_address;
   unsigned int code_space_address;
   unsigned int user_space_address;
   unsigned int code_space_size;
   unsigned int user_space_size;
   unsigned int dstack_address;
   unsigned int dstack_size;
   unsigned int rstack_address;
   unsigned int rstack_size;
} system_image_header;

struct head_file_header {
   unsigned int head_space_address;
   unsigned int head_space_size;
} head_image_header;

/* Error messages ... */

void error_reading(char *msg) {
    fprintf(stdout,"* Error reading %s file.\n",msg);
    fprintf(stdout,"  This might due to incorrect file contents.\n");
    exit(FAIL_READING_FILE);
}

void please_rebuild() {
    fprintf( stdout, "* System is now inconsistent,\n" );
    fprintf( stdout, "  please rebuild the whole system again.\n" );
}

// void no_operation() { } // no operation

/****************************************\
 *           Main  Program              *
\****************************************/

extern char CF_SYSTEM_SPACE;

int main(int argc,char** argv,char** envp)
{
  CommonForthV16x *RunCommonForth;
  char            *cfspace;
  FILE            *fptr;
  FILE            *imagef;
  unsigned 	  base_address;
  int 	   	  bytes,result,already_linked;
  int		  turnkey_size = 0;

   /*
    * Assign CF system space
    */

    cfspace = &CF_SYSTEM_SPACE;

    dbgmsg( "[ Address range : 0x%X ... 0x%X ]\n",
	 (unsigned)cfspace, (unsigned)cfspace+0x400000L );
    RunCommonForth = (CommonForthV16x*) cfspace;

   /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
    *  		Start Loading Common Forth 1.6x				  *
   \* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

   /* 0. open system image file */
    if ( (turnkey_mark[0]==LUKECF) && (turnkey_mark[1]==BINDCF) ) {
       if ( (imagef = fopen(image_name,"rb")) == NULL ) {
         fprintf(stdout,"Fail openning system image file %s.\n",image_name);
         exit( FAIL_OPENNING_FILE );
       }
    } else {
       turnkey_size = turnkey_mark[0];
       if ( (imagef = fopen(argv[0],"rb")) == NULL ) {
         fprintf(stdout,"Fail initializing system.\n");
	 exit( FAIL_OPENNING_FILE );
       } else {
	 fseek( imagef, turnkey_size, SEEK_SET );
       }
    }

   /* 1. read system image header */
    dbgmsg("* Loading system image...\n");

    dbgmsg("\nLoading image header %d bytes = ",sizeof(system_image_header));
    bytes = fread( (void*)&system_image_header, 1,
		   sizeof(system_image_header), imagef );
    dbgmsg("%d bytes read.\n",bytes);
    if (bytes != sizeof(system_image_header))
      error_reading( image_name );

    dbgmsg("loader_env_address=$%X\n",system_image_header.loader_env_address);
    dbgmsg("code_space_address=$%X\n",system_image_header.code_space_address);
    dbgmsg("user_space_address=$%X\n",system_image_header.user_space_address);
    dbgmsg("code_space_size=%d\n",system_image_header.code_space_size);
    dbgmsg("user_space_size=%d\n",system_image_header.user_space_size);
    dbgmsg("dstack_address=%d\n",system_image_header.dstack_address);
    dbgmsg("dstack_size=%d\n",system_image_header.dstack_size);
    dbgmsg("rstack_address=%d\n",system_image_header.rstack_address);
    dbgmsg("rstack_size=%d\n",system_image_header.rstack_size);

    if ( system_image_header.code_space_address != (unsigned)cfspace ) {
       please_rebuild();
       fclose( imagef );
       exit( SYSTEM_INCONSISTENT );
    }

   /* 2. load codes into code space */

    dbgmsg("Loading codes %d bytes ... ",system_image_header.code_space_size);
    bytes = fread( (void*)(system_image_header.code_space_address), 1,
		   system_image_header.code_space_size,imagef );
    dbgmsg("%d bytes read.\n",bytes);
    if (bytes != system_image_header.code_space_size)
       error_reading( image_name );

   /* 2.5 Check whether the FORTH/C linkage has been established or not */

    memcpy( &init_environ, (void*)(system_image_header.loader_env_address),
	    sizeof(init_environ) );
    already_linked = init_environ.cxxlinking;

   /* 3. set up loader environment space */

    memset( &init_environ, 0, sizeof(init_environ) );
    init_environ.argc = (unsigned)argc;
    init_environ.argv = (unsigned)argv;
    init_environ.envp = (unsigned)envp;
    memcpy( &(init_environ.loadinginfo), &_go32_info_block,
	    sizeof( Go32_Info_Block ) );
    init_environ.original_registers.cs = _go32_my_cs();
    init_environ.original_registers.ds = init_environ.original_registers.es 
    				       = _go32_my_ds();
    init_environ.original_registers.ss = _go32_my_ss();

   /* 3.5 Establishing linkage between C(++) and FORTH */

    init_environ.cxxfarpatch = (addr) -1; // not currentlly used
//    if (already_linked == 0) {
       init_environ.cxxlinking    = (unsigned)(void*)(&establish_linkage);
       init_environ.cxxendlinking = (unsigned)(void*)(&end_linkage);
//    }
//    else {
//       init_environ.cxxlinking    = (unsigned)(void*)(&no_operation);
//       init_environ.cxxendlinking = (unsigned)(void*)(&no_operation);
//    }

    while (*envp!=NULL) { dbgmsg("%s\n",*envp++); }
    dbgmsg("(argc,argv,envp)=(%X,%X,%X)\n",(unsigned)argc,(unsigned)argv,(unsigned)envp);

    memcpy( (void*)(system_image_header.loader_env_address),
	    &init_environ, sizeof(init_environ) );

   /* 4. load user area into user space */

    dbgmsg("Loading user area %d bytes ... ",system_image_header.user_space_size);
    bytes = fread( (void*)(system_image_header.user_space_address), 1,
		   system_image_header.user_space_size, imagef );
    dbgmsg("%d bytes read.\n",bytes);
    if (bytes != system_image_header.user_space_size)
       error_reading( image_name );

   /* 4.1. load data stack for multitasking's sake [08/28/'95] */

    bytes = fread( (void*)(system_image_header.dstack_address), 1,
		   system_image_header.dstack_size, imagef );
    if (bytes != system_image_header.dstack_size)
       error_reading( image_name );		

   /* 4.2 load return stack for multitasking's sake [08/28/'95] */

    bytes = fread( (void*)(system_image_header.rstack_address), 1,
		   system_image_header.rstack_size, imagef );
    if (bytes != system_image_header.rstack_size)
       error_reading( image_name );		

    dbgmsg("Finish loading system image.\n");
    fclose( imagef );

   /* 5. open head image file.
    *    If it does not exist, then it is a turnkey system.
    */

    if ( (imagef = fopen(head_name,"rb")) != NULL ) {

	dbgmsg("* Loading head image...\n");

	/* 6. reads head image header */

	dbgmsg("Loading head image header %d bytes ... ",sizeof(head_image_header));
	bytes = fread( (void*)&head_image_header, 1,
		       sizeof(head_image_header), imagef );
	dbgmsg("%d bytes read.\n",bytes);
	if (bytes != sizeof(head_image_header))
	   error_reading( head_name );

      /* 7. read heads into head space */

	dbgmsg("Loading headers %d bytes = ",head_image_header.head_space_size);
	bytes = fread( (void*)head_image_header.head_space_address, 1,
		       head_image_header.head_space_size, imagef );
	dbgmsg("%d bytes read.\n",bytes);
	if (bytes != head_image_header.head_space_size)
	   error_reading( head_name );

	dbgmsg("Finish loading headers.\n");
	fclose( imagef );
    }

    /* * * * * * * * * * * * * * * * * * * * * * *\
     *   Start executing Common Forth system	 *
    \* * * * * * * * * * * * * * * * * * * * * * */

    result = (*RunCommonForth)();

    printf("\nLeaving...\n");

  return result;
}

