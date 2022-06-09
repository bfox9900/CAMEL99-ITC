\ Direct Sprite motion control  BJF Jun 15 2018
\ lets you set the motion of each sprite in a CPU memory table called VECTORS

\ See: SPRITEDEMO for usage example

\ Aug 9 2018
\   -  Changed to accomodate 2@ 2! IN V2.0.21
\   -  2@ 2! were made ANS Compliant in 2.0.21
\   -  improved speed of SP.MOVE
\ Jan 2022  used DUP>R in SP.MOVE,  added TABLE4:

NEEDS SPRITE FROM DSK1.DIRSPRIT

HEX
: TABLE4: ( addr -- )    \ create a table of 4 byte records
     CREATE    ,
        ;CODE ( n -- addr)     \ RUN time
         0A24 ,     \ TOS 2 SLA,  ( TOS 4* )
         A118 ,     \ *W TOS ADD,
         NEXT,
ENDCODE

\ create array of direction vectors in dictionary
\ to hold x y vectors for each sprite (64 BYTES)
HERE  MAX.SP 1+ 4* ALLOT TABLE4: ]VECTOR

\ Vector addition of current postion with offset
\ : VECT+ ( dx dy x y -- x' y') ROT +  -ROT +  SWAP ;
HEX
CODE VECT+ ( dx dy x y -- x' y')  \ 6x FASTER than Forth version
           C236 , \ *SP+ W MOV,
           A136 , \ *SP+ TOS A,
           A588 , \  W  *SP  A,
           NEXT,
           ENDCODE

\ SP.MOVE is critical for fast speed.
\ Uses V@ V! SPLIT VECT+ and FUSE CODE words
\ - V@ (256 uS) reads both X and Y bytes from VDP as an cell (
\   This is faster than using VC@ VC@  (405uS)
\ - SPLIT breaks them into 2 ints on the stack
\ - VECT+ adds the offsets to X & Y
\ - FUSE puts them back together as 1 cell
\ - V! puts the single cell back into VDP ram
: SP.MOVE ( spr# -- )
          DUP SP.Y DUP>R V@ SPLIT ( -- spr# x y ) ( r-- vaddr)
          ROT ]VECTOR 2@ VECT+    ( --  x' y')    ( r-- vaddr)
          FUSE R> V!
;

: ALL-SPRITES ( -- 1st last) 0 SPR# @ ;  \ syntax sugar :-)

\ translate in the mathematical sense
: TRANSLATE ( 1st last  -- ) 1+ SWAP DO  I SP.MOVE  LOOP ;

\ This works like motion in BASIC. It stores SIGNED chars
\ The difference is that that dx dy values will be added to
\ the sprite's position each time you call SP.MOVE
 : MOTION ( dy dx spr# -- )
            >R  SWAP   ( -- vy vx)
            OVER 0<    ( -- vy vx ?)       \ vy is negative?
            IF 1+      ( -- vy vx' )       \ inc. vx
            THEN  R> ]VECTOR 2! ;

\ *NEW* Plural version defines same motion for a range of sprites
: MOTIONS ( dy dx first last -- )  1+ SWAP DO   2DUP I MOTION   LOOP 2DROP ;
DECIMAL
