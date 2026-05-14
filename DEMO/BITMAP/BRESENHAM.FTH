\ BRESENHAM.FTH
\ Line drawing algorithm                        1/26/2001 Brad Eckert
\ This is probably the classic Bresenham, or as I call it, "common sense"
\ algorithm.

\ Camel Forth needs some harness for Brad's code
NEEDS 3RD4TH FROM DSK1.3RD4TH

: DNEGATE  ( d1 -- d2 )  SWAP INVERT SWAP INVERT 1 M+ ;
: 4DROP   S" 2DROP 2DROP" EVALUATE ; IMMEDIATE
: 2OVER   S" 4TH 4TH" EVALUATE  ; IMMEDIATE

\ TMS9900 optimizers really help this old machine go faster
HEX
CODE 2ABS   ( -a -b -- a b )  0756 , 0744 , NEXT, ENDCODE \ *SP ABS, TOS ABS,
CODE NOS1+  (  a  b -- a+1 b)  0596 , NEXT, ENDCODE    \ *SP INC,
CODE X@     ( addr -- n)  05C4 ,  C114 , NEXT, ENDCODE \ CELL+ @

\ VARIABLE CH
\ : PLOT ( X Y ) AT-XY CH @ EMIT ;
NEEDS PLOT FROM DSK1.GRAPHICS2

\ ----------------------------------------------------------------------------
\ First, let's define the inner loop since this is where the work gets done.
\ We'll step one point at a time in one direction and a fraction of a point
\ in the other direction. The variable slope part uses a double-wide accumulator
\ and we use the upper part of the accumulator to plot the actual point.
: SHALLOWLINE   ( SLOPE 0 Y0 X1+1 X0 -- )      \ SLOPE IS BETWEEN -1 AND 1
        DO  I OVER PLOT 2OVER D+  LOOP 4DROP ;

: STEEPLINE     ( slope 0 X0 Y1+1 Y0 -- )      \ 1/slope is between -1 and 1
        DO  DUP I PLOT  2OVER D+  LOOP 4DROP ;

\ Now for the main word, where we look at the slope and decide which type of
\ line to draw.
\                    Y   X
: 2VARIABLE   CREATE 0 , 0 , ;

2VARIABLE POINT0        \ Y1 X1
2VARIABLE POINT1        \ Y0 X0

: PRESCALE      ( dy*2^cellsize dx -- slope 0 0 )
        2DUP XOR >R
        OVER 0< IF >R DNEGATE R> THEN
        DUP 0<  IF NEGATE THEN
        UM/MOD NIP 0
        R> 0< IF DNEGATE THEN 0
;

: LINE          ( X0 Y0 X1 Y1 -- )
        POINT1 2!  2DUP POINT0 2!
        POINT1 @ - SWAP                 ( Y0-Y1 X0 )
        POINT1 X@ -  0 -ROT        ( 0 Y0-Y1 X0-X1 )
        2DUP 2ABS  \ OVER ABS OVER ABS
        2DUP <
        IF
           2DROP
           DUP 0< >R                \ shallow line
           PRESCALE                        ( dslope 0 | f )
           R@ IF POINT0 ELSE POINT1 THEN @
           POINT0 X@ POINT1 X@ R> IF SWAP THEN
           NOS1+     \ SWAP 1+ SWAP
           SHALLOWLINE EXIT
        THEN

        = IF    OVER 0< >R                      \ Steep line
                = DUP IF ABS THEN 0             \ diagonal line ( slope 0 | f )
        ELSE    OVER 0< >R                      \ reverse?
                SWAP PRESCALE                   ( slope 0 | f )
        THEN    R@ IF POINT0 ELSE POINT1 THEN X@
                POINT0 @ POINT1 @ R> IF SWAP THEN
                NOS1+   \ SWAP 1+ SWAP
                STEEPLINE
;

\ BF additions ...

NEEDS VALUE FROM DSK1.VALUES

0 VALUE x
0 VALUE y

: MOVETO  ( x y -- ) TO y   TO x ;
: LINETO  ( x y -- ) 2DUP x y LINE MOVETO ;

\ no safety net !!
: HLINE ( x y len ) -ROT MOVETO  0 DO  x I +  y  PLOT  LOOP ;
: VLINE ( x y len ) -ROT MOVETO  0 DO  x  y I +  PLOT  LOOP ;

HEX F0 CONSTANT $F0
DECIMAL

: TEST
        GRAPHICS2
        PENCIL IS STYLUS
        21 0
        DO
           10 I 4* +  50 I 4* +
           195 I 10 * DUP>R -  R> LINE
        LOOP
        BEGIN KEY? UNTIL
        TEXT
;
