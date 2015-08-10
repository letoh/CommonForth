// MULTASK.4TH
//   High level multitasking code since Common Forth Experiment Version 1.570

                                                // Version 2.0
                                                // Written by : Luke Lee
                                                // 05/09/'94 .. 05/11/'94
						// Last update : 04/27/'96

// Doubly circular linked list , round-robin multi-tasking mechanism //

// NOTE !
// There is no need to add STOP while the task is about to stop, this
// multasker automatically insert STOP into your task.

    // 	    update : 05/15/'94  Safety features and task states.
    // 	    update : 08/21/'95  Better condition checks. 
    //			        Root task can't sleep now.
    //      update : 09/19/'95  Add RootTask for convenience
    // 	    update : 10/05/'95  Move SINGLE to kernel CF0.4TH .
    //      update : 10/10/'95  Add UP>TASK for finding task's name.
    // 	    update : 10/14/'95  Add .TASK-STATE and KILL .
    // 	    update : 12/28/'95  Modify ACTIVATE , or stopped task 
    //			        will never wake again.
    //      update : 01/02/'95  Modify SLEEP, any task could SLEEP
    //			        itself by SELF-SLEEP . 
    //			        Also add TASK-STATE? .
    //      update : 01/29/'96  Add USER|DSTACK| and USER|RSTACK| for
    //			        new FSAVE .
    // Last update : 04/27/'96  Modify TASK: to reset new-task's 'RESET-LIST
    //                          in case ABORT executes it. Also modify USER
    //                          to USERVAR (CF0.4TH), also reset 'TIB, >IN,
    //                          #TIB, SPAN and STATE.

ONLY FORTH ALSO DEFINITIONS
DECIMAL

BASE-ADDRESS |WORK-SPACE |USER-AREA   CONSTANT	RootTask  // Root task's UP0
' RootTask >HEAD  'UP>TASK  !

0 CONSTANT TASK-READY
1 CONSTANT TASK-AWAKE
2 CONSTANT TASK-ASLEEP
3 CONSTANT TASK-STOPPED

USERVAR TASK-STATE
TASK-AWAKE TASK-STATE !


SIZEOF |DATA-STACK   #TASKS /  CONSTANT  USER|DSTACK|
SIZEOF |RETURN-STACK #TASKS /  CONSTANT  USER|RSTACK|
VARIABLE ^TASK  	INVISIBLE
VARIABLE ^DSTACK  	INVISIBLE
VARIABLE ^RSTACK	INVISIBLE

UP@ ^TASK !     SP0 @ ^DSTACK !   RP0 @ ^RSTACK !

UP@ SUCCTASK !  UP@ PREVTASK !		// set root task link to itself

