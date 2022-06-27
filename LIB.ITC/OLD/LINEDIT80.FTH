\ Simple line editor for Blocks TTY I/O Version    2020 Brian Fox

NEEDS BUFFER FROM DSK1.BLOCKS
NEEDS .R     FROM DSK1.UDOTR
NEEDS 80COLS FROM DSK1.80COL
NEEDS -TRAILING FROM DSK1.TRAILING
NEEDS RKEY   FROM DSK1.RKEY

80COLS

VARIABLE SCR

DECIMAL
\ We need LWIDTH cuz C/L holds the full screen width value
64 CONSTANT LWIDTH
: ROW     ( addr -- addr')  DUP LWIDTH TYPE LWIDTH + ;
: LINE    ( addr -- ) ." | " ROW CR ;
: 4LINES  ( addr -- addr')  LINE LINE LINE LINE ;
: 16LINES ( -- )  SCR @ BLOCK  4LINES 4LINES 4LINES 4LINES DROP ;

: ]LINE   ( lin# -- addr) LWIDTH *  SCR @ BLOCK  + ; \ index into block
: (CP)    ( L1 L2 -- ) ]LINE SWAP ]LINE SWAP LWIDTH CMOVE ;
: TAB     ( n -- )  C/L@ MIN VCOL +! ;
: .HEAD   ( n -- ) ." SCR#" 4 .R  10 SPACES ACTIVE COUNT TYPE  CR ;
: BLANK   ( adr len --) BL FILL ;

\ EDITOR COMMANDS
: LIST ( n -- ) PAGE DUP SCR ! .HEAD  16LINES ;
: L    ( -- )  SCR @ LIST ;
: >>   ( -- )  1 SCR +! L ;
: <<   ( -- )  SCR @ 1- 0 MAX  SCR ! L ;
: P   ( line# -- ) 1 PARSE ROT ]LINE SWAP CMOVE UPDATE  L ;
: DEL ( line# -- ) ]LINE LWIDTH BLANK UPDATE L ;  \ delete line#
: CP  ( L1 L2 -- ) (CP) UPDATE  L ;      \ copy L1 to L2
: M   ( L1 L2 -- ) OVER >R (CP) R> DEL ; \ move Li to L2
: RO   ( -- )     ACTIVE COUNT DUP 0=  ABORT" No file name"  OPEN-BLOCKS ;
: O   ( <TEXT> )  BL PARSE OPEN-BLOCKS ;

: EL ( addr len -- )

: LOAD  ( n -- )
        SCR !
        16 0
        DO
           I LINES !
           I ]LINE LWIDTH EVALUATE
        LOOP ;

: -->   ( n -- ) SCR @ 1+ LOAD ;

S" DSK3.MYBLOCKS" OPEN-BLOCKS

0 LIST
