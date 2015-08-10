ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
บ     Common  Forth  Experiment  Version  1.668  Release  Notes  :      บ
ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

ฤฤฤฤฤฤฤฤฤฤ
 Warranty 
ออออออออออ

       This software is distributed WITHOUT ANY WARRANTY.

       I prevented using any low-level operations like BIOS disk I/O,
    since my major goal is to build a common environment which can use 
    other sources outside FORTH world and treat them like FORTH 
    ( Abstract Common Forth ), so I/O performance is not my first 
    consideration.

       Common Forth is implemented as macro-expansion subroutine threaded
    which means the compiled code is fast enough. Besides, many optimizations
    will be done in the future. Therefore, whenever you can prevent CODE 
    words, don't use them, for portabiliby's sake.
    
       And I haven't met any serious problem yet. Several successful projects
    have been implemented with this system, with the supporting of C(++)
    libraries ( such as database library : CodeBase ). The whole system goes
    in protected mode, many illegal operations should abort the whole system.
    However that's depended on the underlying DOS-extender. So I believe 
    your normal programming and operation won't cause any problem. But be 
    careful not to enter any infinite loop in your program, it is not always 
    possible to CTRL-BREAK those operations. For all those low-level I/O
    operations, that's depended on the underlying DOS extender, which might
    again based on VCPI or DPMI.

    ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
      You must realize that this is an experiment system and contains many
      prototypes . So far, they works fine.
    ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

ฤฤฤฤฤฤฤฤฤฤฤ
 Copyright 
อออออออออออ

   ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
   ณ     Note that a PART of this software is protected by GNU's General  ณ
   ณ  Public License ( the loader itself . ) See the detail file          ณ
   ณ  descriptions below. For those not protected programs, all rights    ณ
   ณ  are reserved by Luke Lee.                                           ณ
   ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

       The whole system is written by Luke Lee since 1991, currently public
    domain but not for commercial use. The system kernel CF0.4TH itself is
    derived from 16bit subroutine threaded eForth . You are welcome to
    distribute them but not for profit . Of course any target codes you wrote
    belongs to yourself, you can release a turnkey system or just include
    your source with the WHOLE SYSTEM WITH ALL DOCUMENTS, or just release your
    source code. You can charge fee for your codes but not for any other part
    of this system, even you made some modifications, ( except ONLY for your
    ALMOST COMPLETE REWRITTEN ) . Besides, any turnkey system that provide
    the functions which implemented in this system cannot be charged. For
    example, if you include the assembler/disassembler code in your turnkey
    system, and 'run through' the assembler/disassembler for assembling/
    disassembling, the outputs itself is not chargable. If your turnkey
    system provides only user-interface for DIRECT MANIPULATION of those
    tools, it cannot be charged. The term 'run through' applies to all tools
    except for the kernel codes in CF0.4TH . However the term 'run through'
    itself is quite ambiguous, don't worry, just USE YOUR CONSCIENCE and
    you will know what to do. Just don't charge fee for codes not belongs
    to yourself.

  ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ þ ABSOLUTELY FORBID to use in ANY military purpose except for Taiwan's บ
  บ   self-defence; even for testing things irrelevant to any weapon.      บ
  บ þ NEVER use it for ANYTHING relevant to ANY military purpose.          บ
  บ þ ANY violation to this rule will be treated as much serious problem   บ
  บ   than encroach on my copyright, though I might not have legal ways to บ 
  บ   stop this but this is never to forgive.                              บ
  บ þ Use other's FORTH system for your military purpose but NOT MINE .    บ
  ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
 Sell Your Product
อออออออออออออออออออ

       The best way is that you can sell your product ( not include any
    portion of this system ) and declare that they need this system for
    execution environment ( tell them the version too. ). And tell them
    how to obtain this system. Just like you release MS-DOS executable
    applications without releasing the copyrighted MS-DOS itself.

ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
 Compatibility 
อออออออออออออออ

      There is no guarantee that your application written in this system
    would be compatible with next released Common Forth. This system changes
    RAPIDLY ! Of course you might think this system useless since it change
    so fast. However, you should remember that this is an experiment version.
    This system will be settled down and be compatible with ANSI standard
    after version 2.0 . Before v2.0, I won't follow any standard except mine.

