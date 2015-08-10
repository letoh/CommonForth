//
//  Translate Loading Information for PC Common Forth
//  GO32 Version ( DJGPP + GO32 )
//
//				Version 1.0
//				Written by Luke Lee
//				Last update : 10/04/'95
//


STRUCT: Go32LoadingInfo
  	WORD:  |size_of_this_structure_in_bytes
  	WORD:  |linear_address_of_primary_screen
  	WORD:  |linear_address_of_secondary_screen
  	WORD:  |linear_address_of_transfer_buffer
  	WORD:  |size_of_transfer_buffer
  	WORD:  |pid
  	BYTE:  |master_interrupt_controller_base
  	BYTE:  |slave_interrupt_controller_base
  	HWORD: |selector_for_linear_memory
  	WORD:  |linear_address_of_stub_info_structure
  	WORD:  |linear_address_of_original_psp
  	HWORD: |run_mode
  	HWORD: |run_mode_info
;STRUCT: LoaderInfo

0  CONSTANT  _go32_run_mode_undef
1  CONSTANT  _go32_run_mode_raw
2  CONSTANT  _go32_run_mode_xms
3  CONSTANT  _go32_run_mode_vcpi
4  CONSTANT  _go32_run_mode_dpmi

//
//  Standard Interface for CF system, the following interface should
//  be implemented under any loader .
//

: MasterPICbase (( -- a ))
     // if unknown to loader, do ABORT in case accidental use.
	BASE-ADDRESS |INIT-ENVIRON |LoadingInfo 
	|master_interrupt_controller_base   C@  ; 0 1 #PARMS

: SlavePICbase	(( -- a ))
     // if unknown to loader, do ABORT in case accidental use.
	BASE-ADDRESS |INIT-ENVIRON |LoadingInfo 
	|slave_interrupt_controller_base   C@   ; 0 1 #PARMS

