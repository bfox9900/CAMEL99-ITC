\ pocovdp.fth  text editor using VDP RAM file storage Oct 14 2025

\ library includes
 NEEDS DUMP      FROM DSK1.TOOLS

NEEDS CASE      FROM DSK1.CASE
NEEDS MARKER    FROM DSK1.MARKER
NEEDS RKEY      FROM DSK1.RKEY
NEEDS -TRAILING FROM DSK1.TRAILING
NEEDS MALLOC    FROM DSK1.MALLOC

NEEDS 80COLS FROM DSK1.80COL
 80COLS

HERE
\ Editor specific includes
NEEDS READ-FILE FROM DSK2.FILE2VDP

MARKER /POCO

: PURGE   NEW-$POOL NEW-NODES  #LINES OFF ;

\ utility words
DECIMAL
: >=   1- > ;
: GETXY   ( -- col row) VROW 2@ ;
: BETWEEN ( n lo hi -- ? ) 1+ WITHIN ;
: CLIP    ( n lo hi -- n') ROT MIN MAX  ;
: SCREEN ( u --) 7 VWTR ;
: RETURN;   POSTPONE EXIT  POSTPONE THEN ; IMMEDIATE

\ decrement variable by 'n' but never go below zero
: SAFE-! ( n addr -- ) DUP>R @ SWAP - 0 MAX R> ! ;


\ ============= [ POCO VDP BEGINS ]==============
HEX
17 CONSTANT BLK/CYAN
30 CONSTANT GRN/BLK

DECIMAL
VARIABLE INSERT   \ insert/over-write flag
VARIABLE TOPLINE  \ topline that is listed on screen
VARIABLE CURPOS
VARIABLE updated   \ set to true when you change a buffer

: UPDATE  updated ON ;

: #CHARSRIGHT  ( -- n) C/L@ CURPOS @ - ;
: ERASELN ( -- ) #CHARSRIGHT BL VFILL ;
: PROMPT: ( -- ) 0 23 AT-XY VPOS ERASELN ;

\ Syntax sugar
: LEN   ( addr -- c)  C@ ;
: VLEN  ( Vaddr -- c) VC@ ;

\             ** NAMING CONVENTION **
\  words with a leading '$' return a stack string
\
CREATE FILENAME  16 ALLOT
: $FILENAME ( -- addr len ) FILENAME COUNT ;


\ data structures
128 CONSTANT BUFFSIZE \ buffer is big to allow insertions
: HEAP ( -- addr)  S" H @" EVALUATE ; IMMEDIATE
: EDIT-BUFFER ( -- addr) HEAP ; ( use un-allocated memory)

: $EDIT-BUFFER ( -- addr len)  EDIT-BUFFER COUNT ;  \ access as a stack string

: 'TEXT  ( -- addr) EDIT-BUFFER 1+ ; \ skip the byte count


CREATE XY  0 , 0 ,   \ holds screen position for editline as 2var
\ editor intenal coordinates
XY       CONSTANT ROW
XY CELL+ CONSTANT COL

\ the LINE we are editing is the screen ROW + TOPLINE
\ Added min to limit the valid line nodes
: THELINE#  ( -- n ) ROW @ TOPLINE @ +  ( #LINES @ MIN)  ;

\ addresses in the buffer being edited
DECIMAL

\ manage 80 columns lines on 40 col. screen
DECIMAL
VARIABLE SOL    \ "start of line"

: SCRWIDTH ( -- n)  C/L@ 1- ;
: 80COL-CURSOR ( -- n)  CURPOS @  SOL @ +  80 MIN ;
: 'CURSOR   ( -- addr) 'TEXT  80COL-CURSOR  + ;

\ top 22 #LINES is the editor screen
  C/SCR @ C/L@ - CONSTANT SCRSIZE
  SCRSIZE C/L@ - CONSTANT BOTTOMLINE ( -- Vaddr)

\ -------------------------------------------
\ 40/80 column partial line displayer

\ fast VDP type
: VTYPE  ( adr len  ) DUP>R VPOS SWAP VWRITE R> VCOL +! ;
: FITTED ( addr len -- addr' len') SOL @ /STRING 0 MAX SCRWIDTH MIN ;

DECIMAL
\ : VDP.TYPE BOUNDS ?DO I VC@ VPUT VCOL 1+! LOOP ;  \ slow version

\ * It is 3X faster to VREAD VDP string into RAM then VWRITE it to screen
: VDP.TYPE ( Vaddr len -- ) TUCK PAD SWAP VREAD  PAD SWAP VTYPE ;

: ]TYPELN ( line# -- ) ( TRUE means node is empty )
    DUP ]NODE @ TRUE = IF  DROP  [CHAR] ~ EMIT  RETURN;
    ]POOL$ FITTED VDP.TYPE
