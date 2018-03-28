\ 5x faster type to screen with x,y placement
\ **WARNING** it does not scroll

\ Usage:  S" VDPTYPE is very fast."  0 10 VDPWRITE

: >VPOS    C/L@ * + ;

: OFFSCR? ( len x y -- )
          2DUP >VPOS 3 PICK >R
          + C/SCR @ > ABORT" Off screen" ;

: VDPTYPE ( adr len x y )
          OFFSCR?  AT-XY VPOS SWAP VWRITE ;
