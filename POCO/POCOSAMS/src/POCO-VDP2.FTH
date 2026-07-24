

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
            HOME
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
    GETXY ROW/COL 2!
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

    0 0 ROW/COL 2!
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

\ CR .( Exiting to title page in 3 secs,)
\ 3000 MS

\ BYE
