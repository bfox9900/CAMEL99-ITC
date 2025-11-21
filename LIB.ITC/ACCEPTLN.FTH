\ ACCEPTLN is a fuller featured ACCEPT    Nov 18 2025 FOX
\ Features:
\ Key repeat
\ Insert and overwrite
\ jump to start of line, jump to end of line
\ delete characters to right of cursor
\ Backspace key just moves cursor left

\ NEEDS DUMP FROM DSK1.TOOLS    \ debugging
\ NEEDS MARKER FROM DSK1.MARKER
\ MARKER /EDIT

NEEDS CASE FROM DSK1.CASE          \ 104 bytes
NEEDS RKEY FROM DSK1.RKEY          \ 266 bytes
NEEDS -TRAILING FROM DSK1.TRAILING \  44 bytes

HERE
DECIMAL
VARIABLE INSERT    \ insert/over-write flag
 13 CONSTANT ^M
 80 CONSTANT MAX$LEN
128 CONSTANT BUFFSIZE

\ ========================
\ cursor characters
HEX
1E CONSTANT SQR
1F CONSTANT BOX

DECIMAL
\ 'TEXT uses PAD to save space. It could be a buffer you create.
: 'TEXT ( -- addr) PAD ;

\ ========================
\ ACCEPTLN's cursor variables
CREATE XY  0 , 0 ,      \ holds "home" position
XY CELL+ CONSTANT COL
XY       CONSTANT ROW

\ Name convention: Words ending with '$' return a stack string
: EMPTY   ( addr -- ) BUFFSIZE BL FILL ;
: BUFFER$ ( -- adr len) 'TEXT MAX$LEN -TRAILING ;
: >BUFFER ( adr len --) 'TEXT EMPTY 'TEXT SWAP CMOVE ;
: .BUFFER ( -- ) XY 2@ AT-XY  BUFFER$ -TRAILING 2+ TYPE ;

\ ========================
\ auto-limited cursor movement
  VARIABLE CP    \ cursor position
: HOME     CP OFF ;

: LIMITED  ( n -- n') 0 MAX  MAX$LEN MIN ;
: CP+!     ( n -- ) CP @ +  LIMITED CP ! ;
: 'CURSOR  ( -- adr) 'TEXT CP @ + ;
: !CHAR    ( c -- ) 'CURSOR C!  1 CP+! ;

\ set system cursor to ACCEPTLN location
: @CURSOR ( -- ) COL @ CP @ +  ROW @  AT-XY ;

\ ========================
\ toggle insert mode
HEX
: INS/DEL ( --)
    INSERT DUP @ -1 XOR INSERT !
    @ IF  SQR CURS !
    ELSE  BOX CURS !
    THEN ;

\ ========================
\ split string at cursor
DECIMAL
: RIGHTSIDE  ( adr len -- adr len') CP @ /STRING 0 MAX ;
: LEFTSIDE   ( adr len -- adr len') DROP CP @ ;

\ =======================
\ text manipulation
: SLIDE-LEFT  ( addr len -- ) OVER 1+ -ROT CMOVE ; \ CMOVE ignores len=0
: SLIDE-RIGHT ( addr len -- ) OVER 1+ SWAP LIMITED CMOVE> ;

: DELCHAR    ( --)  \ does not change length of buffer$
    BUFFER$ RIGHTSIDE 2DUP + >R  \ Save address of last char
    SLIDE-LEFT
    BL R> C!
;

: PUSHRIGHT ( --)
    BUFFER$ RIGHTSIDE DUP>R  \ save address of 1st char
    SLIDE-RIGHT
    BL R> C!  \ blank the 1st char
;

HEX
: ACCEPTLN  ( addr len -- addr' len')
    >BUFFER
    BOX CURS !
    VROW 2@  XY 2!  \ set home xy to Forth xy
    RKEY? DROP      \ clear last key press
    INSERT OFF  HOME
    BEGIN
        .BUFFER
        @CURSOR RKEY DUP ^M <>
    WHILE
        DUP BL [CHAR] ~ 1+ WITHIN
        IF
            INSERT @ IF PUSHRIGHT THEN !CHAR
        ELSE
            CASE
            01 OF   8 CP+!  ( TAB )           ENDOF
            B7 OF  -8 CP+!  ( ctrl TAB )      ENDOF
            08 OF  -1 CP+!  ( right arrow )   ENDOF
            09 OF   1 CP+!  ( left arrow )    ENDOF
            03 OF  DELCHAR                    ENDOF
            04 OF  INS/DEL                    ENDOF
            95 OF  HOME                       ENDOF
            96 OF  BUFFER$ -TRAILING NIP CP ! ENDOF ( end)
                   BEEP
            ENDCASE
        THEN
    REPEAT
    DROP
    BUFFER$ -TRAILING
;

HERE SWAP - DECIMAL CR .  .( bytes)

\ testing
: .OUTPUT ( addr len -- )  CR ." Output:"   CR TYPE ;

CREATE T$ S" This string is used for testing      " S,

: TEST    PAGE  T$ COUNT ACCEPTLN   CR .OUTPUT ;
: TESTXY  PAGE  4 4 AT-XY T$ COUNT ACCEPTLN  CR .OUTPUT ;

CREATE LONG$
S" Candace Owens walked into the conversation confident, dismissing climate" S,

: TESTLONG  PAGE LONG$ COUNT ACCEPTLN  CR .OUTPUT ;
