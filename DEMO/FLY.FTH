\ alpha intelligence demonstration with a Fly graphic

\ INCLUDE DSK1.TOOLS
INCLUDE DSK1.GRAFIX
INCLUDE DSK1.RANDOM
INCLUDE DSK1.SOUND

VARIABLE SPEED

\ ==================================
\ sound words
DECIMAL
: SNDINIT     GEN4 3 NOISE MUTE    \ MODE 3: osc 3 controls OSC 4 frequency
              GEN3 1300 HZ MUTE ;

DECIMAL
: HERZ ( n -- n')  15 * HZ  ;  \ convert n -> Hz for NOISE 3 mode.

\             Osc 3 freq. ctrl       Osc 4 volume control
\            ---------------------  --------------------
: BUZZ        GEN3 87  5 RND + HERZ   GEN4 12 4 RND + DB ;
: ANGRY       GEN3 90 10 RND + HERZ   GEN4  6 2 RND + DB ;

\ ==================================
\ character patterns
HEX
 00FE FEFE FEFE FEFE PATTERN: REDBRICK
 3C7E DBFF DBE7 7E3C PATTERN: HAPPYFACE
 3C7E DBFF E7DB 7E3C PATTERN: SADFACE

\ fly's direction patterns
0044 3838 7CFE EE44 PATTERN: NORTHFLY
0060 F27C 3C7C F260 PATTERN: EASTFLY
0006 4F3E 3C3E 4F06 PATTERN: WESTFLY
0044 EEFE 7C38 3844 PATTERN: SOUTHFLY
0808 7CFF 7C1C 1C08 PATTERN: NORTHEASTFLY
1010 3EFF 3E38 3810 PATTERN: NORTHWESTFLY
1038 383E FF3E 1010 PATTERN: SOUTHWESTFLY
081C 1C7C FF7C 0808 PATTERN: SOUTHEASTFLY

\ named chars
DECIMAL
160 CONSTANT THE-FLY
168 CONSTANT BRICK

\ define chars
 REDBRICK  BRICK CHARDEF   BRICK SET#  7 15 COLOR
 NORTHFLY  THE-FLY CHARDEF

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
            RNDY  RNDX BRICK 10 VCHAR
            RNDY  RNDX BRICK  5 HCHAR
            RNDY  RNDX BRICK  3 VCHAR ;

\ ==================================
\ double variable hold Y and X
CREATE VECTOR 0 , 0 ,
CREATE MY-XY  0 , 0 ,    \ independant cursor for alpha guy

: RNDV     ( -- -1 0 1 )  3 RND 1- ;
: NON-0    ( -- n)  BEGIN  RNDV ?DUP UNTIL ;

: NEW-VECTORS  ( -- X Y)      \ we need to prevent a (0,0) vector condition
               RNDV DUP 0=    \ If 1st # is 0
               IF    NON-0    \ wait for a non-zero 2nd #
               ELSE  RNDV
               THEN ;

\ direction testers
: EAST?    ( y x -- y x ? ) 2DUP 0= SWAP 0> AND ;
: NTHEAST? ( y x -- y x ? ) 2DUP 0< SWAP 0> AND ;
: STHEAST? ( y x -- y x ? ) 2DUP 0> SWAP 0> AND ;
: WEST?    ( y x -- y x ? ) 2DUP 0= SWAP 0< AND ;
: NTHWEST? ( y x -- y x ? ) 2DUP 0< SWAP 0< AND ;
: STHWEST? ( y x -- y x ? ) 2DUP 0> SWAP 0< AND ;
: SOUTH?   ( y x -- y x ? ) 2DUP 0> SWAP 0= AND ;
: NORTH?   ( y x -- y x ? ) 2DUP 0< SWAP 0= AND ;

\ change the fly's character to point in the correct direction
: ROTATE-FLY  ( x y -- )
          EAST?    IF 2DROP  EASTFLY      THE-FLY CHARDEF   EXIT THEN
          WEST?    IF 2DROP  WESTFLY      THE-FLY CHARDEF   EXIT THEN
          NORTH?   IF 2DROP  NORTHFLY     THE-FLY CHARDEF   EXIT THEN
          NTHEAST? IF 2DROP  NORTHEASTFLY THE-FLY CHARDEF   EXIT THEN
          STHEAST? IF 2DROP  SOUTHEASTFLY THE-FLY CHARDEF   EXIT THEN
          SOUTH?   IF 2DROP  SOUTHFLY     THE-FLY CHARDEF   EXIT THEN
          NTHWEST? IF 2DROP  NORTHWESTFLY THE-FLY CHARDEF   EXIT THEN
          STHWEST? IF 2DROP  SOUTHWESTFLY THE-FLY CHARDEF   EXIT THEN
          2DROP  ;

: CHANGE-DIR   ( -- )  NEW-VECTORS 2DUP VECTOR 2!  ROTATE-FLY ;

: VECTOR@      ( --  dx dy)  VECTOR 2@ ;
\ : VECT+        ( x y dx dy -- x' y' ) ROT +  -ROT + SWAP ;

HEX
CODE VECT+ ( dx dy x y -- x' y')  \ 6x FASTER than Forth version
           C236 , \ *SP+ W MOV,
           A136 , \ *SP+ TOS A,
           A588 , \  W  *SP  A,
           NEXT,
           ENDCODE

DECIMAL
\ direct memory screen control
: >VPOS        ( Y X -- vaddr)  C/L@ * + ;
: GETXY        ( -- x y) MY-XY 2@ ;
: PUT-CHAR     ( c -- ) GETXY >VPOS VC! ;
: ERASE-FLY    ( -- )   BL PUT-CHAR ;
: SHOW-FLY    ( -- )   THE-FLY PUT-CHAR ;

: READ-CHAR    ( Y X -- c) >VPOS VC@ ;  \ read char without moving cursor
: NEXT-POS     ( -- Y X ) GETXY VECTOR@ VECT+  ;

: MOVE-FLY    ( -- )  ERASE-FLY  NEXT-POS MY-XY 2!  SHOW-FLY ;

DECIMAL
VARIABLE TRYS

\ print right justified n spaces
: .R   ( n n -- )  >R DUP ABS 0 <# #S ROT SIGN #>  R> OVER - SPACES TYPE ;
: .VECTOR  ." Vector"  VECTOR 2@  2 .R  2 .R ." , ";
: .TRYS    ." Trys"   TRYS @  2 .R ." , ";
: .SPEED   ." Speed"  SPEED @ 3 .R ;
: .BRAIN  ( -- )  0 0 CLRLN  .VECTOR SPACE .TRYS SPACE .SPEED  ;
: SAD         THE-FLY SET#  7 1 COLOR  ;
: HAPPY       THE-FLY SET#  2 1 COLOR  ;
: LOOK-AHEAD   ( -- c) NEXT-POS READ-CHAR ;
: CLEAR-AHEAD? ( -- ?) LOOK-AHEAD  BL = ;

: THINK  ( -- )
            SAD                        \ change face & color while thinking
            TRYS OFF                   \ reset the trys counter
            BEGIN
               ANGRY
               CHANGE-DIR              \ get new direction
               .BRAIN                  \ report to screen
               1 TRYS +!               \ count the try
               ?TERMINAL IF EXIT THEN  \ escape if it gets trapped
               CLEAR-AHEAD?
            UNTIL
            HAPPY  ;

: ?REST        ( -- ) 80 RND 7 = IF  SILENT  800 RND MS  CHANGE-DIR THEN ;
: CHANGE-SPEED ( -- ) 35 30  RND + DUP SPEED !  MS  ;

: ?HALT        ( -- )
        ?TERMINAL
        IF SILENT CLEAR
          ." Exit program? (Y/N)"
          KEY [CHAR] Y =
          IF
             BYE
          THEN
       THEN ;

DECIMAL
: RUN      ( -- )
      BEGIN
         SNDINIT SILENT
         16 SCREEN
         PAGE 4 11 AT-XY ." Fly Intelligence Demo"  1000 MS
         PAGE  .BORDER  .WALLS
         RNDY RNDX MY-XY 2!
         HAPPY SHOW-FLY
         CHANGE-DIR
         BEGIN
           CLEAR-AHEAD?
           IF   MOVE-FLY
           ELSE THINK
           THEN CHANGE-SPEED
           BUZZ ?REST
           KEY?
         UNTIL
         ?HALT
      AGAIN ;
