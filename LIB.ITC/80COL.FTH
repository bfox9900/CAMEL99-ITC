\ 80 column mode for F18A video card (tested on Classic99)
\ Register DATA taken from Turbo Forth by Mark Wills
( default colors changed to green on black screen)
HEX
CREATE 40COL
       08 C,  \ count
       00 C,  \ TEXT MODE no external video
       F0 C,  \ 16k mem, interrupts on
       00 C,  \ Text screen address
       00 C,  \ no color table
       01 C,  \ Pattern table at $800
       00 C,  \ Sprite Att. table
       00 C,  \ Sprite Patt. table
       17 C,  \ colors

CREATE 80COL
       15 C,
       04 C, 70 C, 03 C, E8 C, 01 C, 06 C, 00 C, 17 C,
       88 C, 00 C, 00 C, 00 C, 94 C, 10 C, 00 C,

: VREGS    ( addr n -- ) 0 DO   DUP I + C@  I VWTR   LOOP DROP ;
DECIMAL
: 40COLS   ( -- ) 40COL COUNT VREGS  40 C/L!  2 VMODE !  PAGE ;
: 80COLS   ( -- ) 80COL COUNT VREGS  80 C/L! 80 VMODE !  PAGE ;

\ : COLORS   ( fg bg -- ) SWAP 4 LSHIFT +  7 VWTR ;
