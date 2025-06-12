\ Graphics2 Mode Driver for Camel99 Forth    Dec 2022 BJF
\ Written in Forth to show methods.
\ Referenced TI-FORTH: ( CONVERT TO GRAPHICS2 MODE CONFIG 14SEP82 LAO)
\ 2025 Added TABLE: for faster access into VDP tables
\ COMPILES under ITC and DTC systems
CR .( Two colour bit map mode )

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

HEX
CREATE BITS ( -- addr) 80 C, 40 C, 20 C, 10 C, 8 C, 4 C, 2 C, 1 C,

BITS TABLE: ]BIT

\ drawing code ...
HEX
: VAND  ( c Vaddr -- ) S" DUP>R VC@ AND  R> VC!" EVALUATE ; IMMEDIATE

\ PENCIL and ERASER are "execution tokens"
:NONAME ( VOR)     ( c Vaddr -- ) DUP>R VC@  OR  R> VC! ; CONSTANT PENCIL
:NONAME ( VERASE)  ( c Vaddr -- ) >R INVERT R> VAND ; CONSTANT ERASER

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
\ *note: We use UM/MOD because it is the fastest divide in the system.
: PIXPOS ( x y -- )
      SWAP
      FF AND                \ mask X is required
      0 8 UM/MOD 8*         \ compute X offset into VDP memory
      SWAP ]BIT C@          \ convert remainder to bit mask
      SWAP
      ROT 0FF AND
      0 8 UM/MOD             \ compute Y offset into VDP memory
      FUSE                   \ fuse bytes x y into one integer
      +                      \ add the remainder
      ]PDT ;                 \ use integer as index PDT
;

: PLOT   ( x y -- ) S" PIXPOS STYLUS" EVALUATE ; IMMEDIATE

DECIMAL
: 2ROT ( d1 d2 d3 -- d2 d3 d1) S" 2>R 2SWAP 2R> 2SWAP" EVALUATE ; IMMEDIATE
: 4DUP ( d1 d2 -- d1 d2 d1)    S" 4TH 4TH 4TH 4TH" EVALUATE ; IMMEDIATE

\ taken from DSK1.DIRSPRIT library
HEX
CODE DXY   ( x y x2 y2 -- dx dy)
C076 , \  *SP+  R1 MOV, \ x2
6136 , \  *SP+ TOS SUB, \ y2=y2-y
0744 , \       TOS ABS,
6581 , \   R1  *SP SUB, \ x=x-x2
0756 , \       *SP ABS,
NEXT,
ENDCODE

DECIMAL
: LINE ( x1 y1 x2 y2 -- )
\ ANS version of Dr. Ting's recursive line.  R.I.P.
    4DUP \ ROT - ABS -ROT - ABS     \ compute dx dy
    DXY    ( this makes line 20% faster)
    MAX 2 < IF  2DROP PLOT  EXIT THEN
    4DUP
   \ compute mid points
    ROT  + 1+ 2/
    -ROT + 1+ 2/ SWAP
    2DUP 2ROT RECURSE RECURSE ;

0 VALUE x
0 VALUE y

: MOVETO ( x y -- ) TO y   TO x ;
: LINETO  ( x y -- ) 2DUP x y LINE MOVETO ;

\ no safety net !!
: HLINE ( x y len ) -ROT MOVETO  0 DO  x I +  y  PLOT  LOOP ;
: VLINE ( x y len ) -ROT MOVETO  0 DO  x  y I +  PLOT  LOOP ;

HERE SWAP - DECIMAL . .( bytes )

: BIGX
   254 190  0   0 LINE
   254   0  0 190 LINE
;

 : TEST
   GRAPHICS2
   BEGIN
      PENCIL IS STYLUS  BIGX
      ERASER IS STYLUS  BIGX
      KEY?
   UNTIL
   TEXT
;
