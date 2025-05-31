\ BRICKS Demo CAMEL99 Forth saved as EA5 program   Apr 2021  Fox
\ Update May 30 2025, removed variables, used DATA stack
\ based on a BASIC demo by @sometimes99er  Atariage.com
\
\ INCLUDE DSK1.TOOLS
INCLUDE DSK1.GRAFIX
INCLUDE DSK1.RANDOM  \ *NEW*
INCLUDE DSK1.MACROS
INCLUDE DSK1.MARKER

CR .( Compiling BRICKS...)

HERE  ( for measuring size of program code)

HEX
CREATE BRICK1  0000 , 0000 , 0000 , 3F7F ,
CREATE BRICK2  0103 , 0303 , 0303 , FFFF ,

DECIMAL
: BRICKS ( -- )
    7 0 DO
        BRICK1 I 8* 40 + CHARDEF
        BRICK2 I 8* 41 + CHARDEF
    LOOP
;

HEX
CREATE SHADOWS
  0000 , 0000 , 0000 , 0000 ,
  8000 , 0000 , 0000 , 0000 ,
  3F00 , 0000 , 0000 , 0000 ,
  FF00 , 0000 , 0000 , 0000 ,
  0000 , 8080 , 8080 , 8080 ,
  8000 , 8080 , 8080 , 8080 ,
  3F00 , 8080 , 8080 , 8080 ,
  FF00 , 8080 , 8080 , 8080 ,

DECIMAL
: DEF-SHADOWS    SHADOWS  32 ]PDT  64 VWRITE ;

DECIMAL
: SET-COLORS
     5  3  4 COLOR     6  5  6 COLOR
     7  7  9 COLOR     8  9 10 COLOR
     9 11 12 COLOR    10 13  3 COLOR
    11 15 16 COLOR
;

\ rather than computing VDP address from row/col every time
\ we use translation functions on the initial address
MACRO >Right    " 2+"          ( Vaddr -- vaddr' )
MACRO >Down     " C/L@ +"      ( Vaddr -- vaddr' )
MACRO >Corner   " C/L@ + 1+"   ( Vaddr -- vaddr' )
MACRO >Diagonal " C/L@ + 2+"   ( Vaddr -- vaddr' )

\ combine char & char+1 into an integer and write in 1 operation
MACRO .BRICK  " DUP 1+ SWAP FUSE  OVER V!"  ( Vaddr char -- Vaddr)
MACRO SHADOW? " DUP VC@ DUP 39 <"  ( Vaddr -- Vaddr ?)

: ?DIAGLINE   SHADOW? IF  1 OR SWAP VC! EXIT   THEN 2DROP ;
: ?DWNLINE    SHADOW? IF  2 OR SWAP VC! EXIT   THEN 2DROP ;
: ?CLINE      SHADOW? IF  3 OR SWAP VC! EXIT   THEN 2DROP ;
: ?RLINE      SHADOW? IF  4 OR SWAP VC! EXIT   THEN 2DROP ;

DECIMAL
: GO
    GRAPHICS
    14 SCREEN
    DEF-SHADOWS
    BRICKS
    SET-COLORS
    BEGIN
      BEGIN
        30 RND 23 RND >VPOS DUP ( -- Vaddr Vaddr )
        V@ SPLIT  \ read 2 bytes and split them
        40 <  SWAP 40 < AND
      WHILE
       ( -- Vaddr) 7 RND 8* 40 + .BRICK
        DUP >Right    ?RLINE
        DUP >Down     ?DWNLINE
        DUP >Corner   ?CLINE
            >Diagonal ?DIAGLINE
      REPEAT
      DROP
    AGAIN
;

HERE SWAP -
CR DECIMAL . .( bytes added to system)

CR .( Building binary image)
: COLD    WARM  GO  ;

 LOCK
 INCLUDE DSK1.SAVESYS
 CR
 ' COLD  SAVESYS DSK3.BRICKSEXE