o eForth version :

    This system is derived originally from the following eForth :

	Subroutine threaded eForth; Version. 1.0, 1991
	by Richard E. Haskell
		Dept. of Computer Science and Engineering
		Oakland University
		Rochester, Michigan 48309
	which based on
	eForth 1.0 by Bill Muench and C. H. Ting, 1990
	Much of the code is derived from the following sources:
		8086 figForth by Thomas Newman, 1981 and Joe smith, 1983
		aFORTH by John Rible
		bFORTH by Bill Muench

o  GNU is the trademark of Free Software Foundation.

o  MS-DOS is the product of Microsoft Cooperations .


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!  Note that this system is CASE-SENSITIVE !  !
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
 What's Different ?
ออออออออออออออออออออ

What are the differences between CF and other Forth systems ?

    1. High performance Stack Expression : ( Common Forth Unique )
	 Input/output parameter and local variables without headache for
       DUP, SWAP, OVER, TUCK, NIP, ROT ... and still keeps the performance
       since it does not use extra codes to access local variables
       and input/output parameters, and it never move these data into
       return stack, they are just move to top of data stack (TOS) when they
       are needed ( just like PICK ) and move TOS into the cell where they
       are assigned. It is a prototype version. New algorithm will be 
       applied in new version which will compile SWAP, DUP ... directly.

	 See HI.4TH, STKEXPR.4TH for stack parameter and local variable
	 examples .

    2. Subroutine threaded with macro expansion :
	  Fastest Forth system implementation method. In the future, many
       other optimizations will be implemented.

	  Use SEE.4TH or DISASM.4TH to see the compiled code.

    3. Short-cut Boolean evaluation available : ( Common Forth Unique )
	T/F ANDTHEN T/F ANDTHEN .... THEN-AND
	T/F ORELSE  T/F ORELSE  .... ELSE-OR

	  See SHORTCUT.4TH for usage and examples.

    4. FORTH call C(++) and C(++) call FORTH :
	 Since the loader is written by DJGPP ( GNU C++ for PC ), all the
       C(++) functions it used could be called by FORTH with INFIX syntax !
       See INVOKEC.4TH. ( OO features are not implemented yet. )
         And another feature is that after your FORTH program starts, you
       can interpret FORTH words within your C(++) function ! See INVOKEC.H
       for 'forth_interpret(...)' function. About C(++) actually 'CALL' 
       FORTH words, not just interpreting every time, this facility will be
       implemented later.

	  See DEMO_C.4TH for examples of FORTH calls C .

    5. Data structure oriented implementation :
	Most of the data structures are defined by STRUCT: ... ;STRUCT ,
	UNION: ... ;UNION , including the memory map and head structure
	which makes it easier to understand this system.

	  See STRUCT.4TH and MEMMAP.4TH and CPU80486.4TH for examples.
	  For unions, see GRX.4TH for examples.

    6. A very syntax-clear 80486 assembler and disassembler (CPU80486.4TH),
       both PREFIX and POSTFIX syntax are provided and has exactly
       the same syntax except for that the memonic can be put before operands
       or after them.

	  SEE VERIFY.4TH and VERIFYPO.4TH for prefix / postfix examples .

    7. A very fast multitasking system with different mechanism and minimum
       overhead ( much much faster than a single INT instruction in protected
       mode ! ).

          ( MULTASK.4TH )

    8. A very simple meta-compilation mechanism without H: T: ...
       In fact, except for user variables, the meta-compiler implements
       almost no-thing for supporting meta-compilation. 

          ( CFMETA.4TH )

    9. Support one CREATE with multiple DOES> .

	  See the definition of FIELD: in STRUCT.4TH, and ARRAY: in HI.4TH.

   10. A powerful discompiler ( SEE.4TH ), multiple exit loops like :
	   BEGIN ...
	     WHILE ...
		WHILE ...
	   UNTIL ...
		ELSE ...
		THEN ...
	     ELSE ...
	     THEN ...

       could always be discompiled successfully.

   11. Compatible with Chinese system ( such as ETen, 01 ... ).
       That's why it is case-sensitive.

   12. Assertion tools for your debugging version program.

	  See #IF.4TH and ASSERT.4TH .

   13. No floating point stack, all floating goes to data stack. I believe
       2 stack is enough for one FORTH task. Besides, multitasking won't cause
       any problem in this way since there could be many tasks computing
       floating on stack at the same time. There is only one format : 
       64-bit IEEE floating point. Each floating number occupies 2 cells,
       just like double precision integer. Many floating operations goes 
       through INVOKEC.4TH with C(++) function calls, but 387FLOAT.4TH 
       use 387 instructions.

	  See FLOAT.4TH and 387FLOAT.4TH . And the demo program 3DR.4TH.

   14. Pure graphics mode operation. Cursor is emulated by multitasking with
       a CursorTask. A standard graphics interface have been defined which
       means that you can write portable programs which could be executed
       under other Common Forth environments ( like Watcom's loader . ) For
       example, a demonstration program 3DRp.4TH by Sam Chen is now running
       under GO32+DJGPP(V1), RUN386+WATCOM and PMODE/W+WATCOM.

ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
 Running this System
อออออออออออออออออออออ

      If your system support VESA BIOS calls, set the following environment
   for GO32 :
 Example:

  SET GO32=driver F:/cf/vesadrv.vdr gw 640 gh 480 nc 256
		  ฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤ ฤฤยฤฤ- ฤฤยฤฤ- ฤฤยฤฤฤ-
		     ณ                ณ      ณ      ณ
		     ณ                ณ      ณ      ภฤ- default number of
		     ณ                ณ      ณ          colors in graphics mode
		     ณ                ณ      ณ
		     ณ                ณ      ภฤ- default number of pixels of
		     ณ                ณ          screen height in graphics mode
		     ณ                ณ
		     ณ                ภฤ- default number of pixels of screen
		     ณ                    width in graphics mode.
		     ณ
		     ภฤฤ Any driver in the .\DRIVERS subdirectory, choose your
			 suitable driver . Try VIDEOID.EXE written by Bob Berry
			 and find out what kind of driver you need.

		( The maximum number of colors is 32768. )

  SET GRXFONT=G:\gcc\contrib\libgrx\allfonts
     or GRX.4TH will search for .\FONTS for appropriate fonts. Without fonts,
     you cannot see text under GRX's graphics mode.

  You should have at least 3 files to run this system :
		    CF.EXE + CF.IMG + CF.HED .
	    ( or  GO32.EXE + CF. + CF.IMG + CF.HED . )
  Execute CF.EXE to run this system ( or "GO32 CF" ) .

  There are several other drivers now included in the DRIVERS subdirectory,
  which belongs to GNU. You can use them instead of using 'vesadrv.vdr'.

    !  NOTE !  Each time you FSAVE, the original CF.IMG        !
    !          and CF.HED will be overwritten without          !
    !          any backup. So backup them first in case        !
    !          your FSAVEed system won't work.                 !
    !      Two files for solving this problem :                !
    !          CF_IMG.BAK and CF_HED.BAK                       !

ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
  User Manual MANUAL.DOC
ออออออออออออออออออออออออออ

      An user manual is now included in this version named MANUAL.DOC, and 
   I must appologize that my English might not be good enough. However it 
   should be of some use. This file is still under construction.

      There are a few parts of that manual, including basic operations,
   word summary, turnkey systems, meta-compilation, assembly programming
   and how to include your C programs .

ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
บ  Detail Descriptions for this system :                                   บ
ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
 About DOS Extenders 
อออออออออออออออออออออ

      This release version use GO32 for DOS Extender. See README.G32 and
    README.DJ for extra details, for its full source, download DJGPP V1 .

      Before version 1.60, the Common Forth system image is executed under
    Phar Lap's DOS Extender : RUN386.EXE . Version 1.60 is meta-compiled
    from version 1.59 under Phar Lap's RUN386.EXE . Now there are another
    version for Watcom C/C++ which can use PMODE/W , RUN386 ... for its 
    DOS Extender.

      From version 1.60, the whole system is executed under DJGPP's public
    domain DOS Extender GO32.EXE, with an 80387 emulator. Virtual memory is
    supported by GO32, so you can run it under DOS with only 512k RAM but
    with very very terrible performance . But for 4M memory, its performance
    is quite good.

       See README.DJ for DJGPP's info.

    GO32.EXE + EMU387 : DJGPP's public domain DOS Extender with 
			80387 emulator.
      ( + VESADRV.VDR : if you have VESA BIOS, graphics modes defined by
			vesa will be available. For other video cards, 
			use the appropriate driver in the .\DRIVERS )
      * There is a bug in GO32 while opening file with read/write mode or
	write only mode, I have already fixed it and rebuild GO32.EXE by
	Borland C++ 3.1.

    INVOKEC.H + BIND.H
     + EXTENDED.CC .. : Vendor dependent C library. Include your C functions
			only here !
     + INVOKEC.CC ... : ANSI C standard library. (System independent)
     + CF.CC          : Loader's source code.
    SECTIONS.LD       : Command file for GCC's linker : "ld.exe" .
			It defines the memory layout of CF.
    CF                : Use GCC to compile CF.CC ( use CYCLE.BAT or MAKEFILE )
    CF.EXE            : GO32.EXE + CF = CF.EXE ( use BIND.BAT )

    .\DRIVERS\*.*     : Video drivers for GO32.
    .\FONTS\*.*       : Several fonts for GRX.

    Note :  VIDEOID.EXE in .\DRIVERS is a public domain program written
	    by Bob Berry . See VIDEOID.DOC for detail.
    

! Notice !  The programs listed above ( CF.CC + SECTIONS.LD + CF + CF.EXE )   !
! ออออออออ  and any other program released by GNU ( GO32 + EMU387 ... )       !
!           are protected under GNU's copyleft license.                       !
!                                                                             !
!           But all Forth programs listed below contains not a single byte    !
!           from GNU's code, they are originally derived from 16bit           !
!           eForth . The image itself is originally executed under PHAR       !
!           LAP's RUN386 DOS Extender, and for any source codes listed        !
!           below contains NOT A LITTLE CODE FROM GNU's RELEASED programs.    !
!           Except for the interface program definitions which is complete    !
!           compatible with DJGPP's library ( might also be compatible        !
!           with other C(++) compilers ). For all other programs, they are    !
!           all derived ( meta-compiled ) by previous Common Forth from       !
!           version to version. And the Common Forth itself is derived        !
!           from the subroutine threaded 16bit eForth by Richard E. Haskell.  !
!                                                                             !
!           Thus for these programs not protected by GNU's General Public     !
!           License, copyrights are reserved by Luke Lee. See the first       !
!           paragraph of this README.TXT file. Maybe someday I will release   !
!           them according to GNU's General Public License .                  !
!                                                                             !
!           These programs which are not copylefted by GNU can be executed    !
!           under any other DOS Extender ( Portability ) with proper          !
!           environment setting or with some other kind of meta compilation.  !
!           They are all in source level or in machine code level with no     !
!           invocation to GNU's code. You can execute them without DJGPP.     !
!           But for DJGPP interface programs such as GRX.4TH , they           !
!           won't be able to be executed without LIBGRX's code . Of course,   !
!           you can write your own C(++) graphics library which is source     !
!           level compatiable with LIBGRX.                                    !
!                                                                             !
! ! Notice !  Please refer to GNU's General Public License for using GNU's    !  
!             library.                                                        !


  You can use any other C(++) compiler to write a loader in order to load
  the following codes into your operating system.

    CF.INI            : Initialization program, just like AUTOEXEC.BAT .

    CF.IMG            : Common Forth Code/Data image file.
    CF.HED            : Common Forth Head image file.

    CF_IMG.BAK
    CF_HED.BAK        : Backup file for current image, incase you accentially
			deletes them or FSAVE a system which cannot executes
			normally. Just do :
				COPY CF_IMG.BAK CF.IMG
				COPY CF_HED.BAK CF.HED
			to restore original system.

ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
 High Level Forth Modules