;

: (LIST)  ( start end -- ) SWAP DO  I ]TYPELN CR  LOOP ;
: LIST ( start --) DUP 23 +  (LIST) ; \ full page

: REMAINING ( line# -- n) 23 + ROW @ - 1- 0 MAX ;
: PARTLIST ( startline ) DUP REMAINING (LIST) ;

: REDRAW  ( -- ) PAGE  TOPLINE @ LIST ;
: AT-CURSOR ( -- ) CURPOS @ ROW @ AT-XY ;
: AT-LINE   ( -- ) 0 ROW @ AT-XY ;

: VDP$.READ   ( Vaddr len addr ) 2DUP C! 1+ SWAP  VREAD ;
: CLEAN       ( caddr -- ) DUP 1+ BUFFSIZE BL FILL  0 SWAP C! ;

: RELOAD-BUFFER
    EDIT-BUFFER CLEAN
    THELINE# ]POOL$  EDIT-BUFFER VDP$.READ ;

\ -------------------------------------------
\ line manipulation
: ?NEGATIVE  DUP 0< ABORT" #LINES set negative" ; \ DEBUGGING test
: #LINES+! ( n -- )    #LINES @ + ?NEGATIVE #LINES ! ; \ can't go negative
: LASTLINE ( -- n)     #LINES @ 1- ?NEGATIVE ;
: LASTNODE ( -- addr ) LASTLINE ]NODE ;

: ?MEMORY  LASTNODE @  $POOL-SIZE > ABORT" $POOL full" ;

\ compile RAM string into VDP $pool
: VS,  ( addr len -- ) VHERE OVER 1+ VALLOT VPLACE ;

: FREE-NODE ( n -- ) TRUE SWAP ]NODE ! ; \ mark node as free

: REMOVE-NODE ( n -- ) DUP 1+ ]NODE SWAP ]NODE  LASTNODE OVER -  2 MAX  CMOVE ;

\ reserves a []node. Does not put a string in VDP.
: ALLOT-NODE ( line# --) VHERE SWAP ]NODE ! ( 2 VALLOT) ;

: OPEN-NODE ( line#--)
    ]NODE DUP CELL+   ( src dst )
    LASTNODE [ 2 CELLS ] LITERAL +  OVER -  CMOVE>
;

: INSERT-NODE ( n --) DUP OPEN-NODE ALLOT-NODE ;

\ When the edit-buffer is edited we can save it back to the same $POOL address
\ IF the length of the edit-buffer is >= the VDP string.
\ Otherwise we must get a new memory (VHERE: empty space) and update the []NODE.
 : WRITE-BACK ( line# -- ) \ writeback a line buffer to the $pool
    DUP>R ]NODE @ VLEN  EDIT-BUFFER LEN >=  \ compare node string len to buffer len
    IF
        \ re-use $pool address
        $EDIT-BUFFER  R> ]NODE @ VPLACE
    ELSE
        R> ALLOT-NODE
        $EDIT-BUFFER VS, \ compile string to VDP
    THEN
    updated OFF
