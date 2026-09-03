
VARIABLE PASSES
VARIABLE SWAPS

: .REP  CR ." Passes " PASSES @ U.
        CR ." Swaps  " SWAPS @ U. ;

1 CELLS CONSTANT CELL

: BUBBLE ( ADDR CNT -- )
  SWAPS OFF
  PASSES OFF
  DUP 1
  DO
    2DUP 1-  CELLS BOUNDS ( endaddr startaddr)
    DO
      I 2@ <
      IF
         I 2@ SWAP I 2!
         SWAPS 1+!
      THEN
      PASSES 1+!
    CELL +LOOP
  LOOP
  2DROP ;


\ This is the original rosseta code but it cheats by reducing the inner loop
: INSERTION ( ADDR CNT -- )
  SWAPS OFF
  PASSES OFF

  DUP 1
  DO
    2DUP I -  CELLS BOUNDS ( endaddr startaddr)
    DO
      I 2@ <
      IF
         I 2@ SWAP I 2!
         SWAPS 1+!
      THEN
      PASSES 1+!

    CELL +LOOP
  LOOP
  2DROP ;
