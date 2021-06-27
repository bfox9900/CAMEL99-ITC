\ PLOT to 8x8 character matrix                  Jan 27, 2021 Brian Fox

\ BOOLEAN array creator and access words               Brian Fox  2018
\ Tested with  CAMEL99 Forth 16 bits, Gforth 32 bits, iForth 64 bits
\ July 2019, removed Rstack juggling BSET, BRST, BTOG.
\ Relaced with OVER. 20% faster

NEEDS DUMP     FROM DSK1.TOOLS
NEEDS CHARDEF  FROM DSK1.GRAFIX
NEEDS ?BREAK   FROM DSK1.BREAK
NEEDS 3RD      FROM DSK1.3RD4TH

MARKER REMOVE

HEX
\ calculations based on CELL size
                   8 CONSTANT BITS/BYTE
 1 CELLS BITS/BYTE * CONSTANT BITS/CELL

\ create bit array & erase memory area for 'n' bits
: BITS:      ( n -- )
      CREATE  BITS/BYTE /MOD SWAP >R   \ calc memory size
              HERE OVER 0 FILL         \ erase the memory
              R> CELLS + 2+ ALLOT  ;   \ allocate the memory

\ compute bit# in a cell & cell address in memory
\ usage:  42 MYARRAY BITFLD
: BITFLD  ( bit# bits[] -- bit#' addr)
    SWAP 0 BITS/CELL UM/MOD CELLS ROT + ;

\ convert bit# to a bit mask
: BITMASK ( bit# -- n )  0001 SWAP LSHIFT >< ; \ 9900 needs a byte swap

\ API
: BIT@ ( bit# bits[] -- ?) BITFLD @ SWAP RSHIFT 0001 AND ;  \ return 1 bit
: BSET ( bit# bits[] -- )  BITFLD SWAP BITMASK        OVER @  OR SWAP ! ;
: BRST ( bit# bits[] -- )  BITFLD SWAP BITMASK INVERT OVER @ AND SWAP ! ;
: BTOG ( bit# bits[] -- )  BITFLD SWAP BITMASK        OVER @ XOR SWAP ! ;

DECIMAL
64 BITS: MATRIX

HEX

CREATE PCHAR  80 ,

: PCHAR++  PCHAR @ 1+  FF AND PCHAR ! ; \ 128 chars circular

: ERASE   0 FILL ;
: CLR    ( -- ) MATRIX 8 ERASE  MATRIX PCHAR @ CHARDEF ;

: CALCXY ( col row -- ) SWAP  8* +  MATRIX BSET ;

: FINEPLOT  ( col row --) CALCXY   MATRIX PCHAR @ CHARDEF ;

: 8/   ( n -- n')  3 RSHIFT ;

: PLOT ( col row -- )  OVER 8/ OVER 8/ AT-XY PCHAR @ (EMIT) FINEPLOT ;

\ Test code
DECIMAL
CREATE DLY  20 ,

: BOT2TOP CLR
         8 0 DO
           8 0 DO
                  I J FINEPLOT
                  DLY @ MS
               LOOP
         LOOP ;

: TOP2BOT
       CLR
       0 7 DO
       0 7 DO
              I J FINEPLOT
              DLY @ MS
        -1 +LOOP
          ?BREAK
      -1 +LOOP ;

: R2LEFT  CLR
         8 0 DO
           8 0 DO
                  J I FINEPLOT
                  DLY @ MS
               LOOP
               ?BREAK
         LOOP ;


: L2RIGHT  CLR
         0 7  DO
           0 7  DO
                  J I FINEPLOT
                  DLY @ MS
              -1 +LOOP
              ?BREAK
         -1 +LOOP ;


: RUN  BEGIN
         BOT2TOP  R2LEFT
         TOP2BOT  L2RIGHT
      AGAIN ;



HEX 80 SET# 2 3 COLOR
PAGE
CR CR 80 EMIT

: 2ROT   ( d1 d2 d3 -- d2 d3 d1) 2>R 2SWAP 2R> 2SWAP ;
: 2OVER  ( d1 d2 -- d1 d2 d1) 4TH 4TH ;

\ ANS version of C.H. Ting's line drawing code
: LINE ( x1 y1 x2 y2 -- )
     2OVER 2OVER  ROT - ABS >R
     - ABS R>
     MAX  2 <
     IF  2DROP PLOT EXIT THEN
     2OVER 2OVER  ROT + 1+ 2/ >R ( Y3)
     + 1+ 2/ ( X3) R>
     2DUP 2ROT
     RECURSE RECURSE ;
