\ direct SPRITE control lexicon                BFox 2018
\ control by writing direct to VDP RAM
\ - simpler to understand.
\ - Less efficient when moving big no. of sprites

\ this version uses some machine code words for a more speed
\ July 2018  Removed DXY from Kernel and put machine code here

\ INCLUDE DSK1.TOOLS.F   \ for debugging
\ INCLUDE DSK1.ASM9900.F

NEEDS HCHAR  FROM DSK1.GRAFIX  \ must be in Graphics 1 mode

CR .( compiling direct sprite control)
HEX
8802   CONSTANT VDPSTS   \ vdp status register memory mapped address
300    CONSTANT SAT      \ sprite ATTRIBUTE table VDP RAM base address
20 4*  CONSTANT SATsize  \ size of the table, 32 sprites x 4 bytes/record
1F     CONSTANT MAX.SP   \ 32 sprites, 0 .. 31

\ hi speed memory addresses are actually variables
83D4   CONSTANT VDPR1    \ MEMORY for VDP Register 1, TI SYSTEM address

VARIABLE SPR#            \ holds the last sprite defined by SPRITE

\ Sprite descriptor table array CODE word is 2X faster, same size as Forth
\ *** SP.Y is the base address of the 4 byte sprite record
 CODE SP.Y ( char# -- vaddr) \ 4* SAT +
           0A24 ,         \  TOS  2 SLA,
           0224 , SAT ,   \  TOS SAT AI,
           NEXT,
           ENDCODE

CODE SP.X ( char# -- vaddr) \ 4* SAT + 1+
           0A24 ,         \  TOS  2 SLA,
           0224 , SAT ,   \  TOS SAT AI,
           0584 ,         \  TOS INC,
           NEXT,
           ENDCODE

\ These words are the fastest way access sprite decr. table
: SP.X@  ( spr# -- sprx) SP.X VC@ ;    \ fetch X
: SP.Y@  ( spr# -- spry) SP.Y VC@ ;    \ fetch Y

: SP.X!  ( n spr# -- ) SP.X VC! ;      \ store X
: SP.Y!  ( n spr# -- ) SP.Y VC! ;      \ store Y

: SP.PAT  ( n spr# -- vaddr) SP.X 1+ ; \ address of pattern byte
: SP.COLR ( n spr# -- vaddr) SP.X 2+ ; \ address of colr byte

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
\ (remove ?NDX if you need more speed, but you loose protection)
: POSITION  ( sprt# -- dx dy )  SP.Y V@ SPLIT ;
: LOCATE    ( dx dy sprt# -- ) ?NDX  >R FUSE R> SP.Y V! ;
: PATTERN   ( char sprt# -- )  ?NDX  SP.PAT VC! ;
: SP.COLOR  ( col sprt# -- )   ?NDX  >R 1- R> SP.COLR VC! ;

CODE DUP>R ( n -- ) ( r-- n)
          0647 , C5C4 ,    \ TOS RPUSH,
          NEXT,
          ENDCODE
.( .)
: SPRITE  ( char colr x y sp# -- ) \ create a SPRITE, sp# = 0..31
          ?NDX
          DUP>R                 \ copy spr# to rstack
          LOCATE                \ set screen position
          R@ SP.COLOR           \ set the sprite color
          R@ PATTERN            \ set the character pattern to use
          R>  SPR# @ MAX  SPR# ! ; \ update last spr#

\ like Extended BASIC Magnify
: MAGNIFY  ( mag-factor -- ) 
           VDPR1 C@ 0FC AND +  DUP 1 VWTR   VDPR1 C! ;

.( .)
HEX
\ simple machine code optimizers for DIST
CODE RDROP ( -- )
          05C7 ,    \ RP INCT,
          NEXT,
          ENDCODE

CODE RANGE? ( n n n -- n') \ FORTH: OR OR 8000 AND
          E136 ,          \ *SP+ TOS SOC,
          E136 ,          \ *SP+ TOS SOC,
          0244 , 8000 ,   \ TOS 8000 ANDI,
          NEXT,
          ENDCODE

CODE DXY  ( x2 y2 x1 y1 --- dx dy )   \ use by SP.DIST
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
\ factored DIST out from SPRDISTXY in TI-Forth
\ With new machine code words it is almost 2X faster
: DIST   ( x2 y2 x1 y1 -- distance^2) \ distance between 2 coordinates
          DXY  2DUP +                 \ sum the squares
          DUP>R                       \ push a copy
          RANGE?                      \ check out of range
          IF   RDROP 7FFF             \ throw away the copy, return 32K
          ELSE R>                     \ otherwise return the calculation
          THEN ;

: SP.DIST ( #1 #2 -- dist^2 )         \ distance between 2 sprites
          POSITION ROT POSITION DIST ;

: SP.DISTXY ( x y # -- dist^2 ) POSITION DIST ;

.( .)
\ text macros improve speed of coicidence detection
: 2(X^2)   ( n -- 2(n^2) S" DUP * 2*" EVALUATE ;  IMMEDIATE
: <=       ( n n -- ? )  S" 1- <" EVALUATE ; IMMEDIATE

\ VDP status bit set if any two sprites overlap
: COINCALL  ( -- ? ) VDPSTS C@ 20 AND ;

\ 0 means no coincidence
: COINC     ( sp#1 sp#2 tol -- ? )
            2(X^2) -ROT SP.DIST > ;
            
: COINCXY   ( dx dy sp# tol -- ? )
            2(X^2) >R    \ convert tolerance  to squares, push to rstack
            SP.DISTXY    \ compute sprite dist from dx dy
            R> <= ;      \ compare dist to tolerance

