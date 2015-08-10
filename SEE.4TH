// Decompiler for Common Forth Experiment Systems

                                // Written by  : Luke Lee	
				// Version     : 1.60
				// Last update : 01/25/'97

// Modification reports after complete version 1.5 on 01/17/'95
//   [08/06/'95] 1. Clearer comments for this program.
//		 2. Add .[HERE] and modify FOR..NEXT for SEEing 
//		      ... >R ... [ HERE ] ... NEXT ...
//   [09/19/'95] REG_SEE_MACROS  and  MACRO
//   [09/26/'95] Define |SEE| for range see.	
//   [12/23/'95] Do testing in case array '()Codes' overflow .
//   [12/28/'95] Modify due to CF0.4TH, '*' '/' and '/MOD' became MACROs.
//   [03/20/'96] Modify name [ <"> ] into [ "| ].
//   [05/10/'96] Since the control structure words now lay down two
//               elements on data stack, the ... >R ... [ HERE ] ... NEXT ...
//               is no longer valid and should use [ 0 HERE ] instead.
//   [09/19/'96] (v1.57) Add extra macros . (v1.57)
//   [01/19/'97] (v1.57) Add new VCPU instructions [ exit ] and [ nop ] .
//   [01/23/'97] (v1.57) Add CheckImmediate flag for LL(k)Gen.
//   [01/24/'97] (v1.60) Modify [ AFT(..THEN) ] and [ AFT..THEN? ] to
//               distinguish AFT..THEN and AHEAD..THEN .
//               * Also add words to see DEFER words.
//               * Seen (LEAVE)/(?LEAVE) to be LEAVE/?LEAVE.
//   [01/25/'97] Enhance analyst table facilities, modify [ (Analyze) ]
//               and many others. Add more defer words for programmers
//               to enhance this discompiler.

// The situation here is similar to disassembler while variable length
// instructions exists but here it is macros.

// Interface :
//    SEE	 : Take name and decompile it . A deferred word.
//   <SEE>	 : ( ca -- )
//		   Take ca and decompile it . 
//		   Example : ' WORDS <SEE>  is equivalent to  SEE WORDS
//    |SEE|      : ( ca length -- )
//                 Discompile codes between [ ca , ca+length ] .
//    SEE-MACROS : Flag in variable, default value is ON
//			Does further macros need to be recoginized ?
//			Or just leave them as INLINEs ?
// Programmer Interface : 01/24,25/'97
//  for extending the power of SEE.
//    PreDiscompile     ( ca-start ca-end -- ca-start' ca-end' )
//                   Take two arguments, two address for codes,
//                   Return two arguments for further discompilation,
//                   and these two address can be modified according to need.
//    PostDiscompile    ( ca' -- ca'' )
//                   Take two arguments, ca' is the next code address after
//                   ca-end' in PreDiscompile.
//    LinkAnalysts      ( TIB: table_name )
//                   Redirect analyst table.
//    ForwardResolver   ( ctrl_type -- continue? )
//                   Resolve forward info on AnaStack, return TRUE
//                   if handled. This routine should perform AnaStack::Pop
//                   if a forward can be handled.
//    .Source    : A deferred word, for extending this discompiler.

// If you turn REG-SEE-MACROS OFF, you will see a lot of inlines while
// further macros are defined after SEE.4TH is loaded. ( like 387FLOAT.4TH )
// However, turn REG-SEE-MACROS ON will takes up quite amount of memory 
// to grow the Macro-recognization tree .

ONLY FORTH ALSO DEFINITIONS

NEEDS DISASM.4TH

VARIABLE SEE-MACROS		SEE-MACROS ON
DEFER SEE

// ///////////////////////////////////////////////////////////////////////////
//              Tree  Structure  for  Macro  Contractor                     //  
// ///////////////////////////////////////////////////////////////////////////
//                                              Finish on : 11/20/'94
//						Modify on : 01/15/'95

STACK-EXPRESSION ALSO HIDDEN ALSO DEFINITIONS

WARNING OFF
BUG-WARNING OFF

0 CONSTANT ZA   // zero-address instruction
1 CONSTANT 1AI  // 1-address instruction with immediate operand
2 CONSTANT 1AR  // 1-address instruction with PC-relative operand

STRUCT: MACRO-NODE:
        WORD: |CHILD-LIST
        WORD: |ASSOC-MACRO-HEAD
        WORD: |NEXT-NODE
        WORD: |PARENT
        BYTE: |CONTENT
        BYTE: |ADDRESSING
;STRUCT: MACRO-TREE

MACRO-TREE SIZEOF MACRO-TREE 0 FILL
MACRO-TREE  MACRO-TREE |PARENT  !

