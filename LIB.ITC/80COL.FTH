\ 80 column mode for F18A video card (tested on Classic99)
\ Register DATA taken from Turbo Forth by Mark Wills
HEX
CREATE 40COL
       08 C,  \ count
\ ---------------------
       00 C,  \ TEXT MODE no external video
       F0 C,  \ 16k mem, interrupts on VR1
       00 C,  \ Text screen address VR2
       00 C,  \ no color table
       01 C,  \ Pattern table at $800
       00 C,  \ Sprite Att. table
       00 C,  \ Sprite Patt. table
       17 C,  \ colors

CREATE 80COL
       15 C,  \ byte count for this array
\ -------------------
       04 C,  \ VR1
       70 C,  \ VR2
       03 C,  \ VR3
       E8 C,  \ VR4
       01 C,  \ VR5
       06 C,  \ VR6
       00 C,  \ VR7
       17 C,  \ VR8
       88 C,  \ VR9
       00 C,  \ VR10
       00 C,  \ VR11
       00 C,  \ VR12
       94 C,  \ VR13
       10 C,  \ VR14
       00 C,  \ VR15

: VREGS    ( addr n -- ) 0 DO  COUNT  I VWTR   LOOP DROP ;
\ default 40 column mode is called text
DECIMAL
: TEXT   ( -- ) 40COL COUNT VREGS  40 C/L!  2 VMODE !  PAGE ;

: 80COLS   ( -- )
     80COL COUNT VREGS
     80 C/L!
     80 L/SCR *  C/SCR !
     80 VMODE !
     PAGE ;

80COLS
