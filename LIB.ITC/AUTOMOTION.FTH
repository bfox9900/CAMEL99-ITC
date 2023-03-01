\ Interrupt Driven Sprite motion (like Extended BASIC)  BJF July 21 2019
\ Nov 2020  - corrected MOTION to correct X vector when Y vector is negative
\           - Changed ]SMT motion array to machine code. Same size as Forth
\ Jan1 2022 - use TABLE4: from DIRSPRIT.FTH for sprite motion table
\           - faster access to x and y vectors
\ Feb 2023  - Oops! Motion x,y was reversed. Fixed.  Fixed negative motion offset. 

 NEEDS HCHAR    FROM DSK1.GRAFIX
 NEEDS SPRITE   FROM DSK1.DIRSPRIT

HEX
\ * loaded with GRAFIX *
\ : TABLE4: ( Vaddr -- )  \ create a table of 4 byte records
\         CREATE    ,             \ compile base address into this word
\        ;CODE ( n -- Vaddr')     \ RUN time
\             0A24 ,  \ TOS 2 SLA,  ( tos = n x 4 )
\             A118 ,  \ *W TOS ADD,
\             NEXT,
\ ENDCODE

0780 CONSTANT SMT       \ base of Sprite Motion Table (VDP RAM)
SMT    TABLE4: ]SMT.Y   \ SPRITE Motion Table Y vectors (BYTE)
SMT 1+ TABLE4: ]SMT.X   \ x vectors (BYTE)

\ Note: You can access both values at once with V@ and V! 
\  spr# ]SMT.Y V@  SPLIT  ( -- x y )

83C2 CONSTANT AMSQ      \ interrupts, software DISABLE bits

\ AMSQ bit meaning:
\ 80 all interrupts disabled
\ 40 motion disabled
\ 20 Sound disabled
\ 10 quit key disabled

: MOVING     ( n -- ) 837A C! ;   \ # of sprites moving automatically
: INITMOTION ( -- ) 0 MOVING  0 ]SMT.Y 20 4* 0 VFILL ; \ no moving sprites
: STOPMOTION ( -- ) AMSQ C@ 40 OR  AMSQ C! ;           \ stop all sprite motion
: AUTOMOTION ( -- ) SPR# @ 1+ MOVING   AMSQ C@  30 AND  AMSQ C! ;
: ?NEGX      ( dx dy -- dx dy' ) OVER 0< IF 1+ THEN ; \ compensate for 9918 chip
: MOTION     ( dx dy spr# --)  >R ?NEGX  FUSE  R>  ]SMT.Y V! ; 

 INITMOTION
