\ alpha intelligence demonstration with CRAZY behaviour

INCLUDE DSK1.TOOLS
INCLUDE DSK1.GRAFIX
INCLUDE DSK1.RANDOM
INCLUDE DSK1.SOUND

VARIABLE SPEED

\ ==================================
\ sound words
DECIMAL
: SNDINIT     GEN4 3 NOISE MUTE
              GEN3 1500 HZ MUTE ;

: BUZZ        GEN3 1300 SPEED @ - HZ   GEN4 12 4 RND + DB ;
: ANGRY       GEN3 1350 200 RND + HZ   GEN4  6 2 RND + DB ;

\ ==================================
\ character patterns
HEX
 00FE FEFE FEFE FEFE PATTERN: REDBRICK
 3C7E DBFF DBE7 7E3C PATTERN: HAPPYFACE
 3C7E DBFF E7DB 7E3C PATTERN: SADFACE
 42E7 E63C 7E7C 2A49 PATTERN: AFLY

\ named chars
DECIMAL
160 CONSTANT ALPHA-GUY
168 CONSTANT BRICK

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
CREATE MY-XY  RNDY , RNDX ,    \ independant cursor for alpha guy

: RNDV     ( -- -1 0 1 )  3 RND 1- ;
: NON-0    ( -- n)  BEGIN  RNDV ?DUP UNTIL ;

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
: ERASE-FLY    ( -- )   BL PUT-CHAR ;
: SHOW-FLY    ( -- )   ALPHA-GUY PUT-CHAR ;

: READ-CHAR    ( Y X -- c) >VPOS VC@ ;  \ read char without moving cursor
: NEXT-POS     ( -- Y X ) GETXY VECTOR@ VECT+  ;

: MOVE-FLY    ( -- )  ERASE-FLY  NEXT-POS MY-XY 2!  SHOW-FLY ;

DECIMAL
VARIABLE TRYS

\ print right justified n spaces
: .R   ( n n -- )  >R DUP ABS 0 <# #S ROT SIGN #>  R> OVER - SPACES TYPE ;
: .VECTOR  ." Vector"  VECTOR 2@  2 .R ." ," 2 .R ;
: .TRYS    ." Trys "   TRYS @     2 .R ;
: .SPEED   ." Speed "  SPEED @    3 .R ;

: .BRAIN  ( -- )  0 0 CLRLN  .VECTOR SPACE .TRYS SPACE .SPEED  ;

: SAD         ALPHA-GUY  AFLY   OVER CHARDEF    SET#  7 1 COLOR  ;
: HAPPY       ALPHA-GUY  AFLY   OVER CHARDEF    SET#  2 1 COLOR  ;

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
        RNDV 0>     \ if we get 1 ( 33% chance)
        IF
          CHANGE-DIR BUZZ
          100 RND  4 MAX DUP SPEED !  MS
        THEN ;

: FLY  ( -- )
        200 RND 0
        DO
           CLEAR-AHEAD?
           IF   MOVE-FLY
           ELSE ALPHA-THINK
           THEN SPEED @ MS
        LOOP
        SILENT 1000 RND MS ;

DECIMAL
: RUN      ( -- )
       BEGIN
           16 SCREEN
           PAGE 4 10 AT-XY ." Fly Intelligence Demo" 1000 MS
           PAGE  .BORDER  .WALLS
           HAPPY SHOW-FLY
           CHANGE-DIR
           25 SPEED !
           SNDINIT
           BEGIN
              FLY
              KEY?
           UNTIL
           SILENT
           ?TERMINAL IF ABORT THEN
        AGAIN ;
