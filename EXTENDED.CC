/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
 *   Common Forth  386/486   Compiler Specific C(++) Language Extensions   *
 *									   *
 *  	 DJGPP 2.0  Version					   	   *
 *									   *
 *						Written by : Luke Lee	   *
 *						Date       : 07/20/'96	   *
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

#include <dpmi.h>
#include <std.h>
#include <conio.h>
#include <process.h>
#include <io.h>
#include <fcntl.h>
#include <file.h>
#include <dos.h>
#include <go32.h>
#include <sys/stat.h>
#include <grx20.h>
// #include <libbcc.h>


addr _stdaux()	{  return (addr)stdaux; }
addr _stdprn()	{  return (addr)stdprn; }

addr ___dpmi_int_ss(void)	{ return (addr)__dpmi_int_ss; } 
addr ___dpmi_int_sp(void)	{ return (addr)__dpmi_int_sp; } 
addr ___dpmi_int_flags(void)    { return (addr)__dpmi_int_flags; }

// for <grx20.h>
typedef int gr_ellipse_points[GR_MAX_ELLIPSE_POINTS][2];
addr _addr_GrDriverInfo(void)   { return (addr)GrDriverInfo;  }
addr _addr_GrContextInfo(void)  { return (addr)GrContextInfo; }
addr _addr_GrColorInfo(void)    { return (addr)GrColorInfo; }
addr _addr_GrMouseInfo(void)    { return (addr)GrMouseInfo; }
addr _addr_GrDefaultFont(void)	{ return (addr)&GrDefaultFont; }

#define ___ABS(a) (((a)<0) ? -(a) : (a))
void _GGetImage(int left, int top, int right, int bottom, void *bitmap)
{  /* This code is modified from bcc2grx, getimage.c */
  GrContext *gc;
  int w, h;
  char *memory[4];
  int i, np, ps;

  GrSetContext(NULL);
  gc = (GrContext*)bitmap;
  w = ___ABS(right-left)+1;
  h = ___ABS(bottom-top)+1;
  np = GrNumPlanes();
  ps = GrPlaneSize(w,h);
  for (i=0; i < np; ++i)
    memory[i] = ((char *)bitmap) + ((((sizeof(GrContext)+15)&~15)+4) + i*ps);
  while (i<4)
    memory[i++] = NULL;

  GrCreateContext( w, h, memory, gc);
  GrBitBlt( gc, 0, 0, NULL, left, top, right, bottom, GrWRITE);
}

void _GPutImage(int left, int top, void *bitmap, int op)
{
  GrSetContext(NULL);
  GrBitBlt( NULL, left, top, (GrContext*)bitmap,
      0, 0, ((GrContext*)bitmap)->gc_xmax, ((GrContext*)bitmap)->gc_ymax, op);
}

/****************************************************************\
 *  Function  : register_extended_funcs				*
\****************************************************************/

