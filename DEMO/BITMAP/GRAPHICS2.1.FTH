\ Graphics2 Mode Driver for Camel99 Forth May 31 2024 Brian Fox
CR .( This version uses only Forth )
\ Referenced TI-FORTH: ( CONVERT TO GRAPHICS2 MODE CONFIG 14SEP82 LAO)

\  ** VANILLA FORTH VERSION, LIBRARY CODE ONLY **

\ COMPILES under ITC and DTC systems
CR .( Two colour bit map mode )

NEEDS DUMP        FROM DSK1.TOOLS
NEEDS VALUE       FROM DSK1.VALUES
NEEDS CHARSET     FROM DSK1.CHARSET
NEEDS DEFER       FROM DSK1.DEFER
NEEDS 4TH         FROM DSK1.3RD4TH
NEEDS CARRAY      FROM DSK1.ARRAYS

HERE
\
\ TEXT mode so we can return to the Forth console properly
\ KERNEL version does not init all registers
\
HEX
83D4 CONSTANT VDPR1

CREATE 40COL
\    CNT     0     1     2     3     4     5     6     7
      08 C, 00 C, F0 C, 00 C, 0E C, 01 C, 06 C, 02 C, 17 C, 00 C,

: VREGS  ( $addr -- )
      COUNT
      OVER 1+ C@ VDPR1 C! \ store the R1 value from the table
      0 DO
        COUNT I VWTR
      LOOP
      DROP ;

HEX
 0000 VALUE CTAB    \ color table
 2000 VALUE PDT     \ pattern descriptor table
 1800 VALUE IMG     \ image table
 1B00 VALUE SAT     \ sprite attribute table
 3800 VALUE SPT     \ Sprite pattern table

\ this is a complete change to TEXT mode.
: TEXT  ( -- )
      40COL VREGS
      800 TO PDT
      380 TO CTAB
      VTOP OFF
      2 VMODE !
      28 C/L!
      CHARSET    \ restore charset from GROM. VDP memory is mangled
      PAGE ;

: CLEAR   ( -- )  PDT 1800 0 VFILL ;  \ ERASE image table

: COLOR   ( fg bg --)
      SWAP 4 LSHIFT SWAP +    \ merge colors into a byte
      CTAB 1800  ROT VFILL ;  \ init color table

\ setup BITMAP MODE ...
HEX
: INIT-IMAGE ( -- ) 0 IMG 300 BOUNDS DO   DUP I VC! 1+  LOOP  DROP ;

\ VDP register reference
\ VR0   >02 Bitmap mode on
\ VR1   more bits to set mode
\ VR2   Screen image = VR2 * >400 = 1800
\ VR3   set Color table at >0000
\ VR4   PATTERN table= VR4*>800 = 2000
\ VR5   sprite attribute table: VR5 * $80  = >1B00
\ VR6   sprite pattern table:   VR6 * $800 = >3800
\ VR7   screen background colour white on transparent
CREATE GRAPH2
\    CNT     0     1     2     3     4     5     6     7
      08 C, 02 C, E0 C, 06 C, 7F C, 7 C, 36 C,  7 C, F1 C, 00 C,

: GRAPHICS2
    0000 TO CTAB    \ color table
    1800 TO IMG     \ "name" table (TI nomenclature)
    2000 TO PDT     \ pattern descriptor table
    36 80 * TO SAT

    CLEAR
    F 0 COLOR       \ white on transparent
    SAT [ 32 4* ] LITERAL 0 VFILL
    INIT-IMAGE
    E0 VDPR1 C!     \ copy mode into GPL register
    GRAPH2 VREGS

    4 VMODE !
    0 837A C!  ;    \ highest sprite in auto-motion

HEX
\ CREATE BITS ( -- addr) 80 C, 40 C, 20 C, 10 C, 8 C, 4 C, 2 C, 1 C,

8 CARRAY ]BITS
 0 ]BITS DP !
 80 C, 40 C, 20 C, 10 C, 8 C, 4 C, 2 C, 1 C,

\ PLOT computes offset into pattern table per:
\ TI Video Display Processors, Programmer's Guide
\ -----------------------------------------------
\ BYTE_ADDRESS = 8(INT(X/8)) + 256(INT(Y/8)) + (Y MOD 8)
\ Remainder X mod 8 = is index to array of bit values ;

DEFER STYLUS  ( mask Vaddr --)

 : PLOT ( x y -- )
      0FF AND 0 8 UM/MOD >< +       \ compute Y offset into VDP memory
      SWAP 0FF AND 0 8 UM/MOD 8* ( r q)  \ compute X offset & remainder
      SWAP ]BITS C@              \ convert remainder to bit mask
     -ROT +                      \ add Y to X offset
      PDT +                      \ add offset to PDT base address
     ( mask Vaddr) STYLUS ;      \ do stylus code

\ drawing operations
HEX
: VAND    ( c Vaddr -- ) DUP>R VC@  AND  R> VC! ;

\ "execution tokens" to plug into STYLUS
\ Usage:
\ PENCIL IS STYLUS   ERASER IS STYLUS   BRUSH IS STYLUS
:NONAME  ( c Vaddr -- ) DUP>R VC@  OR   R> VC! ; CONSTANT PENCIL
:NONAME  ( c Vaddr -- ) SWAP INVERT SWAP VAND ;  CONSTANT ERASER
:NONAME  ( c Vaddr -- ) DUP>R VC@  XOR  R> VC! ; CONSTANT BRUSH
                                        ' 2DROP  CONSTANT PENUP

DECIMAL
: 2ROT ( d1 d2 d3 -- d2 d3 d1) S" 2>R 2SWAP 2R> 2SWAP" EVALUATE ;  IMMEDIATE
: 4DUP  S" 4TH 4TH 4TH 4TH" EVALUATE ; IMMEDIATE

: LINE ( x1 y1 x2 y2 -- )
\ ANS version of Dr. Ting's recursive line.  R.I.P.
    4DUP  ROT - ABS >R - ABS R>       \ compute dx dy
    MAX 2 < IF  2DROP PLOT  EXIT THEN \ nothing do, get out

    4DUP ROT
    + 1+ 2/ >R    \ compute mid points
    + 1+ 2/ R>
    2DUP 2ROT RECURSE RECURSE ;

0 VALUE x
0 VALUE y

: MOVETO ( x y -- ) TO y   TO x ;
: LINETO  ( x y -- ) 2DUP x y LINE MOVETO ;

\ no safety net !!
: HLINE ( x y len ) >R MOVETO R>  0 DO  x I +  y  PLOT  LOOP ;
: VLINE ( x y len ) >R MOVETO R>  0 DO  y  x I +  PLOT  LOOP ;

HERE SWAP - DECIMAL . .( bytes)
