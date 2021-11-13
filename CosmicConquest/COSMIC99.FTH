\ COSMIC CONQUEST TI-99 Native version                 Nov 2021 Brian Fox
\ based on Gforth verison by Rick Carlino
\ This version will try to use the features of Camel99 and TI-99 hardware

\ Change log:
\ Replaced all -ROT  with -ROT for speed and 20 bytes space saving
\ Replaced 0 FILL  with ERASE
\ Replace all 1 -   with 1-  save  14 bytes
\ Removed Apple ][ character configuration code

\ Camel99 Optimizations
\ Replaced all 2 *  with CELLS
\ Replaced all 2 /  with 2/
\ Replaced all 4 * with 4*
\ Replaced 8 *  with 8*
\ Replaced ARRAY with MATRIX: (ARRAY is 1D in Forth by convention)
\ Added new mapped characters to charset for "space" graphics
\ Added border characters to create a box on play screen

\ HARNESS99.FTH is my new FIG/ANS translation file
\ Wrote smaller INKEY that has 7 bit out uppercase ALPHA output
\
\ Camel99 Forth Library requirements
\ INCLUDE DSK1.CASE
\ INCLUDE DSK1.UDOTR
\ INCLUDE DSK1.MTASK99

INCLUDE DSK1.TOOLS
INCLUDE  DSK5.HARNESS99  \ use DSK# where you have HARNESS99

HERE
DECIMAL
CR .( constants)
         30 CONSTANT SIZE          ( the size of the galactic MATRIX:)
SIZE CELLS  CONSTANT NO-OF-STARS   ( no. of stars in the galaxy)
SIZE 3 * 2/ CONSTANT NO-OF-PLANETS ( planets in galaxy)

    4 CONSTANT NO-OF-B-HOLES       ( no. of black holes)
  200 CONSTANT W1                  ( weight value assigned to planets in score)
    5 CONSTANT W2                  ( weight assigned to ship and troops)
   10 CONSTANT W3                  ( weight assigned to computers troops)
  100 CONSTANT SPEED               ( how quickly computer moves)

1000 CONSTANT delayms   ( milliseconds to wait for in DELAY)

CR .( variables)
0 VARIABLE BUY-V        ( count to stop player buying every move)
0 VARIABLE C-FLEETS     ( no. of computer fleets)
0 VARIABLE C-LEGIONS    ( no. of computer legions for attacks)
0 VARIABLE C-PLANETS    ( no. of computer planets)
0 VARIABLE CLASS-TOTALS ( computers planets classes totals)
0 VARIABLE COMP-START   ( how quickly computer plays)
0 VARIABLE COMPUTER     ( how quickly computer plays)
0 VARIABLE DIFF         ( difficulty of game 1-4)
0 VARIABLE FLEET#       ( Human player's fleet in use)
0 VARIABLE LEG          ( the no. of legions available to buy)
0 VARIABLE LEN          ( no. of moves remaining in game)
0 VARIABLE NEW          ( how often new fleet created)
0 VARIABLE PLANETS      ( no. of players planets)
0 VARIABLE RAND1        ( first random number seed)
0 VARIABLE RAND2        ( second random number seed)
0 VARIABLE START        ( starting score in the game)
0 VARIABLE TEMP1        ( a temporary storage variable)
0 VARIABLE PRICE
0 VARIABLE TROOPS       ( no. of computers troops in game)
0 VARIABLE VTAX         ( tax collected)
0 VARIABLE X            ( temporary storage for X position)
0 VARIABLE Y            ( temporary storage for Y position)
250 VARIABLE CREDIT     ( players credit in taxes)

CR .( utility words)
: ERASE    ( addr u --)    0 FILL ;
: VBLANK   ( Vaddr u --)   BL VFILL ;
: CENTERED ( addr len -- ) C/L@ OVER - 2/ SPACES  TYPE ; \ print centered
: TAB      ( n -- )        VCOL ! ;
: XY@      ( -- col row)   X @ Y @ ;

HEX
: RKEY?   ( -- c ) 83C8 OFF  KEY? ;   \ enables repeating key for TI-99
: BEEPS   ( n -- ) 0 ?DO BEEP 50 MS LOOP ;
: ?LOWER  ( c -- ?)  [CHAR] a  [CHAR] z 1+  WITHIN ;
: TOUPPER ( c -- c') DUP ?LOWER IF 5F AND  THEN ;
: INKEY   ( -- c)    KEY 7F AND  TOUPPER ;  \ uppercase Alpha, 7 bit output


CR .( Heap management and matrix creators)
\ \\\\\\\\\\\\\\\  TI99 CODE  \\\\\\\\\\\\\\\\\\
\ TI99 has 24K RAM.
\ 8K low RAM, 15K Hi RAM. Matrices need 7.3K
\ Using LOW RAM

\ heap memory analogs to HERE ALLOT C,
: HEAP    H @ ;
: HALLOT  H +! ;
: HC,     HEAP C! ;

\ INIT heap pointer & clean up heap space
HEX  2000 H !
HEAP 2000 ERASE

DECIMAL
CR .( 2D matrices allocated in Camel99 HEAP)
: MATRIX: ( cols rows -- )
   CREATE HEAP ,
          DUP HC, * HALLOT
   DOES> ( n n -- addr )
        @ ROT 1- OVER C@ * + + ;

SIZE SIZE MATRIX: GALAXY ( the galactic MATRIX:)
SIZE SIZE MATRIX: INFO1  ( planetary MATRIX:)
SIZE SIZE MATRIX: INFO2  ( strength MATRIX:)
\  11   11 MATRIX: SCREEN ( the screen MATRIX:)
   2    6 MATRIX: FLEETS ( player fleets info)

\ clarification language
: THEPLANET ( -- addr) XY@ INFO1 ;
: #LEGIONS  ( -- addr) XY@ INFO2 ; \ Legions on the planet
: THEGALAXY ( -- addr) XY@ GALAXY ;

CR .( general utility words)
: DELAY      delayms MS ;       \ MS sleeps task while waiting
: BLANKLN    VPOS C/L@ VBLANK ; \ FAST video memory write

( clear message area on text screen)
: CLEAR-MSGE ( -- ) 18 10 DO   0 I AT-XY BLANKLN  LOOP ;

: PROMPT:   ( -- )   0 10 AT-XY  BLANKLN  ;
: LOPROMPT: ( -- )   0 23 AT-XY  BLANKLN ;

\ clear screen, don't change cursor
: CLEAR-SCREEN ( -- )  0  C/SCR @ BL VFILL ;

\ : CLEAR-DISP ( fill screen MATRIX: with FF's)
\   1 1 SCREEN 121 255 FILL ;

: CLEAR-GALAXY ( fills galactic MATRIX: with NULLS)
   1 1 GALAXY SIZE SIZE * ERASE ;

: CLEAR-INFO ( fills info MATRIX:s with NULLs)
   1 1 INFO1 SIZE SIZE * ERASE
   1 1 INFO2 SIZE SIZE * ERASE ;

: RANDOM1 ( --- ran) ( random number in range 1-SIZE)
   RAND1 @ 37 * 651 + DUP RAND1 ! ABS SIZE MOD 1+ ;

: RANDOM2 ( --- ran ) ( random number in range 1-SIZE)
   RAND2 @ 53 * 773 + DUP RAND2 ! ABS SIZE MOD 1+ ;

\ create a double variable to randomly created coordinates
\ reduces stack juggling in game language
CREATE LASTXY   0 , 0 ,
\ create random coordinates and remember them.
: NEWXY  ( -- n n ) RANDOM1 RANDOM2 2DUP LASTXY 2!  ;
: THIS  ( -- n n ) LASTXY 2@ ;  \ return last NEWXY generated

: WRAPPED ( n --- ng ) ( calculates wrap around of galaxy)
   SIZE 1- + SIZE MOD 1+ ;

\ better number input routine.  ACCEPT is multi-tasking ready
:  INPUT  ( -- n )
          DECIMAL
          BEGIN
            PAD DUP 10 ACCEPT  \ ACCEPT text into temp buffer PAD
            NUMBER?            \ convert the number in PAD
          WHILE                \ while the conversion is bad we do this
              ." ? "
              DROP
          REPEAT ;

\ easier to understand this data by name
1 CONSTANT [MY
2 CONSTANT [HIS

: X]        1 FLEETS ; \ byte
: Y]        2 FLEETS ; \ byte
: SHIPS]    4 FLEETS ; \ cell
: LEGIONS]  6 FLEETS ; \ cell

: END-MSGE  CLEAR-MSGE  0 12 AT-XY ." END OF GAME COMMANDER" ;

CR .( TMS9918 Pattern table management)
HEX
 \ Expose TI-99 pattern table at Video RAM $800 as an array
: ]PDT ( ascii# -- ) 8* 800 + ;
DECIMAL
: CHARDEF ( data[] ascii -- ) ]PDT 32 VWRITE ; \ write 32 bytes to video RAM

