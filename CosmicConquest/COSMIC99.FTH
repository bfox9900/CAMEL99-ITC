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

\ HARNESS99.FTH is my new FIG/ANS translation file
\ Wrote smaller INKEY that has 7 bit out uppercase ALPHA output
\

INCLUDE  DSK5.HARNESS99  \ use DSK# where you have MODERNISE

HERE
DECIMAL
CR .( constants)
          30 CONSTANT SIZE          ( the size of the galactic array)
SIZE CELLS   CONSTANT NO-OF-STARS   ( no. of stars in the galaxy)
SIZE 3 * 2/ CONSTANT NO-OF-PLANETS ( planets in galaxy)

    4 CONSTANT NO-OF-B-HOLES        ( no. of black holes)
  200 CONSTANT W1                   ( weight value assigned to planets in score)
    5 CONSTANT W2                   ( weight assigned to ship and troops)
   10 CONSTANT W3                   ( weight assigned to computers troops)
  100 CONSTANT SPEED                ( how quickly computer moves)

1000 CONSTANT delayms ( milliseconds to wait for in DELAY)

CR .( variables)
0 VARIABLE BUY-V        ( count to stop player buying every move)
0 VARIABLE C-FLEETS     ( no. of computer fleets)
0 VARIABLE C-LEGIONS    ( no. of computer legions for attacks)
0 VARIABLE C-PLANETS    ( no. of computer planets)
0 VARIABLE CLASS-TOTALS ( computers planets classes totals)
0 VARIABLE COMP-START   ( how quickly computer plays)
0 VARIABLE COMPUTER     ( how quickly computer plays)
0 VARIABLE DIFF         ( difficulty of game 1-4)
0 VARIABLE FLEET-FLAG   ( no. of players current fleet)
0 VARIABLE LEG          ( the no. of legions available to buy)
0 VARIABLE LEN          ( no. of moves remaining in game)
0 VARIABLE NEW          ( how often new fleet created)
0 VARIABLE PLANETS      ( no. of players planets)
0 VARIABLE RAND1        ( first random number seed)
0 VARIABLE RAND2        ( second random number seed)
0 VARIABLE START        ( starting score in the game)
0 VARIABLE TEMP1        ( a temporary storage v ariable)
0 VARIABLE TROOPS       ( no. of computers troops in game)
0 VARIABLE VTAX         ( tax collected)
0 VARIABLE X            ( temporary storage for X position)
0 VARIABLE Y            ( temporary storage for Y position)
250 VARIABLE CREDIT     ( players credit in taxes)

CR .( utility words)
: ERASE  ( addr u --)    0 FILL ;
: VBLANK ( Vaddr u --)  BL VFILL ;
: XY@  ( -- col row)  X @ Y @ ;

CR .( target specific words)
( DEFINING WORDS)
\ *ORIGINAL CODE*
\ : ARRAY ( 2D Array)
\   CREATE DUP C, * ALLOT DOES>
\   ROT 1 - OVER C@ * + + ;

\ \\\\\\\\\\\\\\\  TI99 CODE  \\\\\\\\\\\\\\\\\\
\ TI99 has 24K RAM.
\ 8K low RAM, 15K Hi RAM. Arrays are 7.3K.
\ Using LOW RAM

\ heap memory analogs to HERE ALLOT C,
: HEAP    H @ ;
: HALLOT  H +! ;
: HC,     HEAP C! ;

\ INIT heap pointer & clean up heap space
HEX  2000 H !
HEAP 2000 ERASE

DECIMAL
CR .( 2D matrices)
: ARRAY  ( 2D MATRIX creator in Camel99 HEAP)
   CREATE HEAP ,
          DUP HC, * HALLOT
   DOES>  @ ROT 1- OVER C@ * + + ;

SIZE SIZE ARRAY GALAXY ( the galactic array)
SIZE SIZE ARRAY INFO1  ( planetary array)
SIZE SIZE ARRAY INFO2  ( strength array)
  11   11 ARRAY SCREEN ( the screen array)
   2    6 ARRAY FLEETS ( player fleets info)

