// Simple Editor In full graphics mode.

// Ehhance KEYBUF.4TH
                                      // Written by Luke Lee for Prof. Chin
                                      // Version 1.0
                                      // Last update  [ 10/25/'95 ]

NEEDS KEYBUF.4TH        // in HIDDEN vocabulary
NEEDS GRAPHICS.4TH

GRAPHICS-MODE

VOCABULARY SimpleEditor
ALSO GRAPHICS ALSO HIDDEN ALSO SimpleEditor ALSO DEFINITIONS

2048          CONSTANT  ed#max-lines
cmd-length 1+ CONSTANT  ed#max-chars

ed#max-lines 1+ ed#max-chars *  CONSTANT    |EditorBuffer|

0 VALUE EditorBuffer
CREATE  (EditorBuffer)  |EditorBuffer|  ALLOT
(EditorBuffer) TO EditorBuffer
        EditorBuffer    |EditorBuffer|  ERASE
: []EditorBuffer        (( n -- l ))
        ed#max-lines MIN ed#max-chars * EditorBuffer + ; 1 1 #PARMS

GrContext  UserScreenContext
CREATE  UserScreen
        GrSizeX  GrSizeY  GrContextSize  ALLOT

GrContext  InvertContext
CREATE  InvertBar
        GrSizeX  G_cell_height 4 +  GrContextSize  ALLOT

SimpleEditor DEFINITIONS

// Original status
0 VALUE CursorState0
0 VALUE OldScrollX0  0 VALUE OldScrollX1 
0 VALUE OldScrollY0  0 VALUE OldScrollY1
0 VALUE Old#column   0 VALUE Old#row
0 VALUE OldScrolling
0 VALUE OldGrCursorLoc
0 VALUE dokey0
0 VALUE PROMPT0
0 VALUE saved_#chars_got 
0 VALUE saved_#max_got
GrTextOption  OldTextOpt

// Keystroke definition

CTRL B  CONSTANT  ^b    // browse mode

  $2D EXTKEY: alt-x     // leave editor
  $16 EXTKEY: alt-u     // undo
  $26 EXTKEY: alt-l     // mark line
  $25 EXTKEY: alt-k     // del to end of line
  $1E EXTKEY: alt-a     // append block to file
  $11 EXTKEY: alt-w     // write block to file
  $13 EXTKEY: alt-r     // read block from file
  $20 EXTKEY: alt-d     // delete line
  $12 EXTKEY: alt-e     // edit a file
  $21 EXTKEY: alt-f     // display file name

  $23 EXTKEY: alt-h     // append history toggle
  $0F EXTKEY: sft-tab

  73  EXTKEY: pgup               81  EXTKEY: pgdn
  119 EXTKEY: ctrl-home
  132 EXTKEY: ctrl-pgup          118 EXTKEY: ctrl-pgdn

  59  EXTKEY: kF1  // Help
  60  EXTKEY: kF2  // file save
  61  EXTKEY: kF3  
  62  EXTKEY: kF4
  63  EXTKEY: kF5  // show user screen
  64  EXTKEY: kF6
  65  EXTKEY: kF7  
  66  EXTKEY: kF8
  67  EXTKEY: kF9  // refresh editor screen
  68  EXTKEY: kF10

DEFER EditorDokey 4 2 #PARMS // for forward reference

// Editor status  //

0 CONSTANT BrowseMode
1 CONSTANT ReplaceMode
2 CONSTANT InsertMode

0 CONSTANT NotHelping
1 CONSTANT HelpFromEditor
2 CONSTANT HelpFromCommand

GrTextOption  EditorTextOpt
GrTextOption  EditorStatusTextOpt

80 CONSTANT Ed#col
28 CONSTANT Ed#row
0  VALUE    EdStatusCharWidth
0  VALUE    EdStatusCharHeight

0  VALUE Edx0   0 VALUE Edy0   0 VALUE Edx1  0 VALUE Edy1

TRUE  VALUE AppendToEditor      // append any history into editor buffer
FALSE VALUE EditorOpened
FALSE VALUE FileModified

NotHelping VALUE HelpMode
-1         VALUE EditorMode

0  VALUE TotalLines
0  VALUE DisplayLine
0  VALUE CurrentLine
0  VALUE CurrentColumn
0  VALUE HomeCount      // number of home pressed
0  VALUE EndCount       // number of end pressed
0  VALUE Marking
-1 VALUE MarkStart      // no marking line
-1 VALUE MarkEnd

0 VALUE help_saved_#chars_got 
0 VALUE help_saved_#max_got
0 VALUE help_CurrentLine
0 VALUE help_TotalLines
0 VALUE help_CurrentColumn
0 VALUE help_DisplayLine
0 VALUE help_Marking
0 VALUE help_MarkStart
0 VALUE help_MarkEnd
0 VALUE help_EditorBuffer
0 VALUE help_FileModified
0 VALUE help_EditorMode

