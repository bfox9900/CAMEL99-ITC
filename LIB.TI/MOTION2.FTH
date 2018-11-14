\ Direct Sprite motion control  BJF Jun 15 2018
\ This version uses separate X and Y values, not a vectors

INCLUDE DSK1.TOOLS.F
INCLUDE DSK1.ASM9900.F
INCLUDE DSK1.DIRSPRIT.F


' SP.Y DROP  \ test that DIRSPRIT.F is loaded


\ create a motion array in HEAP memory
\ to hold x and y vector for each sprite (64 CELLS)
MAX.SP CELLS 1+ MALLOC CONSTANT VECTORS
MAX.SP CELLS 1+ MALLOC CONSTANT TMRS     \ control motion timing
MAX.SP CELLS 1+ MALLOC CONSTANT SPTAB    \ replica of VDP SDT

\ calculate address of an X,Y pair in the VECTOR array
\ : ]MOTION   ( spr# -- addr) 4* VECTORS +  ;
HEX
CODE ]MOTION ( spr# -- addr)
           TOS 2 SLA,
           TOS VECTORS AI,
           NEXT,
           ENDCODE

CODE ]TRANSLAT ( I -- )
     TOS W MOV,           \ index for byte array
     TOS 1 SLA            \ index for cell array
     VECTORS (TOS) SPRITES (W) ADDB,
     TOS POP,
     NEXT,
     ENDCODE


: ALL-SPRITES  S" 0  SPR# @" EVALUATE ; IMMEDIATE

: TRANSLATE ( first last  -- ) 1+ SWAP DO  I ]TRANSLAT  LOOP ;

\ this works like motion in BASIC. It stores SIGNED chars
\ : MOTION ( dy dx spr# -- ) >R >SCHAR  SWAP >SCHAR R> ]MOTION 2! ;
 : MOTION ( dy dx spr# -- ) >R SWAP R> ]MOTION 2! ;

\ *NEW* Plural version defines motion for a range of sprites
: MOTIONS ( dx dy first last -- ) 1+ SWAP DO   2DUP I MOTION   LOOP 2DROP ;