int register_extended_funcs( void ) 
{

  /*   #in     #out           fn addr             fn name
       ---------------------------------------------------------------- */
    if (register_funcs(    /***** <dpmi.h> *****/
	0,	1,	(addr)&___dpmi_int_ss, 	"__dpmi_int_ss",
	0,	1,	(addr)&___dpmi_int_sp, 	"__dpmi_int_sp",
	0,	1,	(addr)&___dpmi_int_flags,"__dpmi_int_flags",
    	0,	0,	(addr)&__dpmi_yield,	"__dpmi_yield",
	2,	1,	(addr)&__dpmi_int,"__dpmi_int", /* DPMI 0.9 AX=0300 */

	1,	1,	(addr)&__dpmi_allocate_ldt_descriptors,
			"AllocateLdtDescriptors",       /* 0.9 AX=0000 */
	1,	1,	(addr)&__dpmi_free_ldt_descriptor,
			"FreeLdtDescriptor",	        /* 0.9 AX=0001 */
	1,	1,	(addr)&__dpmi_segment_to_descriptor,
			"SegmentToDescriptor",          /* 0.9 AX=0002 */
	0,	1,	(addr)&__dpmi_get_selector_increment_value,
			"GetSelectorIncrementValue",    /* 0.9 AX=0003 */
	2,	1,	(addr)&__dpmi_get_segment_base_address,
			"GetSegmentBaseAddress",        /* 0.9 AX=0006 */
	2,	1,	(addr)&__dpmi_set_segment_base_address,
			"SetSegmentBaseAddress",        /* 0.9 AX=0007 */
	1,	1,	(addr)&__dpmi_get_segment_limit,
			"GetSegmentLimit",              /* LSL instruction */
	2,	1,	(addr)&__dpmi_set_segment_limit,
			"SetSegmentLimit",              /* 0.9 AX=0008 */
	1,	1,	(addr)&__dpmi_get_descriptor_access_rights,
		   	"GetDescriptorAccessRights",    /* LAR instruction */
	2,	1,	(addr)&__dpmi_set_descriptor_access_rights,
			"SetDescriptorAccessRights",    /* 0.9 AX=0009 */
	1,	1,	(addr)&__dpmi_create_alias_descriptor,
			"CreateAliasDescriptor",        /* 0.9 AX=000a */
	2,	1,	(addr)&__dpmi_get_descriptor,
			"GetDescriptor",                /* 0.9 AX=000b */
	2,	1,	(addr)&__dpmi_set_descriptor,
			"SetDescriptor",                /* 0.9 AX=000c */
	1,	1,	(addr)&__dpmi_allocate_specific_ldt_descriptor,
			"AllocateSpecificLdtDescriptor",/* 0.9 AX=000d */
	2,	1,	(addr)&__dpmi_get_multiple_descriptors,
			"GetMultipleDescriptors",       /* 1.0 AX=000e */
	2,	1,	(addr)&__dpmi_set_multiple_descriptors,
			"SetMultipleDescriptors",       /* 1.0 AX=000f */
	2,	1,	(addr)&__dpmi_allocate_dos_memory,
			"AllocateDosMemory",            /* 0.9 AX=0100 */
	1,	1,	(addr)&__dpmi_free_dos_memory,
			"FreeDosMemory",                /* 0.9 AX=0101 */
	3,	1,	(addr)&__dpmi_resize_dos_memory,
			"ResizeDosMemory",              /* 0.9 AX=0102 */
	2,	1,	(addr)&__dpmi_get_real_mode_interrupt_vector,
			"GetRealModeInterruptVector",   /* 0.9 AX=0200 */
	2,	1,	(addr)&__dpmi_set_real_mode_interrupt_vector,
			"SetRealModeInterruptVector",   /* 0.9 AX=0201 */
	2,	1,	(addr)&__dpmi_get_processor_exception_handler_vector,
			"GetProcessorExceptionHandlerVector",/* 0.9 AX=0202 */
	2,	1,	(addr)&__dpmi_set_processor_exception_handler_vector,
			"SetProcessorExceptionHandlerVector",/* 0.9 AX=0203 */
	2,	1,	(addr)&__dpmi_get_protected_mode_interrupt_vector,
			"GetProtectedModeInterruptVector",/* 0.9 AX=0204 */
	2,	1,	(addr)&__dpmi_set_protected_mode_interrupt_vector,
			"SetProtectedModeInterruptVector",/* 0.9 AX=0205 */
	2,	1,	(addr)&__dpmi_get_extended_exception_handler_vector_pm,
			"GetExtendedExceptionHandlerVectorPm",/* 1.0 AX=0210 */
	2,	1,	(addr)&__dpmi_get_extended_exception_handler_vector_rm,
			"GetExtendedExceptionHandlerVectorRm",/* 1.0 AX=0211 */
	2,	1,	(addr)&__dpmi_set_extended_exception_handler_vector_pm,
			"SetExtendedExceptionHandlerVecorPm",/* 1.0 AX=0212 */
	2,	1,	(addr)&__dpmi_set_extended_exception_handler_vector_rm,
			"SetExtendedExceptionHandlerVecorRm",/* 1.0 AX=0213 */
	2,	1,	(addr)&__dpmi_simulate_real_mode_interrupt,
			"SimulateRealModeInterrupt",    /* 0.9 AX=0300 */
	1,	1,	(addr)&__dpmi_simulate_real_mode_procedure_retf,
			"SimulateRealModeProcedureRetf",/* 0.9 AX=0301 */
	1,	1,	(addr)&__dpmi_simulate_real_mode_procedure_iret,
			"SimulateRealModeProcedureIret",/* 0.9 AX=0302 */
	3,	1,	(addr)&__dpmi_allocate_real_mode_callback,
			"AllocateRealModeCallback",     /* 0.9 AX=0303 */
	1,	1,	(addr)&__dpmi_free_real_mode_callback,
			"FreeRealModeCallback",         /* 0.9 AX=0304 */
	2,	1,	(addr)&__dpmi_get_state_save_restore_addr,
			"GetStateSaveRestoreAddr",      /* DPMI 0.9 AX=0305 */
	2,	1,	(addr)&__dpmi_get_raw_mode_switch_addr,
			"GetRawModeSwitchAddr",         /* DPMI 0.9 AX=0306 */
	1,	1,	(addr)&__dpmi_get_version,
			"GetVersion",                   /* DPMI 0.9 AX=0400 */
	2,	1,	(addr)&__dpmi_get_capabilities,
			"GetCapabilities",              /* DPMI 1.0 AX=0401 */
	1,	1,	(addr)&__dpmi_get_free_memory_information,
			"GetFreeMemoryInformation",     /* DPMI 0.9 AX=0500 */
	1,	1,	(addr)&__dpmi_allocate_memory,
			"AllocateMemory",               /* DPMI 0.9 AX=0501 */
	1,	1,	(addr)&__dpmi_free_memory,
			"FreeMemory",                   /* DPMI 0.9 AX=0502 */
	1,	1,	(addr)&__dpmi_resize_memory,
			"ResizeMemory",                 /* DPMI 0.9 AX=0503 */
	2,	1,	(addr)&__dpmi_allocate_linear_memory,
			"AllocateLinearMemory",         /* DPMI 1.0 AX=0504 */
	2,	1,	(addr)&__dpmi_resize_linear_memory,
			"ResizeLinearMemory",           /* DPMI 1.0 AX=0505 */
	2,	1,	(addr)&__dpmi_get_page_attributes,
			"GetPageAttributes",            /* DPMI 1.0 AX=0506 */
	2,	1,	(addr)&__dpmi_set_page_attributes,
			"SetPageAttributes",            /* DPMI 1.0 AX=0507 */
	2,	1,	(addr)&__dpmi_map_device_in_memory_block,
			"MapDeviceInMemoryBlock",       /* DPMI 1.0 AX=0508 */
	2,	1,	(addr)&__dpmi_map_conventional_memory_in_memory_block,
			"MapConventionalMemoryInMemoryBlock",/* DPMI 1.0 AX=0509 */
	1,	1,	(addr)&__dpmi_get_memory_block_size_and_base,
			"GetMemoryBlockSizeAndBase",    /* DPMI 1.0 AX=050a */
	1,	1,	(addr)&__dpmi_get_memory_information,
			"GetMemoryInformation",         /* DPMI 1.0 AX=050b */
	1,	1,	(addr)&__dpmi_lock_linear_region,
			"LockLinearRegion",             /* DPMI 0.9 AX=0600 */
	1,	1,	(addr)&__dpmi_unlock_linear_region,
			"UnlockLinearRegion",           /* DPMI 0.9 AX=0601 */
	1,	1,	(addr)&__dpmi_mark_real_mode_region_as_pageable,
			"MarkRealModeRegionAsPageable", /* DPMI 0.9 AX=0602 */
	1,	1,	(addr)&__dpmi_relock_real_mode_region,
			"RelockRealModeRegion",         /* DPMI 0.9 AX=0603 */
	1,	1,	(addr)&__dpmi_get_page_size,
			"GetPageSize",                  /* DPMI 0.9 AX=0604 */
	1,	1,	(addr)&__dpmi_mark_page_as_demand_paging_candidate,
			"MarkPageAsDemandPagingCandidate",/* DPMI 0.9 AX=0702 */
	1,	1,	(addr)&__dpmi_discard_page_contents,
			"DiscardPageContents",          /* DPMI 0.9 AX=0703 */
	1,	1,	(addr)&__dpmi_physical_address_mapping,
			"PhysicalAddressMapping",       /* DPMI 0.9 AX=0800 */
	1,	1,	(addr)&__dpmi_free_physical_address_mapping,
			"FreePhysicalAddressMapping",   /* DPMI 0.9 AX=0801 */
	0,	1,	(addr)&__dpmi_get_and_disable_virtual_interrupt_state,
			"GetAndDisableVirtualInterruptState",/* DPMI 0.9 AX=0900 */
	0,	1,	(addr)&__dpmi_get_and_enable_virtual_interrupt_state,
			"GetAndEnableVirtualInterruptState",/* DPMI 0.9 AX=0901 */
	1,	1,	(addr)&__dpmi_get_and_set_virtual_interrupt_state,
			"GetAndSetVirtualInterruptState",/* DPMI 0.9 AH=09   */
	0,	1,	(addr)&__dpmi_get_virtual_interrupt_state,
			"GetVirtualInterruptState",	/* DPMI 0.9 AX=0902 */
	2,	1,	(addr)&__dpmi_get_vendor_specific_api_entry_point,
			"GetVendorSpecificApiEntryPoint",/* DPMI 0.9 AX=0a00 */
	2,	1,	(addr)&__dpmi_set_debug_watchpoint,
			"SetDebugWatchpoint",	        /* DPMI 0.9 AX=0b00 */
	1,	1,	(addr)&__dpmi_clear_debug_watchpoint,
			"ClearDebugWatchpoint",	        /* DPMI 0.9 AX=0b01 */
	2,	1,	(addr)&__dpmi_get_state_of_debug_watchpoint,
			"GetStateOfDebugWatchpoint",    /* DPMI 0.9 AX=0b02 */
	1,	1,	(addr)&__dpmi_reset_debug_watchpoint,
			"ResetDebugWatchpoint",	        /* DPMI 0.9 AX=0b03 */
	1,	1,	(addr)&__dpmi_install_resident_service_provider_callback,
			"InstallResidentServiceProviderCallback",/* DPMI 1.0 AX=0c00 */
	2,	1,	(addr)&__dpmi_terminate_and_stay_resident,
			"TerminateAndStayResident",     /* DPMI 1.0 AX=0c01 */
	1,	1,	(addr)&__dpmi_allocate_shared_memory,
			"AllocateSharedMemory",	        /* DPMI 1.0 AX=0d00 */
	1,	1,	(addr)&__dpmi_free_shared_memory,
			"FreeSharedMemory",     	/* DPMI 1.0 AX=0d01 */
	2,	1,	(addr)&__dpmi_serialize_on_shared_memory,
			"SerializeOnSharedMemory",      /* DPMI 1.0 AX=0d02 */
	2,	1,	(addr)&__dpmi_free_serialization_on_shared_memory,
			"FreeSerializationOnSharedMemory",/* DPMI 1.0 AX=0d03 */
	0,	1,	(addr)&__dpmi_get_coprocessor_status,
			"GetCoprocessorStatus",         /* DPMI 1.0 AX=0e00 */
	1,	1,	(addr)&__dpmi_set_coprocessor_emulation,
			"SetCoprocessorEmulation",      /* DPMI 1.0 AX=0e01 */
			END ))
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
    if (register_funcs(	 /***** <grx20.h> *****/
        0,      1,      (addr)&_addr_GrDriverInfo,      "&GrDriverInfo",
        0,      1,      (addr)&_addr_GrContextInfo,     "&GrContextInfo",
        0,	1,	(addr)&_addr_GrDefaultFont,     "&GrDefaultFont",
        0,      1,      (addr)&_addr_GrMouseInfo,       "&GrMouseInfo",
        0,      1,      (addr)&_addr_GrColorInfo,       "&GrColorInfo",
        5,      0,      (addr)&_GGetImage,              "_GGetImage",
        4,      0,      (addr)&_GPutImage,              "_GPutImage",
       //////////////////////////////////
       //   setup stuff                // 
       //////////////////////////////////
        1,      1,      (addr)&GrSetDriver,     "GrSetDriver",
      UNKNOWN,  1,      (addr)&GrSetMode,       "GrSetMode",
        1,      0,      (addr)&GrSetModeHook,   "GrSetModeHook",
        2,      1,      (addr)&GrSetViewport,   "GrSetViewport",
        1,      0,      (addr)&GrSetModeRestore,        "GrSetModeRestore",
        1,      0,      (addr)&GrSetErrorHandling,      "GrSetErrorHandling",
        1,      0,      (addr)&GrSetEGAVGAmonoDrawnPlane,"GrSetEGAVGAmonoDrawnPlane",
        1,      0,      (addr)&GrSetEGAVGAmonoShownPlane,"GrSetEGAVGAmonoShownPlane",
                                                               END ))
    if (register_funcs(
       //////////////////////////////////
       //   inquiry stuff              //
       //////////////////////////////////
        0,      1,      (addr)&GrCurrentMode,   "GrCurrentMode",
        0,      1,      (addr)&GrAdapterType,   "GrAdapterType",
        0,      1,      (addr)&GrCurrentFrameMode,      "GrCurrentFrameMode",
        0,      1,      (addr)&GrScreenFrameMode,       "GrScreenFrameMode",
        0,      1,      (addr)&GrCoreFrameMode, "GrCoreFrameMode",
        0,      1,      (addr)&GrCurrentVideoDriver,   "GrCurrentVideoDriver",
        0,      1,      (addr)&GrCurrentVideoMode,      "GrCurrentVideoMode",
        0,      1,      (addr)&GrVirtualVideoMode,      "GrVirtualVideoMode",
        0,      1,      (addr)&GrCurrentFrameDriver,    "GrCurrentFrameDriver",
        0,      1,      (addr)&GrScreenFrameDriver,     "GrScreenFrameDriver",
        1,      1,      (addr)&GrFirstVideoMode,        "GrFirstVideoMode",
        1,      1,      (addr)&GrNextVideoMode, "GrNextVideoMode",
        0,      1,      (addr)&GrScreenX,       "GrScreenX",
        0,      1,      (addr)&GrScreenY,       "GrScreenY",
        0,      1,      (addr)&GrVirtualX,      "GrVirtualX",
        0,      1,      (addr)&GrVirtualY,      "GrVirtualY",
        0,      1,      (addr)&GrViewportX,     "GrViewportX",
        0,      1,      (addr)&GrViewportY,     "GrViewportY",
        0,      1,      (addr)&GrScreenIsVirtual,       "GrScreenIsVirtual",
       ////////////////////////////////////////////////////////////////
       //  RAM context geometry and memory allocation inquiry stuff  //
       ////////////////////////////////////////////////////////////////
        1,      1,      (addr)&GrFrameNumPlanes,        "GrFrameNumPlanes",
        2,      1,      (addr)&GrFrameLineOffset,       "GrFrameLineOffset",
        3,      1,      (addr)&GrFramePlaneSize,        "GrFramePlaneSize",
        3,      1,      (addr)&GrFrameContextSize,      "GrFrameContextSize",
        0,      1,      (addr)&GrNumPlanes,     "GrNumPlanes",
        1,      1,      (addr)&GrLineOffset,    "GrLineOffset",
        2,      1,      (addr)&GrPlaneSize,     "GrPlaneSize",
        2,      1,      (addr)&GrContextSize,   "GrContextSize",     END ))
    if (register_funcs(
       ////////////////////////////////////////////////////////////////
       //    FRAME BUFFER, CONTEXT AND CLIPPING STUFF	             //
       ////////////////////////////////////////////////////////////////
        4,      1,      (addr)&GrCreateContext, "GrCreateContext",
        5,      1,      (addr)&GrCreateFrameContext,    "GrCreateFrameContext",
        6,      1,      (addr)&GrCreateSubContext, "GrCreateSubContext",
        1,      1,      (addr)&GrSaveContext,   "GrSaveContext",
        0,      1,      (addr)&GrCurrentContext,        "GrCurrentContext",
        0,      1,      (addr)&GrScreenContext, "GrScreenContext",
        1,      0,      (addr)&GrDestroyContext,   "GrDestroyContext",
        5,      0,      (addr)&GrResizeSubContext, "GrResizeSubContext",
        1,      0,      (addr)&GrSetContext,    "GrSetContext",

        4,      0,      (addr)&GrSetClipBox,    "GrSetClipBox",         
        5,      0,      (addr)&GrSetClipBoxC,   "GrSetClipBoxC",
        4,      0,      (addr)&GrGetClipBox,    "GrGetClipBox",         
        5,      0,      (addr)&GrGetClipBoxC,   "GrGetClipBoxC",
        0,      0,      (addr)&GrResetClipBox,  "GrResetClipBox",
        1,      0,      (addr)&GrResetClipBoxC, "GrResetClipBoxC",

        0,      1,      (addr)&GrMaxX,          "GrMaxX",
        0,      1,      (addr)&GrMaxY,          "GrMaxY",
        0,      1,      (addr)&GrSizeX,         "GrSizeX",
        0,      1,      (addr)&GrSizeY,         "GrSizeY",
        0,      1,      (addr)&GrLowX,          "GrLowX",
        0,      1,      (addr)&GrLowY,          "GrLowY",
        0,      1,      (addr)&GrHighX,         "GrHighX",
        0,      1,      (addr)&GrHighY,         "GrHighY",      END ))
    if (register_funcs(
       /////////////////////
       //   COLOR STUFF   //
       /////////////////////
        1,      1,      (addr)&GrColorValue,    "GrColorValue",
        1,      1,      (addr)&GrColorMode,     "GrColorMode",
        1,      1,      (addr)&GrWriteModeColor,"GrWriteModeColor",
        1,      1,      (addr)&GrXorModeColor,  "GrXorModeColor",
        1,      1,      (addr)&GrOrModeColor,   "GrOrModeColor",
        1,      1,      (addr)&GrAndModeColor,  "GrAndModeColor",
        1,      1,      (addr)&GrImageModeColor,"GrImageModeColor",

        0,      0,      (addr)&GrResetColors,   "GrResetColors",
        0,      0,      (addr)&GrSetRGBcolorMode,       "GrSetRGBcolorMode",
        0,      0,      (addr)&GrRefreshColors, "GrRefreshColors",

        0,      1,      (addr)&GrNumColors,     "GrNumColors",
        0,      1,      (addr)&GrNumFreeColors, "GrNumFreeColors",

        0,      1,      (addr)&GrBlack,         "GrBlack",
        0,      1,      (addr)&GrWhite,         "GrWhite",
        
        3,      1,      (addr)&GrBuildRGBcolorT,"GrBuildRGBcolorT",
        3,      1,      (addr)&GrBuildRGBcolorR,"GrBuildRGBcolorR",
        1,      1,      (addr)&GrRGBcolorRed,   "GrRGBcolorRed",
        1,      1,      (addr)&GrRGBcolorGreen, "GrRGBcolorGreen",
        1,      1,      (addr)&GrRGBcolorBlue,  "GrRGBcolorBlue",

        3,      1,      (addr)&GrAllocColor,    "GrAllocColor",
        3,      1,      (addr)&GrAllocColorID,  "GrAllocColorID",
        0,      1,      (addr)&GrAllocCell,     "GrAllocCell",

        4,      0,      (addr)&GrSetColor,      "GrSetColor",
        1,      0,      (addr)&GrFreeColor,     "GrFreeColor",

        4,      0,      (addr)&GrQueryColor,    "GrQueryColor",
        4,      0,      (addr)&GrQueryColorID,  "GrQueryColorID",

        0,      1,      (addr)&GrColorSaveBufferSize,   "GrColorSaveBufferSize",
        1,      0,      (addr)&GrSaveColors,    "GrSaveColors",
        1,      0,      (addr)&GrRestoreColors, "GrRestoreColors",  END ))
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
        (4+(sizeof(gr_ellipse_points)/4)),   1,
                        (addr)&GrGenerateEllipse,       "GrGenerateEllipse",
        (6+(sizeof(gr_ellipse_points)/4)),   1,
                        (addr)&GrGenerateEllipseArc,    "GrGenerateEllipseArc",
        6,      0,      (addr)&GrLastArcCoords, "GrLastArcCoords",
        4,      0,      (addr)&GrCircle,        "GrCircle",
        5,      0,      (addr)&GrEllipse,       "GrEllipse",
        7,      0,      (addr)&GrCircleArc,     "GrCircleArc",
        8,      0,      (addr)&GrEllipseArc,    "GrEllipseArc",

        4,      0,      (addr)&GrFilledCircle,  "GrFilledCircle",
        5,      0,      (addr)&GrFilledEllipse, "GrFilledEllipse",
        7,      0,      (addr)&GrFilledCircleArc,  "GrFilledCircleArc",
        8,      0,      (addr)&GrFilledEllipseArc, "GrFilledEllipseArc",

        3,      0,      (addr)&GrPolyLine,      "GrPolyLine",
        3,      0,      (addr)&GrPolygon,       "GrPolygon",
        3,      0,      (addr)&GrFilledConvexPolygon,   "GrFilledConvexPolygon",
        3,      0,      (addr)&GrFilledPolygon, "GrFilledPolygon",
        9,      0,      (addr)&GrBitBlt,        "GrBitBlt",
        2,      1,      (addr)&GrPixel,         "GrPixel",      
        3,      1,      (addr)&GrPixelC,        "GrPixelC",     END ))
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
	2,	1,	(addr)&GrPixelNC,	"GrPixelNC",	
        3,      1,      (addr)&GrPixelCNC,      "GrPixelCNC",   END ))
    if (register_funcs(	

// <<<------ here BELOW

       ////////////////////////////////////////
       //     FONTS AND TEXT PRIMITIVES      //
       ////////////////////////////////////////
	1,	1,	(addr)&GrLoadFont,	"GrLoadFont",
//	1,	1,	(addr)&GrLoadBIOSFont,	"GrLoadBIOSFont",
	1,	0,	(addr)&GrUnloadFont,	"GrUnloadFont",
	1,	0,	(addr)&GrSetFontPath,	"GrSetFontPath",

	4,	0,	(addr)&GrDrawChar,	"GrDrawChar",
	5,	0,	(addr)&GrDrawString,	"GrDrawString",
	5,	0,	(addr)&GrTextXY,	"GrTextXY",
	4,	0,	(addr)&GrDumpChar,	"GrDumpChar",
	5,	0,	(addr)&GrDumpText,	"GrDumpText",
	1,	0,	(addr)&GrDumpTextRegion,"GrDumpTextRegion",

//	1,	1,	(addr)&GrFontHeight,	"GrFontHeight",
//	1,	1,	(addr)&GrFontWidth,	"GrFontWidth",
	2,	1,	(addr)&GrCharWidth,	"GrCharWidth",
	2,	1,	(addr)&GrCharHeight,	"GrCharHeight",
	3,	1,	(addr)&GrStringWidth,	"GrStringWidth",
	3,	1,	(addr)&GrStringHeight,	"GrStringHeight",   END ))
