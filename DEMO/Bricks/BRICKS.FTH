\ BRICKS Demo CAMEL99 Forth saved as EA5 program   Apr 2021  Fox
\ based on a BASIC demo by @sometimes99er  Atariage.com

HERE  ( for measuring size of this code)
\ INCLUDE DSK1.TOOLS
INCLUDE DSK1.GRAFIX
INCLUDE DSK1.RANDOM
\ INCLUDE DSK1.ELAPSE
CR .( Compiling BRICKS...)

\ brick pattern definitions as integers
HEX
CREATE BRICK1  0000 , 0000 , 0000 , 3F7F ,
CREATE BRICK2  0103 , 0303 , 0303 , FFFF ,

\ fastest way to change patterns uses integers
DECIMAL
: BRICKS ( n -- )
     7 0 DO
        BRICK1 I 8* 40 + CHARDEF
        BRICK2 I 8* 41 + CHARDEF
     LOOP
;

\ More familiar way to change patterns ;)
DECIMAL
: SHADOWS
  S" 0000000000000000" 32 CALLCHAR
  S" 8000000000000000" 33 CALLCHAR
  S" 3F00000000000000" 34 CALLCHAR
  S" FF00000000000000" 35 CALLCHAR
  S" 0000808080808080" 36 CALLCHAR
  S" 8000808080808080" 37 CALLCHAR
  S" 3F00808080808080" 38 CALLCHAR
  S" FF00808080808080" 39 CALLCHAR
;

DECIMAL
: SET-COLORS
     5  3  4 COLOR     6  5  6 COLOR
     7  7  9 COLOR     8  9 10 COLOR
     9 11 12 COLOR    10 13  3 COLOR
    11 15 16 COLOR
;

\ Shadow calculators return a VDP address
: Right    ( -- vaddr ) VCOL @ 2+  VROW @    >VPOS ;
: Down     ( -- vaddr ) VROW 2@ 1+           >VPOS ;
: Corner   ( -- vaddr ) VCOL @ 1+  VROW @ 1+ >VPOS ;
: Diagonal ( -- vaddr ) VCOL @ 2+  VROW @ 1+ >VPOS ;

\ emit char & char+1 with one write
: BRICK    ( char -- ) DUP 1+ SWAP FUSE VPOS V! ;
: SHADOW?  ( Vaddr -- Vaddr ?) DUP VC@ DUP 39 < ;

: ?DIAGLINE   SHADOW? IF   1 OR SWAP VC! EXIT   THEN  2DROP ;
: ?DWNLINE    SHADOW? IF   2 OR SWAP VC! EXIT   THEN  2DROP ;
: ?CORNLINE   SHADOW? IF   3 OR SWAP VC! EXIT   THEN  2DROP ;
: ?RLINE      SHADOW? IF   4 OR SWAP VC! EXIT   THEN  2DROP ;

: EMPTY? ( X Y -- ?)
      2DUP AT-XY                \ place cursor
      >VPOS V@ SPLIT  ( -- c c) \ read 2 chars at once then split
      40 < SWAP 40 < ( -- ? ?) AND
;

DECIMAL
: GO
    GRAPHICS
    PAGE 14 SCREEN
    SHADOWS
    BRICKS
    SET-COLORS
    1025 0
    DO
    \ find empty screen location
      30 RND 23 RND EMPTY?
      IF
        7 RND 8* 40 + BRICK
        Right ?RLINE
        Down ?DWNLINE
        Corner ?CORNLINE
        Diagonal ?DIAGLINE
      THEN
    LOOP
    BEEP HONK BEEP
    BEGIN KEY? UNTIL
;

CR
CR .( **Program compiled successfully**)
HERE SWAP -
CR DECIMAL . .( bytes added to system)

 CR .( Creating cold start code)
: COLD    WARM  GO  BYE  ;

 CR .( Locking dictionary )

INCLUDE DSK1.MARKER
LOCK

INCLUDE DSK1.SAVESYS

 CR
 ' COLD  SAVESYS DSK3.BRICKSEXE
