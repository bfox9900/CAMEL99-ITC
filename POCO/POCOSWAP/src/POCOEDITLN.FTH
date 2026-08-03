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

\ *ALL* cursor movements to a new line must write-back the edit-buffer
\ to the current line if the 'updated' flag is set.
: (UP) \ unconditional cursor down
    ?WRITE-BACK
    ROW 1-!
    ROW @ 0<
    IF
        0 SCROLLDN
        ROW OFF
        -1 TOPLINE+!
    THEN
;

: CUP  ( -- )
    THELINE# 0=  IF BEEP  RETURN;
    (UP)  RELOAD-BUFFER  LIMIT-EOL
;

: (DOWN) \ unconditional cursor down
    ?WRITE-BACK
    THELINE# LASTLINE >= IF BEEP  RETURN;
    ROW 1+!
    ROW @ 22 >
    IF
        22 ROW !
        1 TOPLINE+!
        0 SCROLLUP
    THEN ;

: CDOWN ( -- ) (DOWN)  RELOAD-BUFFER LIMIT-EOL ;

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
    ]REMOVE-NODE           \ slide node array up one
    #LINES @ ERASE-NODE    \ make the old last node free for use
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

    ?WRITE-BACK
    $EDIT-BUFFER 2DUP 'LASTCHAR >R  \ save last character address
    RIGHTSIDE >R   ( a   ) ( R: U)
    DUP 1+         ( a a')
    SWAP           ( a' a)
    R> ( a' a u) CMOVE    \ slide text left
    BL R> C!              \ blank the last character
    -1 EDIT-BUFFER LEN+!  \ dec. count byte in buffer
    updated ON            \ mark as modified for ?write-back
;

: DELETE-KEY
    EDIT-BUFFER LEN 0=
    IF   50 MS  FCTN-3
    ELSE DELCHAR
    THEN
;

: EMPTY$ S"  " ; \ dv80 file empty line, is 1 space

: INSERTLN ( $addr len -- )
    ROW @ SCROLLDN
    ?WRITE-BACK
    THELINE# ]INSERT$
    1 #LINES+!
;

: INSERT-BLANKLN    EMPTY$ INSERTLN  RELOAD-BUFFER ;

\ file is saved and reloaded to reclaim VDP memory and nodes
: SAVE ( -- )
    THELINE# WRITE-BACK  \ force save editbuffer
    FLUSH
    PROMPT: ." Saving " $FILENAME 2DUP TYPE  WRITE-FILE
\   PURGE
    PROMPT: ." Reloading ..." $FILENAME READ-FILE
    PROMPT: .FSTATS 250 MS
    REDRAW
;

: HOME  ( -- ) SOL OFF CURPOS OFF ( REDRAW) ;

: GOTO-EOL ( -- ) EDIT-BUFFER LEN  CURPOS ! ;

: ESCAPE
    ?WRITE-BACK FLUSH

    BLK/CYAN SCREEN
    PAGE
    $FILENAME TYPE
    .FSTATS
    CR
    CR ." Forth"

    CR QUIT ;


: NEVER-NULL ( $addr len -- ) \ TI-99 blank lines are 1 space
    DUP 0= IF 2DROP  EMPTY$   updated ON  THEN
;

: SPLITLN ( addr n )
    PAD PLACE
    PAD COUNT LEFTSIDE  THELINE# ]$OVERWRITE
    RELOAD-BUFFER   RETYPE.BUFFER
    (DOWN)
    PAD COUNT RIGHTSIDE INSERTLN
    HOME
    RELOAD-BUFFER
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

DEFER SEARCH1ST
DEFER SEARCHNEXT

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

        86 OF   SEARCH1ST       ENDOF \ ^F
        8E OF   SEARCHNEXT      ENDOF \ ^down arrow

        83 OF   COPY            ENDOF \ ^C
        96 OF   PASTE           ENDOF \ ^V
        98 OF   CUT             ENDOF \ ^X

        93 OF   SAVE            ENDOF
        95 OF   HOME            ENDOF
        84 OF   GOTO-EOL        ENDOF \ ^D or ^right arrow

        BB OF   $EDIT-BUFFER SPLITLN ENDOF  \ ^/

        ESC OF  ESCAPE          ENDOF

    \ DEFAULT CASE:
                BEEP
    ENDCASE
    RKEY? DROP  \ prevents false outputs ??
;

DECIMAL
VARIABLE DEBUG     \ Enable with DEBUG ON

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

: .STATUS
GETXY PROMPT: ." Line# " THELINE# . SPACE ." Lines= " #LINES ?
AT-XY ;

\ ' .BUFFER IS DEBUGGER
' .STATUS IS DEBUGGER

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
       EDITLINE
       $EDIT-BUFFER NEVER-NULL EDIT-BUFFER PLACE
       NEWLINE  \ handle ^m from EDITLINE
    AGAIN
;
