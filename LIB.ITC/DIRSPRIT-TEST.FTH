CR .( direct SPRITE control lexicon  v2.5) \  Mar 23 2022 Brian Fox
\ control by writing direct to VDP RAM
\ Feb 2022   Added TABLE4:
\ Mar 2022   Removed distance calcs for sprites to DSK1.DISTANCE file
\            Added DXY code word for faster COINC.

NEEDS .S     FROM DSK1.LOWTOOLS
NEEDS HCHAR  FROM DSK1.GRAFIX  \ must be in Graphics 1 mode

HERE
CR .( Compiling direct sprite lexicon)
HEX
837B   CONSTANT VDPSTS   \ copy of vdp status register
300    CONSTANT SAT      \ sprite attribute table VDP RAM base address
20 4*  CONSTANT SATsize  \ size of the table, 32 sprites x 4 bytes/record
1F     CONSTANT MAX.SP   \ 32 sprites, 0 .. 31

\ hi speed memory addresses are actually variables
83D4   CONSTANT VDPR1    \ MEMORY for VDP Register 1, TI SYSTEM address

VARIABLE SPR#            \ holds the last sprite defined by SPRITE

: TABLE4: ( Vaddr -- )  \ create a table of 4 byte records
         CREATE    ,             \ compile base address into this word
        ;CODE ( n -- Vaddr')     \ RUN time
             0A24 ,  \ TOS 2 SLA,  ( tos = n x 4 )
             A118 ,  \ *W TOS ADD,
             NEXT,
ENDCODE

SAT     TABLE4: SP.Y
SAT 1+  TABLE4: SP.X
SAT 2+  TABLE4: SP.PAT
SAT 3 + TABLE4: SP.COLR

HEX
\ Operates directly on stack memory, speeds up LOCATE by 14%
 CODE FUSEXY ( x y spr# -- yyxx spr#)
      C036 , \ *SP+ R0 MOV,
      06C0 , \  R0  SWPB,
      A016 , \ *SP R0 ADD,
      C580 , \  R0 *SP MOV,
      NEXT,
      ENDCODE

\ finger trouble protection. Runtime array index test.
: ?NDX  ( n -- n ) MAX.SP OVER < ABORT" Bad SPR#" ;

CR .( .)
: DELALL  ( -- )
          1 ?MODE               \ test for graphics mode
          1 6 VWTR              \ vdp reg 6 = 1, puts ]PDT @ $800
          SAT SATsize BL VFILL  \ init the sprite desc. table with blanks
          SPR# OFF ;            \ #sprites=0

\ They CAN be index protected by the word ?NDX.
\ POSITION is a macro for more COINC speed
: POSITION  ( sprt# -- dx dy ) ( ?NDX) S" SP.Y V@ SPLIT" EVALUATE ; IMMEDIATE
: LOCATE    ( dx dy sprt# -- )   FUSEXY SP.Y V! ;  ( 532 uS)
: PATTERN   ( char sprt# -- )  ( ?NDX) SP.PAT VC! ;
: SP.COLOR  ( col sprt# -- )   ( ?NDX) SWAP 1- SWAP SP.COLR VC! ;
.( .)
: SPRITE  ( char colr x y sp# -- ) \ create a SPRITE, sp# = 0..31
          ?NDX
          DUP>R LOCATE             \ set screen position
          R@    SP.COLOR           \ set the sprite color
          R@    PATTERN            \ set the character pattern to use
          R> SPR# @ MAX  SPR# ! ;  \ update sprite counter variable

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
        DXY  R@  <
        SWAP R> < AND ;

: COINCXY   ( dx dy sp# tol -- ? )
        >R
        POSITION   ( -- x1 y1 x2  y2 )
        DXY  R@ <
        SWAP R> < AND ;

DELALL
HERE SWAP -
CR
CR .( Sprites used ) DECIMAL . .( bytes)
