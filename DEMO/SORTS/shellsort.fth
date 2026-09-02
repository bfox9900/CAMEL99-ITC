\ shell sort from Rossetta Code modified for Camel99 Forth

NEEDS DUMP FROM DSK1.TOOLS
NEEDS RND  FROM DSK1.RANDOM
NEEDS MALLOC FROM DSK1.MALLOC
NEEDS ELAPSE FROM DSK1.ELAPSE
NEEDS VALUE FROM DSK1.VALUES

 1 CELLS CONSTANT CELL

\ harness for Rossetta code version
: CELL-    S" 2-" EVALUATE ; IMMEDIATE \ Native 9900 instruction
: U<=      S" 1+ U<" EVALUATE ; IMMEDIATE

\ Replaces local variables in original code
0 VALUE ARRAY
0 VALUE LEN
0 VALUE GAP

\ --------------------------
DEFER LESS?   ' < IS LESS?

: SHELL  ( addr len -- ) TO LEN   TO ARRAY
  1 BEGIN DUP LEN U<= WHILE 2* 1+ REPEAT TO GAP

  BEGIN GAP 2 =
    IF 1
    ELSE GAP 5 11 */  \ equivalent to /2.2
    THEN DUP TO GAP
  WHILE
    LEN GAP
    DO
      ARRAY I CELLS +
      DUP @ SWAP         ( TEMP LAST )
      BEGIN GAP CELLS -
            ARRAY OVER U<=
      WHILE 2DUP @ LESS?
      WHILE DUP GAP CELLS + OVER @ SWAP !
      REPEAT THEN
      GAP CELLS + !
    LOOP
  REPEAT ;

\ REAL IRON RESULTS
\             reversed    sorted     Random
\ SIZE= 1000  12.50        8.95       15.08
\ SIZE= 500    5.71        3.88        6.63
\ SIZE= 200    1.76        1.28        2.23
\ SIZE= 100    0.85        0.66        1.05
\ SIZE= 50     0.40        0.30        0.45
