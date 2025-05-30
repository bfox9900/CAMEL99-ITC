\ multicolor.fth   for Camel99 Forth    2024 Brian Fox 
\ based on code from TI-Forth  

NEEDS CHARSET FROM DSK1.CHARSET 
HERE 

HEX 
800 CONSTANT PDT
300 CONSTANT SPRITE_ATTR
380 CONSTANT SPRITE_TAB 
\ 000 CONSTANT NAME_TAB 

\ Name vdp registers
HEX 
\ : VDPMODE     0 VWTR ;
\ : VDPCONTROL  1 VWTR ;
\ : NAMETABLE   2 VWTR ;
\ : COLORTABLE  3 VWTR ;
\ : PATTERNS    4 VWTR ;
\ : SPRITEATTR  5 VWTR ;
\ : SPRITEPATT  6 VWTR ;
\ : SCREENCOLOR 7 VWTR ;

: SETVDP2 ( n -- ) 
    0  0 VWTR
    0  2 VWTR
    0E 3 VWTR
    1  4 VWTR 
    6  5 VWTR
    3E0 836E !      \ VSPTR  routine
    0 837A C!
    DUP 83D4 C! 1 VWTR ; 

: HIDESCREEN ( --) 0B0 1 VWTR ;

: NIBBLES  ( n --) 2 RSHIFT 0FF SWAP DO  1+ I OVER  VC!  8 +LOOP ;

: MINIT    ( -- ) -1  18 0 DO  I NIBBLES  LOOP DROP ;

\ like call clear but cursor homes to 0,0 
: CLEAR    PDT 800 0 VFILL 0 0 AT-XY ;  \ erase char patterns 

HEX
: MULTICOLOR      
    HIDESCREEN
    MINIT 
    CLEAR 
    SPRITE_ATTR  80   0 VFILL    \ erase sprite table 
    SPRITE_TAB   20 0F4 VFILL    \   
    20 C/L!  
    300 C/SCR ! 
    0 TOPLN ! 
    3 VMODE !
    4  6 VWTR 
    11 7 VWTR
    0EB SETVDP2 
;

\ After MULTI mode, we need to restore character pattern in VDP
\ CHARSET reads in the default characters from GROM 

: TEXT   TEXT CHARSET PAGE ;

\ MCHAR for Camel99 Forth   Sept 14 2024 Brian fox 
\ Derived from code by Lee Stewart 
: >NAME    ( row col -- Vaddr ) 2/ SWAP 2/ SWAP >VPOS ;
: ]PATTERN ( row char -- Vaddr)  8* PDT +  SWAP 7 AND + ;

HEX 
: NYBBLES ( color Vaddr colorbyte -- colorbyte')   
    SWAP 1 AND 
    IF   F0 AND  
    ELSE 0F AND  SWAP 4 LSHIFT 
    THEN +  ;

: MCHAR  ( color col row --)
    2DUP >NAME VC@ ]PATTERN DUP>R VC@  NYBBLES  R> VC! ;

VARIABLE MCOLOR       \ holds active color 

: ENUM-COLOR  ( 0 <text> -- n) 
  DUP CREATE   , 1+  DOES> @ MCOLOR ! ;   

\ named TI-99 colors set MCOLOR when invoked 
0 ( set 1st color)
ENUM-COLOR TRANS    ENUM-COLOR BLACK    ENUM-COLOR GREEN    ENUM-COLOR LIME
ENUM-COLOR BLUE     ENUM-COLOR SKY      ENUM-COLOR RED      ENUM-COLOR CYAN
ENUM-COLOR RUST     ENUM-COLOR ORANGE   ENUM-COLOR YELLOW   ENUM-COLOR LEMON
ENUM-COLOR OLIVE    ENUM-COLOR MAGENTA  ENUM-COLOR GRAY     ENUM-COLOR WHITE
DROP

: MM.PLOT  ( x y -- ) MCOLOR @ -ROT  MCHAR ;

: XY@      ( -- x y) VROW 2@ ; 
: HLINE    ( n x y --) AT-XY 0 DO  MCOLOR @ XY@ MCHAR  VCOL 1+!  LOOP ;
: VLINE    ( n x y --) AT-XY 0 DO  MCOLOR @ XY@ MCHAR  VROW 1+!  LOOP ; 

DECIMAL 
\ Text macros make LINE clearer but run full speed 
: 2ROT ( d1 d2 d3 -- d2 d3 d1) 
       S" 2>R 2SWAP 2R> 2SWAP" EVALUATE ; IMMEDIATE 
\ : 4DUP ( a b c d -- a b c d a b c d) 
\       S" 3 PICK 3 PICK 3 PICK 3 PICK" EVALUATE ; IMMEDIATE 

 HEX 
 CODE 4DUP ( a b c d -- a b c d a b c d)
   C046 ,          \ SP  R1 MOV,  \ dup stack pointer    \  14
   0646 , C584 ,   \ TOS PUSH,    ( -- a b c d d)        \  28
   0226 , FFFA ,   \ SP -6 AI,    \ make some room       \  12
   C5B1 ,          \ R1 *+ *SP MOV,                      \  28
   C9B1 , 0002 ,   \ R1 *+ 2 (SP) MOV,                   \  30
   C9B1 , 0004 ,   \ R1 *+ 4 (SP) MOV,                   \  30
   NEXT,                                           \ TOTAL 142
 ENDCODE     

DECIMAL 
: LINE ( x1 y1 x2 y2 -- )
\ ANS version of Dr. Ting's recursive line.  R.I.P.
    4DUP  ROT - ABS -ROT - ABS           \ compute dx dy 
    MAX 2 < IF  2DROP MM.PLOT  EXIT THEN \ nothing do, get out  

    4DUP ROT 
    + 1+ 2/ >R    \ compute mid points 
    + 1+ 2/ R>           
    2DUP 2ROT RECURSE RECURSE ;

: MOVETO ( x y -- ) S" AT-XY" EVALUATE ; IMMEDIATE ( alias)
: LINETO ( x y -- ) 2DUP XY@ LINE MOVETO ;

HERE SWAP - DECIMAL . .( bytes)
