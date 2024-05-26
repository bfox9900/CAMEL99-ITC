\ SPRITESII.FTH  re-think on sprite functions   May 2024 Brian Fox

NEEDS HCHAR FROM DSK1.GRAFIX 

CR .( *WARNING* SPRITE args are in TI-FORTH order )

HERE 
HEX
837B   CONSTANT VDPSTS   \ copy of vdp status register
83D4   CONSTANT VDPR1    \ MEMORY for VDP Register 1, TI SYSTEM address
300    CONSTANT SAT      \ sprite attribute table VDP RAM base address

20 4*  CONSTANT SATsize  \ size of the table, 32 sprites x 4 bytes/record
1F     CONSTANT MAX.SP   \ 32 sprites, 0 .. 31
       VARIABLE SPR#     \ holds the last sprite defined by SPRITE

\ A Sprite is controlled by a record of four bytes in VDP RAM.  
\ That's all there is to it. 
\ These words take a Sprite no. and return the VDP address 
\ of the sprite's data field.
\ Think of them like "byte" variables but in VDP RAM.
\ "fetch" them with VC@   
\ "store" them with VC! 
: SP.Y     ( spr# -- Vaddr) 4* SAT + ; 
: SP.X     ( spr# -- Vaddr) 4* [ SAT 1+ ] LITERAL + ; 
: SP.PAT   ( Spr# -- Vaddr) 4* [ SAT 2+ ] LITERAL + ; 
: SP.COLOR ( spr# -- Vaddr) 4* [ SAT 3 + ] LITERAL + ; 

\ add a byte value to a sprite field 
: SP.+!     ( byte Vaddr -- ) DUP VC@ + SWAP VC! ;

HEX 
CODE VC!++  ( char -- ) 
    06C4 ,        \ TOS SWPB,  
    D804 , 8C00 , \ TOS 8C00 @@ MOVB,  
    C136 ,        \ TOS POP, 
    NEXT, 
ENDCODE 

: LOCATE  ( x y # --) SP.Y VC!  VC!++ ;

: POSITION  ( sprt# -- dx dy ) S" SP.Y V@ SPLIT" EVALUATE ; IMMEDIATE

\ We don't actually need this word but it is traditional
( we could load up the fields manually) 

DECIMAL 
: SPRITE ( colr char x y spr# -- )
  SP.Y VC!  VC!++ VC!++ VC!++ ; 

\ like Extended BASIC Magnify but parameters are 1 less
HEX
: MAGNIFY  ( mag-factor -- ) VDPR1 C@ 0FC AND +  DUP 1 VWTR  VDPR1 C! ;

\ VDP status bit set if any two sprites overlap
: COINCALL  ( -- ? ) VDPSTS C@ 20 AND ;

\ 0 in all these words means no coincidence
: COINC  ( spr#1 spr#2 tol -- ?)
    >R
    POSITION ROT POSITION ( -- x1 y1 x2  y2 )
     ROT - ABS R@ <
    -ROT - ABS R> <  AND
;

: COINCXY ( x1 y1 sp# tol -- ? )
    >R
    POSITION ( -- x1 y1 x2  y2 )
     ROT - ABS R@ <
    -ROT - ABS R> < AND
;

HERE SWAP -
CR
CR .( Sprites used ) DECIMAL . .( bytes)
