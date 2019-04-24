
\ SPRITES.FTH VERSION 3.0          16 APR 2018 B.Fox

\ Coincidence ideas from TI-Forth 20oct83 lct, modified for speed

\ - removed motion table. It's simpler to control motion directly
\   A task could be created easily if we really needed automotion
\ - Changed SPRITE to create named sprites. More efficient than
\   using a numbered sprite
\ - Moved sprite table to HEAP memory

\ this implementation uses the same pattern descriptor table
\ for characters and sprites. Starts at $800

\ ==================[ SPRITE FIELD ]======================\
\  SDT[]     Byte 1    Byte 2   Byte 3      Byte 4        \
\ --------------------------------------------------------\
\ Sprite 0   row-1      col    pattern#   clk bit, color  \
\ Sprite 1    "          "        "            "          \
\ ========================================================\

INCLUDE DSK1.TOOLS.F
INCLUDE DSK1.ASM9900.F
INCLUDE DSK1.GRAFIX.F


' VCHAR DROP  \ test if grafix is loaded

\ ======================================================
\ Define SPRITE control tables as arrays
HEX
20     CONSTANT MAX.SP \ 32 sprites, 0 .. 31
300    CONSTANT SDT    \ sprite descriptor table VDP RAM address
8364   CONSTANT SPR#   \ sprite counter is faster as an integer in PAD RAM
8802   CONSTANT VDPSTS \ vdp status register memory mapped address

MAX.SP 4* MALLOC CONSTANT STAB  \ sprite table in Heap memory

\ create FAST array access for automotion
CODE ]SDT  ( char# -- sdt[n])
           TOS 4 SLA,   TOS SDT AI,         NEXT,  ENDCODE
CODE ]STAB    ( char# -- stab[n]) \ 4* STAB + ; \ CPU sprite table
           TOS 4 SLA,   TOS STAB AI,        NEXT, ENDCODE

CODE ]SDT@ ( i -- array[i]@)
           TOS  2 SLA,  SDT (TOS)  TOS MOV, NEXT, ENDCODE
CODE ]SDT!  ( n index --)
           TOS  2 SLA,  *SP+ SDT (TOS) MOV,  TOS POP, NEXT, ENDCODE

CODE ]STAB@  ( i -- array[i]@)
          TOS  2 SLA, STAB (TOS) TOS MOV,  NEXT, ENDCODE
CODE ]STAB!  ( n index --)
          TOS  2 SLA,  *SP+ STAB (TOS) MOV, TOS POP, NEXT, ENDCODE

\ named fields for records  Usage:  12 ]SDT ->PAT
CODE ->PAT   ( addr -- addr') TOS INCT, NEXT, ENDCODE
CODE ->COLR  ( addr -- addr') TOS 3 AI, NEXT, ENDCODE

\ finger trouble protection. Runtime array index test. (remove for speed)
: ?SPR# ( n -- n ) MAX.SP OVER U< ABORT" SPR#>31"  ;

\ support words
: ERASE   ( addr cnt -- ) 0 FILL ;

: DELALL  ( -- )                \ *must run DELALL before using sprites*
          1 ?MODE               \ test for graphics mode
          1 6 VWTR              \ vdp reg 6 = 1, puts ]PDT @ $800
          SDT  MAX.SP 4* 0 VFILL  \ init the sprite desc. table with 0
          STAB MAX.SP 4* ERASE    \ erase sprite table in CPU ram
          SPR# OFF ;            \ #sprites=0
          

: SP.DEL    ( # -- )  DUP ]STAB 4 ERASE
                          ]SDT  4 0 VFILL ;

\ ========================================================
\ The following words are named like X BASIC, but write to CPU memory
\ *** You must run SP.WRITE to affect sprites on the screen ***
\ This can be done in your program, or with a separate task
\ --------------------------------------------------------
: PATTERN   ( char sprt# -- )  ( ?SPR#)  ]STAB ->PAT C! ;

 \ loc. is  2 fused bytes/cell
: LOCATE    ( dx dy sprt# -- ) ( ?SPR#)  >R FUSE R> ]STAB! ;
: POSITION  ( sprt# -- dx dy ) ( ?SPR#)  ]STAB@ SPLIT  ;

\ uses TI BASIC color #s
: SP.COLOR   ( col sprt# -- ) ?SPR#  >R  1- ?COLOR R> ]STAB ->COLR C! ;

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
\ text macro improves speed 
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

CODE 2(X^2) ( n -- 2(n^2) TOS TOS ADD,  TOS 1 SLA, NEXT, ENDCODE

: COINC     ( sp#1 sp#2 tol -- ? ) ( 0 = no coinc  )
            2(X^2) >R SP.DIST   R>  <= ;

: COINCXY   ( dx dy sp# tol -- ? )
            2(X^2) >R   \ convert tolerance  to squares, push to rstack
            SP.DISTXY   \ compute sprite dist from dx dy
            R> <= ;    \ compare dist to tolerance <=

\ bit set if any two sprites overlap
: COINCALL  ( -- ? ) VDPSTS C@ 20 AND ;



( 694 dictionary bytes, 128 bytes of HEAP )

DELALL  CR .( Sprites initialized)
