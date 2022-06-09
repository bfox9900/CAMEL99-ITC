\ direct SPRITE control lexicon  v2              BFox Mar 2022
\ control by writing direct to VDP RAM
\ Less efficient when moving big no. of sprites

\ Feb 2022   Added TABLE4:
\ Mar 2022   Went back to original code for COINC and COINCXY
\            Removed distance computation word. See DISTANCE.FTH

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
         CREATE    ,
        ;CODE ( n -- Vaddr')
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
\ Run DELALL before using sprites
: DELALL  ( -- )
          1 ?MODE               \ test for graphics mode
          1 6 VWTR              \ puts ]PDT @ $800
          SAT SATsize BL VFILL  \ init the sprite table with blanks
          SPR# OFF ;

\ The following words are named like Extended BASIC
\ ?NDX protection is removed for speed. Un-comment if you want it
: POSITION  ( sprt# -- dx dy ) ( ?NDX)
  S" SP.Y V@ SPLIT" EVALUATE ; IMMEDIATE

: LOCATE    ( dx dy sprt# -- )   FUSEXY SP.Y V! ;  ( 532 uS)
: PATTERN   ( char sprt# -- )  ( ?NDX) SP.PAT VC! ;
: SP.COLOR  ( col sprt# -- )   ( ?NDX) SWAP 1- SWAP SP.COLR VC! ;
.( .)
: SPRITE  ( char colr x y sp# -- )
          ?NDX
          DUP>R LOCATE
          R@    SP.COLOR
          R@    PATTERN
          R> SPR# @ MAX  SPR# ! ;

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
