\ FLOGO   CAMEL99 FORTH LOGO to test GRAPHICS2  Mode  Dec 2022 Brian Fox
\ Based on fignition LOGO https://github.com/AshleyF/FIGTurtle
\ Expanded names from single letter commands for clarity

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


NEEDS PLOT  FROM DSK1.GRAPHICS2B

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

: HUE ( fg -- ) 0 COLOR ;

\ ===============================================
\ screen coordinates
255 CONSTANT XMAX
192 CONSTANT YMAX

XMAX 2/ CONSTANT XCNTR
YMAX 2/ CONSTANT YCNTR

\ state variables
 VARIABLE X      \ turtle x position
 VARIABLE Y      \ turtle y position
 VARIABLE ANGL   \ angle of direction
 VARIABLE Q      \ quadrature?
 VARIABLE W      \ Radian ?

\ ===============================================
\ direction table
DECIMAL
CREATE SINTAB
  000 , 027 , 053 , 079 ,
  104 , 127 , 150 , 171 ,
  190 , 206 , 221 , 233 ,
  243 , 249 , 254 , 255 ,
  000 ,

\ expose the table as a byte array. Use text macro for speed
\ : ]N@ ( ndx -- n) S" N + C@" EVALUATE ; IMMEDIATE

\ FAST array with machine Forth compilers
HEX
: 2*,   ( n -- 2(n)  A104 , ;             \ A R4,R4
: []@,   ( addr -- ) C124 , ( addr) , ;   \ MOV addr@(R4),R4
DECIMAL

CODE SIN ( ndx -- addr)  2*, SINTAB []@,  NEXT, ENDCODE

: >DIR ( angle -- coord)
       DUP>R  ABS >R
       R@ 15 MOD
       R@ 30 MOD 14 > IF 15 SWAP - THEN SIN
       R@ 60 MOD 30 > IF NEGATE    THEN 2R> 2DROP ;

\ =======================================
\ coordinate scaling
\ A little machine code makes a difference
HEX
\ : BYTE   00FF AND ;
\ : 256*     ( --c) ><  BYTE ; \ swap byte is 256 * :-)
\ : 256/    ( --c) 8 RSHIFT  BYTE ;

CODE 256*   06C4 , NEXT, ENDCODE  \ TOS SWPB,
CODE 256/   0984 , NEXT, ENDCODE  \ TOS 8 SRL,

DECIMAL
\ returns scaled,centred X,Y values
: XSCALE  ( --c) 256/ XCNTR +  ;
: YSCALE  ( --c) 256/ YCNTR +  ;

DECIMAL
: [X,Y]  ( -- x y) S" X @ XSCALE Y @ YSCALE" EVALUATE ; IMMEDIATE

\ =======================================
\ plotter control
: PEN-UP          ['] 2DROP IS STYLUS ; \ noop, consumes args
: PEN-DOWN           PENCIL IS STYLUS ;

\ =======================================
\ FLOGO COMMANDS
: DRAW   ( -- )     PEN-DOWN  [X,Y] PLOT ;

: HEAD   ( angle -- ) DUP DUP ANGL !  >DIR Q !
                      45 + 60 MOD     >DIR W ! ;

: GOTO   ( x y -- )   PEN-UP  256* Y !  256* X ! ;
: HOME   ( -- )       PEN-UP   0 0 GOTO  0 HEAD ;
: MOV    ( n -- )     DUP Q @ * X +!   W @ * Y +!  DRAW ;

: TURN   ( angle -- ) ANGL +!  ANGL @ HEAD ;

: FWD  ( n -- )
         1 ?DO
             W @ Y +!
             Q @ X +!
            DRAW
         LOOP ;

: BGN    ( -- )  CLEAR  HOME PEN-DOWN  ;
: END    ( -- )  PEN-UP  BEEP  BEGIN KEY? UNTIL  TEXT ;
: WAIT   PEN-UP  500 MS  ;

DECIMAL
\ primitives
: WALK  ( turns moves loops -- )
  0 ?DO  2DUP FWD TURN   LOOP 2DROP PEN-UP ;

: CIRCLE  ( -- ) 1 4 60 WALK ;

\ =======================================
\ DEMO Programs
: SPIRAL  ( -- ) BGN 15 0 DO  CIRCLE  4 TURN  LOOP              WAIT ;

: SINE    ( x -- ) BGN  255  0 DO  I  I >DIR 2/ 2/ 80 + PLOT  LOOP  WAIT ;

: SQUARE  ( -- ) BGN 4 0 DO 50 FWD 15 TURN   LOOP               WAIT ;
: BURST   ( -- ) BGN 60 0 DO 0 0 GOTO  I HEAD  110 FWD  LOOP    WAIT ;

: STAR    ( -- ) 24 80 5 WALK ;
: STARS   ( -- ) BGN 3 0 DO   STAR 20 TURN   LOOP               WAIT ;

: SQUIRAL ( -- ) BGN -50 50 GOTO  20 0 DO 100 FWD 21 TURN LOOP  WAIT ;
: ROSE    ( -- ) BGN 0 50 0 DO 2+ DUP FWD  14 TURN  LOOP        WAIT ;

\ primitives for flower
: HP      ( -- ) 1 5 15 WALK    -1 2 15 WALK ;
: PETAL   ( -- ) HP 30 TURN  HP 30 TURN      ;
: FLOWER  ( -- ) BGN 15 0 DO   PETAL 4 TURN  LOOP               WAIT ;

: DEMO
  GRAPHICS2

    WHITE HUE SINE
    MAGENTA HUE BURST
    GREEN HUE SQUIRAL
    BLUE HUE SPIRAL
    YELLOW HUE STARS
    RED HUE ROSE
    LTRED HUE FLOWER
    TEXT
    BL CHAR _ FUSE  CURS ! ;
