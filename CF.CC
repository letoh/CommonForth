/*
 *   Common Forth Loader                      Version 3.0
 *                                             02/06/'97
 *                                  Written in GNU C++ for PC (DJGPP V2.01)
 *                                          Author : Luke Lee
 */

 // History :
 // ... not recorded.
 // 07/10 .. 07/11/'96 : v2.9
 //     Add transfer_buf, transfer_siz and dos_selector address info as
 //     loading info for Forth.
 // 02/06/'97 : v3.0
 //     Use dynamic memory allocation instead of using link script for 'ld'
 //     ,since the 'ld' behavior is no longer the same as DJ V1 and V2.00

#include <std.h>
#include <stdlib.h>
#include <stdio.h>
#include <go32.h>

#include "bind.h"
#include "invokec.h"

// These constants must be consistent with MEMMAP.4TH !
#define CF_SYSTEM_BASE          0x140000L
#define CF_SYSTEM_SIZE          0x400000L 
#define CF_SYSTEM_SPACE_END	(CF_SYSTEM_BASE+CF_SYSTEM_SIZE)
#define CF_SYSTEM_LIMIT		(CF_SYSTEM_SPACE_END+4096)

#define PAGE_ALIGNMENT  ((unsigned)0xFFFFFFFF-4095)

/* Error codes */

#define FAIL_ALLOCATE_MEMORY	1
#define NOT_ENOUGH_MEMORY       2
#define FAIL_OPENNING_FILE      3
#define FAIL_READING_FILE       4
#define FAIL_WRITING_FILE       5
#define SYSTEM_INCONSISTENT     6

/*
 * Associate Files and Turnkey System 
 */

unsigned int turnkey_mark[2] = { LUKECF,BINDCF };
char *image_name    = "CF.IMG      ";
char *head_name     = "CF.HED      ";

typedef int CommonForthV17x();

struct loader_environ {
   addr argc;           // setup by cf.cc
   addr argv;           // setup by cf.cc
   addr envp;           // setup by cf.cc
   addr cxxlinking;     // setup by cf.cc
   addr cxxendlinking;  // setup by cf.cc
   addr cxxfarpatch;    // setup by cf.cc
   struct register_pair_386 {   // compatiable to DPMI $0300 call
      unsigned int   edi;
      unsigned int   esi;
      unsigned int   ebp;
      unsigned int   reserved_0;
      unsigned int   ebx;
      unsigned int   edx;
      unsigned int   ecx;
      unsigned int   eax;
      unsigned short flags;
      unsigned short es;        // setup by cf.cc
      unsigned short ds;        // setup by cf.cc
      unsigned short fs;        // setup by cf.cc
      unsigned short gs;        // setup by cf.cc
      unsigned short ip;
      unsigned short cs;
      unsigned short sp;
      unsigned short ss;
      unsigned int   esp;       // not in DPMI $0300 call.
   } original_registers;
   char loadinginfo[256];
   addr transfer_buf;   // addr of transfer buffer, setup by cf.cc 07/10/'96
   addr transfer_siz;   // size of transfer buffer, setup by cf.cc 07/10/'96
   addr dos_selector;   // dos memory selector, setup by cf.cc.    07/11/'96
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

void fail_allocating_memory(void) {
    fprintf( stderr," * Fail allocating memory for Common Forth.\n");
    exit( FAIL_ALLOCATE_MEMORY );
}

void not_enough_memory(void) {
    fprintf( stderr," * Not enough memory for loading Common Forth.\n");
    exit( NOT_ENOUGH_MEMORY );
}

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

int main(int argc,char** argv,char** envp)
{
  CommonForthV17x *RunCommonForth;
  char            *cfspace;
  FILE            *fptr;
  FILE            *imagef;
  unsigned        base_address;
  int             bytes,result,already_linked;
  int             turnkey_size = 0;

   /*
    * Assign CF system space
    */

    dbgmsg( "[ sizeof double=%d, float=%d, long=%d, int=%d, short=%d ]\n",
    	 sizeof(double),sizeof(float),sizeof(long),sizeof(int),sizeof(short) );

    dbgmsg( "[sizeof(init_environ.original_registers) = %d]\n", 
            sizeof(init_environ.original_registers) );
    dbgmsg( "[sizeof(init_environ) = %d]\n", sizeof(init_environ) );
    cfspace = (char*) CF_SYSTEM_BASE;

    RunCommonForth = (CommonForthV17x*) cfspace;

   /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
    *           Start Loading Common Forth 1.7x                           *
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
       dbgmsg("system_image_header.code_space_address=$%X ; ",
               system_image_header.code_space_address );
       dbgmsg("cfspace=$%X\n",(unsigned)cfspace);
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
	    sizeof( _go32_info_block ) );
    init_environ.original_registers.cs = _go32_my_cs();
    init_environ.original_registers.ds = init_environ.original_registers.es 
				       = _go32_my_ds();
    init_environ.original_registers.ss = _go32_my_ss();

    // The target system MUST have a transfer buffer !!
    // At best, the transfer buffer is 64k bytes.
    init_environ.dos_selector = _go32_conventional_mem_selector();
    init_environ.transfer_buf =
			  _go32_info_block.linear_address_of_transfer_buffer;
    init_environ.transfer_siz = 
			  _go32_info_block.size_of_transfer_buffer;

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
     *   Start executing Common Forth system     *
    \* * * * * * * * * * * * * * * * * * * * * * */

    result = (*RunCommonForth)();

    printf("\nLeaving...\n"); fflush( stdout );

  return result;
}

