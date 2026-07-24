\ pocovdp.fth  text editor using VDP RAM file storage Oct 14 2025

\ library includes
 NEEDS DUMP      FROM DSK1.TOOLS

NEEDS CASE      FROM DSK1.CASE
NEEDS MARKER    FROM DSK1.MARKER
NEEDS RKEY      FROM DSK1.RKEY
NEEDS -TRAILING FROM DSK1.TRAILING
NEEDS MARKER    FROM DSK1.MARKER
\ load these because they are handy
INCLUDE DSK1.DIR
INCLUDE DSK1.CATALOG

NEEDS 80COLS FROM DSK1.80COL
 80COLS

HERE
\ Editor specific includes
NEEDS READ-FILE FROM DSK2.FILE2VDPB

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
C0 CONSTANT GRN/BLK
A0 CONSTANT YEL/BLK

CREATE MYCOLOR GRN/BLK ,

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

\  VALUE EDIT-BUFFER \ allocated at start up
: EDIT-BUFFER ( -- addr) HEAP ; ( use un-allocated memory)

: $EDIT-BUFFER ( -- addr len)  EDIT-BUFFER COUNT ;  \ access as a stack string

: 'TEXT  ( -- addr) EDIT-BUFFER 1+ ; \ skip the byte count

CREATE XY  0 , 0 ,   \ holds screen position for editline as 2var
\ editor intenal coordinates
XY       CONSTANT ROW
XY CELL+ CONSTANT COL

\ the LINE we are editing is the screen ROW + TOPLINE
\ Added min to limit the valid line nodes
: THELINE#  ( -- n ) ROW @ TOPLINE @ + ;

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

\ fast type to VDP screen memory
: VTYPE  ( adr len  ) DUP>R VPOS SWAP VWRITE R> VCOL +! ;
: FITTED ( addr len -- addr' len') SOL @ /STRING 0 MAX SCRWIDTH MIN ;

DECIMAL
\ : VDP.TYPE BOUNDS ?DO I VC@ VPUT VCOL 1+! LOOP ;  \ slow version

\ * It is 3X faster to VREAD VDP string into RAM then VWRITE it to screen
CREATE TBUFF 82 ALLOT
: VDP.TYPE ( Vaddr len -- ) TUCK TBUFF SWAP VREAD  TBUFF SWAP VTYPE ;

: ]TYPELN ( line# -- ) ( TRUE means node is empty )
    DUP ]NODE @ TRUE = IF  DROP  [CHAR] ~ EMIT  RETURN;
    ]POOL$ FITTED VDP.TYPE
;

: (LIST)  ( start end -- ) SWAP DO  I ]TYPELN CR  LOOP ;
: LIST ( start --) DUP 23 +  (LIST) ; \ full page

: REMAINING ( line# -- n) 23 + ROW @ - 0 MAX ;
: PARTLIST ( startline ) DUP REMAINING (LIST) ;

: REDRAW  ( -- ) PAGE  TOPLINE @ LIST ;
: AT-CURSOR ( -- ) CURPOS @ ROW @ AT-XY ;
: AT-LINE   ( -- ) 0 ROW @ AT-XY ;

: ?SIZE     DUP BUFFSIZE 1+ >  ABORT" VDP$ > BUFFSIZE" ;

\ compile RAM string into VDP $pool
: VS,  ( addr len -- ) VHERE OVER 1+ VALLOT VPLACE ;

: VDP$.GET   ( Vaddr len addr ) 2DUP C! 1+   SWAP ?SIZE VREAD ;
: ]VDP$.PUT   ( $addr len line# ) ]NODE @ VPLACE ;

: CLEAN       ( caddr -- ) DUP 1+ BUFFSIZE BL FILL  0 SWAP C! ;

: RELOAD-BUFFER
    EDIT-BUFFER CLEAN
    THELINE# ]POOL$  EDIT-BUFFER VDP$.GET ;

\ -------------------------------------------
\ line manipulation
: ?NEG
  GETXY
  DUP 0< IF BEEP PROMPT: ." #LINES < 0" 1000 MS THEN
  AT-XY ;

: #LINES+! ( n -- )    #LINES @ +  0 MAX #LINES ! ; \ can't go to 0
: LASTLINE ( -- n)     #LINES @ 1-  ?NEG ;
: LASTNODE ( -- addr ) LASTLINE ]NODE ;