CR .( graphics shapes )
 \ TI-99 specific outer-space characters
 HEX
 CREATE ACOLONY 7884 , 3040 , 4030 , 8478 ,
 CREATE OPLANET 0078 , 8484 , 8484 , 8478 ,
 CREATE EPLANET 0070 , 8850 , 2050 , 8870 ,
 CREATE ASTAR   0000 , 1054 , 2854 , 1000 ,
 CREATE PFLEET  40F8 , 503C , 1040 , F840 ,
 CREATE EFLEET  20C0 , 2438 , 0410 , E010 ,
 CREATE BLKHOLE 7884 , 3078 , 7830 , 8478 ,
 \ -------- double line box chars --------
 CREATE VBARS  2828 , 2828 , 2828 , 2828 ,
 CREATE HBARS  0000 , 00FF , 00FF , 0000 ,
 CREATE ULEFT  0000 , 003F , 202F , 2828 ,
 CREATE URIGHT 0000 , 00F8 , 08E8 , 2828 ,
 CREATE LLEFT  2828 , 282F , 203F , 0000 ,
 CREATE LRIGHT 2828 , 28E8 , 08F8 , 0000 ,

\ re-define shape of characters used in the matrix map
\ This allows us to write the map directly to the screen
DECIMAL
: DEF-CHARS
  ASTAR     2 CHARDEF
  ACOLONY 132 CHARDEF
  OPLANET   4 CHARDEF
  EPLANET   5 CHARDEF
  BLKHOLE   8 CHARDEF
  PFLEET   16 CHARDEF
  EFLEET   17 CHARDEF

  VBARS   133 CHARDEF
  HBARS   134 CHARDEF
  ULEFT   135 CHARDEF
  URIGHT  136 CHARDEF
  LLEFT   137 CHARDEF
  LRIGHT  138 CHARDEF