0 VALUE CurrFile
CREATE  AppendFName  41 ALLOT   AppendFName  41 ERASE
CREATE  ReadFName    41 ALLOT   ReadFName    41 ERASE
CREATE  WriteFName   41 ALLOT   WriteFName   41 ERASE
CREATE  EditFName    41 ALLOT   EditFName    41 ERASE
CREATE  TmpFName     41 ALLOT   TmpFName     41 ERASE   
CREATE  HelpTmpFName 41 ALLOT   HelpTmpFName 41 ERASE

CREATE StatusLine  ed#max-chars ALLOT 0 ,

: $Browse       Z$" Browse"  ; 0 1 #PARMS
: $Replace      Z$" Replace" ; 0 1 #PARMS
: $Insert       Z$" Insert"  ; 0 1 #PARMS

CREATE (Mode$s) ' $Browse , ' $Replace , ' $Insert ,
: Mode$   EditorMode CELL* (Mode$s) + @EXECUTE ; 0 1 #PARMS

: NoModify?     (| key -- T/F |)
        key ctrl-left = ORELSE key ctrl-right = ORELSE key ins = ORELSE
        key left = ORELSE key right = ORELSE key home = ORELSE key end =
        ELSE-OR to T/F ;

: ClearKeyBuf (( -- ))  BEGIN ?KEY WHILE DROP REPEAT ; 0 0 #PARMS