\ : ?MEMORY  LASTNODE @  $POOL-SIZE > ABORT" $POOL full" ;
\ : FREE-NODE ( n -- ) TRUE SWAP ]NODE ! ; \ mark node as free

: ]REMOVE-NODE ( n -- )
    DUP 1+ ]NODE SWAP ]NODE  LASTNODE OVER -  2 MAX  CMOVE ;

: ]ALLOT-NODE ( line# --) VHERE SWAP ]NODE !  ;

\ It's pretty fast to slide the node memory with CMOVE> to make space
: ]OPEN-NODE ( line#--)
    ]NODE DUP CELL+   ( src dst )
    LASTNODE [ 2 CELLS ] LITERAL +  OVER -  CMOVE>
;

: INSERT-NODE ( n --) DUP ]OPEN-NODE ]ALLOT-NODE ;

: ]NEW$      ( addr len line#--) ]ALLOT-NODE  VS,   ;
: ]INSERT$   ( addr len line#--) INSERT-NODE VS,  1 #LINES+! ;

\ When the edit-buffer is edited we can save it back to the same $POOL address
\ IF the length of the edit-buffer is >= the VDP string.
\ Otherwise we must get a new memory (VHERE: empty space) and update the []NODE.
 : WRITE-BACK ( line# -- ) \ writeback a line buffer to the $pool
    DUP>R ]NODE @ VLEN  EDIT-BUFFER LEN >=  \ compare node len to buffer len
    IF
        $EDIT-BUFFER R> ]VDP$.PUT    \ re-use $pool address
    ELSE
        $EDIT-BUFFER R> ]NEW$        \ add a new string
        1 #LINES+!
    THEN
    updated OFF
;

: ?WRITE-BACK ( -- ) updated @ IF  THELINE# WRITE-BACK  THEN ;

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
    $EDIT-BUFFER
    updated @ 0=
    IF   AT-CURSOR VPOS ERASELN  RIGHTSIDE
    ELSE AT-LINE   VPOS ERASELN
    THEN FITTED VTYPE ;

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
   THEN EDIT-BUFFER LEN  CURPOS @ MAX  EDIT-BUFFER C!
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

: |MAX#LINES| ( n -- n')  0  LASTLINE 12 - CLIP ;
: LASTROW  ( -- n)  LASTLINE L/SCR MOD ;

: TOPLINE+!  ( n -- )
   TOPLINE @ +
   DUP LASTLINE > IF  ROW OFF THEN
   |MAX#LINES|  TOPLINE !
;

: TEMP   ( -- addr) PAD 128 + ; \ buffer in unallocated dictionary

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

: (UP) \ unconditional cursor down
    ROW 1-!
    ROW @ 0<
    IF
        ROW OFF
        -1 TOPLINE+!
        0 SCROLLDN
    THEN
;

: (DOWN) \ unconditional cursor down
    ROW 1+!
    ROW @ 22 >
    IF
        22 ROW !
        1 TOPLINE+!
        0 SCROLLUP
    THEN ;

\ *ALL* cursor movements to a new line must write-back the current line
\ move the cursor and then reload the buffer with the new line
: CUP  ( -- )
    ?WRITE-BACK
    THELINE# 0=
    IF BEEP
    ELSE (UP)
    THEN RELOAD-BUFFER
;

: CDOWN ( -- )
    ?WRITE-BACK
    THELINE# LASTLINE >=
    IF   BEEP
    ELSE (DOWN)
    THEN RELOAD-BUFFER
;

\ page moves
: PGUP  ( -- )
    TOPLINE @ 0= IF  BEEP  RETURN;
    ?WRITE-BACK
    -23 TOPLINE+! ROW OFF
    RELOAD-BUFFER  REDRAW
;

