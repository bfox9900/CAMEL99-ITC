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

\ drawing code ...
HEX
: VAND  ( c Vaddr -- ) DUP>R VC@ AND  R> VC! ;

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
\ -----------------------------------------------
\ BYTE_ADDRESS = 8(INT(X/8)) + 256(INT(Y/8)) + (Y MOD 8)
\ Remainder X mod 8 = is index to array of bit values ;

\ *note: We use UM/MOD because it is the fastest divide in the system
HEX
: PIXPOS ( x y -- bit PDT_addr)
 ( Y) 0FF AND
      0 8 UM/MOD             \ compute Y offset into VDP memory
      FUSE                   \ fuse bytes into one integer
      SWAP
 ( X) FF AND                \ mask X is required
      0 8 UM/MOD 8*         \ compute X offset into VDP memory
      SWAP 80 SWAP RSHIFT   \ convert remainder to bit mask
      SWAP
      ROT +                 \ add the remainder
      ]PDT ;                \ use integer as index PDT
;

: PLOT   ( x y -- ) S" PIXPOS STYLUS" EVALUATE ; IMMEDIATE

DECIMAL
\ BRESENHAM.FTH
\ Line drawing algorithm                        1/26/2001 Brad Eckert
\ This is probably the classic Bresenham, or as I call it, "common sense"
\ algorithm.

\ Camel Forth needs some harness for Brad's code
NEEDS 3RD4TH FROM DSK1.3RD4TH

: DNEGATE  ( d1 -- d2 )  SWAP INVERT SWAP INVERT 1 M+ ;
: 4DROP   S" 2DROP 2DROP" EVALUATE ; IMMEDIATE
: 2OVER   S" 4TH 4TH" EVALUATE  ; IMMEDIATE

\ TMS9900 optimizers really help this old machine go faster
HEX
CODE 2ABS   ( -a -b -- a b )  0756 , 0744 , NEXT, ENDCODE \ *SP ABS, TOS ABS,
CODE NOS1+  (  a  b -- a+1 b)  0596 , NEXT, ENDCODE    \ *SP INC,
CODE X@     ( addr -- n)  05C4 ,  C114 , NEXT, ENDCODE \ CELL+ @

\ VARIABLE CH
\ : PLOT ( X Y ) AT-XY CH @ EMIT ;
NEEDS PLOT FROM DSK1.GRAPHICS2
\ ----------------------------------------------------------------------------
\ First, let's define the inner loop since this is where the work gets done.
\ We'll step one point at a time in one direction and a fraction of a point
\ in the other direction. The variable slope part uses a double-wide accumulator
\ and we use the upper part of the accumulator to plot the actual point.
: SHALLOWLINE   ( SLOPE 0 Y0 X1+1 X0 -- )      \ SLOPE IS BETWEEN -1 AND 1
        DO  I OVER PLOT 2OVER D+  LOOP 4DROP ;

: STEEPLINE     ( slope 0 X0 Y1+1 Y0 -- )      \ 1/slope is between -1 and 1
        DO  DUP I PLOT  2OVER D+  LOOP 4DROP ;

\ Now for the main word, where we look at the slope and decide which type of
\ line to draw.
\                    Y   X
: 2VARIABLE   CREATE 0 , 0 , ;

2VARIABLE POINT0        \ Y1 X1
2VARIABLE POINT1        \ Y0 X0

: PRESCALE      ( dy*2^cellsize dx -- slope 0 0 )
        2DUP XOR >R
        OVER 0< IF >R DNEGATE R> THEN
        DUP 0<  IF NEGATE THEN
        UM/MOD NIP 0
        R> 0< IF DNEGATE THEN 0
;

: LINE          ( X0 Y0 X1 Y1 -- )
        POINT1 2!  2DUP POINT0 2!
        POINT1 @ - SWAP                 ( Y0-Y1 X0 )
        POINT1 X@ -  0 -ROT        ( 0 Y0-Y1 X0-X1 )
        2DUP 2ABS  \ OVER ABS OVER ABS
        2DUP <
        IF
           2DROP
           DUP 0< >R                \ shallow line
           PRESCALE                        ( dslope 0 | f )
           R@ IF POINT0 ELSE POINT1 THEN @
           POINT0 X@ POINT1 X@ R> IF SWAP THEN
           NOS1+     \ SWAP 1+ SWAP
           SHALLOWLINE EXIT
        THEN

        = IF    OVER 0< >R                      \ Steep line
                = DUP IF ABS THEN 0             \ diagonal line ( slope 0 | f )
        ELSE    OVER 0< >R                      \ reverse?
                SWAP PRESCALE                   ( slope 0 | f )
        THEN    R@ IF POINT0 ELSE POINT1 THEN X@
                POINT0 @ POINT1 @ R> IF SWAP THEN
                NOS1+   \ SWAP 1+ SWAP
                STEEPLINE
;


0 VALUE x
0 VALUE y

: MOVETO ( x y -- ) TO y   TO x ;
: LINETO  ( x y -- ) 2DUP x y LINE MOVETO ;

\ no safety net !!
: HLINE ( x y len ) -ROT MOVETO  0 DO  x I +  y  PLOT  LOOP ;
: VLINE ( x y len ) -ROT MOVETO  0 DO  x  y I +  PLOT  LOOP ;

HERE SWAP - DECIMAL . .( bytes )
