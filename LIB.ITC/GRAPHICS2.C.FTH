\ Graphics2 Mode V2.9 for Camel99 Forth Dec 2022 BJF
\ Referenced TI-FORTH:
( CONVERT TO GRAPHICS2 MODE CONFIG 14SEP82 LAO)

\ Test results using simple program
\ V2.1  Forth with text macros
\ 2.7   critical VOR VERASE and XY-offset as CODE
\ 2.8   PIXPOS re-coded in ASM, LINE uses tail called optimization
\ 2.9   DXY? removes 1 4DUP call. MID written in code
\ 2.C   PIXPOS uses ideas from ASM_USR @ ATARTAGE.COM

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

\ replacing text macro with code words
HEX
' VC! 2 CELLS + @ CONSTANT VWMODE  \ Access VDP write address sub-routine
' VC@ 2 CELLS + @ CONSTANT VRMODE  \ Access VDP read address sub-routine

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

DEFER STYLUS  ( mask Vaddr --)

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
\ Thoughts of ASMUSR @atartiage.com who has made concise way to do this.
\ My version used 16 instructions but his is only 14 :-)


\ "The code is quite impossible to understand without knowing how
\ the bitmap screen is structured, but here is a rough explanation.
\ The screen address is calculated as:
\ 5_most_significant_bits_of_y * 256 + 5_most_significant_bits_of_x *
\ 8 + 3_least_significant_bits_of_y =

\ 5_most_significant_bits_of_y << 8 + 5_most_significant_bits_of_x << 3 +
\ 3_least_significant_bits_of_y "

\ BF Note:  I adapted his code to work with BITS array

\ MOV  R1,R4         ; 00000000YYYYYYYY
\ SLA  R4,5          ; 000YYYYYYYY00000
\ SOC  R1,R4         ; 000YYYYY???YYYYY
\ ANDI R4,>FF07      ; 000YYYYY00000YYY
\ MOV  R0,R5         ; 00000000XXXXXXXX
\ ANDI R5,7          ; 0000000000000XXX
\ A    R0,R4         ; 000YYYYY00000YYY + 00000000XXXXXXXX
\ S    R5,R4         ; 000YYYYY00000YYY + 00000000XXXXXXXX -
\ 0000000000000XXX = 000YYYYY00000YYY + 00000000XXXXX000 = 000YYYYYXXXXXYYY


\ PIXPOS Register usage
\ R0  X offset
\ R1  dup of Y coordinate
\ R2  Temp Y quotient
\ R5  Y coordinate
\ R4  Forth Accumulator, TOS, outputs PDT address
\ R8  = W = X division remainder
HEX
 CODE PIXPOS ( x y -- c Vaddr)
    *SP R0 MOV,   \ x
    TOS R1 MOV,   \ y
    R1 R4 MOV,
    R4 5  SLA,    \ R4 32*
    R1 R4 SOC,    \ mask r4 with R1
    R4 FF07 ANDI,

    R0 R5 MOV,
    R5 7 ANDI,    \ r5 is index into BITS

    R5 W MOV,         \ dup R5 in W
    W    1 SLA,       \ W 2*
    BITS (W) *SP MOV, \ lookup bit value leave as 2nd on stack

    R0 R4 ADD,
    R5 R4 SUB,
    R4 PDT AI,   \ add index to pattern table base address
    NEXT,
ENDCODE


\ TEXT macro for speed
: PLOT   ( x y -- ) S" PIXPOS STYLUS" EVALUATE ; IMMEDIATE
