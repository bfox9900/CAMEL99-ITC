\ direct SPRITE control lexicon  v2              BFox Aug 6 2020
\ control by writing direct to VDP RAM
\ - simpler to understand.
\ - Less efficient when moving big no. of sprites

\ this version uses some machine code words for a more speed
\ July 2018  Removed DXY from Kernel and put machine code here
\ July 2019  Simplfied DIST for 20% speedup.
\ Aug 2020   Re-wrote COINCXY COINC to be faster
\            Removed SP.X@, SP.Y@.  Use VC@ with them, faster.
\ Feb 2021   Added FUSEXY to speed up locate
\ Feb 2022   Added TABLE4:
\ Mar 2022   Went back to original code for COINC and COINCXY
\            Simplified with -ROT

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
\ INIT SPRITES: You must run DELALL before using sprites*
: DELALL  ( -- )
          1 ?MODE               \ test for graphics mode
          1 6 VWTR              \ vdp reg 6 = 1, puts ]PDT @ $800
          SAT SATsize BL VFILL  \ init the sprite desc. table with blanks
          SPR# OFF ;            \ #sprites=0

\ The following words are named like Extended BASIC
\ They are index protected by the word ?NDX. For more speed use SP.Y etc.
: POSITION  ( sprt# -- dx dy ) ( ?NDX) SP.Y V@ SPLIT ;
\ evolution of LOCATE
\ : LOCATE    ( dx dy sprt# -- ) >R FUSE R> SP.Y V! ;     ( 724 uS)
\ : LOCATE    ( dx dy sprt# -- ) -ROT FUSE SWAP SP.Y V! ; ( 639 uS)
: LOCATE    ( dx dy sprt# -- )   FUSEXY SP.Y V! ;         ( 532 uS)
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

\ Complete re-work of TI-FORTH code
HEX
CODE RANGE? ( n n n -- n') \ FORTH: OR OR 8000 AND
          E136 ,          \ *SP+ TOS SOC,
          E136 ,          \ *SP+ TOS SOC,
          0244 , 8000 ,   \ TOS 8000 ANDI,
          NEXT,
          ENDCODE

CODE DXY  ( x2 y2 x1 y1 --- dx dy )   \ Common factor for SP.DIST,SP.DISTXY
          C036 ,  \ *SP+ R0 MOV,      \ pop x1->R0
          6136 ,  \ *SP+ TOS SUB,     \ pop y1-y2->tos
          6016 ,  \ *SP  R0 SUB,      \ x1-x2->R0, keep stack location
          C0C4 ,  \  TOS R3 MOV,      \ dup tos in r3, MPY goes into R4
          38C4 ,  \  TOS R3 MPY,      \ r3^2, result->r4 (tos)
          C080 ,  \  R0  R2  MOV,     \ dup R0
          3802 ,  \  R2  R0  MPY,     \ RO^2
          C581 ,  \  R1 *SP  MOV,     \ result to stack
          NEXT,                       \ 16 bytes
          ENDCODE
.( .)

\ New version is 2X faster than TI-Forth code
: DIST   ( x2 y2 x1 y1 -- distance^2) \ distance between 2 coordinates
          DXY  2DUP +                 \ sum the squares
          DUP RANGE?                  \ check if out of range
          IF  DROP 7FFF               \ throw away the copy, return 32K
          THEN ;                      \ otherwise return the calculation

: SP.DISTXY ( x   y  spr# -- dist^2 ) SP.Y V@ SPLIT DIST ;
: SP.DIST   ( spr#1 spr#2 -- dist^2 )
        SP.Y V@ SPLIT  ROT  SP.Y V@ SPLIT  DIST ;
: SP.DISTXY ( x y spr# -- dist^2 )    SP.Y V@ SPLIT DIST ;
: SP.DIST   ( spr#1 spr#2 -- dist^2 ) SP.Y V@ SPLIT ROT SP.DISTXY ;

\ 0 in all these words means no coincidence
\ VDP status bit set if any two sprites overlap
: COINCALL  ( -- ? ) VDPSTS C@ 20 AND ;

: COINC ( spr#1 spr#2 tol -- ?)
        COINCALL
        IF
          >R
          POSITION ROT POSITION  ( -- x1 y1 x2  y2 )
          ROT - ABS R@ <
         -ROT - ABS R> <  AND
          EXIT          \ get out
        THEN            \ if coincall=true then do this
        2DROP DROP      \ drop parameters
        FALSE           \ return false flag
 ;

\ : TESTC   TMR@  0 1 8 COINC TMR@ NIP - . ;  \ 1406 uS

 : COINCXY   ( dx dy sp# tol -- ? )
        COINCALL
        IF >R
           POSITION   ( -- x1 y1 x2  y2 )
           ROT - ABS R@ <
          -ROT - ABS R> < AND
           EXIT           \ get out
        THEN              \ if coincall=true then do this
        2DROP 2DROP    \ drop parameters
        FALSE          \ return false flag
 ;

HERE SWAP -
CR
CR .( Sprites used ) DECIMAL . .( bytes)