\ clarification language
: THEPLANET ( -- addr) XY@ INFO1 ;
: #LEGIONS  ( -- addr) XY@ INFO2 ;
: THEGALAXY ( -- addr) XY@ GALAXY ;

CR .( general utility words)
: DELAY      delayms MS ;       \ MS sleeps task while waiting
: BLANKLN    VPOS C/L@ VBLANK ; \ FAST video memory writer

( clear message area on text screen)
: CLEAR-MSGE ( -- ) 18 10 DO   0 I AT-XY BLANKLN  LOOP ;

: PROMPT:   ( -- )   0 10 AT-XY  BLANKLN  ;

\ clear screen, don't change cursor
: CLEAR-SCREEN ( -- )  0 C/SCR @ BL VFILL ;

: CLEAR-DISP ( fill screen array with FF's)
   1 1 SCREEN 121 255 FILL ;

: CLEAR-GALAXY ( fills galactic array with NULLS)
   1 1 GALAXY SIZE SIZE * ERASE ;

: CLEAR-INFO ( fills info arrays with NULLs)
   1 1 INFO1 SIZE SIZE * ERASE
   1 1 INFO2 SIZE SIZE * ERASE ;

: RANDOM1 ( --- ran) ( random number in range 1-SIZE)
   RAND1 @ 37 * 651 + DUP RAND1 ! ABS SIZE MOD 1+ ;

: RANDOM2 ( --- ran ) ( random number in range 1-SIZE)
   RAND2 @ 53 * 773 + DUP RAND2 ! ABS SIZE MOD 1+ ;

: EDGE-CHECK ( n --- ng ) ( calculates wrap around of galaxy)
   SIZE 1- + SIZE MOD 1+ ;

\ better number input routine.  ACCEPT is multi-tasking ready
:  INPUT  ( -- n )
          DECIMAL
          BEGIN
            PAD DUP 10 ACCEPT  \ ACCEPT text into temp buffer PAD
            NUMBER?            \ convert the number in PAD
          WHILE                \ while the conversion is bad we do this
              HONK ." ? "
              DROP
          REPEAT ;

: ]F ( n1 --- add1 ) FLEET-FLAG @ SWAP FLEETS ; ( indexes current fleet array)

: END-MSGE                  ( end of game message)
   TEXT 12 0 VHTAB ." END OF GAME COMMANDER" ;

CR .( graphics shapes and utilities)
 0 VARIABLE SPACEFIG 80 ALLOT  ( shape tables)

 : C$                        ( loads 8-bit value into table)
   OVER C! 1+ ;

 : $                         ( loads 16-bit value into table)
   OVER ! 2 + ;

 SPACEFIG                    ( load shape tables)
   12 $ 31 $ 41 $ 47 $ 63 $ 74 $ HEX
( space shape)
   24 C$ 3F C$ 37 C$ 36 C$ 2E C$ 24 C$ 2C C$ 36 C$ 2E C$ 2C C$
   2E C$ 25 C$ 24 C$ 3C C$ 37 C$ 2E C$ 34 C$ 36 C$ 00 C$
( colony shape)
   12 C$ 2D C$ 24 C$ 24 C$ 3F C$ 3F C$ 36 C$ 36 C$ 2D C$ 00 C$
( planet shape )
   2C C$ 36 C$ 3F C$ 24 C$ 05 C$ 00 C$
( star shape)
   3C C$ 36 C$ 2D C$ 24 C$ 1C C$ 1F C$ 16 C$ 16 C$ 0D C$ 0D C$
   1C C$ 2C C$ 1C C$ 0C C$ 04 C$ 00 C$
( players fleet shape)
   3C C$ 1B C$ 36 C$ 26 C$ 08 C$ 2D C$ 2D C$ 25 C$ 36 C$ 36 C$
   00 C$
( computers fleet shape)
   36 C$ 07 C$ 20 C$ 29 C$ 32 C$ 00 C$

