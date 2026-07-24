\ POCOEDITLN.FTH   23FEB26   Brian Fox

MARKER /EDITLN

DECIMAL
\ limit cursor to end of text like vi
: LIMIT-EOL   CURPOS @  EDIT-BUFFER LEN  MIN  CURPOS ! ;

: CRIGHT ( -- )
    CURPOS @ SCRWIDTH = IF  1 SOL+! RETYPE.BUFFER  RETURN;
    CURPOS @ EDIT-BUFFER LEN >= IF LIMIT-EOL RETURN;
    1 CURPOS+!
;

: CLEFT  ( -- )
    CURPOS 1 OVER SAFE-!
    @ 0=  IF -1 SOL+!   RETYPE.BUFFER  THEN ;

: (UP) \ unconditional cursor down
    ROW 1-!
    ROW @ 0<
    IF
        0 SCROLLDN
        ROW OFF
        -1 TOPLINE+!
    THEN
;

\ *ALL* cursor movements to a new line must write-back the current line
\ move the cursor and then reload the buffer with the new line
: CUP  ( -- )
    THELINE# 0=  IF BEEP  RETURN;

    ?WRITE-BACK  (UP)  RELOAD-BUFFER  LIMIT-EOL
;

: (DOWN) \ unconditional cursor down
    THELINE# LASTLINE >= IF BEEP  RETURN;
    ROW 1+!
    ROW @ 22 >
    IF
        22 ROW !
        1 TOPLINE+!
        0 SCROLLUP
    THEN ;

: CDOWN ( -- )
    ?WRITE-BACK
\    THELINE# LASTLINE >= IF BEEP  RETURN;
    (DOWN)  RELOAD-BUFFER LIMIT-EOL
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
    THELINE# LASTLINE >= IF  BEEP  RETURN;

    THELINE# DELETELINE
    RELOAD-BUFFER
    ROW @ 1+ SCROLLUP
    THELINE# PARTLIST
;

: 'LASTCHAR  ( addr len -- addr' ) + 1- ; \ address of last character

: DELCHAR    ( -- )
    CURPOS @ EDIT-BUFFER LEN = IF  RETURN;
    $EDIT-BUFFER 2DUP 'LASTCHAR >R  \ save last character address
    RIGHTSIDE >R   ( a   ) ( R: U)
    DUP 1+         ( a a')
    SWAP           ( a' a)
    R> ( a' a u) CMOVE    \ slide text left
    BL R> C!              \ blank the last character
    -1 EDIT-BUFFER LEN+!  \ dec. count byte in buffer
    UPDATE                \ mark as modified for ?write-back
;

: DELETE-KEY
    EDIT-BUFFER LEN 0=
    IF   50 MS  FCTN-3
    ELSE DELCHAR
    THEN
;

: EMPTY$ S"  " ; \ dv80 file empty line, is 1 space

: INSERTLN ( $addr -- )
    ROW @ SCROLLDN
    ?WRITE-BACK
    THELINE# ]INSERT$
;

: INSERT-BLANKLN    EMPTY$ INSERTLN  RELOAD-BUFFER ;

\ file is saved and reloaded to reclaim VDP memory and nodes
: SAVE ( -- )
    THELINE# WRITE-BACK  \ force save editbuffer
    PROMPT: ." Saving " $FILENAME 2DUP TYPE  WRITE-FILE
    PURGE
    PROMPT: ." Reloading ..." $FILENAME READ-FILE
    REDRAW
;

: HOME  ( -- ) SOL OFF CURPOS OFF ( REDRAW) ;

: SPLITLN ( addr len -- right len left len)
   2DUP RIGHTSIDE 2SWAP LEFTSIDE
;

: GOTO-EOL ( -- ) EDIT-BUFFER LEN  CURPOS ! ;

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
    ?WRITE-BACK
    THELINE# LASTLINE =
    IF
        $EDIT-BUFFER NEVER-NULL THELINE# ]NEW$
        (DOWN) INSERT-BLANKLN
    ELSE
        CURPOS @ 0=
        IF
            INSERT-BLANKLN  (DOWN)
        ELSE
            (DOWN) INSERT-BLANKLN
            HOME
        THEN
    THEN
    RELOAD-BUFFER   REDRAW
;

: COPY    $EDIT-BUFFER $PUSH CDOWN ;

: CUT
  'STAK @ #STAKLINES = IF  BEEP  RETURN;
   $EDIT-BUFFER $PUSH FCTN-3
;

: PASTE  ( -- ) \ pastes the entire line stack
    'STAK @ 0= IF  BEEP  RETURN;
    BEGIN
       'STAK @
    WHILE
       $POP INSERTLN RELOAD-BUFFER
        RETYPE.BUFFER
    REPEAT
    REDRAW
;

DECIMAL
4 CONSTANT TAB#

: TAB ( -- )  TAB# 0 DO  PUSHRIGHT  BL EMIT2BUFFER  LOOP ;

: -TAB ( -- ) TAB# 0 DO  CLEFT  LOOP ;

HEX
: KEYHANDLER ( char -- )
    CASE
        01 OF   TAB             ENDOF
        B7 OF   -TAB            ENDOF \ ^TAB

        04 OF   INS/DEL         ENDOF
        03 OF   DELETE-KEY      ENDOF
        06 OF   INSERT-BLANKLN  ENDOF \ FCTN 8
        07 OF   FCTN-3          ENDOF \ FCTN 3
        08 OF   CLEFT           ENDOF
        09 OF   CRIGHT          ENDOF
        0A OF   CDOWN           ENDOF
        0B OF   CUP             ENDOF
        0C OF   PGUP            ENDOF
        02 OF   PGDN            ENDOF

        83 OF   COPY            ENDOF \ ^C
        96 OF   PASTE           ENDOF \ ^V
        98 OF   CUT             ENDOF \ ^X

        93 OF   SAVE            ENDOF
        95 OF   HOME            ENDOF
        84 OF   GOTO-EOL        ENDOF \ ^D or ^right arrow
        ESC OF  ESCAPE          ENDOF

    \ DEFAULT CASE:
                BEEP
    ENDCASE
    RKEY? DROP  \ prevents false outputs ??
;

DECIMAL
VARIABLE DEBUG \ Enable with DEBUG ON

DEFER DEBUGGER

: .DEBUG     DEBUG @ IF  DEBUGGER    THEN  ;

\ : .DEBUGSTUFF
\        GETXY
\        PROMPT:
\         THELINE# . SPACE 80COL-CURSOR .
\       SPACE ." Lines " #LINES @ U. ." | " ." Depth= "  DEPTH . SPACE
\         ." | " ." Node " THELINE# ]NODE @ HEX .
\         SPACE EDIT-BUFFER LEN .
\        DECIMAL
\        AT-XY
\ ;

: .BUFFER   GETXY PROMPT: $EDIT-BUFFER TYPE  AT-XY ;

' .BUFFER IS DEBUGGER

: EDITLINE ( -- )
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

: (EDIT)
    REDRAW
    BEGIN
       EDITLINE NEVER-NULL
       NEWLINE  \ handle ^m from EDITLINE
    AGAIN
;
