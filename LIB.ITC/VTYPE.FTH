CR .( VTYPE is a fast TYPE. Mar 3 2025 FOX)
\  AT"  has x,y placement,   
\ ** VTYPE HAS NO SCROLLING. GOES BACK TO TOPLINE ** 
\ Usage:  S" VTYPE is very fast." VTYPE
HEX
: VTYPE ( adr len  ) 
  TUCK VPOS 2DUP + C/SCR @ 2- > 
  IF 0 0 AT-XY  THEN SWAP VWRITE VCOL +! ;

: AT"   ( x y -- ) ?COMP  ( for COMPILING only)
  POSTPONE AT-XY  POSTPONE S"  POSTPONE VTYPE ; IMMEDIATE
  
DECIMAL 
