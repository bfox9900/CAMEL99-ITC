\ JOYST.FTH  from http://www.unige.ch/medecine/nouspikel/ti99/joystick.htm
\ Tested on REAL TI-99, CAMEL99 TTY Jan 8 2020
\ NEEDS  LDCR,  FROM DSK1.ASM9900
\ HEX Outputs in TOS register
\ 01 = Fire
\ 02 = Left
\ 04 = Right
\ 08 = Down
\ 10 = Up
HEX
CODE JOYST ( joystick# -- value ) \ #0 = joyst1, #1 = joyst2
   0224 , 0006 ,  \ TOS  06 AI,     \ joyst# to real CRU adress
   06C4 ,         \ TOS     SWPB,   \
   020C , 0024 ,  \ R12  24 LI,     \ joystick i/o address
   30C4 ,         \ TOS  03 LDCR,   \ write 3 bits to enable joysticks
   020C , 0006 ,  \ R12  06 LI,     \ select column 6
   3544 ,         \ TOS  05 STCR,   \ get 5 bits from joystick
   06C4 ,         \ TOS     SWPB,   \ swap byte
   0544 ,         \ TOS     INV,    \ change to positive logic
   0244 , 001F ,  \ TOS 01F ANDI,   \ mask off the junk
   04E0 , 83D6 ,  \ 83D6 @@ CLR,    \ reset screen timeout
   NEXT,
   ENDCODE
