\ Simple line editor for Blocks

NEEDS BUFFER FROM DSK1.BLOCKS
\ NEEDS 80COLS FROM DSK1.80COL

VARIABLE SCR

DECIMAL
64 CONSTANT LWIDTH

: (LINE) ( lin# -- addr) SCR @ BLOCK SWAP  LWIDTH * + ;
: .LINE  ( lin# --) (LINE) LWIDTH TYPE ; ( slow version)
\ : .LINE  ( lin# - ) (LINE) VPOS  LWIDTH VWRITE ;
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

: LOAD  ( n -- )
        SCR !
        16 0
        DO
           I LINES !
           I (LINE) LWIDTH EVALUATE
        LOOP ;

: -->   ( n -- ) SCR @ 1+ LOAD ;
