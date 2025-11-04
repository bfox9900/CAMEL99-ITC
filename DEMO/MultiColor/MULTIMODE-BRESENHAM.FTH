\ multicolor.fth   for Camel99 Forth    2024 Brian Fox
\ based on code from TI-Forth

NEEDS .S      FROM DSK1.TOOLS   \ debugging
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
    SPRITE_ATTR  80   0 VFILL    \ erase sprite table
    SPRITE_TAB   20 0F4 VFILL    \
    20 C/L!
    300 C/SCR !
    0 TOPLN !
    3 VMODE !
    4  6 VWTR
    11 7 VWTR
    0EB SETVDP2
    CLEAR
;

\ After MULTI mode, we need to restore character pattern in VDP
\ CHARSET reads in the default characters from GROM

: TEXT   TEXT CHARSET PAGE ;

\ MCHAR for Camel99 Forth   Sept 14 2024 Brian fox
\ Derived from code by Lee Stewart
HEX
CODE >NAME ( col row -- Vaddr)
    C076 , \ *SP+ R1 MOV,
    0911 , \  R1   1 SRL,  \ 2/
    0914 , \  TOS  1 SRL,  \ 2/
    0A54 , \  TOS  5 SLA,  \ 32*
    A101 , \  R1 TOS ADD,
    NEXT,
ENDCODE

CODE ]PATTERN ( row char -- Vaddr)  \ address of color byte
    0A34 ,          \ TOS  3 SLA,   \ char index 8*
    0224 , PDT ,    \ TOS PDT AI,   \ add the base address
    C0B6 ,          \ *SP+ R2 MOV,  \ row -> R2
    0242 , 0007 ,   \ R2  7  ANDI,  \ row 8 MOD (faster with AND)
    A102 ,          \ R2  TOS ADD,  \ add pattern offset
    NEXT,
ENDCODE

HEX
CODE NYBBLES ( color column colorbyte -- colorbyte')
    C0B6 ,          \ *SP+ R2 MOV,      \ column to R2
    C0F6 ,          \ *SP+ R3 MOV,      \ new color to R3
    0243 , 000F ,   \ R3  0F ANDI,     \ insure color is legal
    0242 , 0001 ,   \ R2  1  ANDI,
    1303 ,          \ NE IF,
    0244 , 00F0 ,   \        TOS F0 ANDI,
    1003 ,          \ ELSE,
    0244 , 000F ,   \        TOS 0F ANDI,
    0A43 ,          \ R3  4 SLA,
                    \ ENDIF,
    A103 ,          \ R3 TOS ADD,
    NEXT,
ENDCODE

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
: HLINE    ( n x y --) AT-XY 0 DO MCOLOR @ XY@ MCHAR  VCOL 1+! LOOP ;
: VLINE    ( n x y --) AT-XY 0 DO MCOLOR @ XY@ MCHAR  VROW 1+!  LOOP ;
DECIMAL

\ *************************************************************
\ bresenham from rosettacode.com

\ libraries needed by Camel99 forth
NEEDS .S     FROM DSK1.TOOLS
NEEDS DEFER  FROM DSK1.DEFER
NEEDS VALUE  FROM DSK1.VALUES

\ these words change based on the input coordinates
DEFER STEEP         \ noop or swap
DEFER YSTEP         \ 1+ OR 1-

\ replaced local variables with VALUEs for Camel99 Forth
0 VALUE Y
0 VALUE DY
0 VALUE DX

: 2OVER  3 PICK  3 PICK ;

CODE NOOP  NEXT, ENDCODE

: LINE ( x0 y0 x1 y1  -- )
  ROT SWAP   ( x0 x1 y0 y1 )

\ test if line is vertical or horizontal ?
  2DUP  - ABS >R
  2OVER - ABS R> <
  IF         ['] SWAP \ SWAP USE OF X AND Y
  ELSE 2SWAP ['] NOOP
  THEN       IS STEEP \ change action of STEEP

  ( Y0 Y1 X0 X1 )
  2DUP >
  IF SWAP 2SWAP SWAP  \ ENSURE X1 > X0
  ELSE    2SWAP
  THEN

  ( x0 x1 y0 y1 )
  2DUP >         \ is Y descending
  IF   ['] 1-    \ choose a decrementer
  ELSE ['] 1+    \ choose the incremter
  THEN IS YSTEP  \ set YSTEP's action

  OVER - ABS       TO DY  TO Y
  SWAP 2DUP - DUP  TO DX
  2/ ROT 1+ ROT
  ( ERROR X1+1 X0 )
  DO  I Y STEEP MM.PLOT
      DY -
      DUP 0<
      IF   Y YSTEP TO Y
           DX +
      THEN
  LOOP
  DROP ;

: MOVETO ( x y -- ) S" AT-XY" EVALUATE ; IMMEDIATE ( alias)
: LINETO ( x y -- ) 2DUP XY@ LINE MOVETO ;

HERE SWAP - DECIMAL . .( bytes)
