\ editline.fth  experimental editor for a buffer


: PUSHRIGHT ( -- )
    EDIT-BUFFER LEN 78 = IF 2DROP BEEP RETURN;
\  source string  destination  len
    ( *MUST USE CMOVE> here * )
    $EDIT-BUFFER RIGHTSIDE -TRAILING  'CURSOR 1+  SWAP CMOVE>
    BL 'CURSOR C!      \ add a space
    1 EDIT-BUFFER C+!  \ bump the byte count
;

: WRITE.CHAR ( c -- ) INSERT @ IF  PUSHRIGHT  THEN EMIT2BUFFER ;

DECIMAL
\ limit cursor to end of text like vi
: LIMIT-EOL   CURPOS @  EDIT-BUFFER LEN  MIN  CURPOS ! ;

: CRIGHT ( -- )
    CURPOS @ SCRWIDTH = IF  1 SOL+! RETYPE.BUFFER  RETURN;
    1 CURPOS+!
;

: CLEFT  ( -- )
    CURPOS 1 OVER SAFE-!
    @ 0=  IF -1 SOL+!   RETYPE.BUFFER  THEN ;

HEX
: INS/DEL
    INSERT @ -1 XOR INSERT !  \ toggle insert VARIABLE
    INSERT @ IF  1E CURS ! ELSE [CHAR] _ CURS ! THEN
;

: EMPTY$  S"  " ; \ dv80 file empty line, is 1 space

: HOME  ( -- ) SOL OFF CURPOS OFF ( REDRAW) ;

: SPLITLN ( addr len -- right len left len)
   2DUP RIGHTSIDE 2SWAP LEFTSIDE
;

: TOEOL ( -- ) EDIT-BUFFER LEN  CURPOS ! ;

: ESCAPE
    ?WRITE-BACK
    BLK/CYAN SCREEN
    TEXT ." Forth"
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


: EDITLINE ( addr n -- addr n')
    CURPOS OFF
    GETXY XY 2!
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
