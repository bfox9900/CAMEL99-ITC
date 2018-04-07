
\ SPRITES.FTH VERSION 2.0          Feb 2018 B.Fox

\ Coincidence ideas from TI-Forth 20oct83 lct, heavily edited

\ - removed motion table. It's simpler to control motion directly
\   A task could be created easily if we really needed automotion
\ - Changed SPRITE to create named sprites. More efficient than 
\   using a numbered sprite

' VCHAR DROP  \ test if grafix is loaded

\ this implementation uses the same pattern descriptor table
\ for characters and sprites. Starts at $800

\ ==================[ SPRITE FIELD ]======================\
\  SDT[]     Byte 1    Byte 2   Byte 3      Byte 4        \
\ --------------------------------------------------------\
\ Sprite 0   row-1      col    pattern#   clk bit, color  \
\ Sprite 1    "          "        "            "          \
\ ========================================================\

\ *** NEEDS GRAFIX2.HSF -OR- GRAFIX2.FTH ***

\ ======================================================
\ Define SPRITE control tables as arrays
HEX
20     CONSTANT MAX.SP \ 32 sprites, 0 .. 31
300    CONSTANT SDT    \ sprite descriptor table VDP RAM address
8364   CONSTANT SPR#   \ sprite counter is faster as an integer in PAD RAM
8802   CONSTANT VDPSTS \ vdp status register memory mapped address

CREATE STAB  MAX.SP 4*  ALLOT       \ sprite table in CPU RAM

\ these arrays are about 1/2 speed of CODE versions but 2x smaller
\ *they are 2X FASTER than using create/does> (yikes)
: ]SDT     ( char# -- sdt[n])  4* SDT + ;     \ VDP sprite table. 4 byte fields
: ]STAB    ( char# -- stab[n]) 4* STAB + ;    \ CPU sprite table. 4 byte fields.

\ finger trouble protection. Runtime array index test. (remove for speed)
: ?NDX  ( n -- n ) MAX.SP OVER U< ABORT" SPR#>31"  ;

\ named fields for records  Usage:  12 ]SDT ->PAT
: ->PAT   ( addr -- ) S" CELL+"  EVALUATE ; IMMEDIATE
: ->COLR  ( addr -- ) S"  3  +"  EVALUATE ; IMMEDIATE

\ support words
: ERASE   ( addr cnt -- ) 0 FILL ;

\ : FUSE   ( byte byte -- word )  >< + ; \ moved to code

: DELALL  ( -- )                \ *must run DELALL before using sprites*
          1 ?MODE               \ test for graphics mode
          1 6 VWTR              \ vdp reg 6 = 1, puts ]PDT @ $800
          SDT  MAX.SP 4* 0 VFILL  \ init the sprite desc. table with 0
          STAB MAX.SP 4* ERASE    \ erase sprite table in CPU ram
          SPR# OFF ;            \ #sprites=0

\ ========================================================
\ The following words are named like X BASIC, but write to CPU memory
\ *** You must run SP.WRITE to affect sprites on the screen ***
\ This can be done in your program, or with a separate task
\ --------------------------------------------------------
: PATTERN   ( char sprt# -- )  ( ?NDX)  ]STAB ->PAT C! ;

 \ loc. is  2 fused bytes/cell
: LOCATE    ( dx dy sprt# -- ) ( ?NDX)  >R FUSE R> ]STAB ! ;
: POSITION  ( sprt# -- dx dy ) ( ?NDX)  ]STAB @ SPLIT  ;

\ uses TI BASIC color #s
: SPCOLOR   ( col sprt# -- ) ?NDX  >R  1- ?COLOR R> ]STAB ->COLR C! ;

\ Usage:   16 42  10 10 SPRITE: SPR#1
: SPRITE:   ( colr pat y x -- <name> ) \ create a NAMED SPRITE
             SPR# @ ?NDX   \ test for valid sprite#
             >R
             R@ LOCATE     \ set screen position
             R@ PATTERN    \ set the character pattern to use
             R@ SPCOLOR    \ set the sprite color
             R> CONSTANT   \ create a constant that returns this data
             1 SPR# +! ;   \ increment the sprite counter
\ --------------------------------------------------------

\ write all created sprite data to SDT at once. Nothing happens if SPR#=0
: SP.WRITE ( -- ) STAB SDT  SPR# @ 4*  VWRITE ;

\ : VECT+   ( x y dx dy --  x y )  ROT + -ROT + SWAP ;

\ read/write directly to VDP sprite descriptor table
: SP.LOC    ( px py spr# -- ) >R FUSE R> ]SDT V! ;
: SP.POS    ( spr# -- px py ) ]SDT V@ SPLIT ;
: SP.HUE    ( col spr# -- )   >R  1- ?COLOR R> ]SDT ->COLR VC! ;
: SP.PAT    ( c spr# -- )     ]SDT ->COLR VC! ;

: SP.DEL    ( # -- )  DUP ]STAB 4 ERASE
                          ]SDT  4 0 VFILL ;

\ works like Extended BASIC Magnify
: MAGNIFY  ( mag-factor -- ) 83D4 C@ 0FC AND + DUP 83D4 C!  1 VWTR ;

HEX
( factored DIST out from SPRDISTXY in TI-Forth)
: DIST     ( x2 y2 x1 y1 -- distance^2) \ distance between 2 coordinates
            DXY 2DUP +                  \ sum the squares
            DUP >R                      \ push a copy
            OR OR 8000 AND              \ check out of range
            IF R> DROP 7FFF             \ throw away the copy, return 32K
            ELSE R>                     \ otherwise return the calculation
            THEN ;

: SP.DIST   ( #1 #2 -- dist^2 )         \ distance between 2 sprites
            POSITION ROT POSITION DIST ;

: SP.DISTXY ( x y # -- dist^2 ) POSITION DIST ;

: 2(X^2)  ( n -- 2(n^2)  DUP * 2* ;

: COINC     ( sp#1 sp#2 tol -- ? ) ( 0 = no coinc  )
            2(X^2) >R SP.DIST   R>  1- < ; ( <= )

: COINCXY   ( dx dy sp# tol -- ? )
            2(X^2) >R   \ convert tolerance  to squares, push to rstack
            SP.DISTXY   \ compute sprite dist from dx dy
            R> 1- < ;   \ compare dist to tolerance <=

\ bit set if any two sprites overlap
: COINCALL  ( -- ? ) VDPSTS C@ 20 AND ;

( approx. 1102 Bytes)

GRAPHICS DELALL  CR ." Sprite II Support loaded"
