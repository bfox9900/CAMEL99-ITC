\ KIBBIT.FTH   May 25 2024 

\ Originally written by:
\  Greg Goodwin ,  TI Hoosier's User Group, circa 1980s

\ Translated to Camel99 Forth 
NEEDS CASE   FROM DSK1.CASE 
NEEDS PLOT   FROM DSK1.GRAPHICS2 
\ NEEDS SPRITE FROM DSK1.SPRITES2   ( for use with Graphics2)
NEEDS JOYST  FROM DSK1.JOYST


HEX 
\ BASE address of Sprite table in VDP RAM, in GRAPHICS2 Mode 
SSDT CONSTANT SAT

\ access the sprite desciptor table by ascii character value 
: ]SPDTAB  ( n - Vaddr) 8* SSDT + ;

\ Write data from a memory address into the sprite table 
: SPCHAR  ( data_addr char -- ) ]SPDTAB 8 VWRITE ;

\ ================ KIBBIT BEGINS HERE =====================
\ Initializing variables is different in ANS/ISO Forth 
  VARIABLE JOY     50 JOY !   \ joystick y position
  VARIABLE JRT     50 JRT !   \ joystick x position
  VARIABLE SELECT   \ selection. Inits to zero by default 

\ define the sprite shape data but give them a name
CREATE $PENCIL ( -- addr ) F0E0 , E090 , 0804 , 0000 ,
CREATE $ERASER ( -- addr ) 0010 , 387C , 3E1E , 0C00 ,
\ CREATE $BRUSH  ( -- addr ) 8080 , C060 , 6010 , 0800 ,
CREATE $ROLLER ( -- addr ) 007E , 7E02 , 1E10 , 1010 ,

DECIMAL
   1 CONSTANT #1  \ familiar sprite name like BASIC 
HEX 
CODE VC!++  ( char -- ) 
    06C4 ,        \ TOS SWPB,  
    D804 , 8C00 , \ TOS 8C00 @@ MOVB,  
    C136 ,        \ TOS POP, 
    NEXT, 
ENDCODE 

\ : VC!++  ( c --)  8C00 C! ;
\ : V!++   ( n --)  SPLIT VC!++ VC!++ ;

DECIMAL 
: SP.Y     ( spr# -- Vaddr) 4* SAT + ; 
: SP.X     ( spr# -- Vaddr) 4* [ SAT 1+ ] LITERAL + ; 
: SP.PAT   ( Spr# -- Vaddr) 4* [ SAT 2+ ] LITERAL + ; 
: SP.COLOR ( spr# -- Vaddr) 4* [ SAT 3 + ] LITERAL + ; 

: SPRITE    ( colr char x y spr# -- )  SP.Y VC!  VC!++ VC!++ VC!++ ; 
: LOCATE    ( x y # --) SP.Y VC!  VC!++ ;
: POSITION  ( sprt# -- dx dy ) SP.Y V@ SPLIT ; 

: INIT_KIBBIT
   \ set bitmap mode before sprites
   GRAPHICS2        
   \ initialize turtle sprite chars
   $PENCIL 138 SPCHAR
   $ERASER 139 SPCHAR
   $ROLLER 140 SPCHAR

\   Y  X colr char #    
   22 22   5  140  1 SPRITE ;

: TEST  INIT_KIBBIT  BEGIN ?TERMINAL UNTIL TEXT ;   

\ JOYST Output decoding 
HEX 
 01 CONSTANT Fire
 02 CONSTANT Left
 04 CONSTANT Right
 08 CONSTANT Down
 10 CONSTANT Up
 0A CONSTANT Down/left
 0C CONSTANT Down/right
 12 CONSTANT Up/left
 14 CONSTANT Up/right

DECIMAL 
\ these words alter the sprite position by changing the fields in VDP memory 
: GOUP    -1 #1 SP.Y VC+! ; 
: GODOWN   1 #1 SP.Y VC+! ;
: GOLEFT  -1 #1 SP.X VC+! ;
: GORIGHT  1 #1 SP.X VC+! ;

: READ_JOYSTICK 
    0 JOYST 
    CASE 
        Left  OF  GOLEFT         ENDOF
        Right OF  GORIGHT        ENDOF
        Down  OF  GODOWN         ENDOF
        Up    OF  DOUP           ENDOF

    Down/left OF  GODOWN GOLEFT  ENDOF 
   Down/right OF  GODOWN GORIGHT ENDOF 
    Up/left   OF  GOUP   GOLEFT  ENDOF 
    Up/right  OF  GOUP   GORIGHT ENDOF 
    ENDCASE  
;

: DOPENCIL   PENICL IS STYLUS  $PENCIL 138 SPCHAR ; 
: DOERASE    ERASER IS STYLUS ;
: ;
 
: READ_KEYBOARD 
    KEY? 
    CASE
      [CHAR] D OF  DOBRUSH       ENDOF 
      [CHAR] E OF  DOERASE       ENDOF 
      [CHAR] T OF  DOTOGGLE      ENDOF 
      [CHAR] X OF  INIT_KIBBIT   ENDOF 
    ENDCASE   
;

: KIBBIT
   INIT_TURTLE
   BEGIN
     READ_JOYSTICK 
     READ_KEYBOARD 
     1 POSITION PLOT  

     ?TERMINAL   \ test for break key 
   UNTIL
   TEXT ;         \ back to text mode

KIBBIT            \ start program