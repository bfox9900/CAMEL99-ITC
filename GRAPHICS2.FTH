\ Graphics2 Mode for Camel99 Forth Dec 2022 BJF 
\ Referenced TI-FORTH: ( CONVERT TO GRAPHICS2 MODE CONFIG 14SEP82 LAO)

\ NEEDS DUMP        FROM DSK1.TOOLS  
NEEDS VALUE       FROM DSK1.VALUES 
NEEDS CHARSET     FROM DSK1.CHARSET 
NEEDS ARRAY       FROM DSK1.ARRAYS 
NEEDS 4TH         FROM DSK1.3RD4TH   \ fast access to deep stack items 
NEEDS DEFER       FROM DSK1.DEFER 

CR .( compiling two-colour bitmap mode... )  
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

: CLEAR   ( -- )  PDT  1800  0 VFILL ;    \ ERASE pattern table

: COLOR   ( fg bg --)     
      SWAP 4 LSHIFT SWAP +    \ merge colors into a byte 
      CTAB 1800  ROT VFILL ;  \ init color table

: INIT-IMAGE ( -- ) 
    -1 IMG 300 BOUNDS DO  1+ DUP 0FF AND I VC!  LOOP  DROP ;

HEX 
\ machine Forth macros make it easy to create very fast constant arrays
: 2*,     ( n -- 2(n)   0A14 , ;  \ TOS  1 SLA, ("CELLS")
: ()@,   ( addr -- )    C124 , ( addr) , ;  \ addr(TOS) TOS MOV,

CREATE BITS ( -- addr) 80 , 40 , 20 , 10 , 8 , 4 , 2 , 1 , 
CODE >BIT ( 0..7 -- char)  2*,  BITS ()@,  NEXT, ENDCODE  

\ drawing code ...
HEX
: VAND    ( c Vaddr -- ) DUP>R VC@ AND  R> VC! ;

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
   0F1 7 VWTR        \ screen background colour white on transparent 
    0E0 DUP VDPR1 C! 1 VWTR   \ set mode, copy into memory for system  
    0 0 AT-XY
    4 VMODE !  
    0 837A C!  ;      \ highest sprite in auto-motion 


\ Compute offset into pattern table per: 
\ TI Video Display Processors, Programmer's Guide

\ : X-OFF  ( x -- bitmask HorOffset)  0 8 UM/MOD 8*   >R BITS@  R> ;
\ : Y-OFF  ( y -- VertOffset)     0 8 UM/MOD >< + ;

: PIXPOS ( x y -- bit Vaddr)  
       >R  
       0 8 UM/MOD 8*  >R >BIT R>
       R> 0 8 UM/MOD >< + + 
       PDT + ; 

: PLOT   ( x y -- ) PIXPOS STYLUS ;

DECIMAL 
: 2ROT ( d1 d2 d3 -- d2 d3 d1) S" 2>R 2SWAP 2R> 2SWAP" EVALUATE ; IMMEDIATE
: 4DUP ( d1 d2 -- d1 d2 d1)    S" 4TH 4TH 4TH 4TH" EVALUATE ; IMMEDIATE 

HEX
\ manual tail call optimizer 
CODE GOTO   C259 ,  ( *IP IP MOV,)  NEXT, ENDCODE
: -;  ( -- ) 
      HERE 2- @ >BODY       \ get previous XT, compute data field
      -2 ALLOT              \ erase the previous XT
      POSTPONE GOTO  ,      \ compile the address for GOTO
      POSTPONE [            \ turn off compiler
      REVEAL
      ?CSP
; IMMEDIATE

: LINE ( x1 y1 x2 y2 -- )
\ ANS version of Dr. Ting's recursive line R.I.P.
    4DUP  ROT - ABS >R - ABS R> 
    MAX 2 <
    IF  2DROP PIXPOS STYLUS  EXIT THEN

    4DUP  ROT + 1+ 2/ >R 
    + 1+ 2/ R>
    2DUP 2ROT 
    RECURSE RECURSE -;
    
HERE SWAP - DECIMAL . .( bytes)
