\ faster type to screen with x,y placement
\ **WARNING** it only scrolls 1 line

\ Usage:  S" VDPTYPE is very fast." VDPTYPE

: VDPTYPE ( adr len  )
          DUP>R               \ keep screen length
          VPOS OVER + C/SCR @ >
          IF
             SCROLL
          THEN
          VPOS SWAP VWRITE
          R> VCOL +! ;
