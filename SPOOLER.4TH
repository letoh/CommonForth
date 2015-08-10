// Printer SPOOLER 
//				Written by  : Luke Lee
//				Version     : 1.1
//				     update : 01/20/'96 V1.0
//				Last update : 07/10/'96 V1.1


0 VALUE PrinterID    // printer number, 0..2, default=0 : LPT1

HIDDEN ALSO DEFINITIONS

40 CONSTANT SPO#MaxFileNameLength
50 CONSTANT SPO#MaxFilesToPrint

SPO#MaxFileNameLength SPO#MaxFilesToPrint ARRAY: []SpoolerQueue
0 VALUE #FilesInSpooler

0 VALUE HndToPrint

128 CONSTANT Spooler|BUFSIZ|
CREATE ReadBuffer Spooler|BUFSIZ| ALLOT

VARIABLE TerminateSpooler 

: SpoolerMessageTitle	(( -- ))
	SINGLE CR BEEP ." *** Message from SPOOLER : " CR 2 SPACES ;
: SpoolerMessageEnd	(( -- ))
	."  ... " HERROR$ TYPE CR MULTI ;
: FailOpenFileMessage	(( err-code -- ))
	SpoolerMessageTitle
	." Fail openning file"
	SpoolerMessageEnd ;
: FailOpenPrinterMessage	(( err-code -- ))
	SpoolerMessageTitle
	." Fail openning printer device at PRN:"
	SpoolerMessageEnd ;
: FailReadingMessage	(( err-code -- ))
	SpoolerMessageTitle
     	." Error reading file"
	SpoolerMessageEnd ;
: FailWritingMessage	(( err-code -- ))
	SpoolerMessageTitle
     	." Error writing printer"
	SpoolerMessageEnd ;

: PrinterError?		(( status -- T/F ))
        DUP $2800 AND 0<> DUP IF
           SpoolerMessageTitle
           ."  Printer "
           OVER $2000 AND IF ." out of paper " ENDIF
           OVER $0800 AND IF ." , I/O error "  ENDIF
           ASCII . EMIT CR MULTI
        ENDIF
        NIP ; 1 1 #PARMS

: WaitPrinterNotBusy       (( -- T/F ))
        BEGIN
            PAUSE
         // EBP EDI ESI EDX                ECX EBX EAX   int#/flag
            2DUP    DUP PrinterID $03 AND  2DUP    $0200    $17    trap
                                                            DROP
					           >R
            6DROP
            R@ PrinterError? NOT
            WHILE
                R> $8000 AND 0<>          // AH bit7=1 : not busy
        UNTIL
                TRUE
            ELSE
                RDROP FALSE
            THEN
        ; 0 1 #PARMS

: PrintOneByte  (( c -- T/F ))
        $00FF AND >R
     // EBP EDI ESI EDX                ECX EBX EAX   int#/flag
        2DUP    DUP PrinterID $03 AND  2DUP    R>    $17    trap
                                                     >R
        7DROP
        R> PrinterError? NOT ; 1 1 #PARMS

: PrintBuffer   (( buffer size -- T/F ))
        0 DO
           WaitPrinterNotBusy  ANDTHEN
           DUP C@ PrintOneByte THEN-AND
           WHILE
              1+
        LOOP
              TRUE
           ELSE
              3RDROP FALSE
           THEN
        NIP ; 2 1 #PARMS

: PrintOneFile	(( -- ))
     	BEGIN
     	   ReadBuffer Spooler|BUFSIZ| HndToPrint HREAD // Rbytes T | Rerrcode F
     	   WHILE			// Rbytes
     	      ReadBuffer OVER           // Rbytes buffer Rbytes
	      PrintBuffer  TerminateSpooler @ NOT  AND
	      WHILE
     	          Spooler|BUFSIZ| <	// T/F
     	UNTIL				// <empty>
	          12 PrintOneByte DROP  // print a form feed.
	      ELSE			// Rbytes
		  DROP
	      THEN			// Terminated
     	   ELSE			    	// Rerrcode
	      FailReadingMessage
     	   THEN
     	HndToPrint HCLOSE DROP   ; 0 0 #PARMS

