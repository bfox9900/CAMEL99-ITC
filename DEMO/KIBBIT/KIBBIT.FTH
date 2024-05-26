\ KIBBIT.FTH   May 25 2024 

\ Originally written by:
\  Greg Goodwin ,  TI Hoosier's User Group, circa 1980s

\ Translated to Camel99 Forth 
NEEDS CASE  FROM DSK1.CASE 
NEEDS PLOT  FROM DSK1.GRAPHICS2 
NEEDS JOYST FROM DSK1.JOYST


HEX 
\ BASE address of Sprite table in VDP RAM, in GRAPHICS2 Mode 
3800 CONSTANT SSDT 

\ Camel99 Sprite library assumed GRAPHICS 1 mode.
\ We can simply make new Sprite control functions 

HEX
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

\ We don't actually need this word but it is traditional
( we could load up the fields manually) 

\ alternate
HEX 
CODE VC!++  ( char -- ) 
    06C4 ,        \ TOS SWPB,  
    D804 , 8C00 , \ TOS 8C00 @@ MOVB,  
    C136 ,        \ TOS POP, 
    NEXT, 
ENDCODE 

: SP.XY  ( x y # --) SP.Y VC!  VC!++ ;

DECIMAL 
: SPRITE ( colr char x y spr# -- ) 
    SP.Y VC!  VC!++ VC!++ VC!++ ; 

\ access the sprite desciptor table by ascii character value 
: ]SPDTAB  ( n - Vaddr) 8* SSDT + ;

\ Write data from a memory address into the sprite table 
: SPCHAR  ( data_addr char -- ) ]SPDTAB 8 VWRITE ;

\ ================ KIBBIT BEGINS HERE =====================
\ Initializing variables is different in ANS/ISO Forth 
  VARIABLE JOY     50 JOY !   \ joystick y position
  VARIABLE JRT     50 JRT !   \ joystick x position
  VARIABLE SELECT   \ selection. Inits to zero by default 

\ define the sprite shapes a give them a name
CREATE SHAPE1 ( -- addr ) 8050 , 2828 , 2828 , 1000 , 
CREATE SHAPE2 ( -- addr ) 8040 , 2424 , 2424 , 1800 ,
CREATE SHAPE3 ( -- addr ) 8040 , 201C , 0808 , 0800 , 

CREATE ARROW  ( -- addr ) F0E0 , E090 , 0804 , 0000 ,
CREATE ERASER ( -- addr ) 0010 , 387C , 3E1E , 0C00 ,

DECIMAL
   1 CONSTANT #1  \ familiar sprite name like BASIC 
   2 CONSTANT #2 

: INIT_TURTLE
   \ set bitmap mode before sprites
   GRAPHICS2         \ clears SDT
   \ initialize turtle sprite chars
   SHAPE1 138 SPCHAR
   SHAPE2 139 SPCHAR
   SHAPE3 140 SPCHAR

\   Y  X colr char #    
   22 22   5  140  1 SPRITE ;

\ HEX Outputs in TOS register
\ 01 = Fire
\ 02 = Left
\ 04 = Right
\ 08 = Down
\ 10 = Up
\ 0A = down+left
\ 0C = down+right
\ 12 = up+left
\ 14 = up+right


DECIMAL 
: KIBBIT
   INIT_TURTLE
   BEGIN
      1 JOYST CASE      \ y value
         04 OF -1 JOY +! ENDOF
         252 OF 1 JOY +! ENDOF
      ENDCASE
      CASE              \ x value
          04 OF  1 JRT +! ENDOF
         252 OF -1 JRT +! ENDOF
      ENDCASE
      18 = IF           \ fire button?
         1 SELECT +!    \ increment selection
      ENDIF
      SELECT @ CASE
         0 OF DRAW 138 1 SP.PAT ENDOF
         1 OF UNDRAW 139 1 SPRPAT ENDOF
         2 OF DTOG 140 1 SPRPAT ENDOF
         3 OF 0 SELECT ! ENDOF
      ENDCASE
      JRT @ JOY @ 1 SPRPUT    \ move turtle to current position
      JRT @ JOY @ DOT         \ draw/undraw/toggle a dot at current position
      ?KEY 13 = IF      \ CR?
         INIT_TURTLE    \ set bitmap mode/re-initialize turtle to clear screen
      ENDIF
      ?KEY 32 =         \ <space>?
   UNTIL
   TEXT ;               \ back to text mode
KIBBIT            \ start program