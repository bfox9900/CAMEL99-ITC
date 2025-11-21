\ ACCEPTLN is a fuller featured ACCEPT    Nov 18 2025 FOX
\ Features:
\ Insert and overwrite
\ jump to start of line, jump to end of line
\ delete characters to right of cursor
\ Backspace key just moves cursor left

\ NEEDS DUMP FROM DSK1.TOOLS    \ debugging
\ NEEDS MARKER FROM DSK1.MARKER
\ MARKER /EDIT

NEEDS RKEY FROM DSK1.RKEY          \ 266 bytes
NEEDS CASE FROM DSK1.CASE          \ 104 bytes
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

\ Name convention: Words ending with '$' return a stack string
: EMPTY   ( addr -- ) BUFFSIZE BL FILL ;
: BUFFER$ ( -- adr len) 'TEXT MAX$LEN -TRAILING ;

\ ========================
\ cursor control variables
CREATE XY  0 , 0 ,             \ holds screen position for editline
XY CELL+ CONSTANT COL          \ editline's coLumn variable
XY       CONSTANT ROW          \ ediltine's row    variable

\ ========================
\ auto-limited cursor movement
  VARIABLE CP    \ cursor position

: LIMITED  ( n -- n') 0 MAX  MAX$LEN MIN ;
: CP+!     ( n -- ) CP @ +  LIMITED CP ! ;
: 'CURSOR  ( -- adr) 'TEXT CP @ + ;
: !CHAR    ( c -- ) 'CURSOR C!  1 CP+! ;

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
    BUFFER$ RIGHTSIDE DUP 0= IF  2DROP  EXIT THEN
    2DUP + >R    \ Save address of last char
    SLIDE-LEFT
    BL R> C!
;

: PUSHRIGHT ( --)
    BUFFER$ RIGHTSIDE DUP>R SLIDE-RIGHT
    BL R> C!  \ blank the 1st char
;

: @SOL    ( -- ) XY 2@ AT-XY ;  \ AT "start of line"
: @CURSOR ( -- ) COL @ CP @ +  ROW @  AT-XY ;

: >BUFFER ( adr len --) 'TEXT EMPTY 'TEXT SWAP CMOVE ;

HEX
: ACCEPTLN  ( addr len -- addr' len')
    >BUFFER
    BOX CURS !
    VROW 2@  XY 2!  \ set edit xy to Forth xy
    RKEY? DROP      \ clear pending key
    INSERT OFF  CP OFF
    BEGIN
        @SOL BUFFER$ -TRAILING 2+ TYPE
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
            95 OF  CP OFF   ( Home )          ENDOF
            96 OF  BUFFER$ -TRAILING NIP CP ! ENDOF ( end)
                   BEEP
            ENDCASE
        THEN
    REPEAT
    DROP
    BUFFER$
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
