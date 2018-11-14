\ MENULINE  isolate the top line of screen for menus

: MENULINE  ( -- )
           C/L@ VTOP !  0 C/L@ BL VFILL ;

: .MENU   ( addr len -- ) 0 SWAP VWRITE ;
           
: FULLSCREEN ( -- ) 0 VTOP ! ;

MENULINE  S" CAMEL99 Multi-Forth V2 2018" .MENU