;

DEF-CHARS
 \ use (EMIT) which does not interpert control characters
: VLINE ( len --) 0 DO  133 VPUT  VROW 1+!  LOOP ;
: HLINE ( len --) 0 DO  134 (EMIT) LOOP ;
: TOPLINE ( len --) 135 (EMIT)  HLINE  136 (EMIT) ;
: BOTLINE ( len --) 137 (EMIT)  HLINE  138 (EMIT) ;

: WINDOW
  11  7 AT-XY 21 TOPLINE
  11 19 AT-XY 21 BOTLINE
  11  8 AT-XY 11 VLINE
  33  8 AT-XY 11 VLINE ;

CR .( main game words)
: RND-GALAXY! ( n -- ) NEWXY GALAXY C! ;

: SET-UP-GALAXY
   NO-OF-STARS 0
   DO
      2  RND-GALAXY! ( set up stars in galaxy)
   LOOP

   NO-OF-PLANETS 0
   DO
     4 RND-GALAXY!    ( set up planets)
     RANDOM1 4* 8 +  THIS INFO1 C!  ( set up class of planet)
   LOOP

   NO-OF-B-HOLES 0
   DO
      8 RND-GALAXY!  ( set up black holes)
   LOOP ;


CR .( initialisers)
: GAME-LENGTH
   PAGE
   CR
   CR ." DO YOU WANT"
   CR ." 1. SHORT"
   CR ." 2. MEDIUM"
   CR ." 3. LONG"
   CR ." GAME"
   INKEY   ( pick up reply)
   CASE
      49 ( 1) OF 350 LEN ! ( 350 moves) ENDOF
      50 ( 2) OF 700 LEN ! ( 700 moves) ENDOF
                1500 LEN ! ( 1500 moves otherwise)
   ENDCASE
;