;

: ?WRITE-BACK ( -- ) updated @ IF  THELINE# WRITE-BACK  THEN ;

: DELETELINE ( n -- )
    REMOVE-NODE
    LASTNODE ON
    -1 #LINES+!
\ case for deleting the last line
    LASTLINE THELINE# =
    IF  1 ROW SAFE-!
    THEN
;

HEX
0D CONSTANT ^M  \ enter
0F CONSTANT ESC

DECIMAL
: PUTCURS   XY 2@ AT-XY ;
: SOL+!     ( n -- ) SOL  @ +  0 SCRWIDTH CLIP  SOL ! ;
: CURPOS+!  ( n -- ) CURPOS @ +   0 SCRWIDTH CLIP   CURPOS ! ;

\ =======================
\ text functions
DECIMAL
: RIGHTSIDE ( addr len -- addr' len') CURPOS @ /STRING 0 MAX ;
: LEFTSIDE  ( addr len -- addr len')  DROP CURPOS @ ;

: RETYPE.BUFFER ( --)
    AT-CURSOR VPOS ERASELN
    $EDIT-BUFFER RIGHTSIDE FITTED VTYPE ;

\ =======================
\ text manipulation
: NEVER-ZERO ( addr -- ) \ limit byte to 0 or higher
    DUP C@  0 MAX  SWAP C!
;

: EOL  ( addr len -- addr' ) + 1- ; \ address of last character

: DELCHAR    ( -- )
    $EDIT-BUFFER 2DUP EOL >R   \ save last character address
    RIGHTSIDE >R   ( a   )
    DUP 1+         ( a a')
    SWAP           ( a' a)
    R>             ( a' a u)
    CMOVE
    EDIT-BUFFER -1 OVER C+! NEVER-ZERO
    BL R> C!       \ blank the last character
    UPDATE         \ mark as modified for ?write-back
;

\ Automate all this stuff
: EMIT2BUFFER ( c --)
   DUP (EMIT) 'CURSOR C!
   CURPOS @ SCRWIDTH =  \ at right edge of screen?
   IF   1 SOL+!         \ shift the start of line variable
   ELSE 1 CURPOS+!
   THEN EDIT-BUFFER LEN  CURPOS @ MAX EDIT-BUFFER C!
   UPDATE
;

: PUSHRIGHT ( -- )
    EDIT-BUFFER LEN 78 = IF 2DROP BEEP RETURN;
\  source string  destination  len
    ( *MUST USE CMOVE> here * )
    $EDIT-BUFFER RIGHTSIDE -TRAILING  'CURSOR 1+  SWAP CMOVE>
    BL 'CURSOR C!      \ add a space
    1 EDIT-BUFFER C+!  \ bump the byte count
;

: WRITE.CHAR ( c -- ) INSERT @ IF  PUSHRIGHT  THEN EMIT2BUFFER ;

: |MAX#LINES| ( n -- n')  0  #LINES @ 12 - CLIP ;
: LASTROW  ( -- n) #LINES @ L/SCR MOD ;

: TOPLINE+!  ( n -- )
   TOPLINE @ +
   DUP #LINES @ > IF  ROW OFF THEN
   |MAX#LINES|  TOPLINE !
;

: TEMP   ( -- addr) PAD 100 + ; \ buffer in unallocated dictionary

: SCROLLDN ( line# --)
  C/L@ * DUP>R ( R: Vaddr )        \ address of video screen
  SCRSIZE OVER -  TEMP SWAP VREAD  \ copy screen to temp buffer
  TEMP R@ C/L@ +  SCRSIZE OVER - VWRITE
  R> ERASELN ;                     \ erase last line

: SCROLLUP ( line# --)
  C/L@ * DUP>R  ( R: Vaddr )
  ( Vaddr) SCRSIZE OVER -  TEMP  SWAP VREAD \ screen->temp
  TEMP  R> C/L@ -   SCRSIZE OVER - VWRITE   \ temp->screen
  BOTTOMLINE ERASELN ;

DECIMAL
\ limit cursor to end of text like vi
: LIMIT-EOL   CURPOS @  EDIT-BUFFER LEN  MIN  CURPOS ! ;

: CRIGHT ( -- )
    CURPOS @ SCRWIDTH = IF  1 SOL+! RETYPE.BUFFER  RETURN;
    1 CURPOS+!
  \  LIMIT-EOL
;

: CLEFT  ( -- )
    CURPOS 1 OVER SAFE-!
    @ 0=  IF -1 SOL+!   RETYPE.BUFFER  THEN ;

: CUP  ( -- )
    THELINE# 0= IF BEEP  TOPLINE OFF ROW OFF   RETURN;
    ?WRITE-BACK
    ROW 1-!
    ROW @ 0<
    IF
        ROW OFF
        -1 TOPLINE+!
        0 SCROLLDN
    THEN
    RELOAD-BUFFER  \ LIMIT-EOL
;

: (DOWN)    \ unconditional cursor down
    ROW 1+!
    ROW @ 22 >
    IF
        22 ROW !
        1 TOPLINE+!
        0 SCROLLUP
    THEN ;

: DOWN   ?WRITE-BACK (DOWN)  RELOAD-BUFFER ;

: CDOWN ( -- )
    THELINE# LASTLINE >= IF  BEEP  RETURN;
    DOWN  \  LIMIT-EOL
;

\ page moves
: PGUP  ( -- )
    TOPLINE @ 0= IF  BEEP  RETURN;
    ?WRITE-BACK
    -23 TOPLINE+! ROW OFF
    RELOAD-BUFFER  REDRAW
;

: PGDN  ( -- )
    TOPLINE @ 23 + #LINES @ >= IF  BEEP  RETURN;
    ?WRITE-BACK
    23 TOPLINE+!  ROW OFF
    RELOAD-BUFFER  REDRAW
;

HEX
: INS/DEL
    INSERT @ -1 XOR INSERT !  \ toggle insert VARIABLE
    INSERT @ IF  1E CURS ! ELSE [CHAR] _ CURS ! THEN
;

: FCTN-3
    THELINE# DELETELINE
    RELOAD-BUFFER
    LASTLINE 1+ FREE-NODE
    ROW @ 1+ SCROLLUP
    THELINE# PARTLIST
;

: INSERT-BLANKLN
    ROW @ SCROLLDN
    ?WRITE-BACK
    THELINE# INSERT-NODE
    1 #LINES+!
    RELOAD-BUFFER
    ROW @ PARTLIST
;

\ file is saved and reloaded to reclaim VDP memory and nodes
: SAVE ( -- )
    PROMPT: ." Saving " $FILENAME 2DUP TYPE  WRITE-FILE
    PURGE
    PROMPT: ." Reloading ..." $FILENAME READ-FILE
    REDRAW
    .FSTATS ;

: HOME  ( -- ) SOL OFF CURPOS OFF ( REDRAW)  ;

: SPLITLN ( addr len -- right len left len)
   2DUP RIGHTSIDE 2SWAP LEFTSIDE
;

: VDP.PUT$ ( line# ) THELINE# ]NODE @ VPLACE UPDATE ;

: TOEOL ( -- ) EDIT-BUFFER LEN  CURPOS ! ;

: ESCAPE
    ?WRITE-BACK
    BLK/CYAN SCREEN
    PAGE ." Forth"
    CR QUIT ;

: NEWLINE
    THELINE# LASTLINE =
    IF
        ?WRITE-BACK
        (DOWN) HOME
        ROW @ SCROLLDN
        THELINE# ALLOT-NODE  REDRAW
        1 #LINES+!
    ELSE
        CURPOS @ 0=
        IF    INSERT-BLANKLN  (DOWN)
        ELSE  (DOWN) INSERT-BLANKLN
        THEN
    THEN
;

HEX
: KEYHANDLER ( char -- )
    CASE
        04 OF   INS/DEL         ENDOF
        03 OF   DELCHAR         ENDOF
        06 OF   INSERT-BLANKLN  ENDOF \ FCTN 8
        07 OF   FCTN-3          ENDOF \ FCTN 3
        08 OF   CLEFT           ENDOF
        09 OF   CRIGHT          ENDOF
        0A OF   CDOWN           ENDOF
        0B OF   CUP             ENDOF
        0C OF   PGUP            ENDOF
        02 OF   PGDN            ENDOF
        93 OF   SAVE            ENDOF
        95 OF   HOME            ENDOF
        96 OF   TOEOL           ENDOF
        ESC OF  ESCAPE          ENDOF

    \ DEFAULT CASE:
                BEEP
    ENDCASE
    RKEY? DROP  \ prevents false outputs ??
;

DECIMAL

: .DEBUG
    GETXY
    0 23 AT-XY  THELINE# . SPACE 80COL-CURSOR .
    SPACE ." Lines " #LINES @ U. ." | " ." Depth= "  DEPTH . SPACE
    ." | " ." Node " THELINE# ]NODE @ HEX .
    DECIMAL
    AT-XY ;

: NEVER-NULL ( -- ) \ TI-99 blank lines are 1 space
    EDIT-BUFFER LEN 0=
    IF  S"  " EDIT-BUFFER PLACE updated ON THEN
;
: EDITLINE ( -- )
    CURPOS OFF
    GETXY XY 2!
    RELOAD-BUFFER
    BEGIN
        RETYPE.BUFFER
        AT-CURSOR RKEY DUP ^M <>  \ exit loop on <enter> key
     WHILE
        DUP BL [CHAR] ~ BETWEEN
        IF   WRITE.CHAR
        ELSE KEYHANDLER
        THEN .DEBUG
    REPEAT
    DROP
;

DECIMAL
: GET-PATH ( -- addr len ?)
  PARSE-NAME DUP 0= ABORT" File name expected"
  2DUP FILENAME PLACE ;

: INIT-MEMORY
    PURGE
    VHERE 0 ]NODE !  \ null first record

    0 0 XY 2!
    CURPOS OFF  SOL OFF
    TOPLINE OFF  updated OFF
    EDIT-BUFFER CLEAN
;

: ?READ-FILE
    PARSE-NAME DUP 0>
    IF 2DUP FILENAME PLACE
       INIT-MEMORY
       READ-FILE
    RETURN;
    2DROP ;

: LOAD ( <path> )
    INIT-MEMORY
    DECIMAL
    GET-PATH READ-FILE  .FSTATS
;

: EDIT ( -- )
    ?READ-FILE
    GRN/BLK SCREEN
\ set up cursor speed values from DSK1.RKEY
     2 FASTKEY !
    41 SLOWKEY !
    INSERT OFF
    [CHAR] _ CURS !
    REDRAW
    BEGIN
        PUTCURS EDITLINE NEVER-NULL
        NEWLINE  \ ^M Exits editline, so we handle it here
    AGAIN
;

: SAVEAS ( <path> ) GET-PATH  WRITE-FILE ;

: NEW ( <text> )
    GET-PATH
    INIT-MEMORY
    EDIT ;

HEAP CONSTANT ENDHEAP \ remember where HEAP memory ends

\ load these because they are handy
INCLUDE DSK1.DIR
INCLUDE DSK1.CATALOG

: POCO
    WARM 80COLS
    ." Camel99 SUPERCART + Poco Editor 0.8"
    ENDHEAP H ! \ set the heap memory pointer
    ABORT ;

HERE SWAP - DECIMAL . .( BYTES USED )

LOCK

INCLUDE DSK1.SUPERSAVE
' POCO SUPERSAVE DSK1.SUPERPOCO