: NEW-CHILD     ( node byteValue -- node' )
        SWAP HERE >R
        SIZEOF MACRO-NODE: LITERAL DUP ALLOT    ( c nod siz ) // R: nod
        R@ SWAP 0 FILL                          ( c node )    // R: node'
        DUP R@ |PARENT !
        ( newnode ) |CHILD-LIST DUP @ R@ |NEXT-NODE !
        R@ SWAP !       // newnode became the head of child-list
        R@ |CONTENT C!
        R> ; 2 1 #PARMS

: BUILD-NODES  (| ha adrmode ca' stopnode len | currnode -- |)
	stopnode => currnode
	BEGIN 
	   len 0<>
	WHILE
	   currnode  ca' C@  NEW-CHILD => currnode
	   ca' 1+ => ca'  len 1- => len
	REPEAT
	adrmode currnode |ADDRESSING C!
	ha currnode |ASSOC-MACRO-HEAD !  ;

: SEARCH-THREAD		RECURSIVE
	(| ca node len | currbyte currnode -- ca' stop_node |)
     	( not-found: ca node len -- ca' node' )

     // * The only way to decide whether the terminated node is a macro or
     // not is to check the |ASSOC-MACRO-HEAD and see if it is zero.
     // ( check |ADDRESSING field DOES NOT have the same effect since ZA = 0)
     // * The value ca'-ca doesn't mean the size of that macro . It's actual
     // size should be calculated by SIZEOF.    

	len 0= IF
	    ca => ca'   node => stop_node
	ELSE
	    node |CHILD-LIST @ => currnode    ca C@ => currbyte
	    BEGIN
	       currnode 0<> ANDTHEN
	       currnode |CONTENT C@  currbyte <> THEN-AND
	    WHILE
	       currnode |NEXT-NODE @  =>  currnode	
	    REPEAT
	    currnode 0= IF	// leaf nodes
	       ca => ca'  node => stop_node
	    ELSE
	       ca 1+  currnode  len 1-   SEARCH-THREAD	=> stop_node => ca'
	    ENDIF
	ENDIF ;

: REGISTER-MACRO  (| adrMode ca | ca' ha codsize stop_node -- |)
	ca >HEAD => ha   ha |SIZE @ 1- => codsize
	ca   MACRO-TREE   codsize  SEARCH-THREAD  => stop_node => ca'
	ha  adrMode  ca'  stop_node  codsize ca' ca - -  BUILD-NODES ;
	
: REGISTER-MACROS:  ( addrMode -- ) // TIB: <macro-name> <macro-name>
        >R
        BEGIN
          >IN @   BL WORD COUNT NIP   SWAP >IN !
        WHILE
          R@ ' REGISTER-MACRO
        REPEAT RDROP    ; 1 0 #PARMS

ALSO FORTH DEFINITIONS

: MACRO	( -- ) // only zero-addressing macros could be registerred.
	MACRO
	SEE-MACROS @ IF
	    ZA LAST @ HEAD> REGISTER-MACRO
	ENDIF ; 0 0 #PARMS

PREVIOUS DEFINITIONS

WARNING ON
BUG-WARNING ON

// Zero addressing instructions :
 ZA  REGISTER-MACROS:   !  H!  C!  @  H@  C@  0
 ZA  REGISTER-MACROS:   DROP  OVER  DUP  SWAP  ROT  -ROT  NIP  PICK
 ZA  REGISTER-MACROS:   0<  0<>  0=  0>  > =  <  U<  U>  NOT  AND  OR  XOR
 ZA  REGISTER-MACROS:   UM+  NEGATE  UM/MOD  UM*  +  -  *  /  /MOD  SGN
 ZA  REGISTER-MACROS:   CELL+  CELL-  CELL*  CELL/  2*  2/  1+  1-
 ZA  REGISTER-MACROS:   RP@  RP!  >R  R>  R@  RDROP  SP@  SP!
 ZA  REGISTER-MACROS:   UP@  UP!  EXECUTE  @EXECUTE
 ZA  REGISTER-MACROS:   PC@  PH@  P@  PC!  PH!  P!  exit  nop
 ZA  REGISTER-MACROS:   <=  >=  <>  U>=  U<=  0>=  0<=

 ZA  REGISTER-MACROS:   C(++)invoke  256*  256/  2DUP
 ZA  REGISTER-MACROS:   2DROP 3DROP 4DROP 5DROP 6DROP 7DROP 8DROP
 ZA  REGISTER-MACROS:   SF>TOS  DF>TOS

// 1 addressing instructions, immediate value followed :
 1AI REGISTER-MACROS:   (LIT)  doUSER

// 1 addressing instructions, PC-relative value followed : 
 1AR REGISTER-MACROS:   BRANCH  ?BRANCH  JT=0  JT<>0  next  call

// ///////////////////////////////////////////////////////////////////////////
//              Data structure for discompiled codes
// ///////////////////////////////////////////////////////////////////////////

$E8 CONSTANT %CALL%

1AR 1+  CONSTANT    NM  // non-macro
$04     CONSTANT    DASM  // disassembler
$08     CONSTANT    AUXDECOM    // auxiliary decompiler


512     CONSTANT    MaxCode#

// Meanings for |CodeType byte :
//
//    X X X X  X X O O
//    | | | |  | | | |
//    | | | |  | | +-+-- 00 ( ZA )  : Macro, zero address
//    | | | |  | |       01 ( 1AI ) : Macro, 1 address with immediate value     
//    | | | |  | |       10 ( 1AR ) : Macro, 1 address with PC-relative address
//    | | | |  | |       11 : Non-macro
//    | | | |  | +-- 1: Invoke Disassembler
//    | | | |  +-- 1 : Execute |AuxDecom for decompile
//    | | | |
//    +-+-+-+-- Not used.

STRUCT: CodeItem
        WORD: |AssocHead
        WORD: |Address
        WORD: |AssocValue  // |CodeType = ZA, NM : 0
                           //             1AI    : associate value
                           //             1AR    : goto address
        WORD: |AuxDecom
        BYTE: |CodeType
;STRUCT

0 VALUE CurrCodeItemIdx  // Index for current code item

0 CONSTANT Codes // Buffer for saving discompiled data. 
0 CONSTANT CodeItemTrailer

TRUE VALUE CheckImmediate       // 01/23/'97 for LL(k)Gen

CREATE CodeItemHeader
        SIZEOF CodeItem   ALLOT // dummy header
HERE => Codes
        SIZEOF CodeItem   MaxCode#  *       ALLOT
HERE => CodeItemTrailer
        SIZEOF CodeItem   ALLOT // dummy trailer
HERE CONSTANT EndDiscompBuffer

: CleanDiscompBuffer ( -- )
        CodeItemHeader   EndDiscompBuffer OVER -    0 FILL ; 0 0 #PARMS
CleanDiscompBuffer

0  VALUE  EndAnalysisStack
0  VALUE  AnaStackPtr
CREATE AnalysisStack    
        40 2 * CELL* ALLOT
HERE => EndAnalysisStack        HERE => AnaStackPtr
0 , 0 ,  // Store 2 zeros for return value while stack-empty

: ()Codes       ( index -- ^codeItem )
        SIZEOF CodeItem LITERAL *  Codes  +  
	DUP CodeItemTrailer > IF
	   CR ." * Discompile buffer full. Cannot see such a large word." 
	   CR ."   Modify 'MaxCode#' to a larger number." CR BEEP ABORT
	ENDIF ; 1 1 #PARMS

: LastCodeItem  ( -- ^codeitem )
        CurrCodeItemIdx 1-  ()Codes  ; 0 1 #PARMS

: after_macro   ( ca node -- ca' node )
        SWAP OVER |ASSOC-MACRO-HEAD @ |SIZE @ + 1- // ca+macro_size-1 = ca'
        SWAP ; 2 2 #PARMS

: TraceAncestor	( node -- node' / 0  )
        BEGIN
            |PARENT @   DUP MACRO-TREE <>
            WHILE
               DUP |ASSOC-MACRO-HEAD @ 0<>
        UNTIL  
	       // node'p
            ELSE
	       DROP FALSE
            THEN ; 1 1 #PARMS

: SearchMacro   ( ca len -- ca' node ) // not-found: ca len -- ca FALSE
	OVER MACRO-TREE ROT SEARCH-THREAD
        DUP |ASSOC-MACRO-HEAD @ // if not found, assoc-head will be zero
        ( ca ca' stopnode ha ) // fail: ca ca' node' 0
        DUP IF
            DROP NIP after_macro
        ELSE  // back off till some ancestor is an valid macro
            DROP NIP       // ca node'
	    TraceAncestor DUP IF  after_macro  ENDIF
        ENDIF ; 2 2 #PARMS

: @Rel>Abs ( ca+1 -- ca+5 ca+5+[ca+1] ) // Convert relative addr to absolute
        DUP CELL+ SWAP @ OVER + ; 1 2 #PARMS

: 'sGotoAddress ( codeitem -- codeitem's_branching_address )
        |AssocValue @ ; 1 1 #PARMS

: PrevWord ( codeitem -- codeitem' )
        SIZEOF CodeItem LITERAL  -  CodeItemHeader  MAX ; 1 1 #PARMS

: NextWord ( codeitem -- codeitem' )
        SIZEOF CodeItem LITERAL  +  EndDiscompBuffer MIN ; 1 1 #PARMS 

: SetCodeItem   ( ha assocval type codeitem -- )
        TUCK |CodeType C!
        TUCK |AssocValue !
        TUCK |AssocHead !
        0 SWAP |AuxDecom !  // this field is modified later
        ; 4 0 #PARMS

: AddCodeItem   ( ha assocval type -- codeitem )
        CurrCodeItemIdx ()Codes >R
        R@ SetCodeItem
        CurrCodeItemIdx 1+ => CurrCodeItemIdx
        R> ; 2 0 #PARMS

: SetAuxDecompiler      ( ca codeitem -- )
        // Overwrite old aux-decompiler
        OVER ['] NOOP = IF  2DROP EXIT  ENDIF
        DUP |CodeType DUP C@ AUXDECOM OR SWAP C!
        |AuxDecom !  ; 2 0 #PARMS

: InsertDecompiler      ( ca codeitem -- )
        // Insert an decompiler into CodeList, replace 'codeitem'.
        CurrCodeItemIdx 1+  =>  CurrCodeItemIdx
        DUP   DUP NextWord  OVER LastCodeItem NextWord SWAP -  CMOVE>
        DUP |Address @  // keep its |Address field
        OVER  SIZEOF CodeItem LITERAL  0  FILL
        OVER |Address !
        SetAuxDecompiler ; 2 0 #PARMS

// Analyze stack operation :

: AnaStack::Reset       ( -- )
        EndAnalysisStack =>  AnaStackPtr ; 0 0 #PARMS

: AnaStack::Push        ( codeitem ctrl_structure_type -- )
        AnaStackPtr  [ 2 CELL* ] LITERAL -  DUP  =>  AnaStackPtr
        AnalysisStack < ABORT" Decompiler analysis stack overflow!"
        AnaStackPtr 2!  ; 2 0 #PARMS

: AnaStack::Top         ( -- codeitem ctrl_structure_type / 0 0 )
        AnaStackPtr 2@ ; 0 2 #PARMS

: AnaStack::Pop         ( -- codeitem ctrl_structure_type )
        AnaStackPtr 2@
        AnaStackPtr  [ 2 CELL* ] LITERAL +  DUP  =>  AnaStackPtr
        EndAnalysisStack > ABORT" Decompiler analysis stack underflow!"  
        ; 0 2 #PARMS

: ?Exceed_AnaStack      ( stkptr -- stkptr )
        DUP [ 2 CELL* ] LITERAL -   EndAnalysisStack   >
        ABORT" Exceed decompiler ayalysis stack range."  ; 1 1 #PARMS

: AnaStack::Pick        ( n -- codeitem ctrl_structure_type/0 0 )
        2* CELL* AnaStackPtr +  ?Exceed_AnaStack  2@ ; 1 2 #PARMS

: AnaStack::Put         ( codeitem ctrl_structure_type n -- )
        2* CELL* AnaStackPtr +  ?Exceed_AnaStack  2! ; 3 0 #PARMS

: AnaStack::Depth       ( -- n )
        EndAnalysisStack AnaStackPtr - CELL/ 2/ ; 0 1 #PARMS

// ///////////////////////////////////////////////////////////////////////////
//       Words  for  Discompiling  and  Analysis
// ///////////////////////////////////////////////////////////////////////////


: `   ( -- ) // TIB: name  // Get head address of the following
        ' >HEAD ; 0 1 #PARMS

: [`]   ( -- ) // TIB: name  // Compile head address of the following
        ` \ LITERAL ; IMMEDIATE

1 VALUE #TABS

: .1TAB ( -- ) 4 SPACES ; 0 0 #PARMS
: .TABS ( -- ) #TABS 0 ?DO .1TAB LOOP ; 0 0 #PARMS
: TAB++ ( -- ) #TABS 1+ [ 80 4 / ] LITERAL MIN => #TABS ; 0 0 #PARMS
: TAB-- ( -- ) #TABS 1- 1 MAX => #TABS ; 0 0 #PARMS
: NEXTROW  ( -- ) AT? DROP 0<> IF CR ENDIF ; 0 0 #PARMS
: ?.TABS ( -- ) AT? DROP 0= IF .TABS ENDIF ; 0 0 #PARMS

// Display word

: ?NextRow      ( len -- )
        AT? DROP + 1+  80 >= IF  NEXTROW  ENDIF ; 1 0 #PARMS

: ?NextRow.Str   ( str len -- )
        DUP ?NextRow ?.TABS TYPE SPACE ; 2 0 #PARMS

: ?Immediate    ( ha -- )
        CheckImmediate IF       // 01/23/'97
           DUP |ATTRIBUTE H@ IMMED AND IF 
              DUP |NAME-LENGTH C@ 
              " \ " ROT OVER + ?NextRow ?.TABS TYPE
           ENDIF
        ENDIF DROP ; 1 0 #PARMS

: .Word  ( codeitem -- ) 
        DUP |AssocHead @
        DUP ?Immediate |NAME-LENGTH COUNT ?NextRow.Str 
        DUP |CodeType C@ 
        DUP 1AR = ORELSE DUP 1AI = ELSE-OR NIP 
        IF  SPACE DUP |AssocValue @ str ?NextRow.Str  ENDIF 
        DROP ; 1 0 #PARMS

: .WordBranched ( codeitem -- ) // Optimized : CALL XXXX RET ==> JMP XXXX
        |AssocValue @ >HEAD DUP ?Immediate
        |NAME-LENGTH COUNT ?NextRow.Str ; 1 0 #PARMS

: +string       ( ca -- ca' )  COUNT + ; 1 1 #PARMS
: +Zstring      ( ca -- ca' )  +string 1+ ; 1 1 #PARMS

// ///////////  Number literals and inline string literals :  ///////////////

: .(LIT)        ( codeitem -- )
        |AssocValue @ str ?NextRow.Str ; 1 0 #PARMS

: .'"'  ( -- ) ASCII " EMIT SPACE ; 0 0 #PARMS
: .String       ( codeitem str0 len0 -- )
        ROT OVER SWAP |Address @ CELL+ 1+ COUNT    // str0 len0 len0 str len
        ROT OVER + 1+ ?NextRow 2SWAP                  // str len str0 len0
        ?.TABS TYPE .'"'  TYPE  .'"' ; 3 0 #PARMS

: .($") ( codeitem -- )  " $" .String ; 1 0 #PARMS
: .(")  ( codeitem -- )  " " .String ; 1 0 #PARMS
: .(Z$) ( codeitem -- )  " Z$" .String ; 1 0 #PARMS
: .(.") ( codeitem -- )  " ." .String ; 1 0 #PARMS
: .(ABORT")  ( codeitem -- ) " ABORT" .String ; 1 0 #PARMS

// /////////////////////////  Control structures :  ////////////////////////

: control{      ( codeitem n -- )
        NEXTROW ?.TABS
        CASE
          1 OF ." IF" ENDOF
          2 OF ." BEGIN" ENDOF
          3 OF ." FOR" ENDOF
          4 OF ." DO" ENDOF
          5 OF ." ?DO" ENDOF
          6 OF ." AFT" ENDOF
          7 OF ." BEGIN  // <-- indefinite" ENDOF
          8 OF DUP .Word ENDOF // CREATE ... DOES>
	  9 OF ." [ 0 HERE ]" ENDOF //  >R ... [ 0 HERE ] ... NEXT  05/10/'96
         10 OF ." AHEAD" ENDOF
        ENDCASE
        .1TAB TAB++ NEXTROW DROP ; 2 0 #PARMS

: }control{     ( codeitem n -- )
        TAB-- NEXTROW ?.TABS
        CASE
          1 OF ." ELSE" ENDOF
          2 OF ." WHILE" ENDOF
          3 OF ." DOES>" ENDOF
        ENDCASE
        TAB++ NEXTROW DROP ; 2 0 #PARMS

: }control ( codeitem n -- )
        TAB-- NEXTROW ?.TABS
        CASE
          1 OF ." ENDIF" ENDOF
          2 OF ." REPEAT" ENDOF
          3 OF ." UNTIL" ENDOF
          4 OF ." AGAIN" ENDOF
          5 OF ." NEXT" ENDOF
          6 OF ." LOOP" ENDOF
          7 OF ." +LOOP" ENDOF
          8 OF ." THEN" ENDOF
        ENDCASE NEXTROW DROP ; 2 0 #PARMS

: .IF           ( codeitem -- ) 1 control{ ; 1 0 #PARMS
: .ELSE         ( codeitem -- ) 1 }control{ ; 1 0 #PARMS
: .ENDIF        ( codeitem -- ) 1 }control ; 1 0 #PARMS

: .BEGIN        ( codeitem -- ) 2 control{ ; 1 0 #PARMS
: .WHILE        ( codeitem -- ) 2 }control{ ; 1 0 #PARMS
: .REPEAT       ( codeitem -- ) 2 }control ; 1 0 #PARMS

: .UNTIL        ( codeitem -- ) 3 }control ; 1 0 #PARMS

: .AGAIN        ( codeitem -- ) 4 }control ; 1 0 #PARMS

: .FOR          ( codeitem -- ) 3 control{ ; 1 0 #PARMS
: .[HERE]	( codeitem -- ) 9 control{ ; 1 0 #PARMS
: .NEXT         ( codeitem -- ) 5 }control ; 1 0 #PARMS

: .AFT          ( codeitem -- ) 6 control{ ; 1 0 #PARMS
: .AHEAD        ( codeitem -- ) 10 control{ ; 1 0 #PARMS
: .THEN         ( codeitem -- ) 8 }control ; 1 0 #PARMS

: TABcount      ( codeitem -- tab-count )
        |CodeType C@ 2/ 2/ 2/ 2/ ; 1 1 #PARMS

: .?????'       ( codeitem .????? -- ) 
                OVER TABcount
                DUP FOR AFT  TAB--  THEN NEXT
                -ROT EXECUTE
                FOR   TAB++  NEXT ; 2 0 #PARMS
                
: .BEGIN'       ( codeitem -- ) 7 control{ ; 1 0 #PARMS

: .WHILE'       ( codeitem -- ) TAB++ .WHILE ; 1 0 #PARMS

: .WHILE''      ( codeitem -- ) 
        DUP TABcount FOR AFT  TAB--  THEN NEXT TAB++ .WHILE ; 1 0 #PARMS

: .REPEAT'      ( codeitem -- ) 
        DUP .REPEAT TABcount FOR AFT TAB++ THEN NEXT ; 1 0 #PARMS

: .NEXT'        ( codeitem -- ) ['] .NEXT  .?????' ; 1 0 #PARMS
: .UNTIL'       ( codeitem -- ) ['] .UNTIL .?????' ; 1 0 #PARMS
: .AGAIN'       ( codeitem -- ) ['] .AGAIN .?????' ; 1 0 #PARMS
                                

: .THEN'        ( codeitem -- ) .THEN TAB-- ; 1 0 #PARMS

: .DO           ( codeitem -- ) 4 control{ ; 1 0 #PARMS
: .?DO          ( codeitem -- ) 5 control{ ; 1 0 #PARMS
: .LOOP         ( codeitem -- ) 6 }control ; 1 0 #PARMS
: .+LOOP        ( codeitem -- ) 7 }control ; 1 0 #PARMS
: .LEAVE        ( codeitem -- ) DROP " LEAVE" ?NextRow.Str ; 1 0 #PARMS
: .?LEAVE       ( codeitem -- ) DROP " ?LEAVE" ?NextRow.Str ; 1 0 #PARMS

: .=>           ( codeitem -- ) DROP " => " ?NextRow.Str ; 1 0 #PARMS
: .EXIT		( codeitem -- ) DROP " EXIT" ?NextRow.Str ; 1 0 #PARMS


1 CONSTANT %andthen%                    // 01/24/'97
2 CONSTANT %orelse%

: .ANDTHEN/ORELSE       ( str len -- )
                TAB-- NEXTROW ?.TABS
                2 SPACES TYPE  SPACE TAB++ ; 2 0 #PARMS
: FirstANDTHEN/ORELSE   ( codeitem type -- )
                >R AnaStack::Top R@ <>  ORELSE   ( ci aci )
                2DUP 'sGotoAddress SWAP 'sGotoAddress <>   ELSE-OR
                IF
                        OVER R@ AnaStack::Push  TAB++
                ENDIF
                2DROP RDROP ; 2 0 #PARMS

: .ANDTHEN      ( codeitem -- )
                %andthen% FirstANDTHEN/ORELSE
                " ANDTHEN" .ANDTHEN/ORELSE ; 1 0 #PARMS
: .ORELSE       ( codeitem -- )
                %orelse% FirstANDTHEN/ORELSE
                " ORELSE" .ANDTHEN/ORELSE ; 1 0 #PARMS
: .THEN-AND     ( codeitem -- )
                AnaStack::Pop 3DROP
                " THEN-AND" .ANDTHEN/ORELSE TAB-- ; 1 0 #PARMS
: .ELSE-OR      ( codeitem -- )
                AnaStack::Pop 3DROP
                " ELSE-OR" .ANDTHEN/ORELSE TAB-- ; 1 0 #PARMS

// //////////////////////   Colon  Definitions   ////////////////////////

: .In/Out       ( in/out char -- )
        OVER $FF = IF
            2DROP ." ... "
        ELSE
            SWAP OVER + SWAP ?DO #I EMIT SPACE LOOP
        ENDIF ; 2 0 #PARMS

: .StackMap     ( ha -- )
        .1TAB ." ( "
        DUP |IN-PARMS C@ ASCII A .In/Out 
        ." -- "
        |OUT-PARMS C@ ASCII a .In/Out 
        ." )" ; 1 0 #PARMS

: .Semicolon    ( -- )
        CodeItemTrailer |AssocHead @ |ATTRIBUTE H@
        DUP IMMED AND
        IF " ; IMMEDIATE" ?NextRow.Str ELSE " ;" ?NextRow.Str ENDIF
        DUP COMPO AND
        IF " COMPILEONLY" ?NextRow.Str ENDIF
        $80 AND
        IF " MACRO" ?NextRow.Str ENDIF
        CR ; 0 0 #PARMS

: (.Colon)      ( -- )
        CodeItemHeader |AssocHead @ ." : " DUP .ID .StackMap ; 0 0 #PARMS 

: .RecurseDef  ( -- )
        (.Colon) .1TAB 
        TAB++ " RECURSIVE" ?NextRow.Str TAB-- NEXTROW ; 0 0 #PARMS

: .Colon        ( -- )
        (.Colon) NEXTROW ; 0 0 #PARMS

// //////////////////////   CREATE ... DOES>  :   ////////////////////////

: .CREATE   ( codeitem -- ) 8 control{  ; 1 0 #PARMS
: .DOES>    ( codeitem -- ) 3 }control{ ; 1 0 #PARMS

// Since DOES> lay down following codes : 
//        CALL ;DOES 
//        ( >CFA pointer )
//        EXPAND R>     <--- the definition of the defined word
// Use ;DOES to determine whether it is an defining word.

: DefinedWord?  ( ca -- ca-of-DOES> T ) // OR: ca -- ca F
      // Check words which are defined by Defining-words.
        DUP C@ %CALL% =
      ANDTHEN           ( ca )
        DUP 1+ @Rel>Abs NIP
        DUP CELL- CELL- @Rel>Abs NIP  ['] ;DOES  =
        DUP IF  ROT  ELSE  SWAP  ENDIF  DROP
      THEN-AND  ; 1 2 #PARMS

: +DOES>    ( ca -- ca' ) // skip the data which DOES> layed.
        CELL+ ( >CFA pointer )
        SIZEOF R> LITERAL + 1- ; 1 1 #PARMS

// ////////////////////   VARIABLE / CONSTANT   ////////////////////////

0 VALUE CurrWordStart  // These 2 values are initialized by "Discompile"
0 VALUE CurrWordEnd

: SetHeaderTrailer      ( head tail -- )
        CodeItemTrailer SetAuxDecompiler
        CodeItemHeader  SetAuxDecompiler ; 2 0 #PARMS

: .VARIABLE     ( -- )
        ." VARIABLE / CREATE  "
        CodeItemHeader |AssocHead @ .ID ; 0 0 #PARMS

: .Addr/content ( -- )
        CR .1TAB ."  Variable address = " CodeItemHeader DUP |Address @ .
        ." ; content = " |AssocValue @ . CR ; 0 0 #PARMS

: .CONSTANT     ( -- )
        CodeItemHeader |AssocValue @ . SPACE 
        ." CONSTANT / VALUE  "
        CodeItemHeader |AssocHead @ .ID ; 0 0 #PARMS

: .USER         ( -- )
        ." USER  " CodeItemHeader |AssocHead @ .ID ; 0 0 #PARMS

: Variable/Create       ( ca -- ca )
        DUP CodeItemHeader |Address !
        DUP @ CodeItemHeader |AssocValue !
        CurrWordStart >HEAD  CodeItemHeader |AssocHead  !
        ['] .VARIABLE  ['] .Addr/content  SetHeaderTrailer ; 1 1 #PARMS

: Constant/Value        ( ca -- ca )
        DUP @ CodeItemHeader |AssocValue !
        CurrWordStart >HEAD  CodeItemHeader |AssocHead  !
        ['] .CONSTANT  ['] CR  SetHeaderTrailer ; 1 1 #PARMS

: UserVariable          ( ca -- ca )
      // doUSER is an 1-address macro
        CurrWordStart >HEAD  CodeItemHeader |AssocHead  !
        LastCodeItem |AssocValue @ UP@ +
        DUP CodeItemHeader |Address ! @ CodeItemHeader |AssocValue !
        ['] .USER  ['] .Addr/content  SetHeaderTrailer ; 1 1 #PARMS     

// ------------------------------------------------------------------------ //
//       Control structure recognition State Machine implementation :       //
//         There are 16 recognizable control structures category :          //
// ------------------------------------------------------------------------ //

// These name have a clearer meaning :
: AnaStack::TopCodeItem  AnaStack::Top DROP ; 0 1 #PARMS

: Ambigious	( -- )
	// ." * SEE : Ambigious condition, can't SEE this word." CR
	AnaStack::Reset
	ABORT ; 0 0 #PARMS

// There are two kinds of ScanBackward, one stops immediately when it meet
// the destination address codeitem; another stops at the last codeitem 
// with the same address . ( BEGIN , THEN and ENDIF are dummy codeitems, 
// they have their address but in fact there is no code associate with it,
// so several BEGINs ( and THEN and ENDIF, and their random combinations )
// could come together with the same address, like this :
// 	BEGIN 	    <---+	ENDIF <---|	 AFT 
//	   BEGIN    <---|	BEGIN <---|	   IF 
//	      BEGIN <---+			   ENDIF   <---|
//		...				 THEN	   <---|

VARIABLE StopAtLast  // local flag for (ScanBackward) and ScanBackwardX

: SkipSameAddr	( codeitem -- codeitem' )
	BEGIN
	   DUP PrevWord |Address @  OVER |Address @ =
	WHILE
	   PrevWord
	REPEAT ; 1 1 #PARMS

: (ScanBackward)   ( codeitem -- codeitem' )
        DUP 'sGotoAddress SWAP  // ca ci
        BEGIN
           2DUP |Address @ <=
           WHILE
             2DUP |Address @ = SWAP PrevWord SWAP
        UNTIL
             NIP NextWord StopAtLast @ IF  SkipSameAddr  ENDIF
           ELSE // overstep, should be re-discompiled
              // ca ci
              DROP THROW // throw back 'goto-address'  
           THEN ; 1 1 #PARMS

: ScanBackwardI	 ( codeitem -- codeitem' )
      // immediate stop 
	StopAtLast OFF (ScanBackward) ; 1 1 #PARMS

: ScanBackwardL	 ( codeitem -- codeitem' )
      // stop at the last codeitem	
	StopAtLast ON (ScanBackward) ; 1 1 #PARMS

  1  CONSTANT  %ahead/aft-then
  2  CONSTANT  %if-then
 11  CONSTANT  %while-else-then
 12  CONSTANT  %while-else-then'
 15  CONSTANT  %andthen
 16  CONSTANT  %orelse

// Each state represents one kind of control structure, from 1 to 16.
// For each control structure, those words in parenthesis (...) 
// ( eg. '..THEN' in 'AFT(..THEN)' ) means that this control structure can
// be determined according to current 'discompiler pointer', and those words 
// (in parenthesis) will be resolved later and currently only a part of this 
// control structure can be discompiled . So push the other part of this 
// control structure into 'AnaStack' .

// <1>
: AHEAD/AFT(..THEN)   ( codeitem -- codeitem' )
        ['] .AHEAD OVER SetAuxDecompiler
        DUP %ahead/aft-then AnaStack::Push  ; 1 1 #PARMS

// <2>
: IF/WHILE..ELSE(..ENDIF/THEN)  ( codeitem -- codeitem' )
      // Settle .ELSE only . So change AnaStack::Top's CodeItem entry 
      // but don't change its type so that "TryResolveForward" could
      // decide whether it is "..ELSE..THEN" or "..ELSE..ENDIF" .
        ['] .ELSE OVER SetAuxDecompiler
        DUP AnaStack::Pop NIP AnaStack::Push ( change it's codeitem entry )
        ; 1 1 #PARMS

// <3>
: Set.BEGIN     ( codeitem -- codeitem' )
        DUP ScanBackwardI
        ['] .BEGIN SWAP InsertDecompiler
        NextWord  ; 1 1 #PARMS

: BEGIN..UNTIL  ( codeitem -- codeitem' )
        Set.BEGIN  ['] .UNTIL OVER SetAuxDecompiler  ; 1 1 #PARMS

// <4>
: BEGIN..AGAIN  ( codeitem -- codeitem' )
        Set.BEGIN  ['] .AGAIN OVER SetAuxDecompiler  ; 1 1 #PARMS

// <5>
: AnaStack::TopCodeItem++       ( -- ) 
   // The "Set.BEGIN" will insert an extra codeitem prior to ..WHILE.. ,
   // so the top element of analysis stack should be heighten .
        AnaStack::Pop >R NextWord R> AnaStack::Push  ; 0 0 #PARMS

: BEGIN..WHILE..REPEAT  ( codeitem -- codeitem' )
        Set.BEGIN  ['] .REPEAT OVER SetAuxDecompiler
        ['] .WHILE AnaStack::Top DROP NextWord SetAuxDecompiler ; 1 1 #PARMS

// <6>
: FOR..NEXT     ( codeitem -- codeitem' )
        DUP ScanBackwardL PrevWord // this word should be ">R", if it is not,
				   // this word is written in such kind :
				   // ... >R ... [ HERE ] ... NEXT ...
	DUP |AssocHead @  [`] >R  =  IF
            ['] .FOR SWAP SetAuxDecompiler
	ELSE
	    ['] .[HERE] SWAP NextWord InsertDecompiler NextWord
	ENDIF
        ['] .NEXT OVER SetAuxDecompiler  ; 1 1 #PARMS

// <7>
: FOR..AFT..THEN..NEXT  ( codeitem -- codeitem' )
     // AFT..THEN has already been settle down
        DUP 'sGotoAddress OVER ScanBackwardL
        0 >R  // 0 is used for ">R ... R>" pair count
        BEGIN // find the first ">R" before AFT
             2DUP |Address @  >      ( AFT'sNextWord > Codeitem'sAddress )
           ANDTHEN
             // there might be ">R ... R>" pair between FOR .. AFT
             DUP |AssocHead @
             DUP [`] R> = IF  R> 1+ >R  ENDIF
             [`] >R = DUP IF  R> 1- >R  ENDIF
           ANDTHEN
             R@  -1  =
           THEN-AND
           SWAP PrevWord SWAP
        UNTIL
        RDROP NIP NextWord ['] .FOR SWAP SetAuxDecompiler
        ['] .NEXT OVER SetAuxDecompiler  ; 1 1 #PARMS

// <8>
// In state <8>,<9> and <10>, the correct "BEGIN" address cannot be 
// determined, so use "AFT" 's previous word as the position .
: Set.BEGIN..AFT        ( codeitem -- codeitem' )
        DUP ScanBackwardL PrevWord
        ['] .BEGIN' SWAP InsertDecompiler       // indefinite BEGIN
        NextWord  ; 1 1 #PARMS

: BEGIN..AFT..THEN..UNTIL       ( codeitem -- codeitem' )
        Set.BEGIN..AFT  ['] .UNTIL OVER SetAuxDecompiler  ; 1 1 #PARMS

// <9>
: BEGIN..AFT..THEN..AGAIN       ( codeitem -- codeitem' )
        Set.BEGIN..AFT  ['] .AGAIN OVER SetAuxDecompiler  ; 1 1 #PARMS

// <10>
: BEGIN..AFT..THEN..WHILE..REPEAT ( codeitem -- codeitem' )
        Set.BEGIN..AFT  ['] .REPEAT OVER SetAuxDecompiler
        AnaStack::TopCodeItem++
        ['] .WHILE AnaStack::Pop DROP SetAuxDecompiler  ; 1 1 #PARMS

// Currently only single exit is implemented. Multiple exits remain unsolved.
// <11>
: WithinCurrentLoop?    ( chk_codeitem curr_codeitem -- T/F )
        SWAP |Address @ SWAP
        DUP 'sGotoAddress  SWAP |Address @  BETWEEN ; 2 1 #PARMS

DEFER NextWord/NOOP

: Set.WHILE'    ( #i -- )
        DUP AnaStack::Pick DROP NextWord/NOOP
        ['] .WHILE' OVER SetAuxDecompiler
        %while-else-then ROT AnaStack::Put ; 1 0 #PARMS

: ..WHILEs..    ( codeitem -- count ) // return number of WHILEs
        0       // count
        AnaStack::Depth 0 DO
           OVER  #I AnaStack::Pick DROP   SWAP WithinCurrentLoop? 
           NOT IF  // change type, then leave
	     // the last THEN must do some back-tabs so it's different.	
              DUP 1- DUP AnaStack::Pick DROP 
	      %while-else-then' ROT AnaStack::Put  LEAVE
           ENDIF
           #I Set.WHILE'
           1+   ( codeitem count++ )
        LOOP NIP ; 1 1 #PARMS

: Set_TAB_count  ( count codeitem -- )
        |CodeType DUP 
        C@   ROT 2* 2* 2* 2*   OR
        SWAP C! ; 2 0 #PARMS

: FOR..WHILEs..NEXT(..[ELSE]s..THENs)   ( codeitem -- codeitem' )
      // Depth couldn't possible be 0 now since there must be at least
      // one item on AnaStack meet the constrains to enter this routine.
        FOR..NEXT  ['] NOOP IS NextWord/NOOP
        DUP ..WHILEs.. OVER Set_TAB_count
        ['] .NEXT' OVER SetAuxDecompiler  ; 1 1 #PARMS
        
// <12>
: BEGIN..WHILEs..UNTIL(..[ELSE]s..THENs)  ( codeitem -- codeitem' )
        BEGIN..UNTIL  ['] NextWord IS NextWord/NOOP
        DUP ..WHILEs.. OVER Set_TAB_count
        ['] .UNTIL' OVER SetAuxDecompiler  ; 1 1 #PARMS

// <13>
: BEGIN..WHILEs..AGAIN(..[ELSE]s..THENs)   ( codeitem -- codeitem' )
        BEGIN..AGAIN  ['] NextWord IS NextWord/NOOP
        DUP ..WHILEs.. OVER Set_TAB_count
        ['] .AGAIN' OVER SetAuxDecompiler  ; 1 1 #PARMS

// <14>
: BEGIN..WHILEs..REPEAT(..[ELSE]s..THENs)  ( codeitem -- codeitem' )
        BEGIN..WHILE..REPEAT ['] NextWord IS NextWord/NOOP
        DUP ..WHILEs.. 2DUP SWAP Set_TAB_count // Set .REPEAT' 's TAB count
        OVER ['] .REPEAT' SWAP SetAuxDecompiler
        AnaStack::Pop DROP ['] .WHILE'' OVER SetAuxDecompiler
        Set_TAB_count ; 1 1 #PARMS

// <15>
: ANDTHEN(..THEN-AND)   ( codeitem ca -- codeitem' ca' )      // (13)
        SWAP AnaStack::Top NIP %andthen <>
        ORELSE
          AnaStack::Top NIP %andthen = ANDTHEN
          DUP 'sGotoAddress AnaStack::Top DROP 'sGotoAddress <> THEN-AND
        ELSE-OR
        IF
           DUP  %andthen  AnaStack::Push
        ENDIF
        SWAP SIZEOF DROP LITERAL 1- + 
        OVER ['] .ANDTHEN SWAP SetAuxDecompiler  ; 2 2 #PARMS

// <16>
: ORELSE(..ELSE-OR)     ( codeitem ca -- codeitem' ca' )      // (14)
        SWAP AnaStack::Top NIP  %orelse  <>  IF
           DUP %orelse AnaStack::Push
           ['] .ORELSE OVER SetAuxDecompiler
        ENDIF 
        SWAP SIZEOF DROP LITERAL 1- +
        OVER ['] .ORELSE SWAP SetAuxDecompiler  ; 2 2 #PARMS

// Resolve the words in parenthesis :

: AddTrailingCodeItem   ( ca -- )
        AnaStack::Pop DROP
        0 DUP DUP AddCodeItem
        SWAP 'sGotoAddress OVER |Address !
        SetAuxDecompiler  ; 1 0 #PARMS

: ..THEN        ( -- ) // Set .THEN of AFT..THEN
        ['] .THEN  AddTrailingCodeItem  ; 0 0 #PARMS

: ..ENDIF       ( -- )
        ['] .ENDIF  AddTrailingCodeItem  ; 0 0 #PARMS

: ..[ELSE]..THEN'       ( -- )
    // Note that the ".ELSE" is settled by (2).
        ['] .THEN'  AddTrailingCodeItem  ; 0 0 #PARMS

: ..[ELSE]..THEN        ( -- )
        ..THEN ; 0 0 #PARMS

: ..THEN-AND    ( -- )
        ['] .THEN-AND  AddTrailingCodeItem ; 0 0 #PARMS

: ..ELSE-OR     ( -- )
        ['] .ELSE-OR   AddTrailingCodeItem ; 0 0 #PARMS

// ------------------------------------------------------------------------ //

: is:?BRAN  ( codeitem -- T/F )   |AssocHead @ [`] ?BRANCH  =  ; 1 1 #PARMS
: is:BRAN   ( codeitem -- T/F )   |AssocHead @ [`] BRANCH   =  ; 1 1 #PARMS
: is:next   ( codeitem -- T/F )   |AssocHead @ [`] next     =  ; 1 1 #PARMS

: backward?     ( codeitem -- T/F )
        DUP |Address @ SWAP 'sGotoAddress  >=   ; 1 1 #PARMS
: forward?      ( codeitem -- T/F )
        backward? NOT ; 1 1 #PARMS

: forward-?BRANCH-on-stack?     ( -- T/F )
      // This condition tests the possibility of WHILE .. [ELSE] .. THEN 
        AnaStack::TopCodeItem
        DUP 0<>  ANDTHEN  DUP is:?BRAN  ANDTHEN  DUP forward?
        THEN-AND NIP ; 0 1 #PARMS

: WHILEs..ELSEs..THENs? ( codeitem -- T/F )
        forward-?BRANCH-on-stack?  ANDTHEN
        AnaStack::TopCodeItem OVER WithinCurrentLoop?
        THEN-AND NIP ; 1 1 #PARMS

: AFT..THEN?    ( codeitem -- T/F )
      // This condition tests the possibility of AFT .. THEN    
        DUP ScanBackwardL        // ci cib
        DUP PrevWord is:BRAN  
      ANDTHEN
        2DUP 'sGotoAddress SWAP |Address @ <=
      ANDTHEN  // 01/24/'97
        ['] .AFT OVER PrevWord SetAuxDecompiler TRUE
      THEN-AND
        -ROT 2DROP ; 1 1 #PARMS

: Analyze:UNTIL ( codeitem -- codeitem' )
        DUP WHILEs..ELSEs..THENs?
        IF
            BEGIN..WHILEs..UNTIL(..[ELSE]s..THENs)      // (12)
        ELSE
        DUP AFT..THEN?
        IF
            BEGIN..AFT..THEN..UNTIL                     // (8)
        ELSE
            BEGIN..UNTIL                                // (3)
        ENDIF ENDIF  ; 1 1 #PARMS

: Analyze:REPEAT  ( codeitem -- codeitem' )
        DUP AnaStack::Pop ROT WHILEs..ELSEs..THENs? -ROT AnaStack::Push
        IF
            BEGIN..WHILEs..REPEAT(..[ELSE]s..THENs)
        ELSE
        DUP AFT..THEN? IF
            BEGIN..AFT..THEN..WHILE..REPEAT             // (9.5)
        ELSE
            BEGIN..WHILE..REPEAT AnaStack::Pop 2DROP    // (5)
        ENDIF ENDIF ; 1 1 #PARMS

: Analyze:AGAIN ( codeitem ca -- codeitem' )
     // ca = next word address of BRANCH<--     
        OVER WHILEs..ELSEs..THENs?
        IF 
            AnaStack::TopCodeItem 'sGotoAddress  =  IF
                Analyze:REPEAT
            ELSE
                BEGIN..WHILEs..AGAIN(..[ELSE]s..THENs)  // (12)
            ENDIF
        ELSE 
        DROP DUP AFT..THEN? IF
            BEGIN..AFT..THEN..AGAIN                     // (9)
        ELSE
            BEGIN..AGAIN                                // (4)
        ENDIF ENDIF ; 2 1 #PARMS

// "?BRANCH", "BRANCH" and "next" are 1-address instructions, so there is 
// no need to advance the discompiler pointer from ca to ca' .

: Analyze:?BRAN  ( codeitem ca -- codeitem' ca' )
     // ca = address of "?BRANCH" 's next word 
        >R DUP backward? IF
           Analyze:UNTIL
        ELSE // forward
           // Assume it to be .IF first, if it is "WHILE", other words will
           // do the necessary type modifition.
           ['] .IF OVER SetAuxDecompiler
           DUP %if-then AnaStack::Push // either IF or WHILE
        ENDIF R> ; 2 2 #PARMS

: OuterBranch?   ( codeitem -- T/F )
    // Check whether it branch out of current word, if it is, then it is an 
    // optimized word :  CALL XXXX RET ==>  JMP XXXX
        DUP 'sGotoAddress  CurrWordStart 1-  CurrWordEnd  BETWEEN  NOT
        DUP IF
           OVER ['] .WordBranched SWAP SetAuxDecompiler
        ENDIF NIP  ; 1 1 #PARMS

: Analyze:BRAN  ( codeitem ca -- codeitem' ca )
     // ca = address of "BRANCH" 's next word .
        OVER OuterBranch? NOT IF
           >R DUP backward? IF
              R@ Analyze:AGAIN
           ELSE
              forward-?BRANCH-on-stack?  ANDTHEN
              R@   AnaStack::TopCodeItem 'sGotoAddress   =  THEN-AND  IF
                 IF/WHILE..ELSE(..ENDIF/THEN)           // (2)
              ELSE
                 AHEAD/AFT(..THEN)                      // (0)
              ENDIF
           ENDIF R>
        ENDIF ; 2 2 #PARMS

: Analyze:next  ( codeitem ca -- codeitem' ca' )
     // ca = address of "next" 's next word
        >R 
        DUP WHILEs..ELSEs..THENs?
        IF
           FOR..WHILEs..NEXT(..[ELSE]s..THENs)          // (11) 
        ELSE
        DUP AFT..THEN?
        IF
           FOR..AFT..THEN..NEXT                         // (7)
        ELSE
           FOR..NEXT                                    // (6)
        ENDIF ENDIF
        R> ; 2 2 #PARMS

// ///////////////////////////////////////////////////////////////////////////
//          Analyst Table Building                                          //
// ///////////////////////////////////////////////////////////////////////////
// There are two kinds of Analyst table, one is for control structures and
// the other is normal.
//   CtrlStructAnalysts analyze the code flow of the discompiled codes.
//         It can be turned off by setting [ Analysis ] flag OFF.
//   Analysts analyze other compiling words such as strings, literals ...

: +++   ( -- ) // TIB: <name> <name> <name>
        ` ,     ( 1 head )
        ' , ' , ( 2 vectors ) ; 0 0 #PARMS

: (End-Analysts) ;      // build a dummy header for marking table-end
: (AnyWord) ;           // build a dummy header for any word.
: LinkAnalysts    ( -- )  ( TIB: <table_name> -- ) RECURSIVE
        [`] LinkAnalysts ,  ' EXECUTE , -1 ,
        ; 0 0 #PARMS    // Link table to a new place.

CREATE  DefaultCtrlStructAnalysts      // Control structure analysts
      // ------------------------------------------------------
      //        head         addr-adjustor      sourcer
      // ------------------------------------------------------
        +++     ?BRANCH      Analyze:?BRAN      NOOP
        +++     BRANCH       Analyze:BRAN       NOOP
        +++     next         Analyze:next       NOOP

        +++  (End-Analysts)     NOOP            NOOP

    //  +++   (AnyWord)      Analyze:AnyWord    NOOP
    //  LinkAnalysts  AnalystsTableName    // Sample use for LinkAnalysts
      // ------------------------------------------------------

CREATE  DefaultAnalysts                // other compiling word analysts
      // ------------------------------------------------------
      //        head         addr-adjustor      sourcer
      // ------------------------------------------------------
        +++     JT=0      ANDTHEN(..THEN-AND)   NOOP
        +++     JT<>0     ORELSE(..ELSE-OR)     NOOP

        +++     (LIT)           NOOP            .(LIT)
        +++     $"|             +string         .($")
        +++     "|              +string         .(")
        +++     ."|             +string         .(.")
        +++     abort"          +string         .(ABORT")
        +++     Z$"|            +Zstring        .(Z$)

	+++	exit		NOOP		.EXIT

        +++     (DO)            CELL+           .DO
        +++     (?DO)           CELL+           .?DO
        +++     (LOOP)          CELL+           .LOOP
        +++     (+LOOP)         CELL+           .+LOOP
        +++     (LEAVE)         NOOP            .LEAVE
        +++     (?LEAVE)        NOOP            .?LEAVE

        +++     CREATE          NOOP            .CREATE
        +++     ;DOES           +DOES>          .DOES>

        +++     doVAR       Variable/Create     DROP
        +++     doCONST     Constant/Value      DROP
        +++     doUSER      UserVariable        DROP

        +++     %!>             NOOP            .=>

        +++  (End-Analysts)     NOOP            NOOP
      // ------------------------------------------------------

DefaultCtrlStructAnalysts  VALUE  CtrlStructAnalysts
DefaultAnalysts            VALUE  Analysts

VARIABLE Analysis 
Analysis ON

: AnyWordWillDo   ( ca ci ha ana -- ca' ci' ha ana )
     // This could be used to check every word, ex. check its CREATOR ...
        >R R@ CELL+ @ SWAP >R             // ca ci ana^    ana ha
        -ROT SWAP ROT EXECUTE SWAP        // ca ci -- ca' ci'
        R> R> ; 4 4 #PARMS                // ca' ci' ha ana

: (Analyze)       ( ca codeitem analysts_table -- ca' T/F )
        >R DUP |AssocHead @ R>
        BEGIN           // ca ci ha ana
           DUP @ [`] (AnyWord) = IF             // ca ci ha ana
              AnyWordWillDo TRUE
           ELSE
              2DUP @  <>
           ENDIF
           WHILE
              DUP @ [`] LinkAnalysts = IF       // ca' ci' ha ana
                  DUP 2 CELLS + @ -1 <> ABORT" * SEE : Invalid analysts table."
                  CELL+ @
              ELSE
                  [ 3 CELLS ] LITERAL +  // ca ci ha ana' // next analyst
              ENDIF
              DUP @ [`] (End-Analysts) =
        UNTIL
              3DROP FALSE
           ELSE // found   ca ci ha ana
              -ROT HEAD>  OVER |Address @   <>  IF
                 SWAP CELL+ >R SWAP R@ @EXECUTE // ci ca -- ci ca'
                 R> CELL+ @ ROT SetAuxDecompiler
              ELSE
                 2DROP
              ENDIF
	      TRUE      // Analyst worked
           THEN  ; 3 2 #PARMS

: Analyze	( ca codeitem -- ca' )
	2DUP Analysts  (Analyze) NOT  Analysis @ AND
	IF
	   DROP CtrlStructAnalysts (Analyze) DROP
	ELSE
	   -ROT 2DROP
	ENDIF ; 2 1 #PARMS

: LowLevelSolve	 ( goto codeitem -- goto_next T/F )
	DUP -ROT |Address @ 
	DUP  CurrWordEnd OVER -  SearchMacro NIP // ci gt ca node/0
      	DUP IF
      	   -ROT >R
      	   BEGIN // ci node gt ;R: ca
      	      SWAP TraceAncestor DUP 	// ci gt node' node' ;R: ca
      	      WHILE
      	         R@ SWAP after_macro	// ci gt ca' node'
      	         -ROT OVER  =  		// ci node' gt ca'=gt
      	   UNTIL
	     	 -ROT SWAP >R
                 |ASSOC-MACRO-HEAD @  0  ZA  R>  SetCodeItem 
                 TRUE
      	      ELSE
	     	 -ROT 2DROP FALSE
      	      THEN
           RDROP  
      	ELSE
	   NIP ROT DROP
	ENDIF ; 2 2 #PARMS

: Disassemble   ( ca -- ca' )
        ( CPU80486::) DISASSEMBLE
        0 0 DASM  AddCodeItem DROP ; 1 1 #PARMS

: DisassembleSolve  ( goto codeitem -- goto_next T / F F )
        SWAP >R DUP |Address @ 
        ( CPU80486:: ) DISASSEMBLE SWAP >R  0 0 DASM R>  SetCodeItem 
        BEGIN 
           DUP R@ <
        WHILE
           Disassemble   
        REPEAT
        DUP R> = DUP NOT IF
           NIP DUP
        ENDIF ; 2 2 #PARMS

: SolveAmbiguity	( goto codeitem  -- goto_next T / F F )
      // codeitem's address is prior to goto address
        2DUP LowLevelSolve  // goto ci goto' T/F 
      ORELSE
        DROP 2DUP DisassembleSolve
      ELSE-OR 
        2SWAP 2DROP ; 2 2 #PARMS

DEFER ForwardResolver   ( ctrl_type -- continue? )
: DefaultForwardResolver        ( ctrl_type -- continue? )
        TRUE SWAP
        CASE
           %ahead/aft-then   OF  ..THEN           ENDOF
           %if-then   	     OF  ..ENDIF          ENDOF
           %while-else-then  OF  ..[ELSE]..THEN   ENDOF
           %while-else-then' OF  ..[ELSE]..THEN'  ENDOF
           %andthen  	     OF  ..THEN-AND       ENDOF
           %orelse   	     OF  ..ELSE-OR        ENDOF
           SWAP FALSE SWAP
        ENDCASE ; 1 1 #PARMS
' DefaultForwardResolver IS ForwardResolver

: TryResolveForward     ( ca -- ca )  RECURSIVE
        AnaStack::Top 0<> IF
           'sGotoAddress 2DUP = IF      // resolve it
               DROP AnaStack::Top NIP
               ForwardResolver ASSERT{ DUP }?ASSERT" * Foward not resolved."
               DROP
               TryResolveForward   // forwards might reference to same address
           ELSE 2DUP > IF  // re-discompile the lattest word  ( ca goto )
	      // should re-discompile it, (ca > branch to address)	
	       NIP  LastCodeItem  SolveAmbiguity
	       IF  TryResolveForward  ELSE  Ambigious  ENDIF
           ELSE
	       DROP	
	   ENDIF ENDIF
        ELSE
           DROP 
        ENDIF  ; 1 1 #PARMS

: HighLevel?   ( ca -- ca' T/F )        // HighLevel : i.e. Non Macros
        DUP C@ %CALL% = 
      ANDTHEN
        1+ @Rel>Abs 
        DUP CurrWordStart = IF
           ['] .RecurseDef CodeItemHeader SetAuxDecompiler
        ENDIF
        >HEAD 0 NM AddCodeItem Analyze TRUE   ( ca+5+? T )
      THEN-AND ; 1 2 #PARMS

: ReDiscompile  ( ca -- ca' T / F F )
        BEGIN // pop off AnaStack which comes after ca
           AnaStack::Top DROP   DUP 0<>  ANDTHEN 
           2DUP |Address @      <        THEN-AND NIP
        WHILE 
           AnaStack::Pop 2DROP
        REPEAT
        BEGIN // cleanup codeitems which comes after ca
           LastCodeItem |Address @ OVER >
        WHILE
           CurrCodeItemIdx 1-  =>  CurrCodeItemIdx 
        REPEAT
        LastCodeItem SolveAmbiguity  ; 1 2 #PARMS

: LowLevel?    ( ca -- ca' T/F )        // LowLevel : i.e. MACROs
        DUP  CurrWordEnd OVER -  SearchMacro DUP ( ca ca' nd nd ) // ca ca F F
      ANDTHEN
        DUP |ASSOC-MACRO-HEAD @
        SWAP |ADDRESSING C@
        CASE    ( ca ca' ha )
            ZA  OF   0 ZA                         ENDOF
           1AI  OF   SWAP DUP CELL+ -ROT @  1AI   ENDOF
           1AR  OF   SWAP @Rel>Abs ROT SWAP 1AR   ENDOF
        ENDCASE ( ca ca' ha val type )
        AddCodeItem 
        ['] Analyze CATCH ?DUP IF // ca ca' ci goto
            // re-discompile this address since Analyze failed.
            >R 3DROP R> ReDiscompile DUP NOT IF  Ambigious  ENDIF 
            EXIT
        ENDIF
        TRUE DUP ( ca ca' T T )
      THEN-AND NIP ROT DROP ; 1 2 #PARMS

DEFER PreDiscompile     ( ca-start ca-end -- ca-start' ca-end' ) 2 2 #PARMS
DEFER PostDiscompile    ( ca' -- ca'' ) 1 1 #PARMS
' NOOP IS PreDiscompile
' NOOP IS PostDiscompile

: Discompile    ( ca-start ca-end -- ca' )
     // ca' : next word address after ca-end.
        2DUP => CurrWordEnd => CurrWordStart
        PreDiscompile
        SWAP ( ca-end ca-start )
        BEGIN
            DUP  CurrCodeItemIdx ()Codes |Address  !
            HighLevel?  ORELSE
            LowLevel?   ELSE-OR
            NOT IF  Disassemble  ENDIF
            TryResolveForward
        2DUP <= UNTIL DROP
        PostDiscompile
        ; 2 1 #PARMS

// ///////////////////////////////////////////////////////////////////////////
//                      Output functions :
// ///////////////////////////////////////////////////////////////////////////

: ?EXECUTE      ( ca/0 -- )
        ?DUP IF EXECUTE ENDIF   ; 1 0 #PARMS

DEFER .Source
: <.Source>     ( -- )
        CodeItemHeader |AuxDecom @ ?EXECUTE // header
	SHOW-CODES @ SHOW-CODES OFF
        CurrCodeItemIdx  0 DO
            #I  ()Codes  DUP |CodeType C@
            DUP AUXDECOM AND IF
                DROP DUP |AuxDecom @EXECUTE
            ELSE DASM AND IF
                |Address @ NEXTROW
		.TABS ." INLINE[  " DISASM1 DROP ."  ]INLINE" NEXTROW
            ELSE // display words with it's original form if Analysis ON
		Analysis @ IF
                   .Word
		ELSE
		   DUP |Address @ .H TAB TAB .Word NEXTROW
		ENDIF
            ENDIF ENDIF
            NUF? IF  CR ." SEE : User break " LEAVE  ENDIF
        LOOP
	SHOW-CODES !
        CodeItemTrailer |AuxDecom @ ?EXECUTE // trailer
        ; 0 0 #PARMS
' <.Source> IS .Source

: Set.Colon     ( ha -- )
        0 0 CodeItemHeader SetCodeItem
        ['] .Colon  CodeItemHeader   SetAuxDecompiler ; 1 0 #PARMS

: Set.Semicolon  ( ha -- )
        0 0 CodeItemTrailer SetCodeItem
        ['] .Semicolon  CodeItemTrailer  SetAuxDecompiler ; 1 0 #PARMS

: SeeInto  ( code-start code-end -- ca' )
	Analysis ON
	2DUP ['] Discompile CATCH 
	0<> IF
	   Analysis OFF  0 => CurrCodeItemIdx
	   2DROP Discompile  // Why should I use 2DROP but not DROP ?
	ELSE
	   -ROT 2DROP
	ENDIF
	.Source ; 2 1 #PARMS

: SeeColonWord  ( ca -- ca' )
        DUP >HEAD       // ca ha
        DUP Set.Colon  DUP Set.Semicolon
        |SIZE @ OVER + 1-       // startca endca
        SeeInto ; 1 1 #PARMS

: SeeDefinedWord        ( ca -- ca' T ) // OR: ca -- ca F
        >R R@ DefinedWord?
      ANDTHEN
        ['] DEFER R@ CREATOR? IF        // See deferred word  01/24/'97
           ." DEFER " R@ >HEAD .ID TAB
           ." ' " R@ >DEFERRED DUP CODE>HEAD .ID ."  IS " R@ >HEAD .ID CR
           SeeColonWord DROP
        ELSE
           R@ >HEAD Set.Semicolon
           DUP CELL- @ DUP >HEAD DUP .ID SPACE R@ >HEAD .ID CR
           ."   DOES> " R@ >HEAD .StackMap NEXTROW
           |SIZE @ + 1- SWAP [ SIZEOF R> 1- ] LITERAL + ( skip R> )
           SWAP SeeInto
        ENDIF
        TRUE
      THEN-AND RDROP ; 1 2 #PARMS

: ResetSEE	// 09/26/'95
      0 => CurrCodeItemIdx   1 => #TABS   CleanDiscompBuffer  
      AnaStack::Reset ;

FORTH DEFINITIONS

: |SEE|	  ( ca size -- )		// 09/26/'95
	ResetSEE
	CR OVER + SeeInto DROP ; 2 0 #PARMS

: <SEE>   ( ca -- )
        ResetSEE
        CR SeeDefinedWord NOT IF  SeeColonWord   ENDIF DROP ; 1 0 #PARMS

HIDDEN DEFINITIONS

: (SEE)   ( <name> -- )
        ' <SEE> ; 0 0 #PARMS

FORTH DEFINITIONS

' (SEE) IS SEE

BUG-WARNING ON
ONLY FORTH ALSO DEFINITIONS


