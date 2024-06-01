\ SPRITES2.FTH  works with GRAPHICS1 or GRAPHICS2    May 29 2024 BFox 

HERE 
HEX 
837A CONSTANT SPR#    \ SYSTEM byte variable: number of sprites in motion 
837B CONSTANT VDPSTS  \ copy of vdp status register

\ write to VDP current address, address increments automatically
\ : VC!++  ( char -- ) 8C00 C! ; \ moved to GRAPHICS2

\ A Sprite is controlled by a record of four bytes in VDP RAM.  
\ In Forth they are like "byte" variables but in VDP RAM.
\ "fetch" them with VC@, "store" them with VC! 

\ These words take a Sprite no. and return the VDP address of a sprite record 
: SP.Y     ( spr# -- Vaddr) 4* SAT + ; 
: SP.X     ( spr# -- Vaddr) 4* [ SAT 1+ ] LITERAL + ; 
: SP.PAT   ( Spr# -- Vaddr) 4* [ SAT 2+ ] LITERAL + ; 
: SP.COLOR ( spr# -- Vaddr) 4* [ SAT 3 + ] LITERAL + ; 
: SP.SHAPE ( addr len spr# -- ) 8* SPT + SWAP VWRITE ; 

\ *NEW*  parameter order changed. Matches TI Forth, FbForth 
: SPRITE ( colr char x y spr# -- )
    DUP>R SP.Y VC!  VC!++ VC!++ VC!++ 
    R> SPR# C@ MAX  SPR# C! ;  \ update sprite counter variable

\ BASIC style commands 
: POSITION ( sprt# -- x y ) SP.Y V@ SPLIT ; \ 2X faster using V@ 
: LOCATE   ( x y # --) SP.Y VC!  VC!++ ;

DECIMAL 
: DELSPR   ( spr# --)  SP.Y  4 BL VFILL ;
: DELALL   ( -- ) SAT 32 4* BL VFILL   0 SPR# C! ;

HEX
\ like Extended BASIC Magnify but parameters are 1 less
: MAGNIFY  ( mag-factor -- ) VDPR1 C@ 0FC AND +  DUP 1 VWTR  VDPR1 C! ;
: COINCALL ( -- ? ) VDPSTS C@ 20 AND ;

\ compute absolute value of difference between two sprites
HEX
CODE |DXY|  ( x y x2 y2 -- dx dy)
C076 , \  *SP+  R1 MOV, \ x2
6136 , \  *SP+ TOS SUB, \ y2=y2-y
0744 , \       TOS ABS,
6581 , \   R1  *SP SUB, \ x=x-x2
0756 , \       *SP ABS,
NEXT,
ENDCODE

\ return true if any two sprites overlap
: COINC ( spr#1 spr#2 tol -- ?)
    >R  POSITION ROT POSITION |DXY| 
    R@ <  SWAP R> < AND ;
 
: COINCXY   ( x y sp# tol -- ? )
    >R POSITION |DXY|  R@ <  SWAP R> < AND ;

DELALL 
CR .( sprite table initialized) 

CR HERE SWAP - DECIMAL . .( bytes)
HEX
