\ Direct Sprite motion control  BJF Jun 15 2018

\ This is a very simple implementation that lets you
\ set the motion of each sprite in a CPU memory table

\ See: SPRITDMO.FTH for usage examples

\ Aug 9 2018
\   -  Changed to accomodate 2@ 2! IN V2.0.21
\   -  2@ 2! were made ANS Compliant in 2.0.21
\   -  improved speed of SP.MOVE

NEEDS SP.Y  FROM DSK1.DIRSPRIT.F

\ create array of direction vectors in dictionary
\ to hold x y vectors for each sprite (64 BYTES)
CREATE VECTORS   MAX.SP 1+ 4* ALLOT

\ * machine code routines improve speed a lot

\ calculate address of an element in the array
\ : ]VECTOR ( spr# -- addr) 4* VECTORS +  ;
HEX
CODE ]VECTOR ( spr# -- addr)
           0A24 ,            \ TOS 2 SLA,
           0224 , VECTORS ,  \ TOS VECTORS AI,
           NEXT,
           ENDCODE

\ Vector addition of current postion with offset
\ : VECT+ ( dx dy x y -- x' y') ROT +  -ROT +  SWAP ;

CODE VECT+ ( dx dy x y -- x' y')  \ 6x FASTER than Forth version
           C236 , \ *SP+ W MOV,
           A136 , \ *SP+ TOS A,
           A588 , \  W  *SP  A,
           NEXT,
           ENDCODE

\ SP.MOVE is critical for fast speed.
\ Uses V@ V! SPLIT VECT+ and FUSE CODE words
\ - V@ reads both X and Y bytes from VDP as an cell (
\   This is faster than using VC@ VC@  (405uS vs 256 uS)
\ - SPLIT breaks them into 2 ints on the stack
\ - VECT+ adds the offsets to X & Y
\ - FUSE puts them back together as 1 cell
\ - V! puts the single cell back into VDP ram
: SP.MOVE ( spr# -- )  ( DUP>R is defined in DIRSPRIT.F)
          DUP SP.Y DUP>R V@ SPLIT ( -- spr# x y ) ( r-- vaddr)
          ROT ]VECTOR 2@          ( -- x y dx dy) ( r-- vaddr)
          VECT+                   ( --  x' y')    ( r-- vaddr)
          FUSE R> V!
;

: ALL-SPRITES ( -- 1st last) 0 SPR# @ ;  \ syntax sugar :-)

\ translate in the mathematical sense
: TRANSLATE ( 1st last  -- ) 1+ SWAP DO  I SP.MOVE  LOOP ;

\ this works like motion in BASIC. It stores SIGNED chars
 : MOTION ( dy dx spr# -- ) ]VECTOR 2! ;

\ *NEW* Plural version defines motion for a range of sprites
: MOTIONS ( dy dx first last -- ) 1+ SWAP DO   2DUP I MOTION   LOOP 2DROP ;