DECIMAL  DROP
\ FORGET C$  ( we don't need C$ and $ any more)

: SKETCH  ( n ---  )    ( sketch shape n at current position)
   CELLS 0 SWAP SPACEFIG + @ SPACEFIG + DRAW ;

CR .( main game words)

: RND-GALAXY! ( n -- ) RANDOM1 RANDOM2 GALAXY C! ;

: SET-UP-GALAXY
   NO-OF-STARS 0
   DO
      2  RND-GALAXY! ( set up stars in galaxy)
   LOOP

   NO-OF-PLANETS 0
   DO
      RANDOM1 RANDOM2 2DUP 4 -ROT GALAXY C!  ( set up planets)
      RANDOM1 4* 8 + -ROT INFO1 C!    ( set up class of planet)
   LOOP

   NO-OF-B-HOLES 0
   DO
      8 RND-GALAXY!  ( set up black holes)
   LOOP ;

CR .( initialise word)
: INITIALISE
   HCLR ( screen is messy otherwise)
   HOME CR CR
   ." DO YOU WANT" CR ." 1. SHORT" CR ." 2. MEDIUM" CR
   ." 3. LONG" CR ." GAME"
   KEY 127 AND     ( pick up reply)
   CASE
      49 ( 1) OF 350 LEN ! ( 350 moves) ENDOF
      50 ( 2) OF 700 LEN ! ( 700 moves) ENDOF
                1500 LEN ! ( 1500 moves otherwise)
   ENDCASE
   HOME ." INITIALISING"
   CLEAR-GALAXY CLEAR-DISP CLEAR-INFO SET-UP-GALAXY
   1 FLEET-FLAG !          ( make -fleet 1 current fleet)
   250 CREDIT !            ( players credit)
   0 PLANETS !             ( no planets)
   0 C-PLANETS !           ( none for computer either)
   20 1 3 FLEETS ! 20 2 3 FLEETS ! ( fleets start with 20 ships)
   50 1 5 FLEETS ! 50 2 5 FLEETS ! ( fleets have 50 legions each)
   DIFF @ 4* 0 DO ( position computers fleets)
                   RANDOM1 RANDOM2 2DUP 17 -ROT GALAXY C!
                   15 -ROT INFO2 C!
              LOOP
   16 22 18 GALAXY C!
   16 18 22 GALAXY C! ( position fleets)
   22 1 1 FLEETS C!
   18 1 2 FLEETS C!
   18 2 1 FLEETS C!
   22 2 2 FLEETS C!
   29 3 DIFF @ * - NEW !  ( how often computer creates fleets)
   15 DIFF @ 4* * TROOPS ! ( initial no. of computer troops)
   20 DIFF @ * C-LEGIONS ! ( no. of spare computer legions)
   DIFF @ 4* C-FLEETS !   ( no. of computer fleets)
   SPEED DUP COMPUTER !
   COMP-START !   ( how often computer moves)
   1 BUY-V ! ;

: DRAW-BORDERS   ( draw borders o-f display and headings)
   CLEAR-SCREEN
   7 HCOLOUR     ( colour white)
   17 5 HPOSN
      238 5 HLINE 238 126 HLINE 17 126 HLINE 17 5 HLINE
   57 27 HPOSN
      198 27 HLINE 198 104 HLINE 57 104 HLINE 57 27 HLINE
   HOME
   ." PLAYER"
   2  0  VHTAB ." PLANETS ="
   4  0  VHTAB ." EMPIRE"
   6  0  VHTAB ." FLEETS"
   6  21 VHTAB ." PLANETS"
   20 0  VHTAB ." X="
   20 7  VHTAB ." Y="
   21 0  VHTAB ." NO. OF SHIPS ="
   22 0  VHTAB ." LEGIONS ="
   20 25 VHTAB ." SCORE ="
   22 21 VHTAB ." CREDITS" ;

: FIND-DIRECTION     (  --- X Y )
                     ( find out which square player means)
   23 0 VHTAB ." WHICH DIRECTION?"
   2 SPACES INKEY
   CASE
      87 ( up)    OF -1  0 ENDOF
      90 ( down)  OF  1  0 ENDOF
      83 ( right) OF  0  1 ENDOF
      65 ( left)  OF  0 -1 ENDOF
                      0  0
   ENDCASE
   23 0 VHTAB 35 SPACES   ( clear message )
   2 ]F C@ + EDGE-CHECK SWAP
   1 ]F C@ + EDGE-CHECK SWAP ;

