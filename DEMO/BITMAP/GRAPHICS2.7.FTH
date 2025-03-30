\ Graphics2 Mode V2.7 for Camel99 Forth *ITC*  AUG 2023 BJF
\ Referenced TI-FORTH:
( CONVERT TO GRAPHICS2 MODE CONFIG 14SEP82 LAO)
 
\ Test results using simple program
\ V2.1  Forth with text macros
\ 2.7   critical VOR VERASE and XY-offset as CODE

\ COMPILES under ITC ONLY
CR .( Two colour bit map mode )
 
NEEDS DUMP      FROM DSK1.TOOLS
NEEDS MOV,      FROM DSK1.ASM9900
NEEDS VALUE     FROM DSK1.VALUES
NEEDS CHARSET   FROM DSK1.CHARSET
NEEDS 4TH       FROM DSK1.3RD4TH
 
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
 1800 VALUE IMGSIZE \ imgsize is 1800 but this cleans up left over junk
 
: TEXT  ( -- )
    40COL COUNT VREGS
    800 TO PDT
    380 TO CTAB
    VTOP OFF
    2 VMODE !
    28 C/L!
    PDT 800 0 VFILL
    CHARSET    \ restore charset from GROM
    PAGE ;
 
\ INK holds the foreground and background colors as ONE byte
VARIABLE INK   F0 INK !
 
: CLEAR  ( -- )      PDT  IMGSIZE   0  VFILL ; \ ERASE pattern table + a bit mo
: SCREEN ( fg/bg --) CTAB IMGSIZE  ROT VFILL ; \ init color table
 
: INIT-IMAGE ( -- )  \ Per TSM9918 manual bit-map mode
    -1 IMGSIZE 300 BOUNDS DO  1+ DUP 0FF AND I VC!  LOOP  DROP ;
 
\ replacing text macro with code words
HEX
' VC! 2 CELLS + @ CONSTANT VWMODE  \ Access VDP write address sub-routine
' VC@ 2 CELLS + @ CONSTANT VRMODE  \ Access VDP read address sub-routine
 
8800 CONSTANT VDPRD        \ vdp ram read data port
8C00 CONSTANT VDPWD        \ vdp ram write data port
 
\ : VOR   ( c Vaddr -- ) DUP>R VC@  OR  R> VC! ;
CODE VOR ( c Vaddr -- )
    *SP  SWPB,
    VRMODE @@ BL,     \ set read address, disables Interrupts
    W CLR,
    VDPRD @@ W MOVB,  \ read screen data to W
    *SP+ W SOC,       \ OR C on stack with screen data
    VWMODE @@ BL,     \ set the address for writing
    W  VDPWD @@ MOVB, \ write back to screen
    2 LIMI,
    TOS POP,
    NEXT,
ENDCODE
 
 
\ : VAND  ( c Vaddr -- ) S" DUP>R VC@ AND  R> VC!" EVALUATE ; IMMEDIATE
\ : VERASE  ( c Vaddr -- ) >R INVERT R> VAND ;
 
CODE VERASE ( c Vaddr -- )
    *SP SWPB,
    VRMODE @@ BL,    \ set read address
    W CLR,
    VDPRD @@ W MOVB,  \ read screen data to W
    *SP+ W SZC,       \ AND C on stack with screen data
    VWMODE @@ BL,     \ set the address for writing
    W  VDPWD @@ MOVB, \ write back to screen
    2 LIMI,
    TOS POP,
    NEXT,
ENDCODE
 
\ PENCIL and ERASER are "execution tokens"
' VOR    CONSTANT PENCIL
' VERASE CONSTANT ERASER
 
VARIABLE STYLUS   \ usage:  PENCIL STYLUS !   ERASER STYLUS !
 
