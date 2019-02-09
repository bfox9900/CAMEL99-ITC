\ 5x faster type to screen with x,y placement
\ **WARNING** it does not scroll

\ Usage:  S" VDPTYPE is very fast."  0 10 VDPTYPE

: VDPTYPE ( adr len x y )
          >VPOS DUP >R       \ keep screen pos copy
          OVER + C/SCR @ > ABORT" Off screen"
          R> SWAP VWRITE ;
          
          
: VTYPE   VPOS SWAP VWRITE ;           