: PRINT-IT  ( c  --- )
    X @ CELLS 12 +  Y @ 8 +  AT-XY   BL VPUT
      CASE                        ( draw shape)
         2 ( a star)         OF ." *" ( draw star)     ENDOF
         4 ( empty planet)   OF ." O" ( a planet)      ENDOF
         5 ( enemy planet)   OF ." 0" ( a planet)      ENDOF
       132 ( players planet) OF ." @" ( a colony)      ENDOF
        16 ( players fleet)  OF ." P" ( players fleet) ENDOF
        17 ( enemy fleet)    OF ." E" ( enemy fleet)   ENDOF
      ENDCASE
;

: DRAW-SCAN                       ( draw the screen display)
   1 ]F C@ 5 - 2 ]F C@ 5 -
   11 0 DO
      11 0 DO
              OVER EDGE-CHECK OVER EDGE-CHECK
              J Y ! I X ! GALAXY C@
              PRINT-IT 1+
           LOOP
           11 - SWAP 1+ SWAP
        LOOP
   DROP DROP ;

: .SCORE ( -- n)
       PLANETS @ C-PLANETS @ - W1 *
       1 3 FLEETS @  2 3 FLEETS @ +  W2 * +
       1 5 FLEETS @ 2 5 FLEETS @ + W2 * +
       TROOPS @ W3 * -   5 U.R
;

: DRAW-FIGURES    ( draw the totals in the disp1ay)
    2 10 VHTAB PLANETS   @ 5 U.R
   20 33 VHTAB .SCORE
   6 8   VHTAB C-FLEETS  @ 5 U.R
   6 29  VHTAB C-PLANETS @ 5 U.R
   20 2  VHTAB 2 ]F C@ 2 .R
   20 9  VHTAB 1 ]F C@ 2 .R
   21 15 VHTAB 3 ]F @  4 .R
   22 10 VHTAB 5 ]F @  5 U.R
   22 31 VHTAB CREDIT @ 5 U.R
;

: DRAW-DISPLAY
   1 SCALE  DRAW-SCAN DRAW-FIGURES ;

: NEW-FLEET  ( fleet destroyed for some reason)
   \ 24 0 vhtab ." fleet destroyed"
   \ you can still move the fleet cursor around though
   \ and buy more ships and take on more legions

   0  1 ]F C@ 2 ]F C@ GALAXY C! ( remove fleet symbol)
   0 3 ]F !                     ( no ships left)
   0 5 ]F ! ;                   ( no legions left)

: MOVE-FLEET (  X Y ---  )
   2DUP
   0 1 ]F C@ 2 ]F C@ GALAXY C!  ( remove old symbol)
   16 -ROT GALAXY C!              ( position fleet)
   2 ]F C! 1 ]F C! ;            ( update fleet array)

: CHECK-POSITION  ( X Y --- )
                  ( check if move to position X Y is possib
                  ( and take apropriate action)
   EDGE-CHECK SWAP EDGE-CHECK SWAP 2DUP GALAXY C@
   CASE
      0 ( space)      OF MOVE-FLEET ENDOF
      8 ( black hole) OF 23 0 VHTAB ." FLEET IN BLACK HOLE"
                         MOVE-FLEET DELAY NEW-FLEET
                         23 0 VHTAB 35 SPACES ENDOF
      DROP DROP
   ENDCASE
   DRAW-DISPLAY ;

: OTHER-FLEET   ( make other fleet curent fleet)
   FLEET-FLAG @ 1 =
   IF   2 FLEET-FLAG !
   ELSE 1 FLEET-FLAG !
   ENDIF
   DRAW-DISPLAY ;

: MOVE-LEFT
   1 ]F C@ 2 ]F C@ 1- CHECK-POSITION ;

: MOVE-RIGHT
   1 ]F C@ 2 ]F C@ 1+ CHECK-POSITION ;

: MOVE-DOWN
   1 ]F C@ 1+ 2 ]F C@ CHECK-POSITION ;

