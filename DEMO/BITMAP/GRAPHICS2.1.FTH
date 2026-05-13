\ Graphics2.1 Mode Driver for Camel99 Forth    Dec 2022 BJF
\ Written in Forth to show methods.
\ Referenced TI-FORTH: ( CONVERT TO GRAPHICS2 MODE CONFIG 14SEP82 LAO)
\ 2025 Added TABLE: for faster access into VDP tables
\ 2026  simplified stackrobatics in PIXPOS, use FUSE for 256* +

\ COMPILES under ITC and DTC systems
CR .( Two colour bit map mode )
CR .( Uses text macros and tail-call optimization)

NEEDS DUMP        FROM DSK1.TOOLS
NEEDS VALUE       FROM DSK1.VALUES
NEEDS CHARSET     FROM DSK1.CHARSET
NEEDS 4TH         FROM DSK1.3RD4TH   \ fast access to deep stack items
NEEDS DEFER       FROM DSK1.DEFER
NEEDS TABLE:      FROM DSK1.TABLES   \ fast indexing array

HERE
HEX
\
\ text mode so we can return to the Forth console
\ KERNEL version does not init all registers
\
83D4 CONSTANT VDPR1
CREATE 40COL
\    CNT     0     1     2     3     4     5     6     7
      08 C, 00 C, F0 C, 00 C, 0E C, 01 C, 06 C, 02 C, 17 C, 00 C,

: VREGS  ( addr len -- )
         OVER 1+ C@ VDPR1 C! \ store the R1 value from the table
         0 DO  COUNT I VWTR  LOOP DROP ;

HEX
 0000 VALUE CTAB    \ color table
 2000 VALUE PDT     \ pattern descriptor table
 1800 VALUE IMG

PDT TABLE: ]PDT  \ gives faster index into PDT

: TEXT  ( -- )
      40COL COUNT VREGS
      800 TO PDT
      380 TO CTAB
      VTOP OFF
      2 VMODE !
      28 C/L!
      CHARSET    \ restore charset because VDP memory is mangled
      PAGE ;

: CLEAR   ( -- )  PDT  1800  0 VFILL ; \ ERASE pattern table

: COLOR   ( fg bg --)
      SWAP 4 LSHIFT SWAP +    \ merge colors into a byte
      CTAB 1800  ROT VFILL ;  \ init color table

: INIT-IMAGE ( -- )
    -1 IMG 300 BOUNDS DO  1+ DUP 0FF AND I VC!  LOOP  DROP ;

\ drawing code ...
HEX
: VAND  ( c Vaddr -- ) S" DUP>R VC@ AND  R> VC!" EVALUATE ; IMMEDIATE

\ PENCIL and ERASER are "execution tokens"
:NONAME ( VOR)     ( c Vaddr -- ) DUP>R VC@  OR  R> VC! ; CONSTANT PENCIL
:NONAME ( VERASE)  ( c Vaddr -- ) SWAP INVERT SWAP VAND ; CONSTANT ERASER

DEFER STYLUS   \ usage:  PENCIL IS STYLUS    ERASER IS STYLUS

\ setup code ...
: GRAPHICS2
    0000 TO CTAB    \ color table
    1800 TO IMG     \ "name" table (TI nomenclature)
    2000 TO PDT     \ pattern descriptor table

    0A0 1 VWTR      \ VR1 >A0 16K, screen on
    INIT-IMAGE
    F 0 COLOR
    CLEAR
    20 C/L! 300 C/SCR !
    2 0 VWTR          \ VR0 >02 Bitmap mode on
    6 2 VWTR          \ Screen image = 6*>400 = 1800
    07F 3 VWTR        \ Color table at >0000
    7 4 VWTR          \ PATTERN table= VR4*>800 = 2000
    PDT VTOP !        \ VROW VCOL can be used if needed
    70 5 VWTR         \ sprite attribute table: VR5*>80  = >3800
     7 6 VWTR         \ sprite pattern table: VR6 * >800 = >3800
   0F1 7 VWTR         \ screen background colour white on transparent
    0E0 DUP VDPR1 C! 1 VWTR   \ set mode, copy into memory for system
    4 VMODE !
    PENCIL IS STYLUS
    0 837A C!  ;      \ highest sprite in auto-motion

\ Compute offset into pattern table per:
\ TI Video Display Processors, Programmer's Guide
\ -----------------------------------------------
\ BYTE_ADDRESS = 8(INT(X/8)) + 256(INT(Y/8)) + (Y MOD 8)
\ Remainder X mod 8 = is index to array of bit values ;

\ *Note:
\ 1. We use UM/MOD because it is the fastest divide in the system
\ 2. FUSE performs 256* because it puts two bytes together in an integer
\    AA BB  FUSE -> BBAA   in effect it is: BB * 256 + AA

HEX
: PIXPOS ( x y -- bit PDT_addr)
 ( Y) 0 8 UM/MOD        \ -- (Y MOD 8) (Y/8)
      FUSE              \  256(y/8) + (y mod 8)
      SWAP
 ( X) 0 8 UM/MOD 8*     \ compute X offset into VDP memory
      80 ROT RSHIFT     ( -- Y' X' bit )
      -ROT +            ( -- bit ndx)
      ]PDT ;            ( -- bit Vaddr)
;

: PLOT   ( x y -- ) S" PIXPOS STYLUS" EVALUATE ; IMMEDIATE

HERE SWAP - CR DECIMAL . .( bytes )

CR .( Use BRESENHAM file for line generation)