\ VTYPE 5x faster than TYPE.  AT"  has x,y placement
\ **WARNING** it does not scroll

\ Usage:  S" VTYPE is very fast."  VTYPE
\ : TEST  0 10 AT" LIKE DISPLAY-AT BUT FASTER" ;

: VTYPE ( adr len  ) TUCK VPOS SWAP VWRITE  VCOL +! ;

: AT"   ( x y -- )
        ?COMP  ( for COMPILING only)
        POSTPONE AT-XY  POSTPONE S"  POSTPONE VTYPE ; IMMEDIATE