: MOVE-UP
   1 ]F C@ 1- 2 ]F C@ CHECK-POSITION ;

: ENLIST    ( enlisting 1egions on a planet)
   BUY-V @ 0=
   IF  ( it's ok to buy)
       5 BUY-V !  ( can't buy for 5 more moves)
       ( calculate cost of legions)
       RANDOM1 8 / THEPLANET C@ 7 / + DUP TEMP1 !
       PROMPT:  ." COST PER LEGION =" 3 .R
       ( calculate no. of legions available)
       THEPLANET C@ 6 / DUP LEG !
       12 0 VHTAB ." NO OF LEGIONS AVAILABLE = " 3 .R
       ( take the order)
       14 0 VHTAB ." HOW MANY DO YOU REQUIRE?" INPUT
       LEG @ MIN DUP TEMP1 @ * CREDIT @ >
       IF  ( not enough money)
         16 0 VHTAB ." NOT ENOUGH CREDIT"
       ELSE
         5 ]F @ OVER + 5 ]F !  ( update legions)
         TEMP1 @ * CREDIT @ SWAP - CREDIT ! ( update credit)
       ENDIF
   ELSE
      PROMPT:  ." NO TROOPS AVAILABLE"
   ENDIF ;

: RND$ ( -- n) RANDOM1 5 / THEPLANET C@ 10 / + 1+ ;

VARIABLE PRICE
: BUY    ( purchasing of ships at planet)
   BUY-V @ 0=
   IF    ( it's ok to buy)
      5 BUY-V !               ( stop continous buying)
      RND$ PRICE !
      PROMPT:  ." COST PER SHIP = " PRICE @ 2 .R
      12 0 VHTAB ." HOW MANY DO YOU WANT?" INPUT
      CREDIT @ PRICE @ / MIN    ( no more than he can afford)
      DUP 3 ]F +!  \ 3 ]F @ + 3 ]F !  ( update ships in fleet)


      PRICE @ * CREDIT @ SWAP - CREDIT !  ( update credit)
      16   1 ]F C@ 2 ]F C@ GALAXY C!  ( make sure fleet symbol there)
   ELSE
      PROMPT:  ." NO SHIPS AVAILABLE"
   ENDIF ;


: GATHER   ( pick up legions from garrison onto fleet)
   10 0 VHTAB ." HOW MANY DO YOU WISH TO TAKE?" INPUT
   #LEGIONS C@ MIN TEMP1 !  ( no more than are there)
   5 ]F @ TEMP1 @ + 5 ]F !     ( update legions on fleet)
   #LEGIONS C@ TEMP1 @ - #LEGIONS C! ; ( update on planet)

\ Orignal name: "LEAVE"
: DEPLOY   ( leave legions from fleet on planet as garrison)
   PROMPT:  ." HOW MANY DO YOU WISH TO LEAVE?"
   INPUT  5 ]F @ MIN TEMP1 !         ( no more than you have)
   5 ]F @ TEMP1 @ - 5 ]F !    ( update legions on fleet)
   #LEGIONS C@ TEMP1 @ + 255 MIN ( no more than 255)
   #LEGIONS C! ;            ( update on planet)

: FRIENDLY-PLANET   ( options upon landing at colony)
   BEGIN
      PROMPT:  ." CLASS " THEPLANET C@ 8 / 2 .R
      ."  PLANET" 16 SPACES CR  ( give class of planet)
      ." LOCAL GARRISON IS " #LEGIONS C@ 3 .R ."  LEGIONS"
                                ( size of local garrison)
      12 0 VHTAB ." DO YOU WISH TO:" 12 SPACES ( give options)
      CR ." 1.  LEAVE LEGIONS ON PLANET"
      CR ." 2.  GATHER LEGIONS FROM PLANET"
      CR ." 3.  BUY SHIPS"
      CR ." 4.  ENLIST TROOPS"
      CR ." 5.  LEAVE" CR
      KEY 127 AND              ( get reply)
      CLEAR-MSGE
      CASE
         49 ( 1) OF DEPLOY 0 ( leave legions)  ENDOF
         50 ( 2) OF GATHER 0 ( gather legions) ENDOF
         51 ( 3) OF BUY 0    ( buy ships)      ENDOF
         52 ( 4) OF ENLIST 0 ( en1ist troops)  ENDOF
                           1 ( the default: leave planet)
      ENDCASE DELAY
   UNTIL
    CLEAR-MSGE DRAW-DISPLAY ;