: LOCAL         (( ubase uservar -- addr' ))
        UP@ - + ; 2 1 #PARMS

// : SINGLE        (( -- ))	// 10/05/'95 move to CF0.4TH
//         $C3 ['] PAUSE C! ; 0 0 #PARMS

: MULTI         (( -- ))
        $8D ['] PAUSE C! ; 0 0 #PARMS

: MULTI?        (( -- T/F ))
        ['] PAUSE C@ $8D = ; 0 1 #PARMS

: valid-task?     (( task -- T/F ))  // check whether 'task' is a valid addr
        DUP RootTask 
            [ BASE-ADDRESS |WORK-SPACE |END-USER-AREA ] LITERAL WITHIN
	SWAP RootTask - |USERS| MOD 0=  // not |USERS| aligned
	AND  ; 1 1 #PARMS INVISIBLE

: check-valid-task? (( task -- task ))
	DUP valid-task? NOT ABORT" Invalid task address"
	; 1 1 #PARMS INVISIBLE

: SLEEP         (( task -- ))     // ok to sleep twice
        check-valid-task? 
	DUP RootTask
	> IF // root can't sleep.
	    >R // task's user area
	    R@ TASK-STATE LOCAL @ TASK-ASLEEP < IF
               R@ SUCCTASK LOCAL @   R@ PREVTASK LOCAL @ SUCCTASK LOCAL   !
               R@ PREVTASK LOCAL @   R@ SUCCTASK LOCAL @ PREVTASK LOCAL   !
               TASK-ASLEEP R> TASK-STATE LOCAL ! 
	    ELSE
	       RDROP	
	    ENDIF
	ELSE
	    DROP
	ENDIF 
	PAUSE 		// 01/02/'96 ... UP@ SLEEP make self sleep.
	; 1 0 #PARMS

: SELF-SLEEP	(( -- ))	// 01/02/'96
	UP@ SLEEP ; 0 0 #PARMS

: WAKE          (( task -- ))     // ok to wake twice
        check-valid-task?
        DUP PREVTASK LOCAL @ SUCCTASK LOCAL @ OVER 
        <> IF // make this task the current task's succesive task
	    DUP TASK-STATE LOCAL @ TASK-STOPPED <> IF
                >R // task's user area
                SUCCTASK @   R@ SUCCTASK LOCAL   !
                UP@          R@ PREVTASK LOCAL   !
                R@   SUCCTASK @ PREVTASK LOCAL   !
                R@   SUCCTASK  !
                TASK-AWAKE R> TASK-STATE LOCAL !
	    ELSE
		DROP
	    ENDIF
        ELSE // already wake, ignore .
            DROP
        ENDIF  ; 1 0 #PARMS

: STOP	(( -- ))
        UP@ SLEEP TASK-STOPPED TASK-STATE ! PAUSE ; 0 0 #PARMS

: KILL	(( task -- ))	// kill a task immediately 	10/14/'95
	check-valid-task?
	DUP RootTask <> IF
	   DUP SLEEP TASK-STOPPED SWAP TASK-STATE LOCAL !
	ELSE
	   DROP
	ENDIF  ; 1 0 #PARMS

: ^TASK@   ^TASK @ ; 0 1 #PARMS INVIS
: LOCAL!   LOCAL ! ; 3 0 #PARMS INVIS

// All tasks, except for RootTask, have its TIB on the top of return stack,
// just like most other Forth systems are.

: TASK:         (( head-dict-siz code-dict-siz -- ))
        ^TASK @ |USERS| +
        DUP [ BASE-ADDRESS |WORK-SPACE |END-USER-AREA ] LITERAL
        >= ABORT" * Too many tasks."
        CREATE
          DUP ,
          ^TASK !
          USER|DSTACK| NEGATE ^DSTACK +!   USER|RSTACK| NEGATE ^RSTACK +!
          UP@ ^TASK@ |USERS| CMOVE    // inherit parent's user area
          RP@ 
            ^RSTACK @ RP! ['] STOP >R RP@ ^TASK@ RP-SAVED LOCAL !
          RP!               // new task initially executes STOP

          ^DSTACK @ CELL- ^TASK@ SP-SAVED LOCAL! // reserve cell for SET-TASK
          UP@ ^TASK @ PREVTASK LOCAL! // current task is new task's prevtask
          SUCCTASK @  ^TASK@ SUCCTASK  LOCAL!

          ^DSTACK @  ^TASK@ SP0  LOCAL!
          ^RSTACK @ DUP   ^TASK@ RP0  LOCAL!   ^TASK@ 'TIB  LOCAL! // 4/27/96

          HERE  ^TASK@ CP  LOCAL!
          HP @  ^TASK@ HP  LOCAL!
          TASK-READY  ^TASK@ TASK-STATE LOCAL!
	  LAST @  ^TASK@ 'UP>TASK LOCAL!	// reverse link to task's head
          0  ^TASK@ 'RESET-LIST LOCAL!          // 04/27/'96 added
          0  ^TASK@ >IN   LOCAL!                // 04/27/'96 added
          0  ^TASK@ #TIB  LOCAL!                // 04/27/'96 added
          0  ^TASK@ SPAN  LOCAL!                // 04/27/'96 added
          0  ^TASK@ STATE LOCAL!                // 04/27/'96 added

          ALLOT
          ?DUP IF
            |HEAD| /MOD SWAP 0<> IF 1+ |HEAD| * ENDIF // |HEAD| aligned
            NEGATE HP +!
          ENDIF
        DOES>
          @ ; 2 0 #PARMS

: stopped-task  (( -- ))  RECURSIVE
        // after the task is stopped, any accientally wake will cause 
	// it to stop again .
        ['] stopped-task >R STOP ; 0 0 #PARMS INVISIBLE

: exit-task     (( IP -- ))
        CATCH ?DUP IF COUNT TYPE ENDIF
        stopped-task ; 1 0 #PARMS INVISIBLE

: SET-TASK      (( IP TASK -- ))
        >R
        R@ SP0 LOCAL @ CELL- DUP R@ SP-SAVED LOCAL  !  !    // TOS
        ['] exit-task R@ RP0 LOCAL @ CELL- DUP R> RP-SAVED LOCAL ! ! // TOR
        ; 2 0 #PARMS

: ACTIVATE      (( TASK -- ))
        check-valid-task?
        R> OVER SET-TASK 
	TASK-READY   OVER TASK-STATE LOCAL   ! 		// 12/28/'95
	WAKE ; 1 0 #PARMS COMPILEONLY

: BACKGROUND:   (( -- ))
        0 4 K TASK:
        HERE ^TASK @ SET-TASK
        !CSP    ]      ; 0 0 #PARMS

: UP>TASK	(( task -- taskhead ))
	'UP>TASK LOCAL @ ; 1 1 #PARMS

: (TASK.READY)	 ." ready to run ." ;      INVISIBLE
: (TASK.AWAKE)	 ." awake and running ." ; INVISIBLE
: (TASK.ASLEEP)  ." sleeping ." ;	   INVISIBLE
: (TASK.STOPPED) ." stopped ." ; 	   INVISIBLE

CREATE (TASK-STATE.) INVISIBLE
	' (TASK.READY) , 
	' (TASK.AWAKE) ,
	' (TASK.ASLEEP) ,
	' (TASK.STOPPED) ,

: TASK-STATE?	(( ubase -- task-state/-1 ))	// 01/02/'96
	DUP valid-task? IF
	   TASK-STATE LOCAL @	
	ELSE
	   DROP -1
	ENDIF ; 1 1 #PARMS

: .TASK-STATE	(( ubase -- ))		// 10/14/'95
	CR
	DUP valid-task? IF
	   ." Task : " DUP UP>TASK .ID ."  is now "
	   TASK-STATE LOCAL @ 
	   DUP TASK-READY TASK-STOPPED [...] IF
	      TASK-READY - CELL* (TASK-STATE.) + @EXECUTE
	   ELSE
	      DROP ." in unknown status !" CR 
	      ." ! DANGEROUS ! Should be stopped immdiately !" BEEP
	   ENDIF
	ELSE
	   DROP ." .TASK-STATE : Input address is not a valid task address."
	ENDIF
	CR ; 1 0 #PARMS

// Here is a sample of how to create a background task that will do a
// sting of the current file, with the hypothetical word FUNCTION1.  The
// task MYTASK is created with the default function FUNCTION1 assigned to it.
// Next we define a word MYTASK-THIS, what changes the function assigned to
// MYTASK to perform FUNCTION2.  This allows us to change the function a
// task performs without having to define a new task. In each case, the
// task is stopped after its assigned FUNCTION is performed.
//
//
//         BACKGROUND: MYTASK  FUNCTION1 (( STOP )) ;
//
//         : MYTASK-THIS   MYTASK ACTIVATE   FUNCTION2 (( STOP )) ;
//
//
//   This next example defines a variable, and a routine which increments
// the variable in the background.  Notice that the program is an infinite
// loop, and will only stop when put to sleep, or when multi tasking is
// turned off with SINGLE.  This example will actually work, you might try
// typing it into a file and loading it.
//
//
// VARIABLE COUNTS
// BACKGROUND: COUNTER     BEGIN
//                             PAUSE  1 COUNTS +!
//                         AGAIN   ;
//
// MULTI COUNTER WAKE              // start up the COUNTER task
//
// COUNTER SLEEP                 // put the COUNTER task to sleep
// SINGLE                        // disable multi tasking

ONLY FORTH ALSO DEFINITIONS

