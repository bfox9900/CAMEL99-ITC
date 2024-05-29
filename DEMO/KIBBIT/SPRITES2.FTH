\ SPRITESII.FTH  re-think on sprite functions   May 2024 Brian Fox

NEEDS GRAPHICS2 FROM DSK1.GRAPHICS2 

SSDT DROP   \ aborts if this constant not present 

CR .( *WARNING* SPRITE args are in TI-FORTH order )

HERE 
HEX 
\ BASE address of Sprite descriptor table in VDP RAM, in GRAPHICS2 Mode 

837B   CONSTANT VDPSTS   \ copy of vdp status register
83D4   CONSTANT VDPR1    \ MEMORY for VDP Register 1, TI SYSTEM address
SSDT   CONSTANT SAT      \ sprite attribute table VDP RAM base address

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

DECIMAL 
: SPRITE ( colr char x y spr# -- )  SP.Y VC!  VC!++ VC!++ VC!++ ; 
: LOCATE  ( x y # --) SP.Y VC!  VC!++ ;
: POSITION  ( sprt# -- dx dy ) S" SP.Y V@ SPLIT" EVALUATE ; IMMEDIATE

\ access the sprite desciptor table by ascii character value 
: ]SPDTAB  ( n - Vaddr) 8* SDT + ;

\ Write 8 bytes from a memory address into the sprite table 
: SPCHAR  ( data_addr char -- ) ]SPDTAB 8 VWRITE ;

\ like Extended BASIC Magnify but parameters are 1 less
HEX
: MAGNIFY  ( mag-factor -- ) VDPR1 C@ 0FC AND +  DUP 1 VWTR  VDPR1 C! ;

\ VDP status bit set if any two sprites overlap
: COINCALL  ( -- ? ) VDPSTS C@ 20 AND ;
 
HEX
CODE DXY   ( x y x2 y2 -- dx dy)
C076 , \  *SP+  R1 MOV, \ x2
6136 , \  *SP+ TOS SUB, \ y2=y2-y
0744 , \       TOS ABS,
6581 , \   R1  *SP SUB, \ x=x-x2
0756 , \       *SP ABS,
NEXT,
ENDCODE
 
\ ?=0 means no coincidence
: COINC ( spr#1 spr#2 tol -- ?)
        >R
        POSITION ROT POSITION ( -- x1 y1 x2 y2 )
        DXY  R@ <  SWAP R> < AND ;
 
: COINCXY   ( dx dy sp# tol -- ? )
        >R
        POSITION   ( -- x1 y1 x2  y2 )
        DXY  R@ <  SWAP R> < AND ;

HERE SWAP - CR .( Sprites2 used ) DECIMAL . .( bytes)