: PGDN  ( -- )
    TOPLINE @ 23 + LASTLINE >= IF  BEEP  RETURN;
    ?WRITE-BACK
    23 TOPLINE+!  ROW OFF
    RELOAD-BUFFER  REDRAW
;

HEX
: INS/DEL
    INSERT @ -1 XOR INSERT !  \ toggle insert VARIABLE
    INSERT @ IF  1E CURS ! ELSE [CHAR] _ CURS ! THEN
;

: DELETELINE ( n -- )
    ]REMOVE-NODE
\ This bit me. We must reset the lastnode and the next one
    LASTNODE [ 2 CELLS ] LITERAL  FF FILL
    -1 #LINES+!
;

: FCTN-3
    THELINE# LASTLINE = IF  BEEP  RETURN;

    THELINE# DELETELINE
    RELOAD-BUFFER
    ROW @ 1+ SCROLLUP
    THELINE# PARTLIST
;


: EMPTY$ S"  " ; \ dv80 file empty line, is 1 space

: INSERT-BLANKLN
    ROW @ SCROLLDN
    ?WRITE-BACK
    EMPTY$ THELINE# ]INSERT$
    RELOAD-BUFFER
    REDRAW
;

\ file is saved and reloaded to reclaim VDP memory and nodes
: SAVE ( -- )
    PROMPT: ." Saving " $FILENAME 2DUP TYPE  WRITE-FILE
    PURGE
    PROMPT: ." Reloading ..." $FILENAME READ-FILE
    REDRAW
;

: HOME  ( -- ) SOL OFF CURPOS OFF ( REDRAW) ;

: SPLITLN ( addr len -- right len left len)
   2DUP RIGHTSIDE 2SWAP LEFTSIDE
;

: TOEOL ( -- ) EDIT-BUFFER LEN  CURPOS ! ;

: ESCAPE
    ?WRITE-BACK
    BLK/CYAN SCREEN
    PAGE ." Forth"
    CR QUIT ;

: NEVER-NULL ( -- ) \ TI-99 blank lines are 1 space
    EDIT-BUFFER DUP LEN 0= IF  EMPTY$ ROT PLACE   updated ON  RETURN;
    DROP
;

: NEWLINE
    THELINE# LASTLINE =
    IF
        $EDIT-BUFFER NEVER-NULL THELINE# ]NEW$
        (DOWN) INSERT-BLANKLN
    ELSE
        THELINE# WRITE-BACK  ( force a write-back )
        CURPOS @ 0=
        IF
            INSERT-BLANKLN  (DOWN)
        ELSE
            (DOWN) INSERT-BLANKLN
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
        THEN \ .DEBUG
    REPEAT
    DROP
;

DECIMAL
: GET-PATH ( -- addr len ?)
  PARSE-NAME DUP 0= ABORT" File name expected"
  2DUP FILENAME PLACE ;

HEX
: INIT-MEMORY
 \   2000 H !
 \   MAXLINES ALLOCATE-NODES
 \   BUFFSIZE MALLOC TO EDIT-BUFFER

    0 0 XY 2!
    CURPOS OFF  SOL OFF
    TOPLINE OFF  updated OFF
    EDIT-BUFFER CLEAN
    PURGE
    EMPTY$ THELINE# ]NEW$
    1 #LINES+!
;
DECIMAL

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
    GET-PATH READ-FILE
    CR .FSTATS
;

: EDIT ( -- )
    ?READ-FILE
    MYCOLOR @ SCREEN
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

 HEAP BUFFSIZE + CONSTANT ENDHEAP \ remember where HEAP memory ends

HEX
: POCO
    WARM 80COLS
    ." Camel99 SUPERCART + Poco Editor 0.9"
    ENDHEAP H ! \ set the heap memory pointer
    ABORT ;

HERE SWAP - DECIMAL . .( BYTES USED )

 LOCK
HEX 2000 H ! \ reset heap so it won't save as a file
 INCLUDE DSK1.SUPERSAVE
 ' POCO SUPERSAVE DSK1.POCO-SC

CR .( Exiting to title page in 3 secs,)
3000 MS

\ BYE