: COLONISE ( attack an uncolonised planet)
   CLEAR-MSGE
   THEPLANET C@ 8 / RANDOM1 1- 5 / 7 + * 10 / DUP TEMP1 !
   ( calaculate relative strength of planet)
   5 ]F @ >
   IF   ( planet drives off your forces)
      PROMPT:  ." YOUR FORCES RETREAT"
      12 0 VHTAB ." YOUR LOSSES = " 5 ]F @ 2/ DUP 3 .R
      5 ]F @ SWAP - 5 ]F !
      DELAY DELAY
   ELSE ( you capture planet)
      PROMPT:  ." PLANET CAPTURED"
      12 0 VHTAB ." YOUR LOSSES = "
      TEMP1 @ 3 .R
      5 ]F @ TEMP1 @ - 5 ]F !   ( update legions in fleet)
      1 PLANETS +!            ( increment no. of planets)
      132 THEGALAXY C!       ( colony symbol in galaxy)
      DELAY DELAY
      FRIENDLY-PLANET
   ENDIF ;

: EMPTY-PLANET   ( in orbit round uncolonised planet)
   CLEAR-MSGE
   PROMPT:  ." UNCOLONISED CLASS " THEPLANET C@ 8 / 2 .R   ." PLANET"
   12 0 VHTAB ." DO YOU WISH TO ATTACK?" INKEY 89 =
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
   5 ]F @ >
   IF   ( enemy garrison wins)
      PROMPT:  ." YOUR FORCES RETREAT"
      12 0 VHTAB ." YOUR LOSSES = "
      #LEGIONS C@ 5 ]F @ * TEMP1 @ / 2/ #LEGIONS C@ SWAP -  #LEGIONS C!
      5 ]F @ 2/ DUP 3 .R
      5 ]F @ SWAP - 5 ]F !
   ELSE
      0 #LEGIONS C!           ( reduce legions on planet to 0)
      PROMPT:  ." PLANET CAPTURED"
      12 0 VHTAB ." YOUR LOSSES = "
      TEMP1 @ 3 .R
      5 ]F @ TEMP1 @ - 5 ]F !  ( update legions with fleet)
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
   2DUP Y ! X ! TEXT GALAXY C@
   CASE
      4 ( uncolonised planet) OF EMPTY-PLANET    ENDOF
      5 ( computers planet)   OF ENEMY-PLANET    ENDOF
    132 ( players colony)     OF FRIENDLY-PLANET ENDOF
        NOT-PLANET  ( otherwise it's not a planet)
   ENDCASE ;

: REVOLT? ( planet at X,Y revolts)
   12 0 VHTAB ." PLANET AT " Y @ . X @ . ." REVOLTS" DELAY
   THEPLANET C@ 8 / #LEGIONS C@ 2DUP >
   IF   ( revolt succeeds)
      DROP 4 THEGALAXY C!            ( place planet symbol)
      8* 7 + THEPLANET C!            ( set revolt factor 7)
      0 #LEGIONS C!                  ( set lpgions to 0)
      -1 PLANETS +!                   ( reduce no.of planets )
      7 EMIT                          ( ring bell)
      14 0 VHTAB ." SUCCEEDS"
   ELSE ( revolt fails)
      SWAP 2/ - #LEGIONS C!         ( reduce legions)
      THEPLANET C@ 7 OR THEPLANET C!  ( set revolt factor 7)
      14 0 VHTAB ." FAILS"
   ENDIF
   DELAY
   12 0 VHTAB 30 SPACES
   14 0 VHTAB 12 SPACES ;             ( clear messages)

: TAX     ( collect taxes on players planets)
   0 VTAX !                           ( set tax to 0)
   TEXT                               ( select text page)
   PROMPT:  ." TAX COLLECTED ="
   10 17 VHTAB 0 .
   SIZE 1+ 1 DO
     SIZE 1+ 1 DO
                 I J GALAXY C@ 132 =
                 IF   ( it's a colony)
                    I J INFO1 C@ 3 * 5 / ( tax from planet)
                    VTAX @ + DUP VTAX !  ( update tax)
                    10 17 VHTAB 5 .R
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
      7 EMIT                            ( ring bell)
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
                 3 0 DO   BEEP  LOOP ENDIF
                                          ENDOF
           DROP DROP
      ENDCASE
   LOOP
   DRAW-DISPLAY ;

: FIRE     ( players fleet attacks computer fleet)
   0 X !
   TEXT
   2 ]F C@ 2 + DUP 3 - DO
      1 ]F C@ 2 + DUP 3 - DO
         I EDGE-CHECK J EDGE-CHECK GALAXY C@ 17 =
         IF  ( there's a fleet in range)
            I EDGE-CHECK X !
            J EDGE-CHECK Y !
         ENDIF
      LOOP
   LOOP
   X @ 0=
   IF
      PROMPT:  ." NO ENEMY FLEET IN RANGE"
   ELSE
      3 ]F @ #LEGIONS C@ OVER 4* 10 /
      OVER 4* 10 / DUP
      PROMPT:  ." FLEET HIT BY " 5 .R ." UNITS"
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
         3 ]F !
      ENDIF
   ENDIF
   DELAY DELAY CLEAR-MSGE DRAW-DISPLAY   ;

