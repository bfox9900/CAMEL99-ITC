\ Multiple named screens in 32 or 40 Column mode
HEX
: SCREEN ( n -- ) 400 * VPG ! ;

: SCREEN: ( scr# fg bg -- )
     SWAP 4 LSHIFT +   \ colors to byte
     CREATE  ( color) , ( scr#) ,
             400 VP +!  \ allocate 1K vdp ram

     DOES> 2@ 7 VWTR  \ set color
           DUP SCREEN  2 VWTR ;

\ Vpage fg  bg
\ ----- --  --
   0    1   7 SCREEN: SCR0
   4    1   3 SCREEN: SCR4
\   5    1   4 SCREEN: SCR5
