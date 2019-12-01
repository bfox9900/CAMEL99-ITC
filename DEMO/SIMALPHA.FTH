\ alpha intelligence demonstration using characters

INCLUDE DSK1.TOOLS
INCLUDE DSK1.GRAFIX
INCLUDE DSK1.RANDOM
INCLUDE DSK1.MARKER

MARKER ALPHA
\ ==================================
\ character patterns
HEX
 00FE FEFE FEFE FEFE PATTERN: REDBRICK
 3C7E DBFF DBE7 7E3C PATTERN: HAPPYFACE
 3C7E DBFF E7DB 7E3C PATTERN: SADFACE

\ named chars
DECIMAL
160 CONSTANT ALPHA-GUY
168 CONSTANT BRICK

\ define chars
 REDBRICK  BRICK CHARDEF   BRICK SET# 7 15 COLOR

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
CREATE MY-XY  RNDY , RNDX ,    \ independant cursor for alpha guy

: RNDV     ( -- -1 0 1 )  3 RND 1- ;
: NON-0    ( -- n)  BEGIN  RNDV ?DUP UNTIL ;

: NEW-VECTORS  ( -- X Y)      \ we need to prevent a (0,0) vector condition
               RNDV DUP     \ If 1st # <> 0
               IF    RNDV   \ get the second #
               ELSE  DROP NON-0 RNDV  \ else wait for a non-zero 2nd #
               THEN ;

: CHANGE-DIR   ( -- )  NEW-VECTORS VECTOR 2! ;

: VECTOR@      ( --  dx dy)  VECTOR 2@ ;
: VECT+        ( x y dx dy -- x' y' ) ROT +  -ROT + SWAP ;

\ direct memory screen control
: >VPOS        ( Y X -- vaddr)  C/L@ * + ;
: GETXY        ( -- x y) MY-XY 2@ ;
: PUT-CHAR     ( c -- ) GETXY >VPOS VC! ;
: ERASE-MAN    ( -- )   BL PUT-CHAR ;
: SHOW-MAN     ( -- )   ALPHA-GUY PUT-CHAR ;

: READ-CHAR    ( Y X -- c) >VPOS VC@ ;  \ read char without moving cursor
: NEXT-POS     ( -- Y X ) GETXY VECTOR@ VECT+  ;

: MOVE-MAN     ( -- ) ERASE-MAN   NEXT-POS MY-XY 2!  SHOW-MAN ;

DECIMAL
VARIABLE TRYS
VARIABLE SPEED

\ print right justified n spaces
: .R   ( n n -- )  >R DUP ABS 0 <# #S ROT SIGN #>  R> OVER - SPACES TYPE ;

: .BRAIN     ( -- )
     0 0 CLRLN
     ." Vector"  VECTOR 2@  2 .R ." ," 2 .R  SPACE ." Trys " TRYS @ 2 .R  ;

: ALPHA-COLOR  ( n -- )  ALPHA-GUY SET# SWAP 1 COLOR ;
: SAD         ALPHA-GUY  SADFACE   OVER CHARDEF    SET#  7 1 COLOR  ;
: HAPPY       ALPHA-GUY  HAPPYFACE OVER CHARDEF    SET# 13 1 COLOR  ;

: LOOK-AHEAD   ( -- c) NEXT-POS READ-CHAR ;

: CLEAR-AHEAD? ( -- ?) LOOK-AHEAD  BL = ;

: ALPHA-THINK  ( -- )
            SAD                        \ change face & color while thinking
            TRYS OFF                   \ reset the trys counter
            BEGIN
              100 MS                   \ slow down to see sad face
              CHANGE-DIR               \ get new direction
              1 TRYS +!                \ count the try
              TRYS @ ALPHA-COLOR       \ change color with each try
              .BRAIN                   \ report to screen
              CLEAR-AHEAD?
            UNTIL
            HAPPY  ;

DECIMAL
: RUN      ( -- )
       BEGIN
           16 SCREEN
           PAGE 4 10 AT-XY ." Alpha Intelligence Demo" 1000 MS
           PAGE  .BORDER  .WALLS
           HAPPY SHOW-MAN
           CHANGE-DIR
           100 SPEED !
           BEGIN
              CLEAR-AHEAD?
              IF   MOVE-MAN
              ELSE ALPHA-THINK
              THEN SPEED @ MS    \ delay
              KEY?
           UNTIL
           ?BREAK
        AGAIN ;