: INFORMATION   TEXT KEY DROP ;  ( display the text screen information)

HEX
: OBEY-COMMAND
   BUY-V @ -DUP ( fetch BUY-V, duplicate if nonzero)
   IF ( nonzero)
      1- BUY-V !
   ENDIF

   INKEY
   CASE
      ( A) 41 OF MOVE-LEFT   ENDOF
      ( S) 53 OF MOVE-RIGHT  ENDOF
      ( W) 57 OF MOVE-UP     ENDOF
      ( Z) 5A OF MOVE-DOWN   ENDOF
      ( O) 4F OF OTHER-FLEET ENDOF
      ( I) 49 OF INFORMATION ENDOF
      ( L) 4C OF LAND        ENDOF
      ( T) 54 OF TAX         ENDOF
      ( F) 46 OF FIRE        ENDOF
   ENDCASE
;
   \ 24 0 vhtab .s ( print current state of stack )

   \ not sure why sp! is required here and it appears to be syntactically different from gForth
   \ this should reset the parameter stack, are there values ever left lying around?
   \ SP! ;

\ think this needs to be here to reset base
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

: RESTART        ( restarts the stopped game)
   CLEAR-DISP
   HOME DRAW-BORDERS DRAW-DISPLAY
   BEGIN
    [ HEX ]  83C8 OFF  \ enables repeating keys
   [ DECIMAL ]
     KEY?
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
\ slow the game a little by printing how many loops until it's the computer's turn
   0 30 VHTAB COMPUTER @ .
   UNTIL
   END-MSGE ;

: RANDOMIZER
   CR
   CR  ." HIT ANY KEY" KEY RAND1 !  ( random number seed)
   CR  ." AND AGAIN  " KEY RAND2 !    ( random number seed)
;

: DIFFICULTY
   CR CR
   BEGIN
      ." WHAT LEVEL OF DIFFICULTY (1-4) " INPUT DUP
      5 < IF  ( correct response) 1
          ELSE ( incorrect response) DROP CR 0
          ENDIF
   UNTIL
   DIFF !      ( store difficulty)
;

: CENTERED  ( addr len ) C/L@ OVER - 2/ SPACES   TYPE ;

: CONQUEST  ( the main game word)
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
   CR S" Port to Camel99 Forth" CENTERED
   CR S" Brian Fox 2021" CENTERED
   2000 MS
   RANDOMIZER
   DIFFICULTY
   INITIALISE
   RESTART ;

\ CONQUEST
\ BYE
HERE SWAP - DECIMAL U.  .( Bytes)