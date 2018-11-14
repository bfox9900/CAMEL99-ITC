\ Dr. C. H. Ting's Simplest Line Drawing Algorithm
\ Draw a straight line between (x1, y1) and (x2,y2).
\ Determine the end condition, where (x1,y1) and (x2,y2) 
\ are within one pixel distance.
\ Find the aid point between (x1,y1) and (x2,y2).
\ Insert mid point between 1 and 2, then recurse twice 
\ to draw the two segments.

\     HEX
\     CODE VIDEO ( cx dx ax -- ) \IBM BIOS video service
\          AX POP DX POP CX POP     10 INT    NEXT END-CODE
\     : TEXT    0 0 2 VIDEO ;  \ Return to text mode.
\     : GRAPH   0 0 4 VIDEO ;  \ Set high-resolution graphics mode.

\ Given a coordinate pair and a color code,
\ Paint one dot on the Screen.
\     CODE PLOT ( x y color --)
\          AX POP  0200 # AX ADD  DX POP  CX POP 10 INT
\          NEXT END-CODE

NEEDS .S       FROM DSK1.TOOLS
NEEDS INLINE[  FROM DSK1.INLINE
NEEDS 4TH      FROM DSK1.3RD4TH
NEEDS ELAPSE   FROM DSK1.ELAPSE

CHAR * CONSTANT pen

: PLOT ( x y ) AT-XY pen EMIT 20 MS  ;

: 2ROT   ( d1 d2 d3 -- d2 d3 d1) 2>R 2SWAP 2R> 2SWAP ;
: 2OVER  ( d1 d2 -- d1 d2 d1) 2>R 2DUP  2R> 2SWAP ;

: DRAW ( X1 Y1 X2 Y2 -- )
     2OVER 2OVER  ROT - ABS >R
     - ABS R>
     MAX  2 <
     IF
         2DROP PLOT EXIT
     THEN
         2OVER 2OVER  ROT + 1+ 2/ >R ( Y3)
         + 1+ 2/ ( X3) R>
         2DUP 2ROT
         RECURSE RECURSE ;

\ optimizers
CODE 4DUP   INLINE[ 4TH 4TH 4TH 4TH ]      NEXT,  ENDCODE
CODE -ABS   INLINE[ - ABS ]                NEXT, ENDCODE
CODE 2ROT   INLINE[  2>R 2SWAP 2R> 2SWAP ] NEXT, ENDCODE

: FDRAW ( X1 Y1 X2 Y2 -- )
     4DUP  ROT -ABS >R
     -ABS R>
     MAX  2 <
     IF
         2DROP PLOT EXIT
     THEN
         4DUP  ROT + 1+ 2/ >R ( Y3)
         + 1+ 2/ ( X3) R>
         2DUP 2ROT
         RECURSE RECURSE ;

: TEST1  PAGE  23 0 DO   0 I  39 23 I -  DRAW   2 +LOOP ;

: TEST2  PAGE  23 0 DO   0 I  39 23 I -  FDRAW  2 +LOOP ;




