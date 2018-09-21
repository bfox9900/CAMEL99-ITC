\ 5x faster type to screen with x,y placement
\ **WARNING** it does not scroll

\ Usage:  S" VDPTYPE is very fast."  0 10 VDPWRITE

\ : >VPOS    C/L@ * + ;  ( V2.024 is CODE word)

: ?OFFSCR ( len x y -- )
          2DUP >VPOS 3 PICK + C/SCR @ > 
          ABORT" Off screen" ;

: VDPTYPE ( adr len x y )
          ?OFFSCR  >VPOS SWAP VWRITE ;
