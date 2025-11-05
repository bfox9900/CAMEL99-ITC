\ bresenham from rosettacode.com

\ libraries needed by Camel99 forth
NEEDS .S     FROM DSK1.TOOLS
NEEDS DEFER  FROM DSK1.DEFER
NEEDS VALUE  FROM DSK1.VALUES

\ these words change based on the input coordinates
DEFER STEEP         \ noop or swap
DEFER YSTEP         \ 1+ OR 1-

\ replaced local variables with VALUEs for Camel99 Forth
0 VALUE Y
0 VALUE DY
0 VALUE DX

: 2OVER  3 PICK  3 PICK ;

CODE NOOP  NEXT, ENDCODE

: CHECK-DIRECTION  ( x0 x1 y0 y1 -- Y0 Y1 X0 X1 )
  ROT SWAP   ( x0 x1 y0 y1 )
  2DUP  - ABS >R  ( r: -- dy)
  2OVER - ABS R>  ( dx dy )
  < IF       ['] SWAP
  ELSE 2SWAP ['] NOOP \ change direction we draw
  THEN       IS STEEP \ change action of STEEP
;

: ASCEND/DESCEND ( x0 x1 y0 y1 )
  2DUP >         \ is Y ascending?
  IF   ['] 1-    \ choose a decrementer
  ELSE ['] 1+    \
  THEN IS YSTEP  \ set YSTEP's action
;

: ADJUST-X ( Y0 Y1 X0 X1 -- x0 x1 y0 y1 )
  2DUP >
  IF SWAP 2SWAP SWAP  \ ENSURE X1 > X0
  ELSE    2SWAP
  THEN
;

: LINE ( x0 y0 x1 y1  -- )
  CHECK-DIRECTION
  ASCEND/DESCEND
  ADJUST-X

  OVER - ABS  TO DY  ( y0) TO Y
  SWAP 2DUP - DUP  TO DX
  2/ ROT 1+ ROT
  ( ERROR X1+1 X0 )
  DO
    I Y STEEP MM.PLOT
    DY -
    DUP 0<
    IF  Y YSTEP TO Y
        DX +
    THEN
  LOOP
  DROP ;