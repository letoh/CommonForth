/*
 *   MetaForth Loader                         Version 1.0
 *					       02/05/'96
 *                                  Written in GNU C++ for PC (DJGPP)
 *                                          Author : Luke Lee
 */

#include <std.h>
#include <stdlib.h>
#include <stdio.h>

typedef int MetaForth(void);

/****************************************\
 *           Main  Program              *
\****************************************/

extern char MF_SYSTEM_SPACE;

int main(int argc,char** argv,char** envp)
{
  MetaForth  *RunMetaForth;
  char       *mfspace,*image_name;
  FILE       *imagef;

   /*
    * Assign CF system space
    */

    mfspace = &MF_SYSTEM_SPACE;
    RunMetaForth = (MetaForth*)mfspace;
    if (argc>1) 
        image_name = argv[1]; 
    else
        image_name = "MF.BIN";

   /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
    *  		Loading Meta Forth 1.0				  *
   \* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

    if ( (imagef = fopen(image_name,"rb")) == NULL ) {
       fprintf(stdout,"Fail openning system image file %s.\n",image_name);
       exit( 1 );
    }
    fread( (void*)(mfspace), 1, (512*1024L), imagef );
    fclose( imagef );

    /* * * * * * * * * * * * * * * * * * * * * * *\
     *   Start executing MetaForth system	 *
    \* * * * * * * * * * * * * * * * * * * * * * */

    return (*RunMetaForth)();

}

