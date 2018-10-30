\ alpha intelligence demonstration using characters

INCLUDE DSK1.TOOLS
INCLUDE DSK1.GRAFIX
INCLUDE DSK1.RANDOM

MARKER ALPHA
\ ==================================
\ character patterns
HEX
 00FE FEFE FEFE FEFE PATTERN: REDBRICK
 3C7E DBFF DBE7 7E3C PATTERN: HAPPYFACE
 3C7E DBFF E7DB 7E3C PATTERN: SADFACE
 0022 5508 C92A 1C3E PATTERN: PLANT

\ named chars
DECIMAL
160 CONSTANT ALPHA-GUY
168 CONSTANT BRICK
176 CONSTANT FOOD

\ define chars
 REDBRICK  BRICK CHARDEF   BRICK  SET#  7 15 COLOR
 PLANT    FOOD CHARDEF   FOOD SET# 13 1 COLOR

: CLIP       ROT MIN MAX ;

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
\ motion control

CREATE VECTOR 0 , 0 ,
CREATE MY-XY  RNDY , RNDX ,    \ independant cursor for alpha guy

: RNDV   ( -- -1 0 1 )  3 RND 1- ;

: NON-0  ( -- n)
             BEGIN
                RNDV DUP 0 <>
             UNTIL ;

: NEW-VECTORS  ( -- X Y)      \ we need to prevent a (0,0) vector condition
               RNDV DUP 0=    \ If 1st # is 0
               IF    NON-0    \ wait for a non-zero 2nd #
               ELSE  RNDV
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
     ." Vector"  VECTOR 2@  2 .R ." ," 2 .R
     SPACE ." Trys " TRYS @ 2 .R
     SPACE ." Energy " SPEED @ 150 - ABS 3 .R ;

: SAD         ALPHA-GUY  SADFACE   OVER CHARDEF    SET#  9 1 COLOR  ;
: HAPPY       ALPHA-GUY  HAPPYFACE OVER CHARDEF    SET# 12 1 COLOR  ;

: .PLANT      176 RNDY RNDX >VPOS  VC! ;

: PLANTS      RNDY 0 DO  .PLANT LOOP ;

: SPEED!     ( n -- ) 5 150 CLIP  SPEED ! ;
: SPEED++    ( -- ) SPEED @ 35 - SPEED! ;   \ speed is inverse
: SPEED--    ( -- ) SPEED @ 1+  SPEED! ;

: EAT        ( -- )
             BL NEXT-POS >VPOS VC!
             SPEED++ ;

: CLEAR-AHEAD? ( -- ?) NEXT-POS READ-CHAR  BL = ;
: FOOD?        ( -- ?) NEXT-POS READ-CHAR  FOOD = ;

: ALPHA-THINK  ( -- )
            SAD SPEED--                \ change face & color while thinking
            TRYS OFF                   \ reset the trys counter
            BEGIN
               1 TRYS +!               \ count the try
               CHANGE-DIR              \ get new direction
               .BRAIN 50 MS                                               
               CLEAR-AHEAD?
            UNTIL
            HAPPY   ;

DECIMAL
: RUN      ( -- )
       BEGIN
           PAGE 4 10 AT-XY ." Alpha Intelligence Demo" 1000 MS
           PAGE
           16 SCREEN
           .BORDER  .WALLS  PLANTS
           HAPPY SHOW-MAN
           CHANGE-DIR
           150 SPEED!     \ 150 is slow, longest delay
           BEGIN
              FOOD? IF BEEP EAT THEN
              CLEAR-AHEAD?
              IF   MOVE-MAN   \ if true
              ELSE ALPHA-THINK             \ otherwise
              THEN SPEED @ MS
              KEY?
           UNTIL
           ?BREAK
        AGAIN ;

