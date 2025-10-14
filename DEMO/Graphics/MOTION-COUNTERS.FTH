\ EXPERIMENTAL motion control using TI-99 ROM METHOD

\ Each sprite has an X and Y motion value.
\ The motion values are loaded into a 2nd variable that acts like a downcounter.
\ When a counter hits zero, the sprite is moved one pixel and the counter is reset.
NEEDS SPRITE  FROM DSK1.DIRSPRIT
NEEDS TABLE2: FROM DSK1.TABLES

CREATE MOTIONS  32 CELLS ALLOT   \
CREATE COUNTERS 32 CELLS ALLOT   \ 2 bytes for each sprite
CREATE VECTORS  32 CELLS ALLOT   \ x/y direction vectors

\ tables allow machine speed indexing into memory
MOTIONS     TABLE2: ]MOTION.Y
MOTIONS 1+  TABLE2: ]MOTION.X

COUNTERS    TABLE2: ]COUNT.Y
COUNTERS 1+ TABLE2: ]COUNT.X

VECTORS     TABLE2: ]VECT.Y
VECTORS  1+ TABLE2: ]VECT.X


: MOTION  ( dx dy spr# -- ) DUP>R   ;

: --C@  ( addr -- c)  DUP C@ 1- DUP>R  SWAP C! R> ;
: VC++   ( Vaddr -- )  DUP VC@ 1+ SWAP VC! ;

: RESET.X ( spr# --) DUP>R ]MOTION.X C@  R> ]COUNT.X C!;
: RESET.Y ( SPR# --) DUP>R ]MOTION.Y C@  R> ]COUNT.Y C! ;

: MOVE.X ( spr# -- )
  DUP ]COUNT.X --C@ IF  EXIT  THEN  \ counter not zero. get out
  DUP>R SP.X DUP VC@  R@ ]VECT.X C@ + SWAP VC!
  RESET.X
;

HEX
MOTIONS  20 CELLS  0 FILL
COUNTERS 20 CELLS 0 FILL