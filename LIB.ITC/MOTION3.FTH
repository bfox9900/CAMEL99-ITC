\ Direct Sprite motion control

\ Version 3 uses a local sprite desc. table
\ - a vector table of y , x vectors
\ - a timer table of y , x  motion values 
\ - an AUX table used to count down time between motion

' SP.Y DROP  \ test that DIRSPRIT.F is loaded

\ create a motion array in HEAP memory
\ to hold x y vectors for each sprite (64 BYTES)
MAX.SP 1+ 2* MALLOC CONSTANT VECTORS   \ vector table in Heap memory
MAX.SP 1+ 4* MALLOC CONSTANT LSDT      \ local sprite desc. table

\ * machine code routines improve speed by 50%

\ calculate address of an element in the array
\ : ]VECTOR  ( spr# -- addr) 4* VECTORS +  ;
HEX
CODE ]VECTOR ( spr# -- addr)
           0A24 ,            \ TOS 2 SLA,
           0224 , VECTORS ,  \ TOS VECTORS AI,
           NEXT,
           ENDCODE

\ Vector addition of current postion with offset
\ : VECT+ ( dx dy x y -- x' y') ROT +  -ROT +  SWAP ;

CODE VECT+ ( dx dy x y -- x' y')  \ 6x FASTER
           C236 , \ *SP+ W MOV,
           A136 , \ *SP+ TOS A,
           A588 , \  W  *SP  A,
           NEXT,
           ENDCODE

: ALL-SPRITES  S" 0 SPR# @" EVALUATE ; IMMEDIATE

\ SP.MOVE gets speed from using V@ V! SPLIT VECT+ and FUSE
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

: TRANSLATE ( first last  -- ) 1+ SWAP DO  I SP.MOVE  LOOP ;

\ write all created sprite data to SDT at once. Nothing happens if SPR#=0
\ SP.WRITE is used to create auto-motion under multi-task control.
: SDT.UPDATE ( -- ) STAB SDT  SPR# @ 4*  VWRITE ;
\ this works like motion in BASIC. It stores SIGNED chars
 : MOTION ( dy dx spr# -- ) ]VECTOR 2! ;

\ *NEW* Plural version defines motion for a range of sprites
: MOTIONS ( dy dx first last -- ) 1+ SWAP DO   2DUP I MOTION   LOOP 2DROP ;