: Old-dokey  (( buf #chars_got #max_got key -- #chars_got' #max_got' ))
        dokey0 EXECUTE ; 4 2 #PARMS

: RefreshCursor  (| -- |)
        CurrentColumn CurrentLine DisplayLine - AT ;

: DrawStatusString      (| | drstr drlen -- |)
        StatusLine COUNT to drlen to drstr      
        GrDrawString( drstr , drlen , 1 , Edy1 1+ , EditorStatusTextOpt ) ;

: ClearStatusLine       (| -- |)
        StatusLine Ed#col 0 FILL
        GrFilledBox( 0 , Edy1 1+ , GrMaxX , GrMaxY , 
                     EditorStatusTextOpt |txo_bgcolor |v @ )  ;

: RefreshStatusLine     (| | mdchr -- |)
        RefreshCursor ClearStatusLine
        FileModified IF  ASCII *  ELSE  BL  ENDIF to mdchr
// sprintf( StatusLine 1+ , Z$" line %d column %d disp %d at %d total %d marking %d start %d end %d" , 
// CurrentLine , CurrentColumn , DisplayLine , CurrentLine DisplayLine - , TotalLines , Marking , MarkStart , MarkEnd )
        sprintf( StatusLine 1+ , 
                 Z$"   File %s %c Line : %d  Column : %d     %s Mode " ,
                 EditFName 1+ , mdchr , CurrentLine 1+ , CurrentColumn 1+ ,
                 Mode$ );
        StatusLine C!  DrawStatusString ;

: InvertLine    (| line | x0 y0 -- |)
     // invert color of 'line'
        line DisplayLine DUP Ed#row 1- + [...] IF
           0 line DisplayLine - GCursor>Coord to y0 to x0
           G_HideCursor
           GrBitBlt( NULL , x0 , y0 , InvertContext ,
                     0 , 0 , GrMaxX , G_cell_height 1- , GrXOR );
        ENDIF ;

: Marked?       (( line -- marked? ))
        MarkStart MarkEnd 2DUP MIN -ROT MAX  [...]  ; 1 1 #PARMS

: RefreshScreen         (| | thisline -- |)
//      Edx0 Edy0 Edx1 Edy1 Ed#col Ed#row GSetScrollRange
        EditorTextOpt G_PCTextOption SIZEOF GrTextOption LITERAL CMOVE
        CLS GCursorOFF
        Ed#row 0 DO
            DisplayLine #I + to thisline
            thisline []EditorBuffer COUNT TYPE G_HideCursor CR
            thisline Marked? IF thisline InvertLine ENDIF
        LOOP GCursorON
        ClearKeyBuf
        RefreshStatusLine ;

GTextInfo: EditorInfo

: StatusInputDokey (| buf #chars_got #max_got key -- #chars_got' #max_got' |)
        #chars_got to #chars_got'   #max_got to #max_got'
        key ESC <> ANDTHEN key $FF <= ORELSE key NoModify? ORELSE key del = 
        ORELSE key ctrl-end = ELSE-OR THEN-AND
        IF
           buf #chars_got #max_got key Old-dokey to #max_got' to #chars_got'
        ELSE
           key CASE
             ESC   OF  TRUE to Enterred? 0 to #chars_got' 0 to #max_got' ENDOF
             up    OF  0 0 AT buf 1- COUNT
                       DUP to #chars_got' DUP to #max_got' TYPE ENDOF
             alt-d OF  buf #chars_got #max_got ESC Old-dokey 
                       to #max_got' to #chars_got'              ENDOF
           ENDCASE
        ENDIF ;

: StatusLineInput  (| prompt$ buf len | editor-dokey old-^his -- buf' len' |)
     // * buf 1- must be a valid address !
     // Display 'prompt$' , read strings into 'buf' with length 'len'
        StatusLine Ed#col BL FILL
        EditorInfo GSaveTextInfo
        ['] dokey >BODY @ to editor-dokey
        ^history to old-^his  buf 1- to ^history // prevent record into history
        GScrolling OFF
        EditorStatusTextOpt G_PCTextOption SIZEOF G_PCTextOption LITERAL CMOVE
        0 Edy1 1+ GrMaxX GrMaxY 1- 79 1 GSetScrollRange 0 0 AT
        ClearStatusLine
        prompt$ COUNT TYPE
        AT? GCursor>Coord GrMaxX 1- GrMaxY 1- 50 1 GSetScrollRange
        ['] StatusInputDokey IS  dokey
        buf len 50 MIN $input to len' to buf'
        FALSE to Enterred?
        old-^his to  ^history
        editor-dokey  IS  dokey
        EditorInfo GRestoreTextInfo ;

: MessageDisplay        (| message len -- |)
        ClearStatusLine
        StatusLine message len $+ DROP DrawStatusString ;

: CurrentBuf    CurrentLine []EditorBuffer ; 0 1 #PARMS

: FixLineBuffer (| line | linebuf len -- |)
        line []EditorBuffer to linebuf
        linebuf COUNT to len
        len 0<> IF
          // scan forward
           len 0 ?DO
              DUP C@ BL < IF  BL OVER C!  ENDIF  1+  // fix control characters
           LOOP
          // scan backward
           1-
           len 0 ?DO  // delete trailing spaces
              DUP C@ BL <= IF  0 OVER C!  ELSE  LEAVE  ENDIF 1-
           LOOP
           linebuf - 0 MAX linebuf C! // store new length
        ELSE
           DROP
        ENDIF  ;

: FixCurrentBuf (| -- |)
        CurrentLine FixLineBuffer ; 

: Column++      (| -- |)
        CurrentColumn 1+ Ed#col 1- MIN to CurrentColumn RefreshStatusLine ;

: Column--      (| -- |)
        CurrentColumn 1- 0 MAX to CurrentColumn  RefreshStatusLine ;

: Tablets       (| -- |)
        CurrentColumn 2/ 2/ 2/ 1+ 2* 2* 2* Ed#col 1- MIN to CurrentColumn
        RefreshStatusLine ;

: RevTablets    (| -- |)
        CurrentColumn 2/ 2/ 2/ 1- 2* 2* 2* 0 MAX to CurrentColumn
        RefreshStatusLine ;

: MarkThis      (| | markend0 -- |)
        MarkEnd to markend0  CurrentLine to MarkEnd 
        markend0 MarkStart - SGN   MarkEnd markend0 - SGN *  1+ SGN
        IF  MarkEnd  ELSE  markend0  ENDIF
        DUP MarkStart <> IF InvertLine ELSE DROP ENDIF ;
// the following is original version without mathematical analysis :
//      MarkEnd to markend0
//      CurrentLine to MarkEnd
//      markend0 MarkStart > IF
//         MarkEnd markend0 < IF        // shrinking
//            markend0
//         ELSE
//            MarkEnd                   // growing
//         ENDIF
//      ELSE markend0 MarkStart < IF
//         MarkEnd markend0 > IF        // shrinking
//            markend0
//         ELSE
//            MarkEnd                   // growing
//         ENDIF
//      ELSE // markend0 MarkStart =
//         MarkEnd
//      ENDIF ENDIF
//      DUP MarkStart <> IF  InvertLine  ELSE  DROP  ENDIF ;

: ?MarkThis     (| -- |)
        Marking IF  MarkThis  ENDIF ;

: HomeKey       (| -- |)
        HomeCount 1+ to HomeCount
        HomeCount CASE
           1 OF  0 to CurrentColumn                                     ENDOF
           2 OF  FixCurrentBuf DisplayLine to CurrentLine
                 0 to CurrentColumn ?MarkThis RefreshScreen             ENDOF
           3 OF  FixCurrentBuf 0 DUP DUP to CurrentLine to DisplayLine
                 to CurrentColumn ?MarkThis
                 RefreshScreen 0 to HomeCount                           ENDOF
        ENDCASE
        RefreshStatusLine ;

: GotoLineEnd   (| -- |)   CurrentBuf C@ Ed#col 1- MIN to  CurrentColumn ;

: EndKey        (| -- |)
        EndCount 1+ to EndCount
        EndCount CASE
           1 OF  GotoLineEnd                                    ENDOF
           2 OF  FixCurrentBuf DisplayLine Ed#row 1- + to CurrentLine
                 GotoLineEnd ?MarkThis RefreshScreen            ENDOF
           3 OF  FixCurrentBuf TotalLines to CurrentLine
                 CurrentLine Ed#row - 1+ 0 MAX to DisplayLine
                 GotoLineEnd ?MarkThis 
                 RefreshScreen  0 to EndCount                   ENDOF
        ENDCASE
        RefreshStatusLine ;

: CurrentLine++ (| | currline0 -- |)
        FixCurrentBuf
        CurrentLine to currline0
        CurrentLine 1+ ed#max-lines MIN to CurrentLine
        CurrentLine DisplayLine - Ed#row >= IF
            DisplayLine 1+  ed#max-lines Ed#row - 1-  MIN to DisplayLine
            Marking IF 
               RefreshScreen // scrolling up
            ELSE
               G_ScrollUp
               GrFilledBox( 0 , Edy1 G_cell_height - , 
                         GrMaxX , Edy1 ,  EditorTextOpt |txo_bgcolor |v @ )
               AT? 0 Ed#row 1- AT 
               DisplayLine Ed#row + 1- []EditorBuffer COUNT TYPE
               AT
            ENDIF
        ENDIF
        FixCurrentBuf
        currline0  ed#max-lines <> IF ?MarkThis ENDIF 
        ClearKeyBuf RefreshStatusLine ;

: CurrentLine-- (| | currline0 -- |)
        FixCurrentBuf
        CurrentLine to currline0
        CurrentLine 1- 0 MAX to CurrentLine
        CurrentLine DisplayLine < IF
            DisplayLine 1- 0 MAX to DisplayLine
            Marking IF
               RefreshScreen // scrolling down
            ELSE
               G_ScrollDown
               GrFilledBox( 0 , 0 , GrMaxX , G_cell_height 1- , 
                         EditorTextOpt |txo_bgcolor |v @ );
               AT?  0 0 AT DisplayLine []EditorBuffer COUNT TYPE  AT
            ENDIF
        ENDIF
        FixCurrentBuf
        currline0 0<> IF ?MarkThis ENDIF
        ClearKeyBuf RefreshStatusLine ;

: down-1page    (| -- |)
        FixCurrentBuf
        CurrentLine Ed#row 1- + DUP ed#max-lines > IF
           DROP ed#max-lines DUP Ed#row 1- -
        ELSE
           DisplayLine Ed#row 1- +  ed#max-lines Ed#row - 1-  MIN
        ENDIF
        to DisplayLine to CurrentLine
        FixCurrentBuf
        ?MarkThis RefreshScreen ;

: up-1page      (| -- |)
        FixCurrentBuf
        CurrentLine Ed#row 1- - DUP 0< IF
           DROP 0 DUP
        ELSE
           DisplayLine Ed#row 1-  - 0 MAX
        ENDIF
        to DisplayLine to CurrentLine
        FixCurrentBuf
        ?MarkThis RefreshScreen ;

: ToggleMarking  (| -- |)
        Marking NOT IF // mark
           TRUE TO Marking
           CurrentLine DUP to MarkStart to MarkEnd
           CurrentLine InvertLine
           RefreshStatusLine
        ELSE // unmark
           FALSE TO Marking
           -1 DUP to MarkStart to MarkEnd
           RefreshScreen
        ENDIF ;

: MoveUp        (| line# col# -- |)
     // Move block up , for <del> key .................. not implemented
        ;

: MoveDown      (| line# col# | len -- T/F |)
        line# 0 ed#max-lines [...] IF
           line# 1+ TotalLines 1+ MAX ed#max-lines MIN to TotalLines
           line# 1+ ed#max-lines MIN []EditorBuffer
           DUP ed#max-chars + OVER
           TotalLines ed#max-lines MIN []EditorBuffer SWAP -
           DUP 0>= to T/F
           T/F IF
              MOVE  line# 1+ []EditorBuffer ed#max-chars 0 FILL
              line# []EditorBuffer COUNT col# - 1+ 0 MAX to len
              col# +   DUP  line# 1+ []EditorBuffer 1+  len  MOVE
              len 0 FILL
              len 1-  0 MAX line# 1+ []EditorBuffer  C!
              col#    0 MAX line# []EditorBuffer     C!
           ELSE
              3DROP
           ENDIF
        ENDIF ;

: EnterKey      (| -- |)
        CurrentLine ed#max-lines <> IF
           FixCurrentBuf
           EditorMode InsertMode = IF
              CurrentLine CurrentColumn MoveDown IF
                 0 to CurrentColumn CurrentLine++ RefreshScreen
              ENDIF
              TRUE to FileModified
           ELSE // ReplaceMode or BrowseMode
              0 to CurrentColumn CurrentLine++
           ENDIF
           FixCurrentBuf
        ENDIF ;

: DeleteLine    (| -- |)
        CurrentLine TotalLines <= ANDTHEN TotalLines 0<> THEN-AND IF
           CurrentBuf ed#max-chars +  CurrentBuf 
           OVER TotalLines 1+ ed#max-lines MIN []EditorBuffer SWAP - 
           DUP 0> IF MOVE ELSE 3DROP ENDIF
           TotalLines []EditorBuffer ed#max-chars ERASE
           TRUE to FileModified 
           TotalLines 1- to TotalLines RefreshScreen
        ENDIF ;

// File operations :

CREATE  MessageBuf  80 ALLOT

: $Copy  (| src$ dest$ -- |) // Zero byte added
        dest$ OFF dest$ src$ COUNT $+ COUNT + 0 SWAP C! ;

: DisplayFileName  (| -- |)
        $" * Editing file name : " MessageBuf $Copy
        MessageBuf EditFName COUNT $+ 
        FileModified IF "  * " $+  ENDIF
        COUNT MessageDisplay  ;

: MessageCanceled       (| -- |)
        $" * Command canceled ." MessageBuf $Copy 
        MessageBuf COUNT MessageDisplay ;
        
: MessageFailOpen       (| filename -- |)
        MessageBuf OFF  
        filename C@ 0<> IF
           MessageBuf " * Error opening appending file : " $+
           filename COUNT $+ COUNT MessageDisplay 
        ELSE
           MessageCanceled 
        ENDIF ;

: Fail/Success  (( err -- str len ))
        IF " failed : " ELSE " successful : " ENDIF ; 1 2 #PARMS

: MessageAppend (| err -- |)
        MessageBuf OFF MessageBuf " * Appending file " $+
        err Fail/Success $+ AppendFName COUNT $+ COUNT MessageDisplay ;

: MessageRead   (| err -- |)
        MessageBuf OFF MessageBuf " * Reading file " $+
        err Fail/Success $+ ReadFName COUNT $+ COUNT MessageDisplay ;

: MessageWrite  (| err -- |)
        MessageBuf OFF MessageBuf " * Writing file " $+
        err Fail/Success $+ WriteFName COUNT $+ COUNT MessageDisplay ;

: InputFileName (| prompt$ namebuf maxlen -- |)
        prompt$  namebuf 1+  maxlen 1-  StatusLineInput 
        DUP namebuf C!  +  0  SWAP  C! ;

: MarkedArea    (( -- limit start )) 
        MarkStart MarkEnd MAX 1+ MarkStart MarkEnd MIN  ; 0 2 #PARMS

: AppendMarkAreaToFile   (| | buf len err -- |)
        Marking IF
           $"  Append block to file : " AppendFName 40 InputFileName
           fopen( AppendFName 1+ , Z$" at" ) to CurrFile
           CurrFile NULL = IF
              AppendFName MessageFailOpen
           ELSE
              FALSE to err
              MarkedArea ?DO
                 #I []EditorBuffer COUNT to len to buf
                 fprintf( CurrFile , Z$" %.*s%c" , len , buf , <LF> )
                 EOF = IF  TRUE to err LEAVE  ENDIF
              LOOP
              fclose( CurrFile ); DROP
              ToggleMarking     // Unmark
              err MessageAppend
           ENDIF
        ENDIF ;

: (WriteToFile) (| | buf len err -- |)
        FALSE to err
        fopen( WriteFName 1+ , Z$" wt" ) to CurrFile
        CurrFile NULL = IF
           WriteFName MessageFailOpen
        ELSE
           Marking IF  MarkedArea  ELSE  TotalLines 1+  0  ENDIF
           ?DO
               #I []EditorBuffer COUNT to len to buf
               fprintf( CurrFile , Z$" %.*s%c" , len , buf , <LF> )
               EOF = IF  TRUE to err LEAVE  ENDIF
           LOOP
           fclose( CurrFile ); DROP
           Marking IF  
              ToggleMarking  
           ELSE  
              WriteFName EditFName $Copy  err to FileModified
           ENDIF
           err MessageWrite
        ENDIF ;

: WriteToFile   (| -- |)
        Marking IF  $"  Write marked block to file : "
        ELSE        $"  Write to file : "
        ENDIF
        WriteFName 40 InputFileName
        (WriteToFile) ;

CREATE readlinebuf      ed#max-chars CELL+ ALLOT

: (ReadFromFile)    (| | toline len -- err |)
        FALSE to err
        fopen( ReadFName 1+ , Z$" rt" ) to CurrFile
        CurrFile NULL = IF
           ReadFName MessageFailOpen
        ELSE
           CurrentLine to toline
           BEGIN
              fgets( readlinebuf , ed#max-chars , CurrFile ) to err
           err readlinebuf = WHILE
              strlen( readlinebuf ) to len
              toline 0 MoveDown DROP
              readlinebuf  toline []EditorBuffer 1+  len  CMOVE
              len toline []EditorBuffer C!
              toline FixLineBuffer
              toline 1+ to toline
           REPEAT
           ferror( CurrFile ) to err
           fclose( CurrFile ); DROP
           RefreshScreen  err 0<> MessageRead
           TRUE to FileModified
        ENDIF ;

: ReadFromFile  (| -- |)
     // read file to current line
        Marking NOT IF
           $"  Read block from file : " ReadFName 40 InputFileName
           (ReadFromFile) DROP
        ENDIF ;

: UnMarking   (| -- |)  Marking IF  ToggleMarking  ENDIF ;

: SaveCurrentFile  (| | curMarking? -- |)
        HelpMode NotHelping = IF
           Marking to curMarking?  FALSE to Marking
           WriteFName TmpFName $Copy
           EditFName WriteFName $Copy
           (WriteToFile)
           TmpFName WriteFName $Copy 
           curMarking? to Marking
        ENDIF ;

: QuitCurrentFile   (| | cmdkey -- quit_successful |)
        TRUE to quit_successful
        FileModified IF
           GModeNow? NOT IF  GRAPHICS-MODE  ENDIF
           MessageBuf OFF MessageBuf " * Save modified file " $+
           EditFName COUNT $+ "  ('Y'es/'N'o/to 'A'nother/'ESC' cancel)?" $+
           COUNT MessageDisplay BEEP
           ClearKeyBuf 0 to cmdkey
           BEGIN
              KEY to cmdkey
              cmdkey ASCII Y = ORELSE cmdkey ASCII N = ORELSE
              cmdkey ASCII A = ORELSE cmdkey ESC = ELSE-OR
           UNTIL
           cmdkey ASCII Y = IF
              UnMarking  EditFName C@ 0= IF  
                 ASCII A to cmdkey
              ELSE
                 SaveCurrentFile
              ENDIF
           ELSE cmdkey ASCII N = IF
              UnMarking
           ENDIF ENDIF
           cmdkey ASCII A = IF  
              WriteToFile   WriteFName C@ 0<> to quit_successful
           ENDIF
           quit_successful  cmdkey ESC <> AND  to quit_successful
        ENDIF ;

: (EditFile)    (| -- err |)
        ReadFName TmpFName $Copy  EditFName ReadFName $Copy
        (ReadFromFile) to err
        TmpFName ReadFName $Copy
        FALSE to FileModified ;

: EditFile      (| -- |)
        QuitCurrentFile IF
          // File reading
           EditorBuffer TotalLines 1+ []EditorBuffer OVER - ERASE
           0 to TotalLines  0 to DisplayLine  0 to CurrentColumn
           0 to CurrentLine
           $" * Input file name to edit : " EditFName 40 InputFileName
           (EditFile) DROP
        ELSE
           MessageCanceled
        ENDIF ;

// ////////////////////////////////////////////////////////

GTextInfo: UserTextInfo

: OpenEditor    (| #chars_got #max_got -- |)
        UserTextInfo GSaveTextInfo
        GModeNow? NOT IF  GRAPHICS-MODE  ENDIF
        GCursorState TO CursorState0
        GCursorOFF
        #chars_got -1 <> IF
           #chars_got to saved_#chars_got  #max_got to saved_#max_got
        ENDIF
        GrBitBlt( UserScreenContext , 0 , 0 ,
                  NULL , 0 , 0 , GrMaxX , GrMaxY , GrWRITE );
        G_PCTextOption  OldTextOpt  SIZEOF GrTextOption LITERAL  MOVE
        GGetScrollRange to Old#row to Old#column 
        to OldScrollY1 to OldScrollX1 to OldScrollY0 to OldScrollX0
        GScrolling @ to OldScrolling
        WHITE  G_PCTextOption |txo_fgcolor |v  !
        BLUE   G_PCTextOption |txo_bgcolor |v  !
        GScrolling OFF
        ['] dokey >BODY @  to  dokey0
        ['] EditorDokey IS dokey  // different behavior in editor
        GCursor@  to  OldGrCursorLoc
        TRUE to EditorOpened
        'PROMPT @  to  PROMPT0  ['] NOOP 'PROMPT !
        Edx0 Edy0 Edx1 Edy1 Ed#col Ed#row GSetScrollRange
        GCursorON RefreshScreen ;

: PutUserScreen   (| -- |)
        GrBitBlt( NULL , 0 , 0 ,
                  UserScreenContext , 0 , 0 , GrMaxX , GrMaxY , GrWRITE ) ;

: CloseHelp     (| -- #chars_got #max_got |)
        free( EditorBuffer );
        help_EditorBuffer to EditorBuffer  help_CurrentLine   to CurrentLine
        help_TotalLines   to TotalLines    help_CurrentColumn to CurrentColumn
        help_DisplayLine  to DisplayLine   help_Marking       to Marking
        help_MarkStart    to MarkStart     help_MarkEnd       to MarkEnd
        help_FileModified to FileModified  help_EditorMode    to EditorMode
        help_saved_#chars_got to #chars_got  help_saved_#max_got to #max_got
        NotHelping TO HelpMode
        HelpTmpFName EditFName $Copy
        RefreshScreen ;

0 VALUE Saved'?KEY
0 VALUE MarkedKey^
2VARIABLE PasteResetter

: EndPasteReset (( -- ))
        0 to MarkedKey^
        Saved'?KEY 0<> IF
           Saved'?KEY '?KEY !  0 TO Saved'?KEY
           PasteResetter POP-RESETTER
        ENDIF ; 0 0 #PARMS

: KeyforPasteMarking    (( -- chr T/F ))
        Marking ANDTHEN EditorOpened NOT THEN-AND IF
           MarkStart []EditorBuffer COUNT MarkedKey^ =  IF // next line
              DROP ^m   
              MarkStart 1+ to MarkStart   0 to MarkedKey^
              MarkStart MarkEnd > IF
                 -1 DUP to MarkStart to MarkEnd  FALSE to Marking
                 EndPasteReset
              ENDIF
           ELSE
              MarkedKey^ + C@  MarkedKey^ 1+ to MarkedKey^
           ENDIF
           TRUE
        ELSE
           CR ." * Here should never be executed ." CR EndPasteReset ABORT
        ENDIF ; 0 2 #PARMS

: PasteMarkedArea       (| -- |)
        Marking IF // set paste key
           '?KEY @ to Saved'?KEY  0 to MarkedKey^
           MarkStart MarkEnd 2DUP MIN to MarkStart MAX to MarkEnd 
           ['] EndPasteReset PasteResetter PUSH-RESETTER
           ['] KeyforPasteMarking '?KEY  !
        ENDIF ;

: CloseEditor  (| -- #chars_got #max_got |)
        HelpMode HelpFromEditor = IF
           CloseHelp to #max_got to #chars_got
        ELSE
           HelpMode HelpFromCommand = IF  CloseHelp 2DROP  ENDIF
           GCursorOFF
           FixCurrentBuf
           OldScrollX0 OldScrollY0 OldScrollX1 OldScrollY1 Old#column Old#row
           GSetScrollRange
           OldScrolling GScrolling !
           dokey0  IS  dokey
           PutUserScreen
           OldTextOpt  G_PCTextOption  SIZEOF GrTextOption LITERAL  MOVE
           CursorState0 IF  GCursorON  ENDIF
           OldGrCursorLoc  GCursor!
           FALSE to EditorOpened
           PROMPT0 'PROMPT !
           UserTextInfo GRestoreTextInfo
           saved_#chars_got to #chars_got  saved_#max_got to #max_got
           PasteMarkedArea
        ENDIF ;

: ShowHelp (| #chars_got #max_got | memblk -- |)
        HelpMode NotHelping <> IF  EXIT  ENDIF
        calloc( 1 , |EditorBuffer| ) to memblk
        memblk NULL = IF
           " * Not enough memory for reading help file." MessageDisplay EXIT
        ENDIF
        EditorOpened  IF  
           HelpFromEditor to HelpMode 
        ELSE  
           HelpFromCommand to HelpMode
           #chars_got #max_got OpenEditor
        ENDIF
        #chars_got to help_saved_#chars_got  #max_got to help_saved_#max_got
        CurrentLine   to help_CurrentLine    TotalLines    to help_TotalLines
        CurrentColumn to help_CurrentColumn  DisplayLine   to help_DisplayLine
        Marking       to help_Marking        MarkStart     to help_MarkStart
        MarkEnd       to help_MarkEnd        EditorBuffer  to help_EditorBuffer
        FileModified  to help_FileModified   EditorMode    to help_EditorMode
        0 to CurrentLine 0 to TotalLines 0 to CurrentColumn 0 to DisplayLine
        UnMarking  FALSE TO FileModified
        BrowseMode to EditorMode
        memblk to EditorBuffer
        EditFName HelpTmpFName $Copy
        HelpMode HelpFromEditor = IF  $" SIMPED.HLP" ELSE $" MANUAL.DOC"  ENDIF
        EditFName $Copy (EditFile) IF  CloseEditor 2DROP  ENDIF ;

: InvokeOldDokey        (| #max_got key -- #chars_got' #max_got' |)
        key alt-k = IF  ctrl-end to key  ENDIF
        Marking ANDTHEN key NoModify? NOT THEN-AND IF  f(10) to key  ENDIF
        CurrentBuf C@ Ed#col 1- >= ANDTHEN  is-insert?  THEN-AND
        ORELSE  CurrentColumn Ed#col 1- >=  ELSE-OR  IF
           key NoModify? ORELSE key del = ORELSE key ^h = ORELSE
           key ctrl-end = ELSE-OR NOT IF f(10) to key ENDIF
        ENDIF
        CurrentBuf 1+ CurrentColumn #max_got key Old-dokey
        2DUP to #max_got' to #chars_got'
        MAX CurrentBuf C! // store length
        AT? DROP to CurrentColumn
        TotalLines CurrentLine MAX to TotalLines
        HelpMode NotHelping = IF
          is-insert? IF InsertMode ELSE ReplaceMode ENDIF to EditorMode
        ENDIF
        key NoModify? NOT IF  TRUE to FileModified  ENDIF
        FixCurrentBuf RefreshStatusLine ;

: ModelessKeys
        (| #chars_got #max_got key -- #chars_got' #max_got' key_patched  |)
        #chars_got to #chars_got' #max_got to #max_got'
        TRUE to key_patched
        key CASE
           up      OF  CurrentLine-- CurrentBuf C@ to #max_got' ENDOF
           down    OF  CurrentLine++ CurrentBuf C@ to #max_got' ENDOF
           right   OF  Column++                                 ENDOF
           left    OF  Column--                                 ENDOF
           home    OF  HomeKey                                  ENDOF
           end     OF  EndKey                                   ENDOF
           pgup    OF  up-1page   CurrentBuf C@ to #max_got'    ENDOF
           pgdn    OF  down-1page CurrentBuf C@ to #max_got'    ENDOF
           ^i      OF  Tablets                                  ENDOF
           sft-tab OF  RevTablets                               ENDOF
           ESC     OF  CloseEditor to #max_got' to #chars_got'  ENDOF
           alt-x   OF  CloseEditor to #max_got' to #chars_got'  ENDOF
           alt-a   OF  AppendMarkAreaToFile                     ENDOF
           alt-w   OF  WriteToFile                              ENDOF
           alt-l   OF  ToggleMarking                            ENDOF
           kF1     OF  #chars_got #max_got ShowHelp             ENDOF
           kF9     OF  RefreshScreen                            ENDOF
           kF2     OF  SaveCurrentFile                          ENDOF
           kF7     OF  ENDOF
           alt-f7  OF  ENDOF
           FALSE to key_patched
        ENDCASE ;

: (EditorDokey) 
      (| buf #chars_got #max_got key | key_patched -- #chars_got' #max_got' |)
        #chars_got #max_got key ModelessKeys to key_patched 
        to #max_got' to #chars_got' 
        key_patched NOT IF
           EditorMode BrowseMode = IF
              key CASE
                 ^b  OF  HelpMode NotHelping = IF
                            is-insert? IF InsertMode ELSE ReplaceMode ENDIF 
                            to EditorMode  RefreshStatusLine
                         ENDIF                                  ENDOF
                 ins OF  ENDOF // Can't change editing mode
                 key NoModify? IF
                     #max_got key InvokeOldDokey to #max_got' to #chars_got'
                 ENDIF
              ENDCASE
           ELSE // not in browse mode
              key CASE
                  ^m    OF  EnterKey
                            CurrentBuf C@ to #max_got' 0 to #chars_got' ENDOF
                  ^b    OF  BrowseMode to EditorMode RefreshStatusLine  ENDOF
                  kF5   OF  CloseEditor KEY DROP OpenEditor             ENDOF
                  alt-d OF  DeleteLine CurrentBuf C@ to #max_got'       ENDOF
                  alt-r OF  ReadFromFile CurrentBuf C@ to #max_got'     ENDOF
                  alt-e OF  EditFile    CurrentBuf C@ to #max_got'      ENDOF
                  alt-f OF  DisplayFileName                             ENDOF
                  #max_got key InvokeOldDokey to #max_got' to #chars_got'
              ENDCASE
           ENDIF
        ENDIF
        key home <> IF 0 to HomeCount ENDIF
        key end  <> IF 0 to EndCount  ENDIF   ;

' (EditorDokey) IS EditorDokey
0 VALUE JustEnterred?
0 VALUE old^history

: EditorActivateKey (| buf #chars_got #max_got key -- #chars_got' #max_got' |)
        #chars_got to #chars_got'   #max_got to #max_got'
        EditorOpened NOT ANDTHEN JustEnterred? ANDTHEN 
        AppendToEditor ANDTHEN EditorMode BrowseMode <> THEN-AND IF
            FALSE to JustEnterred?
            ^history old^history <>  IF
               TotalLines []EditorBuffer C@ 0<> IF
                  TotalLines 1+ ed#max-lines MIN to TotalLines
               ENDIF
               TRUE to FileModified
               ^history-- ^history TotalLines []EditorBuffer $Copy ^history++
            ENDIF
        ENDIF
        key CASE
            kF1    OF   #chars_got #max_got ShowHelp      ENDOF
            pgup   OF   #chars_got #max_got OpenEditor    ENDOF
            pgdn   OF   #chars_got #max_got OpenEditor    ENDOF
            alt-h  OF   AppendToEditor NOT to AppendToEditor
                        AppendToEditor NOT IF BEEP ENDIF  ENDOF
            buf #chars_got #max_got key  DEFERS dokey  // patch old dokey
            to #max_got'  to #chars_got'
            Enterred? to JustEnterred?  ^history to old^history
        ENDCASE  ;

: EditorInit (| -- |)
        GrCreateContext( GrSizeX , GrSizeY , UserScreen , 
                         UserScreenContext ); DROP
        GrCreateContext( GrSizeX , G_cell_height 4 + , InvertBar ,
                         InvertContext ); DROP
        GrCreateContext( GrSizeX , G_cell_height 1+ , InvertBar ,
                         InvertContext ); DROP
        GrSetContext( InvertContext );
        GrFilledBox( 0 , 0 , GrMaxX , G_cell_height 1+ , DARKGRAY );
        GrSetContext( NULL );
        GrSizeX Ed#col /  to EdStatusCharWidth
        20 to EdStatusCharHeight
        GrFindBestFont( EdStatusCharWidth , EdStatusCharHeight , 1 ,
                        Z$" pc*" , EditorStatusTextOpt ); DROP
        YELLOW   EditorStatusTextOpt |txo_fgcolor |v  !
        DARKGRAY EditorStatusTextOpt |txo_bgcolor |v  !
        0 DUP to Edx0 to Edy0
        GrMaxX to Edx1  GrMaxY EdStatusCharHeight - to Edy1
        G_PCTextOption  EditorTextOpt  SIZEOF EditorTextOpt LITERAL  MOVE
        WHITE  EditorTextOpt |txo_fgcolor |v  !
        BLUE   EditorTextOpt |txo_bgcolor |v  !
        is-insert? IF  InsertMode  ELSE  ReplaceMode  ENDIF to EditorMode
        $" NONAME.4TH" EditFName $Copy
        ['] EditorActivateKey IS dokey ;

: EditorMain (| -- |)
        GRAPHICS-MODE EditorInit  MULTI ;

EditorMain

FORTH DEFINITIONS

: BYE   QuitCurrentFile IF  BYE  ELSE  MessageCanceled  ENDIF ; 0 0 #PARMS
: BYE'  QuitCurrentFile IF  BYE' ELSE  MessageCanceled  ENDIF ; 0 0 #PARMS

ONLY FORTH ALSO DEFINITIONS

