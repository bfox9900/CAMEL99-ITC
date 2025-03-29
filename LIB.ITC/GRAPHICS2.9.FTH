\ Graphics2 Mode V2.9 for Camel99 Forth Dec 2022 BJF 
\ Referenced TI-FORTH: 
( CONVERT TO GRAPHICS2 MODE CONFIG 14SEP82 LAO)

\ Test results using simple program
\ V2.1  Forth with text macros   
\ 2.7   critical VOR VERASE and XY-offset as CODE
\ 2.8   PIXPOS re-coded in ASM, LINE uses tail called optimization
\ 2.9   DXY? removes 1 4DUP call. MID written in code

\ COMPILES under ITC ONLY
CR .( Two colour bit map mode )  

NEEDS DUMP      FROM DSK1.TOOLS  
NEEDS MOV,      FROM DSK1.ASM9900 
NEEDS VALUE     FROM DSK1.VALUES 
NEEDS CHARSET   FROM DSK1.CHARSET 
NEEDS ARRAY     FROM DSK1.ARRAYS 
NEEDS 4TH       FROM DSK1.3RD4TH \ fast access to deep stack items 

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

VARIABLE STYLUS   \ usage:  PENCIL STYLUS !   ERASER STYLUS !

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
: PLOT   ( x y -- ) S" PIXPOS STYLUS PERFORM " EVALUATE ; IMMEDIATE 

\ ====================================
\ line drawing 
DECIMAL 
: 2ROT ( d1 d2 d3 -- d2 d3 d1) S" 2>R 2SWAP 2R> 2SWAP" EVALUATE ; IMMEDIATE
\ : 4DUP ( d1 d2 -- d1 d2 d1)    S" 4TH 4TH 4TH 4TH" EVALUATE ; IMMEDIATE 
 HEX 
 CODE 4DUP ( a b c d -- a b c d a b c d)
   C046 ,          \ SP  R1 MOV,  \ dup stack pointer    \  14
   0646 , C584 ,   \ TOS PUSH,    ( -- a b c d d)        \  28
   0226 , FFFA ,   \ SP -6 AI,    \ make some room       \  12
   C5B1 ,          \ R1 *+ *SP MOV,                      \  28
   C9B1 , 0002 ,   \ R1 *+ 2 (SP) MOV,                   \  30
   C9B1 , 0004 ,   \ R1 *+ 4 (SP) MOV,                   \  30
   NEXT,                                           \ TOTAL 142
 ENDCODE     

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

HEX
\ : DXY  ( x y x2 y2 -- dY dX) ROT - ABS -ROT - ABS  ;
: X1   3 (SP) ;
: Y1   2 (SP) ;
: X2   1 (SP) ;
: Y2   *SP  ;

CODE DXY?   ( x y x2 y2 --x y x2 y2 ?)
      TOS PUSH,  
   Y2 TOS MOV, 
    Y1 Y2 SUB, 
       Y2 ABS, 

    X1 X2 SUB, 
       X2 ABS, 
\ MAX     
    *SP TOS CMP, 
    LO IF, TOS POP, 
    ELSE,   SP INCT, 
    ENDIF, 
\ 2 < 
    TOS 2 CI, 
    LO IF, TOS SETO, 
    ELSE,  TOS CLR, 
    ENDIF,
    NEXT,
ENDCODE


  \ : MID  + 1+ 2/    \ compute mid points 
  \  + 1+ 2/ R>           

CODE MID ( x1 y1 x2 y2 -- n )
    A136 , \ *SP+ TOS ADD, \ +
    0584 , \      TOS INC, \ 1+
    0814 , \ TOS  1  SRA, \ 2/
    NEXT,
ENDCODE     

DECIMAL 
: LINE ( x1 y1 x2 y2 -- )
\ ANS version of Dr. Ting's recursive line.  R.I.P.
    4DUP DXY? IF  2DROP PLOT  EXIT THEN 
    4DUP ROT 
    MID >R MID R> 
    2DUP 2ROT RECURSE RECURSE ;

\ : LINE ( x1 y1 x2 y2 -- )
\ ANS version of Dr. Ting's recursive line R.I.P.
\    4DUP  ROT - ABS >R - ABS R> 
\    MAX 2 <
\    IF  2DROP PLOT  EXIT THEN
\    4DUP  ROT + 1+ 2/ >R 
\    + 1+ 2/ R>
\    2DUP 2ROT 
\    RECURSE RECURSE -;
 
0 VALUE x
0 VALUE y 

: MOVETO ( x y -- ) TO y   TO x ;
: LINETO  ( x y -- ) 2DUP x y LINE MOVETO ;

\ no safety net !! 
: HLINE ( x y len ) >R MOVETO R>  0 DO  x I +  y  PLOT  LOOP ; 
: VLINE ( x y len ) >R MOVETO R>  0 DO  y  x I +  PLOT  LOOP ; 

HERE SWAP - DECIMAL . 
