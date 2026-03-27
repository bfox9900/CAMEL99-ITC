\ Graphics2 Mode Driver for Camel99 Forth    Dec 2022 BJF
\ Written in Forth
\ Referenced TI-FORTH: ( CONVERT TO GRAPHICS2 MODE CONFIG 14SEP82 LAO)

\ COMPILES under ITC and DTC systems
CR .( Two colour bit map mode )

NEEDS DUMP        FROM DSK1.TOOLS
NEEDS VALUE       FROM DSK1.VALUES
NEEDS CHARSET     FROM DSK1.CHARSET
NEEDS ARRAY       FROM DSK1.ARRAYS
NEEDS 4TH         FROM DSK1.3RD4TH   \ fast access to deep stack items
NEEDS DEFER       FROM DSK1.DEFER

HERE
HEX
\ setup code ... ( this verbose on purpose to clarify VDP setup )
: BITMAP-MODE   2 0 VWTR  4 VMODE ! ;
: VDP-REG1     ( n --)  DUP VDPR1 C! 1 VWTR ;  \ set mode, copy into memory for system
: NAME-TABLE   ( Vaddr -- )  400 / DUP TO NMT      2 VWTR ; \ "name" table (TI nomenclature)
: COLOR-TABLE   ( Vaddr -- )  40 / DUP TO CTAB   3 VWTR ;
: PATTERN-TABLE ( Vaddr -- ) 800 / DUP TO PDT    4 VWTR ;
: SPR-ATTRIB-TABLE ( Vaddr -- ) 80 /  DUP TO SAT  5 VWTR ; \ VR5*>80  = >3800
: SPR-PATTRN-TABLE ( Vaddr --)  800 /  DUP TO SPT  6 VWTR ; \  VR6 * >800 = >3800

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
 0 VALUE CTAB    \ color table
 0 VALUE PDT     \ pattern descriptor table
 0 VALUE NMT     \ name table
 0 VALUE SAT     \ sprite attribute table
 0 VALUE SPT     \ Sprite pattern table
 0 VALUE SCRCOLOR \ fg bg combined as 1 byte

: TEXT  ( -- )
      000 NAME-TABLE
      800 PATTERN-TABLE
      380 COLOR-TABLE
      VTOP OFF
      2 VMODE !
      28 C/L!
      CHARSET    \ restore charset because VDP memory is mangled
      PAGE ;

: CLEAR   ( -- )  PDT  1800  0 VFILL ; \ ERASE pattern table

: COLOR  ( fg bg --) SWAP 4 LSHIFT SWAP + TO SCRCOLOR ; ( merge colors into a byte)

: INIT-COLOR-TABLE  ( fg bg --)
      COLOR
      CTAB 1800 SCRCOLOR VFILL ;  \ init color table

: INIT-IMAGE ( -- )
    -1 NMT 300 BONAMEDO  1+ DUP 0FF AND I VC!  LOOP  DROP ;

HEX
CREATE BITS ( -- addr) 80 C, 40 C, 20 C, 10 C, 8 C, 4 C, 2 C, 1 C,

\ drawing code ...
HEX
: VAND  ( c Vaddr -- ) S" DUP>R VC@ AND  R> VC!" EVALUATE ; IMMEDIATE

\ PENCIL and ERASER are "execution tokens"
:NONAME ( VOR)     ( c Vaddr -- ) DUP>R VC@  OR  R> VC! ;  CONSTANT PENCIL
:NONAME ( VERASE)  ( c Vaddr -- ) >R INVERT R> VAND ;      CONSTANT ERASER
:NONAME  ( c Vaddr -- ) DUP>R VC@  XOR  R> VC! ;           CONSTANT BRUSH
                                                  ' 2DROP  CONSTANT PENUP

DEFER STYLUS   \ usage:  PENCIL IS STYLUS    ERASER IS STYLUS


: SCREEN-COLORS  ( fg bg -- ) COLOR  SCRCOLOR 7 VWTR ;

: GRAPHICS2
    0A0 1 VWTR      \ VR1 >A0 16K, screen on
    F 1 SCREEN-COLORS  \ screen background colour white on transparent
    INIT-IMAGE
    CLEAR
    20 C/L! 300 C/SCR !
    BITMAP-MODE
    1800 NAME-TABLE
    1FC0 COLOR-TABLE
    3800 PATTERN-TABLE
    2000 TO PDT       \ move pattern descriptor table Why?
    PDT VTOP !        \ VROW VCOL can be used if needed

    3800 SPR-ATTRIB-TABLE
    3800 SPR-PATTRN-TABLE
    0E0 VDP-REG1
    0 837A C!  ;    \ highest sprite in auto-motion

\ Compute offset into pattern table per:
\ TI Video Display Processors, Programmer's Guide
: PIXPOS ( x y -- )
      SWAP
      FF AND                \ mask X is required
      0 8 UM/MOD 8*         \ compute X offset into VDP memory
      SWAP BITS + C@        \ convert remainder to bit mask
      SWAP ROT 0FF AND
      0 8 UM/MOD             \ compute Y offset into VDP memory
      >< + +                 \ combine x y into integer
      PDT + ;                \ add all offsets to PDT base address
;

: PLOT   ( x y -- ) S" PIXPOS STYLUS" EVALUATE ; IMMEDIATE

DECIMAL
: 2ROT ( d1 d2 d3 -- d2 d3 d1) S" 2>R 2SWAP 2R> 2SWAP" EVALUATE ; IMMEDIATE
: 4DUP ( d1 d2 -- d1 d2 d1)    S" 4TH 4TH 4TH 4TH" EVALUATE ; IMMEDIATE

DECIMAL
: LINE ( x1 y1 x2 y2 -- )
\ ANS version of Dr. Ting's recursive line.  R.I.P.
    4DUP  ROT - ABS -ROT - ABS           \ compute dx dy
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
: HLINE ( x y len ) -ROT MOVETO  0 DO  x I +  y  PLOT  LOOP ;
: VLINE ( x y len ) -ROT MOVETO  0 DO  x  y I +  PLOT  LOOP ;

HERE SWAP - DECIMAL . .( bytes )
