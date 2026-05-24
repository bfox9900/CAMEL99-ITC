\ Graphics2 (2.1) Mode Driver for Camel99 Forth May 11 2026 Brian Fox

CR .( Graphics 2.1 May 11 2026)
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
NEEDS JIT:        FROM DSK1.JIT

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

\ PLOT computes offset into pattern table per:
\ TI Video Display Processors, Programmer's Guide
\ -----------------------------------------------
\ BYTE_ADDRESS = 8(INT(X/8)) + 256(INT(Y/8)) + (Y MOD 8)
\ Remainder X mod 8 = is index to array of bit values ;

DEFER STYLUS  ( mask Vaddr --)   \ screen writing routine is changeable

\ ** FUSE joins two bytes into an integer. IE:  ( aa bb ) 256*  + ( -- BBAA)
JIT: PIXPOS ( x y -- )
           0 8 UM/MOD FUSE          \ 256(INT(Y/8)) + (Y MOD 8)
      SWAP 0 8 UM/MOD 8* ( y' r x') \ (X MOD 8)  8(INT(X/8))
      80 ROT RSHIFT -ROT ( m y' x') \ convert Rem to bit mask, move to bottom
      +                             \ add Y to X offset
      PDT +                         \ add offset to PDT base address
     ( mask Vaddr) ;JIT         \ do stylus code

: PLOT ( x y -- ) S" PIXPOS STYLUS" EVALUATE ; IMMEDIATE

\ drawing operations
HEX
: VAND    ( c Vaddr -- ) DUP>R VC@  AND  R> VC! ;

\ "execution tokens" to plug into STYLUS
\ Usage:
\ PENCIL IS STYLUS   ERASER IS STYLUS   BRUSH IS STYLUS
:NONAME  ( c Vaddr -- ) DUP>R VC@  OR   R> VC! ; CONSTANT PENCIL
:NONAME  ( c Vaddr -- ) SWAP DROP 0  SWAP VAND  DUP>R VC@  OR   R> VC! ;
CONSTANT ERASER

:NONAME  ( c Vaddr -- ) DUP>R VC@  XOR  R> VC! ; CONSTANT BRUSH
                                        ' 2DROP  CONSTANT PENUP

PENCIL IS STYLUS

HERE SWAP - DECIMAL . .( bytes)
