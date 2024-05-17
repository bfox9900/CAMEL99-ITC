\ FLOGO   CAMEL99 FORTH LOGO to test GRAPHICS2  Mode  Dec 2022 Brian Fox 
\ Based on fignition LOGO https://github.com/AshleyF/FIGTurtle

\ MIT License

\ Copyright (c) 2021 Ashley Feniello

\ Permission is hereby granted, free of charge, to any person obtaining a copy
\ of this software and associated documentation files (the "Software"), to deal
\ in the Software without restriction, including without limitation the rights
\ to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
\ copies of the Software, and to permit persons to whom the Software is
\ furnished to do so, subject to the following conditions:

\ The above copyright notice and this permission notice shall be included in all
\ copies or substantial portions of the Software.

\ Jan 2023
\ Expanded names from single letter commands for clarity
\ Rewrite of many primitive words to use Camel99 abilities and Forth Assembler
\ Handed code [X,Y] coordinates word for big speed-up 

NEEDS MOV,  FROM DSK1.ASM9900
NEEDS PLOT  FROM DSK1.GRAPHICS2

\ ===============================================
\ named colors
DECIMAL 
 \ named colors for Graphics programs
: ENUM  ( 0 <text> -- n) DUP CONSTANT  1+ ;

0 ENUM TRANS
  ENUM BLACK
  ENUM MEDGRN
  ENUM LTGRN
  ENUM BLUE
  ENUM LTBLU
  ENUM RED
  ENUM CYAN
  ENUM MEDRED
  ENUM LTRED
  ENUM YELLOW 
  ENUM LTYEL
  ENUM GREEN
  ENUM MAGENTA
  ENUM GRAY
  ENUM WHITE
DROP

: HUE ( fg -- ) 0 SWAP FUSE SCREEN ; 

\ ===============================================
\ TI-99 bit mapped screen coordinates
255 CONSTANT XMAX
192 CONSTANT YMAX

XMAX 2/ CONSTANT XCNTR
YMAX 2/ CONSTANT YCNTR

\ values are slightly faster than variables 
 0 VALUE X      \ turtle x position
 0 VALUE Y      \ turtle y position
 0 VALUE ANGL   \ angle of direction
 0 VALUE DX     \ x vector 
 0 VALUE DY     \ y vector 

\ ===============================================
\ direction table 
DECIMAL
CREATE SINTAB
  000 , 027 , 053 , 079 ,
  104 , 127 , 150 , 171 ,
  190 , 206 , 221 , 233 ,
  243 , 249 , 254 , 255 ,
  000 , 

\ FAST constant array uses machine Forth compilers
HEX
: 2*,    ( n -- 2(n)  A104 , ;            \ A R4,R4
: []@,   ( addr -- ) C124 , ( addr) , ;   \ MOV addr@(R4),R4

DECIMAL
CODE SIN ( n -- sin[x] )  2*, SINTAB []@,  NEXT, ENDCODE

: >DIR ( angle -- coord)
       DUP>R  ABS >R
       R@ 15 MOD
       R@ 30 MOD 14 > IF 15 SWAP - THEN SIN
       R@ 60 MOD 30 > IF NEGATE    THEN 2R> 2DROP ;

\ =======================================
\ coordinate scaling
\ A little machine code makes a difference 
HEX 
\ Old Forth version 
\ : BYTE   00FF AND ;
\ : 256/    ( --c) 8 RSHIFT  BYTE ;
\ : XSCALE  ( c -- c) 256/ XCNTR + BYTE ;
\ : YSCALE  ( c -- c) 256/ YCNTR + BYTE ;
\ : [X,Y]  ( -- x y) S" X XSCALE   Y YSCALE" EVALUATE ; IMMEDIATE 

 CODE [X,Y] ( -- x y) \ return coordinates scaled for 255x192
    TOS PUSH, 
  ' Y >BODY @@ TOS MOV, 
    TOS SWPB,      \ 256* 
    TOS YCNTR AI,  \ add centering offset 
    TOS 0FF ANDI,  \ mask to byte value 

  ' X >BODY @@ W MOV, 
    W SWPB,      \ 256* 
    W XCNTR AI,  \ add centering offset 
    W 0FF ANDI,  \ mask to byte value  
    W PUSH,
    NEXT, 
 ENDCODE 

      
DECIMAL 
\ =======================================
\ plotter control  
: PEN-UP          ['] 2DROP STYLUS ! ; \ noop, consumes args 
: PEN-DOWN           PENCIL STYLUS ! ;

\ =======================================
\ FLOGO COMMANDS
: DRAW   ( -- )  S" [X,Y] PLOT" EVALUATE ; IMMEDIATE 

: (HEAD)  ( -- ) 
    DUP >DIR TO DX          
    45 + 60 MOD >DIR TO DY ;

: HEAD   ( angle -- )  DUP TO ANGL  (HEAD) ;
: GOTO   ( x y -- )   8* TO Y   8* TO X ;
: HOME   ( -- )       0 0 GOTO  0 HEAD ;
: MOV    ( n -- )     DUP DX * +TO X   DY * +TO Y  DRAW ;

: TURN   ( angle -- ) +TO ANGL  ANGL (HEAD) ;

: FWD  ( n -- )
         1 ?DO
             DY +TO Y
             DX +TO X
            DRAW 
         LOOP ;

: CLS   ( -- )  CLEAR  HOME ;

DECIMAL
\ =======================================
\ DEMO Programs
: CIRCLE  ( -- )  60 0 DO  4 FWD  1 TURN  LOOP ; 
: SPIRAL  ( -- )  15 0 DO  CIRCLE  4 TURN  LOOP ;

: SINE    ( X -- )   255  0 DO  I  I >DIR 2/ 2/  80 + PLOT  LOOP ;

: SQUARE  ( -- )  4  0 DO  50 FWD 15 TURN   LOOP ;
: BURST   ( -- )  60 0 DO  0 0 GOTO  I HEAD  110 FWD  LOOP ;

: STAR     5 0 DO  80 FWD  24 TURN  LOOP ; 
: STARS   ( -- )  3 0 DO  STAR  20 TURN  LOOP ;

: SQUIRAL ( -- )  -50 50 GOTO  20 0 DO  100 FWD  21 TURN  LOOP  ;
: ROSE    ( -- )  0 50 0 DO  2+ DUP FWD  14 TURN  LOOP  ;

\ primitives for flower 
: HP  15 0 DO  5 FWD  1 TURN  LOOP  
      15 0 DO  2 FWD -1 TURN  LOOP ; 

: PETAL   ( -- ) HP  30 TURN  HP 30 TURN ;

: FLOWER  ( -- )  15 0 DO   PETAL 4 TURN  LOOP  ;

: DEMO     
  GRAPHICS2 
  PEN-DOWN 
  CLS  WHITE HUE    SINE  
  CLS  MAGENTA HUE  BURST  
  CLS  GREEN HUE    SQUIRAL  
  CLS  BLUE HUE     SPIRAL  
  CLS  YELLOW HUE   STARS  
  CLS  RED HUE      ROSE  
  CLS  LTRED HUE    FLOWER  
  TEXT ;

CR .( Type DEMO )
