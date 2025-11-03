\ VDP BLOCK EDITOR   Nov 2025 Brian Fox

NEEDS DUMP  FROM DSK1.TOOLS
NEEDS BLOCK FROM DSK1.BLOCKS
NEEDS .R    FROM DSK1.UDOTR
NEEDS -TRAILING FROM DSK1.TRAILING
NEEDS 80COLS FROM DSK1.80COL

80COLS
\ VDP Screen editor edits a line of VDP memory
\ outputs stack string  Aug 31 2025 B Fox
NEEDS CASE      FROM DSK1.CASE
NEEDS RKEY      FROM DSK1.RKEY

DECIMAL
HERE
13 CONSTANT ^M     \ enter key
VARIABLE INSERT    \ insert/over-write flag

: BLANK    BL FILL ;
: BLKCURS  30 CURS ! ;
: BOXCURS  31 CURS ! ;

\ auto-limited cursor movement controls
\ : CUP       VROW @ 1-  0 MAX VROW ! ;
\ : CDOWN     VROW @ 1+  L/SCR 1- MIN  VROW ! ;
: CRIGHT    VCOL @ 1+  64 MIN VCOL ! ;
: CLEFT     VCOL @ 1-  0 MAX  VCOL ! ;

: INS/DEL \ toggle insert mode
    INSERT DUP @ -1 XOR OVER !
    @ IF BOXCURS  ELSE BLKCURS THEN ;

\ ========================
\ Screen text functions
: VLINE      ( -- VDPaddr) VROW @ C/L@ * ;
: EOL        ( -- VDPaddr)  VLINE C/L@ 1- + ;
: RIGHTSIDE  ( -- VDPaddr len) VLINE C/L@  VCOL @ /STRING ;
\ : LEFTSIDE   ( -- VDPaddr len) VLINE VCOL @ ;
: VCOPY      ( vaddr len addr -- ) SWAP VREAD ;
: READVDP    ( addr -- ) VLINE 64 ROT VCOPY ;

\ =======================
\ text manipulation
: DELCHAR    ( -- )
    RIGHTSIDE 1 /STRING TUCK     \ cut 1st char of RIGHTSIDE, tuck length
    PAD VCOPY                    \ copy to temp buffer
    PAD VPOS ROT VWRITE          \ write buffer back to CURSOR position
    BL EOL VC!                   \ erase last char on line
;

: PUSHRIGHT ( -- )
    RIGHTSIDE TUCK               \ tuck length for later
    PAD VCOPY                    \ read right side of line into PAD
    BL VPUT                      \ put a blank at cursor position
    PAD VPOS 1+ ROT VWRITE       \ write PAD back at VPOS+1
;

HEX
: KEYHANDLER ( char -- )
    CASE
        08 OF  CLEFT        ENDOF
        09 OF  CRIGHT       ENDOF
        03 OF  DELCHAR      ENDOF
        04 OF  INS/DEL      ENDOF
               BEEP
    ENDCASE
;

: PRINTABLE? ( char -- ?) BL [CHAR] ~ 1+ WITHIN ;
: WRITE-CHAR ( char -- ) INSERT @ IF PUSHRIGHT THEN VPUT CRIGHT ;

: VDP-EDITLINE ( addr -- addr n)
    DUP>R C/L@ BLANK \ save address on Rstack & erase
    INSERT OFF       \ overwriting mode
    BLKCURS
    RKEY? DROP       \ clear the key reader
    BEGIN
        RKEY DUP ^M <>
    WHILE
        DUP PRINTABLE?
        IF   WRITE-CHAR
        ELSE KEYHANDLER
        THEN
    REPEAT
    DROP               \ enter key
    [CHAR] _ CURS !    \ Camel99 cursor
    R@ READVDP
    R> 64 -TRAILING
;
\ -----------------------------------------------
\ block editor begins
VARIABLE #LINE
VARIABLE SCR
VARIABLE PAGE#
VARIABLE ELINE#

\ PRIMITIVES
DECIMAL
: CELL-  S" 2-" EVALUATE ; IMMEDIATE
: TAB   VCOL @ 8 +  C/L@ MIN  VCOL ! ;
: BLANK ( addr n -- ) BL FILL ;

: LINE  ( l# -- addr n)  64 *  SCR @ BLOCK + 64 ;
: LINE! ( addr n l# -- ) 64 *  SCR @ BLOCK + SWAP CMOVE UPDATE  ;
: GETXY ( -- x y) VROW 2@ ;
: .SCR# ( -- )   ." SCR#"  SCR @  U. ;
: .FILE   ACTIVE COUNT TYPE ;
: .HEADER  .SCR# TAB TAB .FILE ;
: .LINE ( l# --) DECIMAL DUP 3 .R  SPACE LINE -TRAILING TYPE ;

\ USER COMMANDS
: LIST  ( s# - )
  SCR ! PAGE .HEADER 16 0 DO  CR I .LINE   LOOP CR ;

: USE   PARSE-NAME  OPEN-BLOCKS ;
: LL    SCR @ LIST ; \ re-list
: >>    SCR DUP 1+! @ LIST ;
: <<    SCR DUP 1-! @ LIST ;
: GO    DUP SCR @ LIST ;

: CLEAR ( n -- ) BUFFER B/BUF BLANK  UPDATE ;
: COPY  ( src dst -- ) FLUSH SWAP  BLOCK  CELL- !  UPDATE ;

: PL  ( line# -- <TEXT> ) >R 1 PARSE R> LINE! LL ; \ put line

: ATLINE  ( -- )  1+ 4 SWAP AT-XY ; \ place cursor on line 0
: CUP       VROW @ 1-  1 MAX   VROW ! ;
: CDOWN     VROW @ 1+  16 MIN  VROW ! ;
: ELINE     VROW @ 1+ ;
: /CR       CDOWN   4 VCOL ! ; \ editor carriage return

: EDITLINE
  VCOL @ >R           \ start of VDP line is saved
  PAD VDP-EDITLINE
  R> /STRING          \ cut off string at VCOL location
  VROW @ 1- LINE! /CR     \ write it back to block
;

: EDIT ( scr# -- )
     LIST
     0 ATLINE
     BEGIN
       KEY
       CASE
        [CHAR] i OF EDITLINE                   ENDOF
        [CHAR] I OF EDITLINE                   ENDOF
              10 OF CDOWN                      ENDOF
              13 OF CDOWN                      ENDOF
              11 OF CUP                        ENDOF
              15 OF 0 18 AT-XY ." Forth " QUIT ENDOF
       ENDCASE
     AGAIN
;

HERE SWAP - DECIMAL . .( bytes )
