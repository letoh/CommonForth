//
//  Translate Loading Information for PC Common Forth
//  Watcom Version
//
//				Version 1.0
//				Written by Luke Lee
//				Last update : 10/04/'95
//


// //////////////////////////////////////////////////////////////////// //
//  Standard Interface for CF system, the following interface should	//
//  be implemented under any loader .					//
// ////////////////////////////////////////////////////////////////////	//

: MasterPICbase (( -- a ))	$8 ; 0 1 #PARMS
: SlavePICbase	(( -- a ))	$70 ; 0 1 #PARMS