CREATE PrinterFileName 10 ALLOT

BACKGROUND: SPOOLER
    	BEGIN
	   BEGIN
	      #FilesInSpooler 0>  TerminateSpooler @ NOT   AND
	   WHILE
              PrinterFileName OFF
              PrinterFileName " LPT" $+ PrinterID 1+ $03 AND <# #S #> $+
              COUNT WRITE/ONLY OPEN IF
	         HCLOSE DROP
		 0 []SpoolerQueue COUNT READ/ONLY OPEN IF
		     to HndToPrint PrintOneFile
		 ELSE
		     FailOpenFileMessage
		 ENDIF
		 1 []SpoolerQueue  0 []SpoolerQueue
		 #FilesInSpooler SPO#MaxFileNameLength *  MOVE
		 #FilesInSpooler 1- to #FilesInSpooler
	      ELSE
	      	 FailOpenPrinterMessage   0 to #FilesInSpooler
	      ENDIF
	   REPEAT
	   SELF-SLEEP
    	AGAIN ;

: NoFileInQueue  ." * No file in queue currently." CR ;

FORTH DEFINITIONS

: $PRINT	(( $"filename" -- ))
      // Print text file by SPOOLER
      	TerminateSpooler OFF
	#FilesInSpooler SPO#MaxFilesToPrint < IF
	    DUP COUNT READ/ONLY OPEN IF // Try open, test if exist.
	       HCLOSE DROP
	       #FilesInSpooler []SpoolerQueue
	       OVER C@ 1+ SPO#MaxFileNameLength MIN  MOVE
	       #FilesInSpooler 1+ TO #FilesInSpooler
	       SPOOLER WAKE MULTI
     	    ELSE
     	       ." * Fail openning file " SWAP COUNT TYPE
	       ." : " HERROR$ TYPE CR
     	    ENDIF
	ELSE
	    CR ." * SPOOLER buffer full, can't print file "
	    COUNT TYPE ." ." CR
	ENDIF ; 1 0 #PARMS

: PRINT    (( -- )TIB: <filename> )
      // Print a file by SPOOLER
	BL WORD $PRINT ; 0 0 #PARMS

: SPOOLER/STATUS
	CR ." * SPOOLER Status :"
	CR ." * Max number of files to print : " SPO#MaxFilesToPrint . 
	CR ." * Number of files in SPOOLER queue : " #FilesInSpooler . CR
	#FilesInSpooler 0> IF
	   ." * Currently printing : " 0 []SpoolerQueue COUNT TYPE CR
	   #FilesInSpooler 1 > IF
	      ." * File(s) in queue :" CR
	      #FilesInSpooler 1 ?DO
	         ."   File " #I 2 U.0R ." : " #I []SpoolerQueue COUNT TYPE CR
	         NUF? ?LEAVE
	      LOOP 
	   ELSE
	      NoFileInQueue
	   ENDIF
	ELSE
	   NoFileInQueue
	ENDIF ;

: SPOOLER/RESET
	MULTI? MULTI
	0 TO #FilesInSpooler
        0 TO PrinterID   // print to LPT1 by default
	TerminateSpooler ON 
	SPOOLER WAKE
	BEGIN    PAUSE SPOOLER TASK-STATE? TASK-AWAKE <>    UNTIL
	TerminateSpooler OFF
	NOT IF SINGLE ENDIF ; 0 0 #PARMS

: SPOOLER/SUSPEND	SPOOLER SLEEP ; 0 0 #PARMS

: SPOOLER/CONTINUE	SPOOLER WAKE ; 0 0 #PARMS

ONLY FORTH ALSO DEFINITIONS

