\ COPYPASTE.FTH  for POCO editor   Feb 2026 BJFox

' POCO  DROP \ is the editor loaded?

DECIMAL
32 CONSTANT #STAKLINES
#STAKLINES 1- CONSTANT STAKWRAP
82 CONSTANT STAKWIDTH

\ circlular string stack resides in LOW RAM
HEAP CONSTANT LNSTAK[]  #STAKLINES STAKWIDTH * CELL+  H +!

VARIABLE 'STAK    \ line stak pointer

: STAK+!  ( n -- )  'STAK @ +  STAKWRAP AND  'STAK ! ;
: STAKLN  ( n -- addr) 'STAK @ STAKWIDTH *  LNSTAK[] + ;

: $PUSH  ( addr n -- ) 1 STAK+!  STAKLN PLACE  ;
: $POP   ( -- addr n ) STAKLN COUNT  -1 STAK+! ;