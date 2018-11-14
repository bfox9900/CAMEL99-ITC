\ sprite control adapted from TI-Forth  20oct83 lct

\ complete re-write for CAMEL99 Multi-Forth May 25,2017 BJF
\ Oct 19, 2017 - MOVEALL, replaced with faster SP.MOVE

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
1F     CONSTANT MAX.SP         \ 32 sprites, 0 .. 31
300    CONSTANT SDT            \ sprite descriptor table in VDP RAM
20 4*  CONSTANT SDT#           \ size of the table 32 sprites X 4 bytes/record
837A   CONSTANT SPR#           \ sprite counter. same address as used by XB
8802   CONSTANT VDPSTS         \ vdp status register memory mapped address

CREATE MT    SDT# ALLOT   \ motion table is array of 32 motion vectors
CREATE AUX   SDT# ALLOT   \ automotion down counters
CREATE STAB  SDT# ALLOT   \ sprite X,Y table in CPU RAM

\ named fields for sprite record.  Usage:  12 ]SDT ->PAT
: ->PAT   ( addr -- addr+2) POSTPONE 2+  ; IMMEDIATE
: ->COLR  ( addr -- addr+3) POSTPONE 3 POSTPONE + ; IMMEDIATE

: ]MOTION  ( spr# -- mt[n])   4* MT + ;      \ CPU motion table is 2 cells/record
: ]AUX     ( spr# -- aux[n])  4* AUX + ;     \ array of down counters
: ]STAB    ( spr# -- stab[n]) S" 4* STAB +" EVALUATE ; IMMEDIATE  \ CPU sprite table. 4 BYTE fields.

\ using text MACROs here for speed improvement
\ returns VDP sprite Decriptor X address
: SP.X   ( spr# -- vdp_addr) ]STAB ;

\ returns VDP sprite Decriptor Y address
: SP.Y   ( spr# -- vdp_addr) ]STAB 1+ ;

: SP.X@  ( spr# -- sprx) SP.X VC@ ;    \ fetch X
: SP.Y@  ( spr# -- spry) SP.Y VC@ ;    \ fetch Y

: SP.X!  ( n spr# -- ) SP.X VC! ;      \ store X
: SP.Y!  ( n spr# -- ) SP.Y VC! ;      \ store Y

\ finger trouble protection. Runtime array index test. (remove for speed)
: ?NDX  ( n -- n ) MAX.SP OVER U< ABORT" SPR#>31"  ;

\ named fields for records  Usage:  12 ]SDT ->PAT
: ->PAT   ( addr -- ) S" CELL+"  EVALUATE ; IMMEDIATE
: ->COLR  ( addr -- ) S"  3  +"  EVALUATE ; IMMEDIATE

\ support words
: ERASE   ( addr cnt -- ) 0 FILL ;

: DELALL  ( -- )                \ *must run DELALL before using sprites*
          1 ?MODE               \ test for graphics mode
          1 6 VWTR              \ vdp reg 6 = 1, puts ]PDT @ $800
          SDT SDT# BL VFILL     \ init the sprite desc. table with blanks
          MT   SDT# ERASE       \ erase motion table
          STAB SDT# ERASE       \ erase sprite table in CPU ram
          AUX  SDT# ERASE
          SPR# OFF ;            \ #sprites=0

\ ========================================================
\ The following words are named like X BASIC, but write to CPU memory
\ *** You must run SP.SHOW to affect sprites on the screen ***
\ This can be done in your program, or with a separate task
\ --------------------------------------------------------
: PATTERN   ( char sprt# -- )  ( ?NDX)  ]STAB ->PAT C! ;
: LOCATE    ( dx dy sprt# -- ) ( ?NDX)  >R FUSE R> ]STAB ! ;    \ loc. is  2 fused bytes/cell

\ we shift motion vectors to upper byte before storing
\ motion ranges:
\  1 ..  7F -> 0100..7F00,
\ -1 .. -7F -> FF00..8100
: MOTION    ( vx vy sprt# -- ) ( ?NDX)  \ ]motion is a 2VARIABLE array
            ?NDX >R
            8 LSHIFT SWAP               \ convert motion values to integers
            8 LSHIFT SWAP
            R> ]MOTION 2! ;

: POSITION  ( sprt# -- dx dy ) ( ?NDX)  ]STAB @ SPLIT  ;
: SP.COLOR  ( col sprt# -- ) ?NDX  >R  1- ?COLOR R> ]STAB ->COLR C! ; \ uses TI BASIC color #s

: SPRITE  ( colr pat y x sp# -- )     \ create a SPRITE, # = 0..31
             ?NDX                     \ test for valid sprite#
             >R                       \ push spr# to rstack
             0 0 R@ MOTION            \ set motion vectors to 0,0
             R@ LOCATE                \ set screen position
             R@ PATTERN               \ set the character pattern to use
             R> SP.COLOR              \ set the sprite color
             1 SPR# +! ;              \ increment the sprite counter
\ --------------------------------------------------------

\ update all sprite data in VDP using fast VWRITE
: SP.SHOW ( -- ) STAB SDT SPR# @ 4* VWRITE ;  \ VWRITE can handle 0 bytes in V1.92

: 1-!@    ( addr -- n ) -1 OVER +!  @ ;

: SP.MOVE  ( spr# -- )  \ dx dy is a motion vector
            DUP >R ]MOTION @  R@ ]AUX !
            R@ ]AUX ->X 1-!@
            0= IF
                 R@ ]SDT V@   SPLIT VECT+ FUSE   R> ]SDT V!
            THEN ;

\ This word can be used in a TASK to create 'AUTOMOTION'
: SP.MOVER  ( -- )    \ update all sprite positions and write to VDP
            0 ]MOTION  0 ]AUX  32 4*  MOVE    \ copy motion to aux table
            SPR# @ 0
            ?DO
                  I ]AUX  DUP 1-!
                  @ 0= IF I ]MOTION @ DUP / ( -- -1 | 1) THEN
            LOOP


            SP.SHOW ;

\ change sprite and update screen immediatley
: SP.LOC    ( dx dy sprt# -- ) LOCATE SP.SHOW ;
: SP.STOP   ( sprt# -- )  ?NDX 0 0 ROT MOTION SP.SHOW ;

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

: <=        ( n n -- ? ) 1- < ;

: COINC     ( sp#1 sp#2 tol -- ? ) ( 0 = no coinc  )
            2(X^2) >R SP.DIST   R>  <= ;

: COINCXY   ( dx dy sp# tol -- ? )
            2(X^2) >R                   \ convert tolerance  to squares, push to rstack
            SP.DISTXY                   \ compute sprite dist from dx dy
            R> <= ;                     \ compare dist to tolerance

: COINCALL  ( -- ? ) VDPSTS C@ 20 AND ; \ bit set if any two sprites overlap

: SP.DEL    ( # -- )  DUP ]STAB 4 ERASE
                          ]SDT  4 0 VFILL ;
( 1102 Bytes)

GRAPHICS DELALL  CR .( Sprite Support loaded)
