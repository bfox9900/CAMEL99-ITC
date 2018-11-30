\ direct SPRITE control lexicon
\ control by writing direct to VDP RAM
\ - simpler to understand.
\ - Less efficient when moving big no. of sprites

\ this version uses inline code words for a little more speed
\ INCLUDE DSK1.TOOLS.F
INCLUDE DSK1.GRAFIX.F
INCLUDE DSK1.CODE.F

HEX
8802   CONSTANT VDPSTS   \ vdp status register memory mapped address
300    CONSTANT SDT      \ sprite descriptor table address in VDP RAM
20 4*  CONSTANT SDTsize  \ size of the table, 32 sprites x 4 bytes/record
1F     CONSTANT MAX.SP   \ 32 sprites, 0 .. 31
8364   CONSTANT SPR#     \ sprite counter is kept in FAST RAM
                         \ TI SYSTEM defined address

\ Sprite descriptor table array CODE word is 2X faster
CODE ]SDT ( char# -- sdt[n])
           0A24 ,         \  TOS  2 SLA,
           0224 , SDT ,   \  TOS SDT AI,
           NEXT,
ENDCODE

\ named fields for sprite record.  Usage:  12 ]SDT ->PAT
: ->PAT   ( addr -- addr+2) POSTPONE 2+  ; IMMEDIATE
: ->COLR  ( addr -- addr+3) POSTPONE 3 POSTPONE + ; IMMEDIATE

\ faster access to Sprite descriptor table X,Y bytes than using
\ LOCATE and POSITION
\ ** NO sprite# limits, be careful **

\ using text MACROs here for speed improvement
\ returns VDP sprite Decriptor X address
: SP.X   ( spr# -- vdp_addr) ]SDT 1+ ; IMMEDIATE

\ returns VDP sprite Decriptor Y address
: SP.Y   ( spr# -- vdp_addr) ]SDT ;  IMMEDIATE

: SP.X@  ( spr# -- sprx) SP.X VC@ ;    \ fetch X
: SP.Y@  ( spr# -- spry) SP.Y VC@ ;       \ fetch Y

: SP.X!  ( n spr# -- ) SP.X VC! ;      \ store X
: SP.Y!  ( n spr# -- ) SP.Y VC! ;         \ store Y

\ compile time literal address compiler gives maximum speed
\ Usage:  99 [ 5 SP.X ]!
\ : ]!     ( addr -- ) POSTPONE ] POSTPONE LITERAL POSTPONE VC! ; IMMEDIATE
\ : ]@     ( addr -- ) POSTPONE ] POSTPONE LITERAL POSTPONE VC@ ; IMMEDIATE

\ finger trouble protection. Runtime array index test.
: ?NDX  ( n -- n ) MAX.SP OVER < ABORT" Bad SPR#" ;
\ : ?SPR# ( n -- n ) DUP SPR# @ > ABORT" undefined SPR#" ;

\ INIT SPRITES: You must run DELALL before using sprites*
: DELALL  ( -- )
          1 ?MODE               \ test for graphics mode
          1 6 VWTR              \ vdp reg 6 = 1, puts ]PDT @ $800
          SDT SDTsize BL VFILL  \ init the sprite desc. table with blanks
          SPR# OFF ;            \ #sprites=0

\ The following words are named like Extended BASIC
\ (remove ?NDX if you need more speed, but you loose protection)
: POSITION  ( sprt# -- dx dy ) ( ?NDX)  ]SDT V@ SPLIT  ;
: LOCATE    ( dx dy sprt# -- ) ( ?NDX)  ]SDT -ROT FUSE SWAP V! ;
: PATTERN   ( char sprt# -- )  ?NDX  ]SDT ->PAT VC! ;
: SP.COLOR  ( col sprt# -- )   ?NDX  ]SDT ->COLR SWAP 1- SWAP  VC! ;

CODE DUP>R ( -- )
          0647 ,  C5C4 , \ TOS RPUSH,
          NEXT,
          ENDCODE

: SPRITE    ( char colr x y sp# -- ) \ create a SPRITE, sp# = 0..31
             ?NDX
             DUP>R                 \ copy spr# to rstack
             LOCATE                \ set screen position
             R@ SP.COLOR           \ set the sprite color
             R@ PATTERN            \ set the character pattern to use
             R>
             DUP SPR# @ >
             IF   SPR# ! THEN      ;  \ update last spr#

\ like Extended BASIC Magnify
: MAGNIFY  ( mag-factor -- ) 83D4 C@ 0FC AND + DUP 83D4 C!  1 VWTR ;

HEX
\ text macros improve speed of coicidence detection
: 2(X^2)   ( n -- 2(n^2) S" DUP * 2*" EVALUATE ;  IMMEDIATE
: <=       ( n n -- ? )  S" 1- <" EVALUATE ; IMMEDIATE

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

\ factored DIST out from SPRDISTXY in TI-Forth
\ With new machine code words it is almost 2X faster
: DIST     ( x2 y2 x1 y1 -- distance^2) \ distance between 2 coordinates
            DXY  2DUP +                 \ sum the squares (DXY is code word)
            DUP>R                       \ push a copy
            RANGE?                      \ check out of range
            IF   RDROP 7FFF             \ throw away the copy, return 32K
            ELSE R>                     \ otherwise return the calculation
            THEN ;

: SP.DIST   ( #1 #2 -- dist^2 )         \ distance between 2 sprites
            POSITION ROT POSITION DIST ;

: SP.DISTXY ( x y # -- dist^2 ) POSITION DIST ;

( 0 means no coinc  )
: COINC     ( sp#1 sp#2 tol -- ? ) 2(X^2) -ROT SP.DIST >  ;

: COINCXY   ( dx dy sp# tol -- ? )
            2(X^2) >R    \ convert tolerance  to squares, push to rstack
            SP.DISTXY    \ compute sprite dist from dx dy
            R> <= ;      \ compare dist to tolerance

\ bit set if any two sprites overlap
: COINCALL  ( -- ? ) VDPSTS C@ 20 AND ;

