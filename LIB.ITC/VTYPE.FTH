\ VTYPE is faster than TYPE.  AT"  has x,y placement,   APR 16 FOX
CR .( ** VTYPE HAS NO SCROLLING ** )
\ Usage:  S" TYPE is now very fast."  TYPE
\ : TEST  0 10 AT" LIKE DISPLAY-AT BUT FASTER" ;
HEX
: VTYPE ( adr len  ) TUCK VPOS SWAP VWRITE  VCOL +! ;
: AT"   ( x y -- ) ?COMP  ( for COMPILING only)
        POSTPONE AT-XY  POSTPONE S"  POSTPONE VTYPE ; IMMEDIATE

