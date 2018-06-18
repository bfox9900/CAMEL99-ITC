\ Direct Sprite motion control  BJF Jun 15 2018

' SP.Y DROP  \ test that DIRSPRIT.F is loaded

\ create a motion array in HEAP memory
\ to hold x y vectors for each sprite (64 BYTES)
CREATE VECTORS MAX.SP 1+ 4* ALLOT

\ * machine code routines improve speed by 50%

\ calculate address of an element in the array
\ : ]MOTION   ( spr# -- addr) 4* VECTORS +  ;
HEX
CODE ]MOTION ( spr# -- addr)
           0A24 ,            \ TOS 2 SLA,
           0224 , VECTORS ,  \ TOS VECTORS AI,
           NEXT,
           ENDCODE

\ VECTOR ADD and fuse into a sprite x,y location
\ : VECT+ ( dx dy x y -- x' y') ROT +  -ROT +  SWAP ;
CODE VECT+ ( dx dy x y -- u)  \ 6x FASTER
           C236 , \ *SP+ W MOV,
           A136 , \ *SP+ TOS A,
           A588 , \  W  *SP  A,
           NEXT,
           ENDCODE

: ALL-SPRITES  S" 0 SPR# @" EVALUATE ; IMMEDIATE

: SP.MOVE ( spr# -- )  ( DUP>R is defined in DIRSPRIT.F)
          DUP ]MOTION 2@ ( dx dy )
          ROT SP.Y DUP>R V@ SPLIT ( dx dy x y )
          VECT+  R@ VC!  R> 1+ VC! ;

 : TRANSLATE ( first last  -- ) 1+ SWAP DO  I SP.MOVE  LOOP ;

\ this works like motion in BASIC. It stores SIGNED chars
\ : MOTION ( dy dx spr# -- ) >R >SCHAR  SWAP >SCHAR R> ]MOTION 2! ;
 : MOTION ( dy dx spr# -- ) >R SWAP R> ]MOTION 2! ;

\ *NEW* Plural version defines motion for a range of sprites
: MOTIONS ( dx dy first last -- ) 1+ SWAP DO   2DUP I MOTION   LOOP 2DROP ;

