\ Interrupt Driven Sprite motion (like Extended BASIC)  BJF July 21 2019
\ Nov 2020  - corrected MOTION to correct X vector when Y vector is negative
\           - Changed ]SMT motion array to machine code. Same size as Forth
 NEEDS HCHAR    FROM DSK1.GRAFIX
 NEEDS SPRITE   FROM DSK1.DIRSPRIT

HEX
0780 CONSTANT SMT       \ SPRITE motion table VDP address
83C2 CONSTANT AMSQ      \ interrupts, software DISABLE bits

\ AMSQ bit meaning:
\ 80 all interrupts disabled
\ 40 motion disabled
\ 20 Sound disabled
\ 10 quit key disabled

\ access the sprite tables in VDP as an array
\ : ]SMT       ( spr# -- VDP-addr) 4* SMT + ;
CODE ]SMT ( spr# -- vaddr)
          0A24 ,           \  TOS  2 SLA,
          0224 , SMT ,     \  TOS SAT AI,
          NEXT,
          ENDCODE

: MOVING     ( n -- ) 837A C! ;   \ # of sprites moving automatically
: INITMOTION ( -- ) 0 MOVING   SMT 20 4* 0 VFILL ; \ no moving sprites
: STOPMOTION ( -- ) AMSQ C@ 40 OR  AMSQ C! ;       \ stop all sprite motion
: AUTOMOTION ( -- ) SPR# @ 1+ MOVING   AMSQ C@  30 AND  AMSQ C! ;
\ : >SCHAR  ( n -- c') FF AND  ;  \ convert n to signed CHAR
: MOTION  ( vx vy spr# -- )
            >R  SWAP   ( -- vy vx)
            OVER 0<    ( -- vy vx ?)       \ vy is negative?
            IF 1+      ( -- vy vx' )       \ inc. vx
            THEN  FUSE  R> ]SMT V! ;       \ fuse bytes, put in motion table

 INITMOTION
