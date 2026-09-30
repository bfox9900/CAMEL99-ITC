CR .( Graphics2 Mode V2.9B for Camel99 Forth Mar 2025 BJF)
\ Referenced TI-FORTH:
( CONVERT TO GRAPHICS2 MODE CONFIG 14SEP82 LAO)

\ Test results using simple program
\ V2.1  Forth with text macros
\ 2.7   critical VOR VERASE and XY-offset as CODE
\ 2.8   PIXPOS re-coded in ASM, LINE uses tail called optimization
\ 2.9   DXY? removes 1 4DUP call. MID written in code
\ 2.C   Uses DEFER word for STYLUS

\ COMPILES under ITC ONLY
CR .( Two colour bit map mode )

NEEDS DUMP      FROM DSK1.TOOLS
NEEDS MOV,      FROM DSK1.ASM9900
NEEDS VALUE     FROM DSK1.VALUES
NEEDS CHARSET   FROM DSK1.CHARSET
NEEDS ARRAY     FROM DSK1.ARRAYS
NEEDS 4TH       FROM DSK1.3RD4TH \ fast access to deep stack items
NEEDS DEFER     FROM DSK1.DEFER

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

\ Expose hidden sub-rotuines in the kernel
HEX
' VC! 2 CELLS + @ CONSTANT VWMODE  \ VDP write address sub-routine
' VC@ 2 CELLS + @ CONSTANT VRMODE  \ VDP read address sub-routine

8800 CONSTANT VDPRD        \ vdp ram read data port
8C00 CONSTANT VDPWD        \ vdp ram write data port

\ : VOR   ( c Vaddr -- ) DUP>R VC@  OR  R> VC! ;
CODE VOR ( c Vaddr -- )
        VRMODE @@ BL,     \ set read address, disables Interrupts
        W CLR,
        VDPRD @@ W MOVB,  \ read screen data to W
        W SWPB,
        *SP+ W SOC,       \ OR C on stack with screen data
        W SWPB,
        VWMODE @@ BL,     \ set the address for writing
        W  VDPWD @@ MOVB, \ write back to screen
        TOS POP,
        2 LIMI,
        NEXT,
ENDCODE

\ : VAND  ( c Vaddr -- ) S" DUP>R VC@ AND  R> VC!" EVALUATE ; IMMEDIATE

\ : VERASE  ( c Vaddr -- ) >R INVERT R> VAND ;
CODE VERASE ( c Vaddr -- )
        VRMODE @@ BL,    \ set read address
        W CLR,
        VDPRD @@ W MOVB, \ read screen data to W
        W SWPB,
        *SP+ W SZC,      \ AND C on stack with screen data
        W SWPB,
        VWMODE @@ BL,    \ set the address for writing
        W  VDPWD @@ MOVB, \ write back to screen
        2 LIMI,
        TOS POP,
        NEXT,
ENDCODE

\ PENCIL and ERASER are "execution tokens"
' VOR    CONSTANT PENCIL
' VERASE CONSTANT ERASER

DEFER STYLUS
\ usage:  PENCIL IS STYLUS  ERASER IS STYLUS
PENCIL IS STYLUS

\ setup VDP code ...
: GRAPHICS2
    0000 TO CTAB        \ color table
    1800 TO IMG         \ "name" table (TI nomenclature)
    2000 TO PDT         \ pattern descriptor table

    0A0 1 VWTR          \ VR1 >A0 16K, screen on
    INIT-IMAGE
    F 0 COLOR           \ white on transparent
    CLEAR
    20 C/L! 300 C/SCR !
    2 0 VWTR            \ VR0 >02 Bitmap mode on
    6 2 VWTR            \ Screen image = 6*>400 = 1800
    07F 3 VWTR          \ Color table at >0000
    7 4 VWTR            \ PATTERN table= VR4*>800 = 2000
    70 5 VWTR           \ sprite attribute table: VR5*>80  = >3800
     7 6 VWTR           \ sprite pattern table: VR6 * >800 = >3800
    F1 7 VWTR           \ screen background colour white on transparent
    0E0 DUP VDPR1 C! 1 VWTR   \ set mode, copy into memory for system
    4 VMODE !
    0 837A C!  ;        \ highest sprite in auto-motion


\ Compute offset into pattern table per:
\ TI Video Display Processors, Programmer's Guide

CREATE BITS ( -- addr) 80 , 40 , 20 , 10 , 8 , 4 , 2 , 1 ,

\ =============================================
\ PIXPOS Register usage
\ R0  X offset
\ R1  dup of Y coordinate
\ R2  Temp Y quotient
\ R3  Y coordinate
\ R4  Forth Accumulator, outputs PDT address
\ R8  = W = X division remainder

CODE PIXPOS  ( x y -- bit Vaddr)
\ mask x,y to 8 bit values
    TOS 00FF ANDI,
    *SP R0 MOV,     \ get X into R0, leave stack position available
    R0 00FF ANDI,

\ calc X offset
    R0  W MOV,     \ copy x to W
    R0  3 SRA,     \ divide by 8
    R0  3 SLA,     \ mult quot by 8.  R0 = X offset
    R0  W SUB,     \ sub-tract result -> W = remainder

\ convert remainder to bit mask
    W    1 SLA,       \ W 2*
    BITS (W) *SP MOV, \ lookup bit value leave as 2nd on stack

\ calc Y offset
    TOS R1  MOV,    \ DUP Y for subtraction later
    TOS   3 SRA,    \ divide by 8 = Y quotient
    TOS  R2 MOV,    \ dup quotient result
    R2    3 SLA,    \ mult quot by 8
    R2   R1 SUB,    \ sub-tract result = remainder
        TOS SWPB,   \ Y quotient 256*

\ compute pattern table address
    R1   TOS ADD,   \ add remainder to quotient
    R0   TOS ADD,   \ add X offset to Y offset
    TOS  PDT AI,    \ add index to pattern table base address
    NEXT,
ENDCODE

\ TEXT macro for speed
: PLOT   ( x y -- ) S" PIXPOS STYLUS" EVALUATE ; IMMEDIATE

HERE SWAP - DECIMAL .
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