// <<<------ here above
       /////////////////////////////////////////////////
       //    MOUSE AND KEYBOARD INPUT UTILITIES	      //
       /////////////////////////////////////////////////
    if (register_funcs(
        0,      1,      (addr)&GrMouseDetect,   "GrMouseDetect",
        1,      0,      (addr)&GrMouseEventMode,        "GrMouseEventMode",
        0,      0,      (addr)&GrMouseInit,     "GrMouseInit",
        1,      0,      (addr)&GrMouseInitN,    "GrMouseInitN",
        0,      0,      (addr)&GrMouseUnInit,   "GrMouseUnInit",
        2,      0,      (addr)&GrMouseSetSpeed, "GrMouseSetSpeed",
        2,      0,      (addr)&GrMouseSetAccel, "GrMouseSetAccel",
        4,      0,      (addr)&GrMouseSetLimits,        "GrMouseSetLimits",
        4,      0,      (addr)&GrMouseGetLimits,        "GrMouseGetLimits",
        2,      0,      (addr)&GrMouseWarp,     "GrMouseWarp",
        2,      0,      (addr)&GrMouseEventEnable,      "GrMouseEventEnable",
        2,      0,      (addr)&GrMouseGetEvent, "GrMouseGetEvent",
        3,      0,      (addr)&GrMouseGetEventT,        "GrMouseGetEventT",
        0,      1,      (addr)&GrMousePendingEvent,     "GrMousePendingEvent",

        0,      1,      (addr)&GrMouseGetCursor,        "GrMouseGetCursor",
        1,      0,      (addr)&GrMouseSetCursor,        "GrMouseSetCursor",
        2,      0,      (addr)&GrMouseSetColors,        "GrMouseSetColors",
     UNKNOWN,   0,      (addr)&GrMouseSetCursorMode,    "GrMouseSetCursorMode",
        0,      0,      (addr)&GrMouseDisplayCursor,    "GrMouseDisplayCursor",
        0,      0,      (addr)&GrMouseEraseCursor,      "GrMouseEraseCursor",
        0,      0,      (addr)&GrMouseUpdateCursor,     "GrMouseUpdateCursor",
        0,      1,      (addr)&GrMouseCursorIsDisplayed,        "GrMouseCursorIsDisplayed",

        5,      1,      (addr)&GrMouseBlock,    "GrMouseBlock",
        1,      0,      (addr)&GrMouseUnBlock,  "GrMouseUnBlock",

        0,      1,      (addr)&getkbstat,       "getkbstat",

       /////////////////////////////////////////////////
       //     MISCELLANEOUS UTILITIY FUNCTIONS	      //
       /////////////////////////////////////////////////
        6,      0,      (addr)&GrResizeGrayMap, "GrResizeGrayMap",
        2,      1,      (addr)&GrMatchString,   "GrMatchString",      END ))

    /* ---------------------------------------------------------------- */
//    if (register_funcs(	 /***** <libbcc.h> *****/
//        5,      0,      (addr)&getimage,        "getimage",
//        4,      0,      (addr)&putimage,        "putimage",
//        4,      0,      (addr)&imagesize,       "imagesize",        END ))
    /* ---------------------------------------------------------------- */
    {
       return (1==1);
    }

  return (1==0);
}