DECIMAL
: INITIALISE
   CR
   CR ." INITIALISING"
   CLEAR-GALAXY  CLEAR-INFO  SET-UP-GALAXY
   1 FLEET# !          ( make fleet 1 current fleet)
   250 CREDIT !            ( players credit)

   0 PLANETS !             ( no planets)
   0 C-PLANETS !           ( none for computer either)

   20 [MY SHIPS] !  ( 1 = player's fleets)
   20 [HIS SHIPS] ! ( 2 = computer's fleets)

   50 [MY LEGIONS] !
   50 [HIS LEGIONS] ! ( fleets have 50 legions each)

   DIFF @ 4* 0
  ?DO ( position computers fleets)
         17 NEWXY GALAXY C!
        15 THIS INFO2 C!
  LOOP
   16 22 18 GALAXY C!
   16 18 22 GALAXY C! ( position fleets)

   22 [MY Y] C!   ( players Y)
   18 [MY X] FLEETS C!   ( players x)
   18 [HIS Y] C!   ( enemy y )
   22 [HIS X] C!   ( enemy x)

   29 3 DIFF @ * - NEW !   ( how often computer creates fleets)
   15 DIFF @ 4* * TROOPS ! ( initial no. of computer troops)
   20 DIFF @ * C-LEGIONS ! ( no. of spare computer legions)
   DIFF @ 4* C-FLEETS !    ( no. of computer fleets)
   SPEED DUP COMPUTER !  COMP-START !  ( how often computer moves)
   1 BUY-V !
;

\ ** re-factored score computation **
\ Computed Weighted score
\ part_score= (player# - computer#) * weight
: PLANET-DIFF ( -- n) PLANETS @  C-PLANETS @ -   W1 *  ;
: FLEETS-DIFF ( -- n) [MY SHIPS] @  [HIS SHIPS] @ -  W2 * ;
: FLEETS-DIFF ( -- n) [MY LEGIONS] @  [HIS LEGIONS] @ -  W2 * ;
: TROOP-VALUE ( -- n) TROOPS @ W3 * ;

:  SCORE ( -- n)
      PLANET-DIFF
      FLEETS-DIFF  +
      FLEETS-DIFF  +
      TROOP-VALUE  +  ;
\ ---------------------
\       total

DECIMAL
: .(X,Y)  ( y x -- )  ." ("  2 .R ." ,"  2 .R ." )" ; \ print coordinate

: DRAW-LABELS
     HOME      ." PLAYER"
    0  1 AT-XY ." PLANETS:"
    0  4 AT-XY ." EMPIRE"
    0  5 AT-XY ." FLEETS:"   12 TAB ." PLANETS:"
    0 21 AT-XY ." SHIPS :"
    0 22 AT-XY ." LEGIONS:" 24 22 AT-XY ." CREDITS:"
    0 20 AT-XY ." COORDS:"
    25 20 AT-XY ." SCORE:"
;

: .LEGIONS     9 22 AT-XY [MY LEGIONS] @ 5 U.R ;
: .SHIPS       7 21 AT-XY [MY SHIPS] @   4 .R  ;

: DRAW-FIGURES  ( draw the stats)
    10 1 AT-XY PLANETS @   4  .R
    7  5 AT-XY C-FLEETS @  4 U.R   20 TAB C-PLANETS @ 4 U.R

    7 20 AT-XY  [MY Y] C@  [MY X] C@  .(X,Y)
    .SHIPS
    .LEGIONS
   31 22 AT-XY CREDIT @    5 U.R
   31 20 AT-XY SCORE       5 U.R
;

: FIND-DIRECTION     (  --- X Y )
( find out which square player means)
   LOPROMPT: ." WHICH DIRECTION? "
   INKEY
   CASE
      87 ( up)    OF -1  0 ENDOF
      90 ( down)  OF  1  0 ENDOF
      83 ( right) OF  0  1 ENDOF
      65 ( left)  OF  0 -1 ENDOF
                      0  0
   ENDCASE
   LOPROMPT:   ( clear message )
   [MY Y] C@ + WRAPPED SWAP
   [MY X] C@ + WRAPPED SWAP ;

: PRINT-IT  ( c  --- )  X @ CELLS 12 +  Y @ 8 +  AT-XY   VPUT  ;

: DRAW-SCAN ( draw the screen display)
   [MY X] C@ 5 -  [MY Y] C@ 5 -
   11 0 DO
      11 0 DO
              OVER WRAPPED OVER WRAPPED
              J Y ! I X ! GALAXY C@  PRINT-IT
              1+
           LOOP
           11 - SWAP 1+ SWAP
        LOOP
   DROP DROP
;

: DRAW-DISPLAY  ( 1 SCALE )
    DRAW-LABELS  DRAW-SCAN  DRAW-FIGURES  WINDOW ;

: REDRAW   PAGE  DRAW-DISPLAY ;

: NEW-FLEET  ( fleet destroyed for some reason)
   \ 24 0 vhtab ." fleet destroyed"
   \ you can still move the fleet cursor around though
   \ and buy more ships and take on more legions

   0 [MY X] C@  [MY Y] C@ GALAXY C! ( remove fleet symbol)
   0 [MY SHIPS] !                  ( no ships left)
   0 [MY LEGIONS] ! ;              ( no legions left)

: MOVE-FLEET (  X Y ---  )
   2DUP
   0 [MY X] C@ [MY Y] C@ GALAXY C!  ( remove old symbol)
   16 -ROT GALAXY C!              ( position fleet)
   [MY Y] C! [MY X] C! ;            ( update fleet MATRIX:)

: CHECK-POSITION  ( X Y --- )
   WRAPPED SWAP WRAPPED SWAP 2DUP GALAXY C@
   CASE
      0  OF MOVE-FLEET              ENDOF ( empty space)

      8  OF LOPROMPT: ." FLEET IN BLACK HOLE"
            MOVE-FLEET HONK DELAY
            NEW-FLEET  LOPROMPT:
                                    ENDOF
      DROP DROP
   ENDCASE
   DRAW-DISPLAY ;

\ needs to add death detector to end when FLEETS are exhausted
: OTHER-FLEET   ( make other fleet current fleet)
   FLEET# @ 1 =
   IF   2 FLEET# !
   ELSE 1 FLEET# !
   ENDIF
   DRAW-DISPLAY ;

: MOVE-LEFT  ( -- )   [MY X] C@    [MY Y] C@ 1- CHECK-POSITION ;
: MOVE-RIGHT ( -- )   [MY X] C@    [MY Y] C@ 1+ CHECK-POSITION ;
: MOVE-DOWN  ( -- )   [MY X] C@ 1+ [MY Y] C@    CHECK-POSITION ;
: MOVE-UP    ( -- )   [MY X] C@ 1- [MY Y] C@    CHECK-POSITION ;

: ENLIST    ( enlisting 1egions on a planet)
   BUY-V @ 0=
   IF  ( it's ok to buy)
       5 BUY-V !  ( can't buy for 5 more moves)
       ( calculate cost of legions)
       RANDOM1 8 / THEPLANET C@ 7 / + DUP TEMP1 !
       PROMPT:  ." COST PER LEGION =" 3 .R
       ( calculate no. of legions available)
       THEPLANET C@ 6 / DUP LEG !
       0 12 AT-XY ." NO OF LEGIONS AVAILABLE = " 3 .R
       ( take the order)
       0 14 AT-XY ." HOW MANY DO YOU REQUIRE?" INPUT
       LEG @ MIN DUP TEMP1 @ * CREDIT @ >
       IF  ( not enough money)
         0 16 AT-XY ." NOT ENOUGH CREDIT"
       ELSE
         [MY LEGIONS] @ OVER + [MY LEGIONS] !  ( update legions)
         TEMP1 @ * CREDIT @ SWAP - CREDIT ! ( update credit)
       ENDIF
   ELSE
      PROMPT:  ." NO TROOPS AVAILABLE"
   ENDIF
   .LEGIONS ;

: RND-DOLLARS ( -- n) RANDOM1 5 / THEPLANET C@ 10 / + 1+ ;

: BUY    ( purchasing of ships at planet)
   BUY-V @ 0=
   IF    ( it's ok to buy)
      5 BUY-V !               ( stop continous buying)
      RND-DOLLARS >R
      PROMPT:  ." COST PER SHIP = " PRICE @ 2 .R
      0 12 AT-XY ." HOW MANY DO YOU WANT?" INPUT
      CREDIT R@  / MIN    ( no more than he can afford)
      DUP [MY SHIPS] +!

      CREDIT @  R@ * - 0 MAX  CREDIT !  ( update credit)
      16  [MY Y] C@  [MY X] C@ GALAXY C!  ( make sure fleet symbol there)
   ELSE
      PROMPT:  ." NO SHIPS AVAILABLE"
   ENDIF
   R> DROP
   .SHIPS ;


: GATHER   ( pick up legions from garrison onto fleet)
   0 10 0 AT-XY ." HOW MANY DO YOU WISH TO TAKE?" INPUT
   #LEGIONS C@ MIN >R  ( no more than are there)
   [MY LEGIONS] @  R@  + [MY LEGIONS] !     ( update legions on fleet)
   #LEGIONS C@  R>  - #LEGIONS C! ; ( update on planet)

\ Orignal name: "LEAVE"
\ : DEPLOY   ( leave legions from fleet on planet as garrison)
\   PROMPT:  ." HOW MANY DO YOU WISH TO LEAVE? "
\   INPUT  5 ]F @ MIN TEMP1 !         ( no more than you have)
\   5 ]F @ TEMP1 @ - 5 ]F !    ( update legions on fleet)
\   #LEGIONS C@ TEMP1 @ + 255 MIN ( no more than 255)
\   #LEGIONS C! ;            ( update on planet)

\ Orignal name: "LEAVE"
: DEPLOY   ( leave legions from fleet on planet as garrison)
   BEGIN
     PROMPT: ." HOW MANY DO YOU WISH TO LEAVE? "
     INPUT [MY LEGIONS] @ OVER <
   WHILE
      PROMPT: ." You don't have that many!"
      HONK 500 MS
      DROP
   REPEAT
   DUP NEGATE [MY LEGIONS] +!
   #LEGIONS C@  + 255 MIN   #LEGIONS C! ;


: FRIENDLY-PLANET ( -- ?)  ( options upon landing at colony)
   BEGIN
      PROMPT:  ." CLASS " THEPLANET C@ 8 / 2 .R
      ."  PLANET" 16 SPACES CR  ( give class of planet)
      ." LOCAL GARRISON IS " #LEGIONS C@ 3 .R ."  LEGIONS"
                                ( size of local garrison)
      0 12 AT-XY ." DO YOU WISH TO:" 12 SPACES ( give options)
      CR ." 1.  LEAVE LEGIONS ON PLANET"
      CR ." 2.  GATHER LEGIONS FROM PLANET"
      CR ." 3.  BUY SHIPS"
      CR ." 4.  ENLIST TROOPS"
      CR ." 5.  LEAVE" CR
      INKEY              ( get reply)
      CLEAR-MSGE
      CASE
         49 ( 1) OF DEPLOY FALSE ( leave legions)  ENDOF
         50 ( 2) OF GATHER FALSE ( gather legions) ENDOF
         51 ( 3) OF BUY    FALSE ( buy ships)      ENDOF
         52 ( 4) OF ENLIST FALSE ( en1ist troops)  ENDOF
                           TRUE  ( the default: leave planet)
      ENDCASE DELAY
   UNTIL
    CLEAR-MSGE DRAW-DISPLAY ;

: PLANET-STRENGTH ( -- n)
    THEPLANET C@ 8 / RANDOM1 1- 5 / 7 + * 10 /
;

: .LOSSES  ( n - ) ." YOU LOST " 3 .R  ."  LEGIONS" ;

: COLONISE ( attack an uncolonised planet)
   CLEAR-MSGE
   PLANET-STRENGTH DUP >R  \ USE rstack as temp variable

   [MY LEGIONS] @ >
   IF   ( planet drives off your forces)
      PROMPT: ." YOUR FORCES RETREATED"
      DELAY
      0 12 AT-XY R@ 2/ DUP .LOSSES
      [MY LEGIONS] @ SWAP -   0 MAX [MY LEGIONS] !

      DELAY DELAY
   ELSE ( you capture planet)
      PROMPT:  ." PLANET CAPTURED"
      0 12 AT-XY  R@ .LOSSES
      [MY LEGIONS] @ R@ -  0 MAX [MY LEGIONS] !   ( update legions in fleet)
      1 PLANETS +!
      132 THEGALAXY C!
      DELAY DELAY
      FRIENDLY-PLANET
   ENDIF
   .LEGIONS
   R> DROP ;

: EMPTY-PLANET   ( in orbit round uncolonised planet)
   CLEAR-MSGE
   PROMPT:  ." UNCOLONISED CLASS " THEPLANET C@ 8 / 2 .R   ." PLANET"
   0 12 AT-XY ." DO YOU WISH TO ATTACK?" INKEY 89 =
   IF
      COLONISE
   ENDIF
    CLEAR-MSGE ;

: NOT-PLANET   ( there isn't a planet where he's trying to land)
   PROMPT:  ." NO PLANET THERE"
   DELAY  CLEAR-MSGE ;

: ATTACK       ( attack a planet controlled by the computer)
   CLEAR-MSGE
   ( calculate enemy garrisons effective strength)
   #LEGIONS C@ RANDOM1 1- 5 / 7 + * 10 / DUP  TEMP1 !
   [MY LEGIONS] @ >
   IF   ( enemy garrison wins)
      PROMPT:  ." YOUR FORCES RETREAT"
      0 12 AT-XY ." YOUR LOSSES = "
      #LEGIONS C@ [MY LEGIONS] @ * TEMP1 @ / 2/ #LEGIONS C@ SWAP -  #LEGIONS C!
      [MY LEGIONS] @ 2/ DUP 3 .R
      [MY LEGIONS] @ SWAP - [MY LEGIONS] !
   ELSE
      0 #LEGIONS C!           ( reduce legions on planet to 0)
      PROMPT:  ." PLANET CAPTURED"
      0 12 AT-XY ." YOUR LOSSES = "
      TEMP1 @ 3 .R
      [MY LEGIONS] @ TEMP1 @ - [MY LEGIONS] !  ( update legions with fleet)
      132 THEGALAXY C!         ( put colony in galaxy)
      1 PLANETS +!             ( increment planets)
     -1 C-PLANETS +!           ( decrement computer planets)
      THEPLANET C@ 8 / MINUS CLASS-TOTALS +!
      DELAY                    ( reduce classes of compo plnts)
      FRIENDLY-PLANET
   ENDIF
   DELAY  CLEAR-MSGE ;

: ENEMY-PLANET   ( player orbits enemy planet)
   THEPLANET C@ 8 /
   PROMPT:  ." CLASS " 2 .R ."  PLANET" CR CR
   ." ENEMY GARRISON OF STRENGTH "
   #LEGIONS C@ 3 .R CR CR
   ." DO YOU WISH TO ATTACK?" INKEY  89 =
   IF
      ATTACK
   ENDIF
  CLEAR-MSGE ;

: LAND   ( land on adjacent planet)
   FIND-DIRECTION
   2DUP Y ! X !  GALAXY C@
   CASE
      4  OF EMPTY-PLANET    ENDOF
      5  OF ENEMY-PLANET    ENDOF
    132  OF FRIENDLY-PLANET ENDOF
            NOT-PLANET
   ENDCASE ;

: REVOLT? ( planet at X,Y revolts)
   0 12 AT-XY ." PLANET AT " Y @ . X @ . ." REVOLTS" DELAY
   THEPLANET C@ 8 / #LEGIONS C@ 2DUP >
   IF   ( revolt succeeds)
      DROP 4 THEGALAXY C!            ( place planet symbol)
      8* 7 + THEPLANET C!            ( set revolt factor 7)
      0 #LEGIONS C!                  ( set lpgions to 0)
      -1 PLANETS +!                   ( reduce no.of planets )
     BEEP                          ( ring bell)
      0 14 AT-XY ." SUCCEEDS"
   ELSE ( revolt fails)
      SWAP 2/ - #LEGIONS C!         ( reduce legions)
      THEPLANET C@ 7 OR THEPLANET C!  ( set revolt factor 7)
      0 14 AT-XY ." FAILS"
   ENDIF
   DELAY
   0 12 AT-XY 30 SPACES
   0 14 AT-XY 12 SPACES ;             ( clear messages)

: TAX     ( collect taxes on players planets)
   0 VTAX !                           ( set tax to 0)
   PROMPT:  ." TAX COLLECTED ="
   17 10 AT-XY 0 .
   SIZE 1+ 1 DO
     SIZE 1+ 1 DO
                 I J GALAXY C@ 132 =
                 IF   ( it's a colony)
                    I J INFO1 C@ 3 * 5 / ( tax from planet)
                    VTAX @ + DUP VTAX !  ( update tax)
                    17 10 AT-XY 5 .R
                    I J INFO1 C@ 7 AND -DUP
                    IF ( doesn't revolt)
                       I J INFO1 DUP C@ 1- SWAP C!
                    ELSE ( revolt)
                       I X ! J Y ! REVOLT?
                    ENDIF
                 ENDIF
               LOOP
             LOOP
    CREDIT @ VTAX @ + CREDIT !            ( update credit)
    CLEAR-MSGE DRAW-DISPLAY ;

: COMPUTER-TURN   ( computers turn to do something)
   -1 NEW +!                            ( decrement NEW)
   NEW @ 0=
   IF    ( computer creates new fleet)
      3 BEEPS                            ( ring bell)
      1 C-FLEETS +!                     ( update comp. fleets)
      29 4 DIFF @ * - NEW !             ( reset NEW)
      CLASS-TOTALS @ 8 / DUP C-LEGIONS +!
      DUP TROOPS +!
      BEGIN
         RANDOM1 RANDOM2 2DUP GALAXY C@ 0=
         IF  ( empty space in galaxy)
            2DUP 17 -ROT GALAXY C!   ( place fleet symbol)
            INFO2 C! 1                  ( plus legions)
         ELSE
            DROP DROP DROP 0
         ENDIF
      UNTIL
   ENDIF
   DIFF @ 0 DO   ( see if computer colonises planet)
      RANDOM1 RANDOM2 2DUP GALAXY C@
      CASE
         4 OF ( empty planet)
              2DUP 2DUP 5 -ROT GALAXY C! ( place colony)
              C-LEGIONS @ 2/ DUP C-LEGIONS !
              -ROT INFO2 C!
              1 C-PLANETS +!
              INFO1 C@ 8 / CLASS-TOTALS +!
                                          ENDOF
       132 OF ( players planet)
              2DUP Y ! X ! INFO2 C@ C-LEGIONS @ 2/ <
              IF ( captures planet)
                 C-LEGIONS @ 3 / C-LEGIONS !
                 5 THEGALAXY C!
                 THEPLANET C@ 8 / CLASS-TOTALS +!
                 1 C-PLANETS +!
                -1 PLANETS +!
                 5 BEEPS
               ENDIF
                                          ENDOF
           DROP DROP
      ENDCASE
   LOOP
   DRAW-DISPLAY ;

: FIRE     ( players fleet attacks computer fleet)
   0 X !

   [MY Y] C@ 2 + DUP 3 - DO
      [MY X] C@ 2 + DUP 3 - DO
         I WRAPPED J WRAPPED GALAXY C@ 17 =
         IF  ( there's a fleet in range)
            I WRAPPED X !
            J WRAPPED Y !
         ENDIF
      LOOP
   LOOP
   X @ 0=
   IF
      PROMPT:  ." NO ENEMY FLEET IN RANGE"
   ELSE
      [MY SHIPS] @   #LEGIONS C@ OVER 4* 10 /
      OVER 4* 10 / DUP
      PROMPT:  ." FLEET HIT BY " .  ." UNITS"
      -ROT - 0 MAX DUP 0=
      IF ( computers fleet destroyed)
         DROP TROOPS @ #LEGIONS C@ - TROOPS !
        ( reduce computers troops)
          0 THEGALAXY C!       ( destroy fleet symbol)
         -1 C-FLEETS +!        ( reduce comps fleets)
      ELSE
       ( reduce spare troops)
         #LEGIONS C@ OVER - TROOPS @ SWAP - TROOPS !
         #LEGIONS C!          ( reduce legions in fleet)
      ENDIF
      - 0 MAX DUP 0=
      IF  ( players fleet destroyed)
         DROP NEW-FLEET
      ELSE
         [MY SHIPS] !
      ENDIF
   ENDIF
   DELAY DELAY CLEAR-MSGE DRAW-DISPLAY   ;

: PRESSANY   LOPROMPT: ." Press a key to return" KEY DROP ;

: HELP
  PAGE ." Key controls:
  CR
  CR ." W, Z  up,down"
  CR ." A, S  left,right"
  CR
  CR ." L - Land on a planet"
  CR ." T - Tax your planets"
  CR ." I - Information"
  CR ." F - Fire / attack enemy"
  CR ." O - Switch to Other fleet"
  CR
  CR ." H - show this HELP screen"
  CR PRESSANY
  REDRAW
;

: INFORMATION
  PAGE ."  Information Screen"
  CR   ." --------------------"
  CR
  CR   ." A STAR"        25 TAB   2 (EMIT)
  CR
  CR   ." A COLONY"      25 TAB 132 (EMIT)
  CR
  CR   ." Empty PLANET"  25 TAB   4 (EMIT)
  CR
  CR   ." Enemy PLANET"  25 TAB   5 (EMIT)
  CR
  CR   ." Black hole"    25 TAB   8 (EMIT)
  CR
  CR   ." Unkown object" 25 TAB  11 (EMIT)
  CR
  CR   ." Player FLEET"  25 TAB  16 (EMIT)
  CR
  CR   ." Enemy FLEET"   25 TAB  17 (EMIT)
  CR PRESSANY
  REDRAW
;

: >FORTH  HONK  0 0 AT-XY ." *Forth*"   ABORT  ;

: OBEY-COMMAND ( c -- )
   BUY-V @  IF ( nonzero)  -1 BUY-V +!  ENDIF
   CASE
      [CHAR] A  OF MOVE-LEFT  ENDOF
      [CHAR] S  OF MOVE-RIGHT ENDOF
      [CHAR] W OF MOVE-UP     ENDOF
      [CHAR] Z OF MOVE-DOWN   ENDOF
      [CHAR] O OF OTHER-FLEET ENDOF
      [CHAR] I OF INFORMATION ENDOF
      [CHAR] L OF LAND        ENDOF
      [CHAR] T OF TAX         ENDOF
      [CHAR] F OF FIRE        ENDOF
      [CHAR] H OF HELP        ENDOF
       15      OF >FORTH      ENDOF  \ escape key for debugging
   ENDCASE
;

DECIMAL
: COMPUTER? ( -- ?)   ( is it the computers turn or not)
   COMPUTER DUP 1-! @
   IF ( <>0)
       FALSE
   ELSE
      COMP-START @ COMPUTER !  \ reset countdown timer
      TRUE
   ENDIF ;

: GAME-END?
   LEN @ 0= ;    ( game end if LEN is zero)

: GAME       ( GAME LOOP )
   PAGE
   DRAW-LABELS DRAW-DISPLAY
   BEGIN
      RKEY? ?DUP
      IF ( player has pressed a key)
         OBEY-COMMAND
         -1 LEN +!
         100 MS
      ENDIF
      COMPUTER?
      IF
         COMPUTER-TURN
      ENDIF
      GAME-END?
  \ debug line
   20 0 AT-XY ." Stk=" DEPTH 2 .R  5 SPACES  COMPUTER @ 3 .R
   UNTIL
   END-MSGE ;

: RANDOMIZER
   CR
   CR
   CR
   CR  ." HIT ANY KEY" KEY RAND1 !  ( random number seed)
   CR  ." AND AGAIN  " KEY RAND2 !  ( random number seed)
;

: DIFFICULTY ( -- )
   CR
   BEGIN
      CR ." WHAT LEVEL OF DIFFICULTY (1-4) "
      INPUT
      DUP 5 1 WITHIN ( reversed args [(5 1]  means "NOT WITHIN")
   WHILE
      DROP HONK
   REPEAT
   DIFF !      ( store difficulty)
;

HEX
00C1 CONSTANT GREEN/BLACK  \ Apple ][   Colours :-)
\
\ TMS9918 Video chip register 7 Controls FG/BG colours
DECIMAL
: COLORS  ( byte -- ) 7 VWTR ;

: TITLE
   GREEN/BLACK COLORS
   PAGE
   CR
   CR
   CR S" WELCOME TO COSMIC CONQUEST" CENTERED
   CR
   CR S" DEVISED AND WRITTEN BY" CENTERED
   CR
   CR S" ALAN SARTORI-ANGUS, 1982" CENTERED
   CR
   CR
   CR
   CR
   CR
   CR S" Port for Camel99 Forth" CENTERED
   CR S" Brian Fox 2021" CENTERED
   2000 MS
;

DECIMAL
: RUN   ( the main game word)
   DECIMAL
   DEF-CHARS
   TITLE
   RANDOMIZER
   DIFFICULTY
   GAME-LENGTH
   INITIALISE
   GAME ;

HERE SWAP - DECIMAL U.  .( Bytes)
