\ alpha intelligence demonstration with CRAZY behavior updated Mar 2021  Fox

NEEDS DUMP  FROM DSK1.TOOLS
NEEDS COLOR FROM DSK1.GRAFIX
NEEDS RND   FROM DSK1.RANDOM
NEEDS HZ    FROM DSK1.SOUND
NEEDS .R    FROM DSK1.UDOTR 

VARIABLE SPEED
 
\ ==================================
\ sound words
DECIMAL
: SNDINIT     GEN4 3 NOISE MUTE
              GEN3 1500 HZ MUTE ;
 
: BUZZ        GEN3 1250 SPEED @ - HZ   GEN4 14 4 RND + DB ;
: ANGRY       GEN3 1350 200 RND + HZ   GEN4  6 2 RND + DB ;


\ named chars
DECIMAL
160 CONSTANT ALPHA-FLY
168 CONSTANT BRICK


\ ==================================
\ character patterns
HEX
 00FE FEFE FEFE FEFE PATTERN: REDBRICK
 3C7E DBFF DBE7 7E3C PATTERN: HAPPYFACE
 3C7E DBFF E7DB 7E3C PATTERN: SADFACE

\ 8 fly patterns for 8 compass points
CREATE NFLY  2418 , 3C7E , FFDB , 1800 ,
CREATE SFLY  0018 , DBFF , 7E3C , 1824 ,
CREATE WFLY  0C1C , B87E , 7EB8 , 1C0C ,
CREATE EFLY  3038 , 1D7E , 7E1D , 3830 ,
CREATE NWFLY 2020 , FF3F , 3C3E , 3630 ,
CREATE NEFLY 0404 , FFFC , 3C7C , 6C0C ,
CREATE SWFLY 3036 , 3E3C , 3FFF , 2020 ,
CREATE SEFLY 0C6C , 7C3C , FCFF , 0404 ,

DECIMAL
CREATE DIRS  \ 2d array of fly patterns in 8 compass directions
    0000 ,   0000 ,  0000  ,  0000 ,
    NWFLY ,  NFLY ,  NEFLY ,  WFLY ,  
    0000  ,  EFLY ,  SWFLY ,  SFLY ,  
    SEFLY ,  0000 ,  0000  ,  0000 ,

DECIMAL
: [,]   ( row col addr -- ) SWAP CELLS +  SWAP 3 * CELLS + ;

: NORM  ( x y -- y' x') 2+ SWAP 2+ ;

: ]POINT  ( x y -- ) NORM DIRS [,] @ ALPHA-FLY CHARDEF ;

\ define chars
 REDBRICK  BRICK CHARDEF   BRICK SET#  7 15 COLOR

: CLIP   ( n low hi -- n') ROT MIN MAX ;

: RNDX   ( -- x)  23 RND 2 22 CLIP ;
: RNDY   ( -- y)  33 RND 2 30 CLIP ;

: .BORDER   ( -- )
          \ col row
             0   1 BRICK 32 HCHAR
             0  23 BRICK 32 HCHAR
             0   1 BRICK 23 VCHAR
            31   1 BRICK 23 VCHAR ;
 
: .WALLS
            RNDY  RNDX BRICK 10 VCHAR
            RNDY  RNDX BRICK 18 HCHAR
            RNDY  RNDX BRICK  8 HCHAR
            RNDY  RNDX BRICK 10 VCHAR
            RNDY  RNDX BRICK  4 VCHAR
            RNDY  RNDX BRICK  3 VCHAR
            RNDY  RNDX BRICK  8 HCHAR
            RNDY  RNDX BRICK 10 VCHAR ;

\ ==================================
\ double variable hold Y and X
CREATE VECTOR 0 , 0 ,
CREATE MY-XY  10 , 10 ,    \ independant cursor for alpha guy
 
: RNDV     ( -- -1 0 1 )  3 RND 1- ;
: NON-0    ( -- n)  BEGIN  RNDV ?DUP UNTIL ;
 
: NEW-VECTORS  ( -- X Y)      \ we need to prevent a (0,0) vector condition
               RNDV DUP 0=    \ If 1st # is 0
               IF    NON-0    \ wait for a non-zero 2nd #
               ELSE  RNDV
               THEN ;

: CHANGE-DIR   ( -- )  NEW-VECTORS 2DUP VECTOR 2! ]POINT ;