\ setup VDP code ...
: GRAPHICS2
    0 3900 0 VFILL      \ erase most of VDP RAM to clean any junk
 
    0000 TO CTAB        \ color table
    1800 TO IMGSIZE     \ "name" table (TI nomenclature)
    2000 TO PDT         \ pattern descriptor table
 
    0A0 1 VWTR          \ VR1 = >A0 Means: 16K RAM, screen on
    INIT-IMAGE
    CLEAR
    F0 SCREEN           \ white on transparent
 
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
CREATE BITS ( -- addr) 80 C, 40 C, 20 C, 10 C, 8 C, 4 C, 2 C, 1 C,
 
\ =======================================================
\ 1st section of this code: courtesy @ASMUSR
\   *** VIA E/A MANUAL PAGE 336 ***
\ MODIFIED TO output ARGS for VOR and VC!
 
 
CODE (PLOT)  ( x y -- bit PDT[x,y] ink CTAB[x,y] )
   *SP    W  MOV,   \ COPY X but keep the stack position
    TOS   R1 MOV,   \ copy Y
    TOS   5  SLA,   \ Y * 32
    R1   TOS SOC,   \ OR R1 into R4
    TOS FF07 ANDI,  \ mask to: 000YYYYY00000YYY
    W    TOS ADD,   \ add x to y offset
 
    W     7 ANDI,   \ X 8 MOD -> W = bit# of the pixel
    W   TOS SUB,    \ tos = offset into CTAB of the byte we need
 
\ convert remainder in W to a bit mask using lookup table
        *SP CLR,    \ clear the x value stack position
    BITS (W) 1 (SP) MOVB, \ lookup bit value leave as 2nd on stack
 
\ push offset onto stack and add PDT base address
    TOS PUSH,
' PDT >BODY @@ *SP ADD,  \ get payload of a constant needs some magic
 
    SP DECT,             \ make room for the ink value
    INK @@ *SP MOV,      \ assign ink to 2nd stack item
    NEXT,
ENDCODE
 
\ TEXT macro for speed
: PLOT   ( color-byte x y -- ) S" (PLOT) VC! VOR" EVALUATE ; IMMEDIATE
 
HEX
\ manual tail call optimizer. Improves LINE by 1.5%
CODE GOTO   C259 ,  ( *IP IP MOV,)  NEXT, ENDCODE
 
: -;  ( -- )
      HERE 2- @ >BODY       \ get previous XT, compute data field
      -2 ALLOT              \ erase the previous XT
      POSTPONE GOTO  ,      \ compile the address for GOTO
      POSTPONE [            \ turn off compiler
      REVEAL
      ?CSP
; IMMEDIATE
 
\ ====================================
\ line drawing
DECIMAL
 : 2ROT ( d1 d2 d3 -- d2 d3 d1) S" 2>R 2SWAP 2R> 2SWAP" EVALUATE ; IMMEDIATE
 : 4DUP ( d1 d2 -- d1 d2 d1 d2) S" 4TH 4TH 4TH 4TH" EVALUATE ; IMMEDIATE
 
CODE MIDPOINT   *SP+ TOS ADD,  TOS INC,  TOS 1 SRA,  NEXT, ENDCODE ( + 1+ 2/ )
CODE |-|        *SP+ TOS SUB,  TOS ABS,  NEXT, ENDCODE
 
DECIMAL
: LINE ( x1 y1 x2 y2 -- )
\ ANS version of Dr. Ting's recursive line R.I.P.
    4DUP  ROT |-| >R |-| R> MAX
    2 <
    IF  2DROP PLOT  EXIT
    THEN
    4DUP
    ROT MIDPOINT >R MIDPOINT
    R> 2DUP 2ROT
    RECURSE RECURSE
-;
 
0 VALUE x
0 VALUE y
 
: MOVETO ( x y -- ) TO y   TO x ;
: LINETO  ( x y -- ) 2DUP x y LINE MOVETO ;
 
\ no safety net !!
: HLINE ( x y len ) >R MOVETO R>  0 DO  x I +  y  PLOT  LOOP ;
: VLINE ( x y len ) >R MOVETO R>  0 DO  y  x I +  PLOT  LOOP ;
 
 