ออออออออออออออออออออออออออ

  You don't have to FLOAD or NEEDS these modules yourself, they have already
  been FLOADed previously.

  HI.4TH      : Miscellaneous words and other high level definition module
		loading program. It is used only when the target system
		has just been Meta-compiled, not until you FLOAD HI.4TH
		you can't do SAVE-SYSTEM ( FSAVE ) or WORDS or FORGET ....

  STRUCT.4TH  : Simple data structure defining words, nesting data
		structures and unions are also supported, the Forth head
		structure is now defined this way to reduce the requirement
		for accessing fields by specifying the offset value directly.

		For example, you might have to use "10 +" to access the
		field with offset 10 in a data structure, this is not a
		good programming habit and may result in unpredictable
		bugs, now use STRUCT: and ;STRUCT to define structures
		will help you preventing such kind of problems.

  MEMMAP.4TH  : System memory description, use STRUCT: and ;STRUCT to
		describe memory map.

  CASE.4TH    : CASE ... OF ... ENDOF ... ENDCASE structure.

  DOLOOP.4TH  : DO ... LOOP and ?DO ... LOOP. ( +LOOP, LEAVE and ?LEAVE
		are also included ).

  VOCAB.4TH   : Vocabulary words. Note: The word ".VOCS" replace the name
				       in F-PC : "VOCS" .

  MULTASK.4TH : A very fast multitasking system for Common Forth; unlike any
		other FORTH systems, its execution mechanism is not a jump;
		and sleep tasks will cause no delay since there is no jump
		instructions to jump through them. (prototype)

		I use circular double linked-list to implement this. It's
		usage is still the same as other Forth systems but the
		internal mechanism is different.

  STKEXPR.4TH : Introduced in Common Forth 1.2, the stack expression for
		data stack. There is no need to put local variables in
		return stack. Read the file for more examples. (prototype)

		From CF 1.48, it supported one CREATE and multiple DOES> .
		In fact, in previous versions, you could use single CREATE
		and multiple DOES> before you FLOAD STKEXPR.4TH; now it is
		available even if STKEXPR.4TH is FLOADed .
		( Example : FIELD: in STRUCT.4TH )

		Some stack balance checking has already been implemented.

		Now compiling words doesn't have to care about how to
		maintain a correct value of the local stack pointer . You
		don't even have to know what the 'compiling time local stack
		pointer' is.

  FSAVE.4TH   : Save system, FSAVE is the alias for SAVE-SYSTEM, it will
		create 2 image files, one named CF.IMG which stores the
		code space of your system; another named CF.HED which
		stores the head space of your system. If you are building
		a turnkey system, just drop the CF.HED . (prototype)

  SHORTCUT.4TH : My creation. In fact, this idea came from ADA language;
		 in ADA, if you don't specifically use 'ANDTHEN' and 'ORELSE'
		 , all Boolean evaluation will be treated as full evaluation.
		 Now I introduce ANDTHEN ... THEN-AND and ORELSE ... ELSE-OR
		 control structure for FORTH .

  KEYBUF.4TH   : Command history recording tools, with a simple line editor.
		 Its function is very similar to DOSKEY.COM in MSDOS 5.0.
		 (prototype)

  TRACER.4TH   : A simple debugging tool. Stack depth checking before enter/
		 leave some Forth word, execution sequence displaying and
		 data stack frame displaying. (prototype)
		    Reference to TRACER.4TH for detail help.
		 Ex.  TRACER ON
		      FLOAD HANOI.4TH
		      TRACING ON
		      4 TOWER-OF-HANOI          // See the result !
		      TRACER/RESET

  #IF.4TH      : Conditional compilation .
		   Syntax :
			... #IF ... #ELSE ... #ENDIF

  ASSERT.4TH   : Assertion making tool. For testing program's assertion.
		 (prototype)
		 Like :
		    ASSERT{
			ArrayIndex  LowerBound UpperBound  BETWEEN
		    }?ASSERT" Array index exceed boundary."
		 A variable named NODEBUG is used to control the compiling
		 process, if you use 'NODEBUG ON' , ASSERT{ won't lay down
		 any code. In short, it's function is just like <assert.h>
		 in C(++) language.

 ---------------------------------------------------------------------
 * Not like those modules listed above which are loaded by HI.4TH, the
   following files should be FLOADed explicitly .
 ---------------------------------------------------------------------

  ALLTOOLS.4TH : FLOAD this file will eventually FLOAD some of the following
		 tools below, just for your convenience .
		 Note that it takes a lot of memory since SEE will grow
		 VERY fast for building the 'macro recoginaztion tree',
		 the algorithm and data structure will be modified later
		 and it will save at least 80% memory wasted in one-way
		 branching tree nodes.

  CPU80486.4TH : A complete 80486 assembler, including both 16-bit mode and
		 32-bit mode, use USE16 and USE32 to switch between them.
		    Both PREFIX and POSTFIX syntax are implemented. The
		 default setting is prefix syntax . If you wants to use
		 postfix syntax, just type in " POSTFIX SYNTAX " . In the
		 PREFIX SYNTAX setting, postfix syntax could be used either !
		 But for macro definition and inline definitions, you have
		 to use postfix syntax.
		    All instructions and addressing modes are supported
		 ( except for ESC ), only valid instructions with appropriate
		 addressing modes are accepted by this assembler, all
		 other combinations will be treated as error. So you don't
		 have to worry about that it might generate some illegal
		 instructions. All legal instructions and addressing modes
		 have already been checked by PHAR-LAP debugger ( I also found
		 some bugs in 386DEBUG while disassembling ) and Turbo
		 assembler/debugger.
		   However, I strongly suggest you use DISASM.4TH to examine
		 the assembled codes since I don't guarantee that all
		 possible errors in your code word would be detected by this
		 assembler. So it is possible that some of your errors will
		 not be reported on screen.

		   The syntax is very clear and uniform,
		 for example :

		   PREFIX SYNTAX
		     // default setting, allow both PREFIX and POSTFIX syntax

		// INSTRUCTION     DESTINATION     SOURCE
		      MOV        { VARIABLE-NAME }  EAX
		      MOV        { EAX ESI + }      234 #
		      JMP        ' FORTH-NAME #
		      JMPF       1234 # ABCDDCBA #
		      CALLF      { ADDRESS }

		   POSTFIX SYNTAX

		//   DESTINATION     SOURCE  INSTRUCTION
		   { VARIABLE-NAME }  EAX       MOV
		   { EAX ESI + }      234 #     MOV
		   ' FORTH-NAME #               JMP
		   1234 # ABCDDCBA #            JMPF
		   { ADDRESS }                  CALLF

		 For each instruction, refer to VERIFY.4TH for a correct
		 syntax.

		   Now global labels are also implemented now, forward
		references are also allowed. See VERIFY.4TH for usage.

		From version 1.55, CPU80486.4TH also includes a complete
		80486 disassembler.

		Advantage of postfix notation :
	       1. Meet the concept of data-flow.
	       2. Easy to used in colon definitions in order to compile
		  some codes, for example, a macro ( for postfix syntax
		  only ) :

			ALSO ASSEMBLER ALSO FORTH DEFINITIONS
			: T   EAX ;   : SP EBP ;
			: $PUSHT
				SP     { SP 4 - }   LEA
			      { SP }     T          MOV  ;
			PREVIOUS PREVIOUS
			CODE: TEST    ( -- 5 )
				$PUSHT
				T       5 #     MOV
				RET     
                                ;CODE

	       3. Since this system is a macro expansion subroutine threaded
		  Forth system, the execution speed is much faster than
		  direct threaded codes ( except for screen I/O , disk I/O ),
		  so you should implement your Forth program with high level
		  words whenever possible.
		  ( Try :
			DECIMAL
			: TEST 1000000 FOR 4311 431 + DROP NEXT ;
			TEST
		    in 80486-50 CPU, this takes about 1/2 second )

	      þ  NOTE:  It is NOT public domain, you could use it to
		write assembly for your own application, the target code
		is of course yours but the assembler/disassembler itself
		is copyrighted and cannot be used for commercial use. You
		are agree to distribute it but not for profit.

  DISASM.4TH   : An output program using CPU80486.4TH's disassembler .
		 There are two kinds of output format, one is "CFASM-LOOK",
		 which is the default setting; the other is "MASM-LOOK".
		 Using CFASM-LOOK will make the outputs looks exactly
		 the same as CPU80486.4TH syntax ; yet using MASM-LOOK
		 will makes it looks like MASM syntax .

  VERIFY.4TH   : This file is written originally for debugging the assembler,
		 since all the instructions have already been verified, it
		 now become a valuable reference for a correct syntax for
		 each instruction . There is another version named VERIFYPO.4TH
		 for POSTFIX SYNTAX.

  INVOKEC.4TH  : C++ function invoking tool. This is THE ONLY feature in
		 this system. You could even use infix C syntax to invoke
		 C functions, like :
			cprintf( Z$" %d %d" , a , b );
		 Refer to DEMO_C.4TH for detail.
		 (prototype)

  SEE.4TH      : A powerful discompiler. The discompiling process never need
		 the disassembler ( DISASM.4TH + CPU80486.4TH ), but if it
		 fail to discompile any word it will invoke the disassembler
		 to display it. That's why it needs DISASM.4TH. The
		 discompiling process never invoke assembler/disassembler.

		    Many complex control structure have already been
		 implemented. Currently the following control structure
		 cannot be seen yet, it will soon be modified.
			DO      ...
				WHILE 
				   ...
			LOOP       
				   ...
				ELSE 3RDROP
				   ...
				THEN

  FLOAT.4TH    : Floating point operations. It will load INVOKEC.4TH first.
		 Before you FLOADing this package, numbers like "1.234" are
		 illegal. Now "1.234" will be converted into 64bit floating
		 on data stack. You can use 'F.' or 'E.' ... to display it.

  387FLOAT.4TH : Like FLOAT.4TH but faster since it use 80387 instructions
		 directly. However, I cannot guarntee that all floating
		 point exceptions will be handled. If you are seeking for
		 safer floating point package, use FLOAT.4TH instead.

  GRX.4TH      : Graphics mode interface implemented according to DJGPP's
		 GRX library. Please reference to LIBGRX.DOC for a manual 
		 for GRX library functions .

  GRAPHICS.4TH : A prelimiliary release of Common Forth Standard Graphics
		 Interface. Follow this standard interface and your graphics
		 program will works under other environments like Watcom's
		 graphics library ( of course, runs under watcom's execution
		 environment ).
		 Use 'GRAPHICS-MODE' to enter graphics mode,
		 Use 'TEXT-MODE' to return text mode. Please reference to
		 MANUAL.DOC .

  DOSCMD.4TH   : Commonly used DOS words like DIR , COPY , CD ...

  CHINESE.4TH  : A Chinese System for Common Forth, support Eten System,
		 and Chinese input facility have not been implemented yet .
		 For its usage please refers to MANUAL.DOC.

  KEYTABLE.4TH : A keyboard mapping tools, remap your keyborard or perform
		 some special action on special key-stroke.

  SPOOLER.4TH  : A background spooler for printing, it's a good sample 
		 program for multitasking. A new version is implemented,
                 now the printer output is thru BIOS calls, and it will 
                 check for printer busy to achieve minimum delay for 
                 faster printers.

  LOG.4TH      : A very useful tool for logging terminal texts, written by
                 Sam Chen and modified by Luke Lee for graphics mode. It's
                 especially useful while debugging. For example :
                   FLOAD LOG.4TH
                   LOGTO HANOI.LOG
                   TRACER ON
                   FLOAD HANOI.4TH
                   TRACER OFF TRACING ON
                   4 TOWER-OF-HANOI
                   LOGEND
                   DOS EDIT HANOI.LOG

  DBG1652.4TH  : An assembly level debugger for Common Forth v1.652 written by
		 Sam Chen, not fully implemented yet. 
		 If you see wired characters in source code, it is Chinese 
		 Big-5 code.

ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
  Meta Compilation Modules
ออออออออออออออออออออออออออออ

  Please reference to MANUAL.DOC or CFMETA.4TH for details.

  CFMETA.4TH : Meta compiler.

  CF0.4TH    : Common Forth 1.6X source code.

  CFMETA     : Automatical meta-compilation

  META2      : For automatical meta pass 2.

ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
  Demonstration Programs
ออออออออออออออออออออออออออ

  * Many other demonstration programs are included in .\SAMPLES subdirectory.

  DEMO_C.4TH  : Demonstration program for writing C function calls.
		Also demonstrates floating point numbers.

  DEMO_SEE.4TH : Demonstration program to use SEE .

  DEMO_GRX.4TH : Only partially implemented, demonstrates the minimal power
		 of GRX library and GRX text-emulation .

  ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
  3DROTATE.4TH : A program written by George Mai, and I just port it
		 to this system. It's a good example for demonstrating
		 multitasking, graphics facility and the performance
		 of floating operations.
  3DR.4TH      : A facinating rewritten version by Sam Chen, try it and
		 you will be surprised. Total eight background tasks (
		 including the cusor-task ) and one forground task.
		 This program is written specifically for DJGPP+GRX.
  3DRP.4TH     : A portable version for 3DR by Sam Chen, I just modify
		 it for standard graphics library GRAPHICS.4TH, this
		 program can be executed under different environments :
		 DJGPP+GO32, WATCOM+PHARLAP and WATCOM+PMODE/W .
  ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

  HANOI.4TH   : A demonstration for recursive programs and Stack Expression,
		you will see the much more readable FORTH word
		TOWER-OF-HANOI, compare it with the old-styled FORTH
		TOWER-OF-HANOI0 and you will realize how elegant and how
		clear you can express your FORTH program with the unique
		Stack Expression for Common Forth.

  FIB.4TH     : Another demonstration program for stack expression, it is
		recommended that you should not use integer greater than
		30 ( type in "30 FIB" ), or you might have to wait for
		a VERY LONG time.

  KEYBUF.4TH  : You could treat this tool as another demonstration program,
		It use a lot of Stack Expression, including using them in
		CASE ... ENDCASE structure.

  ROMAN.4TH   : An example from Thinking Forth, I implement it with different
		way, but I believe the implementation in Thinking Forth is
		much better since I use CASE structure to prevent calculation.

  * For other sample programs, refers to .\SAMPLES subdirectory.

ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
  Turnkey System Building
อออออออออออออออออออออออออออ

  In this version, you can build your turnkey application now, there are
  several files supporting this :

  RKSEARCH.4TH : Robin-Karp string searching algorithm, in this algorithm,
		 a good prime number is very important, I use 8388593 
		 for CONSTANT RKMagic , if you can find a better prime 
		 number, please tell me, it will speed up this algorithm.

  TURNKEY.4TH  : There are three versions for this, for DJGPP+GO32, 
		 for WATCOM+PHARLAP and for WATCOM+PMODE/W, the only 
		 difference is this word :
		: TurnkeySystemFiles    (( -- $name1 $name2 ))
			$" GO32.EXE"     $" TURNKEY."   // GO32 version.
		//      $" STUB386.EXE"  $" TURNKEY."   // Phar Lap RUN386
		//      $" NUL"          $" CF.EXE"     // PMode/W version
			; 0 2 #PARMS

		 comment out the other versions and leave the one you need,
		 and you can build your turnkey application according to
		 the C/C++ compiler you are using.

  T3DRP.4TH    : A sample turnkey program for 3DRP.4TH, 
		 which can be executed under different platforms : 
		 DJGPP+GO32 , WATCOM+PHARLAP and WATCOM+PMODE/W .
		 Try this :
			F:\CF>CF FLOAD T3DRP.4TH BYE
		 and it will build 3DRP.EXE, 3DRP.IMG and 3DRP.HED.

		 You can release the 3DRP.EXE as your application.
		
  T3DR.4TH     : A sample turnkey building program for 3DR.4TH,
		 try this :
			F:\CF>CF FLOAD T3DR.4TH BYE
		 and it will build 3DR.EXE, 3DR.IMG and 3DR.HED.

		 You can release the 3DR.EXE as your application.
		 
  THANOI.4TH   : A sample program for HANOI.4TH . 
			CF FLOAD THANOI.4TH BYE
		 will build HANOI.EXE, HANOI.IMG and HANOI.HED.

ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
  About MetaForth v1.0
ออออออออออออออออออออออออ

      In the sub-directory MF, it contains a tiny 32-bit Forth system 
   named 'MetaForth'. The purpose for this system is for 'teaching'
   meta-compilation. This system might not have pratical use but
   should serve good for teaching's purpose.
       
      No documentation for this system yet, sorry.   


   The complete meta-compiling procedure is :

    A) Executable needed : CF v1.654 or above, GO32.EXE+MF.
       Source needed : MFMETA.4TH and MF.MF

    B) Steps : Copy the MetaForth source to your working directory,
	       for example, F:\CF :

     B.1) Meta compilation from Common Forth to Meta Forth.
	1. F:\CF>CF.EXE
	2. FLOAD MFMETA.4TH
	3. FSAVE MF.BIN BYE
	- - - - - - - - - - - - - - -
     B.2) Meta compiling MetaForth itself.
	4. F:\CF>GO32 MF
	5. HERE META
	6. $180000 META
	7. FSAVE MF.BIN BYE
	goto step 4. to meta again. (just like RIFORTH)

   Demonstration programs for MetaForth :

        HI.MF    : Miscellaneous hi-level definitions for MetaForth.
	HANOI.MF : Tower-of-Hanoi .
	FIB.MF   : Fibonacci number .
	TEST.MF  : Several testing .

      How to run :
        1. GO32 MF
        2. FLOAD HI.MF
        3. FLOAD TEST.MF
        4. FLOAD HANOI.MF
        5. 4 TOWER-OF-HANOI
        6. FLOAD FIB.MF
        7. .FIBSEQ

	Note :
	   1. MF. is build from MAKEFILE with DJGPP.
	   2. MF.EXE is a turnkey system build from MF.4TH . Just like
	      the above turnkey applications you have seen.



					eMail address : comforth@ms2.hinet.net

	þ P.S.  Mail me only bugs since I might not have time to reply your
		letter, please. And Thanks.

						       10/09/'97    Luke Lee
      .   ๚  ๚  ๙  ๙ ๙๙๙ฤ ฤฤ ฤฤฤ ฤฤฤฤ ฤฤฤฤฤฤ ฤฤฤฤฤฤฤ ออออออออออออออออออออออออ

