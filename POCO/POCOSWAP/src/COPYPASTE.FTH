\ COPYPASTE.FTH  for POCO editor   Feb 2026 BJFox
CR .( COPYPASTE for POOO SWAPFILE uses VDP RAM )
CR

DECIMAL
64 CONSTANT #STAKLINES
#STAKLINES 1- CONSTANT STAKWRAP
82 CONSTANT STAKWIDTH

CREATE TEMP$  STAKWIDTH ALLOT

\ >>NOTE<< circlular string stack resides in *VDP RAM*
HEX 1000 CONSTANT LNSTAK[]
#STAKLINES STAKWIDTH * CELL+  VP +!  \ allocate the space in VP variable

VARIABLE 'STAK    \ line stak pointer

: STAK+!  ( n -- )  'STAK @ +  STAKWRAP AND  'STAK ! ;
: STAKLN  ( n -- addr) 'STAK @ STAKWIDTH *  LNSTAK[] + ;
: $PUSH  ( addr n -- ) 1 STAK+!  STAKLN VPLACE ;

: $POP   ( -- addr n )
    STAKLN VCOUNT DUP>R TEMP$ SWAP VREAD
    TEMP$ R>
    -1 STAK+! ;
