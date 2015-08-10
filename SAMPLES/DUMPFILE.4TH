128 CONSTANT |BUFSIZ|
CREATE ReadBuffer |BUFSIZ| ALLOT

: DUMPFILE	(( -- ))
     BL WORD COUNT READ/ONLY OPEN IF 
        >R		// R: handle
        BEGIN
           ReadBuffer |BUFSIZ| R@ HREAD // bytes T | errcode F // R: handle
           WHILE			// bytes  // R: handle
              ReadBuffer OVER TYPE	// <balance>
              |BUFSIZ| < NUF? OR	// T/F    // R: handle
        UNTIL			    	// <empty> // R: handle
           ELSE			    	// errcode // R: handle
     	      ." * Error reading file " CR // <balance>
	      ." Error message : " HERROR$ (( err -- str len )) 
     	      TYPE			// <empty> // R: handle
           THEN		// R: handle
        R> HCLOSE DROP
     ELSE
        ." * Fail openning file : " HERROR$ TYPE CR
     ENDIF ;

