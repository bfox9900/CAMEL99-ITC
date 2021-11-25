\ PLOT to 8x8 character matrix                  Jan 27, 2021 Brian Fox

NEEDS DUMP     FROM DSK1.TOOLS
NEEDS CHARDEF  FROM DSK1.GRAFIX
NEEDS ?BREAK   FROM DSK1.BREAK

MARKER REMOVE
\ BIT array creator & operators
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
\ =========================================

DECIMAL
64 BITS: MATRIX

HEX

CREATE PCHAR 80 ,    \ 1ST plottable character

: PCHAR++  PCHAR @ 1+  FF AND PCHAR ! ; \ 128 chars circular

: ERASE   0 FILL ;
: VERASE  0 VFILL ;
: 8/       ( n -- n')  3 RSHIFT ;
: DOTS>XY ( dotcol dotrow -- col row) SWAP 8/ SWAP 8/ ;
: CLRCHAR  ( -- ) PCHAR @ ]PDT 8 VERASE ;

: CALCXY ( col row -- )  8* +  MATRIX BSET ;

: PLOT  ( col row --)
       2DUP DOTS>XY AT-XY PCHAR @ (EMIT)
       CALCXY  MATRIX PCHAR @ CHARDEF ;

HEX 80 SET# 2 3 COLOR
PAGE
CR CR 80 EMIT

CREATE PXY  0 , 0 ,   \ remember coarse screen position
: D=   ( d d -- ?) ROT = -ROT = AND ;

: PLOT ( DotCol DotRow --)
     DOTXY>XY GCHAR LASTCHAR @ <
     AT-XY  \ coarse position
     PCHAR @ EMIT
     SWAP 8 MOD SWAP 8 MOD FINEPLOT ;

\ Test code
DECIMAL
CREATE DLY  20 ,
: BOT2TOP CLR
         8 0 DO
           8 0 DO
                  I J PLOT
                  DLY @ MS
               LOOP
         LOOP ;

: TOP2BOT
       CLR
       0 7 DO
       0 7 DO
              I J PLOT
              DLY @ MS
        -1 +LOOP
          ?BREAK
      -1 +LOOP ;

: R2LEFT  CLR
         8 0 DO
           8 0 DO
                  J I PLOT
                  DLY @ MS
               LOOP
               ?BREAK
         LOOP ;


: L2RIGHT  CLR
         0 7  DO
           0 7  DO
                  J I PLOT
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
