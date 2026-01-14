\ multicolor mode toys for FbForth  by B Fox 

0 VARIABLE MCOLOR       \ holds active color 

: ENUM-COLOR  ( 0 <text> -- n) 
  DUP <BUILDS  , 1+  DOES> @ MCOLOR ! ;   

\ named TI-99 colors set MCOLOR when invoked 
0 ( set 1st color)
ENUM-COLOR TRANS    ENUM-COLOR BLACK    ENUM-COLOR GREEN    ENUM-COLOR LIME
ENUM-COLOR BLUE     ENUM-COLOR SKY      ENUM-COLOR RED      ENUM-COLOR CYAN
ENUM-COLOR RUST     ENUM-COLOR ORANGE   ENUM-COLOR YELLOW   ENUM-COLOR LEMON
ENUM-COLOR OLIVE    ENUM-COLOR MAGENTA  ENUM-COLOR GRAY     ENUM-COLOR WHITE
DROP

: MM.PLOT  ( x y -- ) MCOLOR @ -ROT  MCHAR ;

: XY@      ( -- x y) VROW 2@ ; 
: HLINE    ( n x y --) AT-XY  0 DO  MCOLOR @ XY@ MCHAR  VCOL 1+!  LOOP ;
: VLINE    ( n x y --) AT-XY  0 DO  MCOLOR @ XY@ MCHAR  VROW 1+!  LOOP ; 
