\ ACCEPTLN is a fuller featured ACCEPT    Nov 18 2025 FOX
\ Modified Jan 13 2026: Edits buffer in place using pointer
\ Jan 15 added 1 level UNDO
\ Features:
\ Key repeat
\ Insert and overwrite
\ jump to start of line, jump to end of line
\ +TAB -TAB
\ delete characters to right of cursor
\ Backspace key just moves cursor left

 NEEDS DUMP FROM DSK1.TOOLS    \ debugging
 NEEDS MARKER FROM DSK1.MARKER
NEEDS CASE FROM DSK1.CASE          \ 104 bytes

MARKER /EDIT
NEEDS RKEY FROM DSK1.RKEY          \ 266 bytes
NEEDS -TRAILING FROM DSK1.TRAILING \  44 bytes

HERE
DECIMAL
VARIABLE INSERT    \ insert/over-write flag
 13 CONSTANT ^M

\ ========================
\ cursor characters
HEX
1E CONSTANT SQR \ insert editing
1F CONSTANT BOX \ over-type editing

DECIMAL
CREATE ^BUFFER 0 , 0 ,      \ pointer to buffer string
^BUFFER CONSTANT $LEN       \ address of length
$LEN CELL+ CONSTANT 'TEXT   \ address of text

\ ========================
\ ACCEPTLN's cursor variables
CREATE XY  0 , 0 ,      \ holds "home" position
XY       CONSTANT ROW
XY CELL+ CONSTANT COL

\ Name convention: Words ending with '$' return a stack string
: BUFFER$ ( -- adr len) ^BUFFER 2@ ;
\ : .BUFFER ( -- ) XY 2@ AT-XY  BUFFER$ TYPE ;

\ UNDO words
: VPAD  ( -- Vaddr) VP @ ; \ start of free VDP RAM
: COPY-TEXT ( -- ) BUFFER$ VPAD SWAP VWRITE ;
: UNDO  ( -- ) VPAD BUFFER$ VREAD ;


\ ========================
\ auto-limited cursor movement
  VARIABLE CP    \ cursor position
: HOME     CP OFF ;

: LIMITED  ( n -- n') 0 MAX  $LEN @ MIN ;
: CP+!     ( n -- ) CP @ +  LIMITED CP ! ;
: 'CURSOR  ( -- adr) 'TEXT @ CP @ + ;
: !CHAR    ( c -- ) 'CURSOR C!  1 CP+! ;

\ set system cursor to ACCEPTLN cursor location
: @CURSOR ( -- ) COL @ CP @ +  ROW @  AT-XY ;

\ ========================
\ toggle insert mode
HEX
: INS/DEL ( --)
    COPY-TEXT
    INSERT DUP @ -1 XOR INSERT !
    @ IF  SQR CURS !
    ELSE  BOX CURS !
    THEN ;

\ ========================
\ split string at cursor
DECIMAL
: RIGHTSIDE  ( adr len -- adr len') CP @ /STRING 0 MAX ;
: LEFTSIDE   ( adr len -- adr len') DROP CP @ ;

\ print buffer at cursor. 2+ puts extra spaces at end
: RELINE  ( -- ) BUFFER$ RIGHTSIDE TYPE ;

\ =======================
\ text manipulation
: SLIDE-LEFT  ( addr len -- ) OVER 1+ -ROT CMOVE ; \ CMOVE ignores len=0
: SLIDE-RIGHT ( addr len -- ) OVER 1+ SWAP LIMITED CMOVE> ;

: DELCHAR    ( --)  \ does not change length of buffer$
    COPY-TEXT
    BUFFER$ RIGHTSIDE 2DUP + >R  \ Save address of last char
    SLIDE-LEFT
    BL R> C!
;

: PUSHRIGHT ( --)
    BUFFER$ RIGHTSIDE DUP>R  \ save address of 1st char
    SLIDE-RIGHT
    BL R> C!  \ blank the 1st char
;

: GETXY ( -- col row) VROW 2@ ; \ get Forth's screen x,y

\ Uses TI-99 key codes
HEX
: ACCEPTLN  ( addr len -- addr' len')
   ^BUFFER 2!
    GETXY XY 2!     \ set editor xy to current screen xy
    RKEY? DROP      \ clear last key press
    INSERT OFF  BOX CURS !
    HOME
    BEGIN
        @CURSOR RELINE    \ display the buffer text
        @CURSOR RKEY DUP ^M <>
    WHILE
        DUP BL [CHAR] ~ 1+ WITHIN
        IF  COPY-TEXT
            INSERT @ IF PUSHRIGHT THEN DUP !CHAR EMIT
        ELSE
            CASE
            01 OF   8 CP+!     ENDOF ( TAB )
            B7 OF  -8 CP+!     ENDOF ( ctrl TAB )
            08 OF  -1 CP+!     ENDOF ( right arrow )
            09 OF   1 CP+!     ENDOF ( left arrow )
            06 OF  UNDO        ENDOF ( FCTN 8 REDO )
            03 OF  DELCHAR     ENDOF
            04 OF  INS/DEL     ENDOF
            95 OF  HOME        ENDOF
            96 OF  BUFFER$ -TRAILING NIP CP ! ENDOF ( end)
                   BEEP
            ENDCASE
        THEN
    REPEAT
    DROP
    [CHAR] _ CURS !
    BUFFER$
;

HERE SWAP - DECIMAL CR .  .( bytes)

\ testing
\ CREATE T$ S" This string is used for testing        " S,

\ : .OUTPUT ( addr len -- )  CR ." Output:"   CR TYPE ;

\ editing string "in situ" dictionary (dangerous)
\ : TEST    PAGE  T$ COUNT ACCEPTLN   CR .OUTPUT ;

\ create text buffer
\ CREATE EBUFF 128 ALLOT
\ S" Candace Owens walked into the conversation confident, dismissing climate"
\ EBUFF PLACE

\ : TESTLONG    PAGE EBUFF COUNT DROP 120 ACCEPTLN  CR ;
