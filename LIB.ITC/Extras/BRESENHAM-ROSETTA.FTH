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

: LINE ( x0 y0 x1 y1  -- )
  ROT SWAP   ( x0 x1 y0 y1 )
  2DUP  - ABS >R
  2OVER - ABS R> <
  IF         ['] SWAP \ SWAP USE OF X AND Y
  ELSE 2SWAP ['] NOOP
  THEN       IS STEEP \ change action of STEEP

  ( Y0 Y1 X0 X1 )
  2DUP >
  IF SWAP 2SWAP SWAP  \ ENSURE X1 > X0
  ELSE    2SWAP
  THEN
  ( x0 x1 y0 y1 )
  2DUP >         \ is Y descending
  IF   ['] 1-    \ choose a decrementer
  ELSE ['] 1+    \
  THEN IS YSTEP  \ set YSTEP's action

  ( x0 x1 y0 y1 )
  OVER - ABS  TO DY  ( y0) TO Y
  SWAP 2DUP - DUP  TO DX
  2/ ROT 1+ ROT
  ( ERROR X1+1 X0 )
  DO  I Y STEEP MM.PLOT
      DY -
      DUP 0<
      IF   Y YSTEP TO Y
           DX +
      THEN
  LOOP
  DROP ;