: VECTOR@      ( --  dx dy)  VECTOR 2@ ;

\ Forth vector addition
\ : VECT+        ( x y dx dy -- x' y' ) ROT +  -ROT + SWAP ;

\ Using machine code
 HEX
 CODE VECT+ ( dx dy x y -- x' y')  \ 6x FASTER than Forth version
           C236 , \ *SP+ W MOV,
           A136 , \ *SP+ TOS A,
           A588 , \  W  *SP  A,
           NEXT,
           ENDCODE

 DECIMAL
\ direct memory screen control
: GETXY        ( -- x y) MY-XY 2@ ;
: PUT-CHAR     ( c -- ) GETXY >VPOS VC! ;
: ERASE-FLY    ( -- )   BL PUT-CHAR ;
: SHOW-FLY    ( -- )   ALPHA-FLY PUT-CHAR ;

: SAD         ALPHA-FLY ( AFLY   OVER CHARDEF)   SET#  9 1 COLOR ;
: HAPPY       ALPHA-FLY ( AFLY   OVER CHARDEF)   SET#  2 1 COLOR ;


: READ-CHAR    ( Y X -- c) >VPOS VC@ ;  \ read char without moving cursor
: NEXT-POS     ( -- Y X ) GETXY VECTOR@ VECT+  ;
 
: MOVE-FLY    ( -- )  ERASE-FLY  NEXT-POS MY-XY 2!  SHOW-FLY ;

DECIMAL
VARIABLE TRYS

\ print right justified n spaces
: .VECTOR  ." Vector"  VECTOR 2@  2 .R ." ," 2 .R ;
: .TRYS    ." Trys "   TRYS @     2 .R ;
: .SPEED   ." Speed "  SPEED @    3 .R ;
: CLRLN    AT-XY VPOS  C/L@  BL VFILL ;
: .BRAIN  ( -- )  0 0 CLRLN  .VECTOR SPACE .TRYS SPACE .SPEED ;

: LOOK-AHEAD   ( -- c) NEXT-POS READ-CHAR ;

: CLEAR-AHEAD? ( -- ?) LOOK-AHEAD  BL = ;
 
: ALPHA-THINK  ( -- )
            SAD                        \ change face & color while thinking
            TRYS OFF                   \ reset the trys counter
            BEGIN
               ANGRY
               CHANGE-DIR              \ get new direction
               1 TRYS +!               \ count the try
               .BRAIN                  \ report to screen
              CLEAR-AHEAD?
            UNTIL
            HAPPY  BUZZ ;

: CRAZY ( -- )      \ crazy random movement
        100 RND 10 <
        IF
          CHANGE-DIR BUZZ
          200 RND  30 MAX DUP SPEED !  MS
        THEN ;

: FLYBRAIN  ( -- )
        200 RND 100 + 0
        DO
           CLEAR-AHEAD?
           IF   MOVE-FLY
           ELSE ALPHA-THINK
           THEN SPEED @ MS
           ?TERMINAL IF SILENT TRUE ABORT" HALT!" THEN
           CRAZY
         LOOP
;

DECIMAL
: RUN      ( -- )
       BEGIN
           16 SCREEN
           PAGE 4 10 AT-XY ." Fly Intelligence Demo" 1000 MS
           PAGE  .BORDER  .WALLS
           HAPPY SHOW-FLY
           CHANGE-DIR
           60 SPEED !
           SNDINIT
           BEGIN
              FLYBRAIN
              KEY?
              SILENT 1000 RND MS
           UNTIL
           SILENT
           ?TERMINAL IF ABORT THEN
        AGAIN ;
CR
CR .( -- Type RUN to start the program)
 
 
 
