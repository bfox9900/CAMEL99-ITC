\ Simple line editor for Blocks

NEEDS BUFFER FROM DSK1.BLOCKS

VARIABLE SCR
VARIABLE SOL
VARIABLE SWID   C/L @ 4 - SWID !

DECIMAL
64 CONSTANT LWIDTH

: -TRAILING  ( adr len -- adr len')     \ remove trailing blanks (spaces)
             1-
             BEGIN  2DUP + C@ BL =      \ test char at end of string (adr+len)
             WHILE  1-                  \ while it is a blank, decrement length
             REPEAT
             1+ ;

: (LINE) ( lin# -- addr) SCR @ BLOCK SWAP  LWIDTH * + ;
\ : .LINE  ( lin# --) (LINE) SOL @ + SWID @ TYPE ; ( 40 COL version)

: .LINE  ( lin# --) (LINE) LWIDTH -TRAILING TYPE ; ( slow version)

\ : .LINE  ( lin# - ) (LINE) SOL @ + VPOS  SWID @ VWRITE ;
: (CP) ( L1 L2 -- ) (LINE) SWAP (LINE) SWAP LWIDTH CMOVE ;

\ Line editor commands
: LIST   ( s# - ) PAGE DUP SCR ! ." SCR# "  3 U.R
         16 0 DO   CR I 2 .R  I .LINE   LOOP  CR QUIT ;

: ED ( -- ) SCR @ LIST ;
: >> ( -- ) 1 SCR +! ED ;
: << ( -- ) SCR @ 1- 0 MAX  SCR ! ED ;

: P  ( line# -- ) 0 PARSE ROT (LINE) SWAP CMOVE UPDATE  ED ;
: D  ( line# -- ) (LINE) LWIDTH BLANKS UPDATE ED ;
: CP ( L1 L2 -- ) (CP) UPDATE ED ;
: M  ( L1 L2 -- ) OVER >R (CP) R> D ;
: R  ( -- ) 28 SOL !  ED ;   \ list right side of block
: L  ( -- ) SOL OFF   ED ;   \ list left side of block

: LOAD  ( n -- )
        SCR !
        16 0
        DO
           I LINES !
           I (LINE) LWIDTH -TRAILING EVALUATE
        LOOP ;

: -->   ( n -- ) SCR @ 1+ LOAD ;
