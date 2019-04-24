\ 80 column mode for F18A video card (tested on Classic99)
\ Register DATA taken from Turbo Forth by Mark Wills
( default colors changed to green on black screen)

NEEDS GRAPHICS  FROM DSK1.GRAFIX

HEX
CREATE 40COL
       08 C, 00 C, F0 C, 00 C, 0E C, 01 C, 06 C, 02 C, 20 C,

CREATE 80COL
       15 C, 04 C, 70 C, 03 C, E8 C, 01 C, 06 C, 00 C,
       20 C, 88 C, 00 C, 00 C, 00 C, 94 C, 10 C, 00 C,

: VREGS    ( addr n -- ) 0 DO  DUP I + C@  I VWTR  LOOP DROP ;

DECIMAL
\ we have to over-write the old versions to handle 80cols
: TEXT     ( -- ) 40COL COUNT VREGS  TEXT  ;
: COLD     ( -- ) TEXT  COLD ;
: TINT     ( fg bg -- ) SWAP 4 LSHIFT +  7 VWTR ;

: 80COLS   ( -- ) TEXT 80COL COUNT VREGS  80 C/L!  PAGE  80 VMODE ! ;

\ You need to LOAD GRAFIX2.FTH first if you are using 80COLS and GRAPHICS
: GRAPHICS ( -- ) TEXT GRAPHICS ;

80COLS 
PAGE


