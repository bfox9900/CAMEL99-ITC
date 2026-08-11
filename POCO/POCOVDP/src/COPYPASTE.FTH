\ COPYPASTE.FTH  for POCO editor   Feb 2026 BJFox
CR .( 48 line copy/paste in LOW RAM for POCO VDP)

DECIMAL
48 CONSTANT #STAKLINES
82 CONSTANT STAKWIDTH

\ string stack resides in LOW RAM
HEAP CONSTANT LNSTAK[]  #STAKLINES STAKWIDTH * CELL+  H +!

VARIABLE 'STAK    \ line stak pointer

: STAK+!  ( n -- )
 'STAK @ +  DUP #STAKLINES > IF  DROP BEEP  EXIT THEN
 'STAK ! ;

: STAKLN  ( n -- addr) 'STAK @ STAKWIDTH *  LNSTAK[] + ;

: $PUSH  ( addr n -- ) 1 STAK+!  STAKLN PLACE  ;
: $POP   ( -- addr n ) STAKLN COUNT  -1 STAK+! ;
