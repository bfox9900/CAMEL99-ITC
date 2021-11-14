\ COSMIC CONQUEST TI-99 Native version                 Nov 2021 Brian Fox
\ based on Gforth verison by Rick Carlino
\ This version will try to use the features of Camel99 and TI-99 hardware

\ Change log:
\ Replaced all ROT ROT  with -ROT for speed and 20 bytes space saving
\ Replaced 0 FILL  with ERASE
\ Replace all 1 -   with 1-  save  14 bytes
\ Removed Apple ][ character configuration code
\ replaced FIG Forth VARIABLE
\ Removed all original screen control words
\ Attempt to make some syntax for accessing data rather than just numbers

\ ANS/Camel99 Optimizations
\ Replaced all 2 *  with CELLS
\ Replaced all 2 /  with 2/
\ Replaced all 4 *  with 4* (Camel99 code word)
\ Replaced all 8 *  with 8* (Camel99 code word)
\ Replaced ARRAY with MATRIX: (ARRAY is 1 dimension in Forth by convention)
\ Added new mapped characters to charset for "space" graphics
\ Added border characters to create a box on play screen
\ Wrote new INKEY.  7 bit output, uppercase ALPHA
\ re-factored extremely long words into smaller words
\ replaced a lot of code with +! operator where possible


\ HARNESS99.FTH is my new FIG/ANS translation file

\ Camel99 Forth Library requirements
INCLUDE DSK1.TOOLS  \ for debugging only

INCLUDE DSK1.CASE
INCLUDE DSK1.UDOTR

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
 VARIABLE BUY-V        ( count to stop player buying every move)
 VARIABLE C-FLEETS     ( no. of computer fleets)
 VARIABLE C-LEGIONS    ( no. of computer legions for attacks)
 VARIABLE C-PLANETS    ( no. of computer planets)
 VARIABLE CLASS-TOTALS ( computers planets classes totals)
 VARIABLE TIMER    ( how quickly computer plays)

 VARIABLE DIFF         ( difficulty of game 1-4)
 VARIABLE FLEET#       ( Human player's fleet in use)
 VARIABLE LEG          ( the no. of legions available to buy)
 VARIABLE LEN          ( no. of moves remaining in game)
 VARIABLE NEW          ( how often new fleet created)
 VARIABLE MY-PLANETS   ( no. of players planets)
 VARIABLE RAND1        ( first random number seed)
 VARIABLE RAND2        ( second random number seed)
 VARIABLE START        ( starting score in the game)
\  VARIABLE TEMP1        ( we don't need no stinking temporary variables mang)
 VARIABLE TROOPS       ( no. of computers troops in game)
 VARIABLE VTAX         ( tax collected)
 VARIABLE X            ( temporary storage for X position)
 VARIABLE Y            ( temporary storage for Y position)
250 CREATE CREDIT  ,   ( players credit in taxes)

CR .( utility words)
: ERASE    ( addr u --)    0 FILL ;
: VBLANK   ( Vaddr u --)   BL VFILL ;
: CENTERED ( addr len -- ) C/L@ OVER - 2/ 1- SPACES  TYPE ; \ print centered
: TAB      ( n -- )        VCOL ! ;
: XY@      ( -- col row)   X @ Y @ ;

HEX
: RKEY?   ( -- c ) 83C8 OFF  KEY? ;   \ enables repeating key for TI-99

DECIMAL 
: BEEPS   ( n -- ) 0 ?DO BEEP 50 MS LOOP ;
: DELAY      delayms MS ;
: BLANKLN    VPOS C/L@ VBLANK ; \ FAST video memory write

: 1+!   ( int-addr -- )  1 SWAP +! ;  \ like C  ++
: 1-!   ( int-addr -- ) -1 SWAP +! ;  \ like C  --

: ENDIF      POSTPONE THEN ; IMMEDIATE   \ FIG FORTH

: HOME ( --- )  0 0 AT-XY ;

HEX
: ?LOWER  ( c -- ?)  [CHAR] a  [CHAR] z 1+  WITHIN ;
: TOUPPER ( c -- c') DUP ?LOWER IF 5F AND  THEN ;
: INKEY   ( -- c)    KEY 7F AND  TOUPPER ;  \ uppercase Alpha, 7 bit output
DECIMAL

CR .( Heap management and matrix creators)
\ \\\\\\\\\\\\\\\  TI99 CODE  \\\\\\\\\\\\\\\\\\
\ TI99 has 24K RAM.
\ 8K low RAM, 15K Hi RAM. Matrices need 7.3K
\ Using LOW RAM

\ heap memory analogs to HERE ALLOT C,  and ,
: HEAP    H @ ;
: HALLOT  H +! ;
: HC,     HEAP C!  1 HALLOT ;
: H,      HEAP !   2 HALLOT ;

\ INIT heap pointer & clean up heap space
HEX  2000 H !
HEAP 2000 ERASE

DECIMAL
CR .( 2D matrices allocated in Camel99 HEAP)
: BYTE-MATRIX: ( cols rows -- )
   CREATE HEAP ,
          DUP HC, * HALLOT
   DOES> ( n n -- addr )
         @ ROT 1- OVER C@ * + + ;

\ : 2D-ARRAY: ( rows cols -- )  \ 2D integer 2D-ARRAY
\    CREATE  HEAP , CELLS SWAP CELLS
\           ( cols) H, ( rows) H,
\    DOES> @          ( -- base-addr )
\         DUP CELLS+ @  ( -- base-addr cols )
;

\ Changed to descriptive names for the data :-)
SIZE SIZE BYTE-MATRIX: GALAXY    ( the galactic MATRIX:)
SIZE SIZE BYTE-MATRIX: PLANET    ( planetary MATRIX:)
SIZE SIZE BYTE-MATRIX: GARRISON  ( strength MATRIX:)

   2    6 BYTE-MATRIX: FLEETS ( player fleets info)

\ easier to understand this data by name
1 CONSTANT [MY   ( human side of matrix)
2 CONSTANT [HIS  ( enemy side of matrix)

: X]       ( n -- addr) 1 FLEETS ; \ byte
: Y]       ( n -- addr) 2 FLEETS ; \ byte

\ We can simplify the code and save space
: X]@    X] C@ ;
: Y]@    Y] C@ ;
: XY]@  ( n -- x y)  DUP Y]@ SWAP X]@ ;

: SHIPS]   ( n -- addr) 3 FLEETS ; \ cell
: SHIPS]@  ( ndx -- n) SHIPS] @  ;

: LEGIONS]  ( n -- addr) 5 FLEETS ; \ cell
: LEGIONS]@ ( ndx -- x) LEGIONS] @ ;

: THEPLANET ( -- addr) XY@ PLANET ;
: #LEGIONS  ( -- addr) XY@ GARRISON ; \ Legions on the planet
: THEGALAXY ( -- addr) XY@ GALAXY ;

( clear message area on text screen)
: CLEAR-MSG ( -- ) 18 10 DO   0 I AT-XY BLANKLN   LOOP ;

: PROMPT:   ( -- ) 0 10 AT-XY  BLANKLN ;
: LOPROMPT: ( -- ) 0 23 AT-XY  BLANKLN ;

: CLEAR-SCREEN ( -- )  0  C/SCR @ BL VFILL ; \ does NOT touch cursor

: []ERASE ( addr --) SIZE SIZE * ERASE ;  \ erase a matrix ;

: CLEAR-GALAXY ( -- )  1 1 GALAXY []ERASE ;

: CLEAR-INFO
    1 1 PLANET []ERASE
    1 1 GARRISON []ERASE ;

: RANDOM1 ( --- ran) ( random number in range 1-SIZE)
   RAND1 @ 37 * 651 + DUP RAND1 ! ABS SIZE MOD 1+ ;

: RANDOM2 ( --- ran ) ( random number in range 1-SIZE)
   RAND2 @ 53 * 773 + DUP RAND2 ! ABS SIZE MOD 1+ ;

\ create a double variable to hold randomly created coordinates
\ reduces stack juggling in game language
CREATE LASTXY   0 , 0 ,

\ create random coordinates and remember them.
: NEWXY  ( -- n n ) RANDOM1 RANDOM2 2DUP LASTXY 2!  ;
: THIS  ( -- n n ) LASTXY 2@ ;  \ return last NEWXY generated

: WRAP ( n --- ng ) SIZE 1- + SIZE MOD 1+ ; ( wrap galaxy coordinate)

\ number input routine
: #INPUT  ( -- n )
          DECIMAL
          BEGIN
            PAD DUP 10 ACCEPT  \ ACCEPT text into temp buffer PAD
            NUMBER?            \ convert the number in PAD
          WHILE                \ while the conversion is bad we do this
              ."  ? "
              DROP
          REPEAT ;


CR .( TMS9918 Pattern table management)
HEX
 \ Expose TI-99 pattern table at Video RAM $800 as an array
: ]PDT ( ascii# -- ) 8* 800 + ;
DECIMAL
: CHARDEF ( data[] ascii -- ) ]PDT 32 VWRITE ; \ write 32 bytes to video RAM

CR .( graphics shapes )
 \ TI-99 specific

 \ outer-space characters
 HEX
 CREATE ACOLONY 7884 , 3040 , 4030 , 8478 ,
 CREATE OPLANET 0078 , 8484 , 8484 , 8478 ,
 CREATE EPLANET 0070 , 8850 , 2050 , 8870 ,
 CREATE ASTAR   0000 , 1054 , 2854 , 1000 ,
 CREATE PFLEET  40F8 , 503C , 1040 , F840 ,
 CREATE EFLEET  20C0 , 2438 , 0410 , E010 ,
 CREATE BLKHOLE 7884 , 3078 , 7830 , 8478 ,
 CREATE NOFLEET 0084 , 4800 , 0048 , 8400 , \ fleet empty icon

 \ double line box chars
 CREATE VBARS  2828 , 2828 , 2828 , 2828 ,
 CREATE HBARS  0000 , 00FF , 00FF , 0000 ,
 CREATE ULEFT  0000 , 003F , 202F , 2828 ,
 CREATE URIGHT 0000 , 00F8 , 08E8 , 2828 ,
 CREATE LLEFT  2828 , 282F , 203F , 0000 ,
 CREATE LRIGHT 2828 , 28E8 , 08F8 , 0000 ,

\ TI-99 specific strategy
\ Re-define shape of characters used in the matrix map
\ This allows us to PLOT the map directly to the video screen

DECIMAL
17 CONSTANT FOE  \ enemy ship character

: DEF-CHARS
  ASTAR     2 CHARDEF
  ACOLONY 132 CHARDEF
  OPLANET   4 CHARDEF
  EPLANET   5 CHARDEF
  BLKHOLE   8 CHARDEF
  PFLEET   16 CHARDEF  \ player's fleet icon
  EFLEET  FOE CHARDEF  \ enemy's fleet icon

  VBARS   133 CHARDEF
  HBARS   134 CHARDEF
  ULEFT   135 CHARDEF
  URIGHT  136 CHARDEF
  LLEFT   137 CHARDEF
  LRIGHT  138 CHARDEF
;

DEF-CHARS
 \ Camel99 Forth: use (EMIT) which does not interpret control characters
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
   NO-OF-STARS 0 DO  2  RND-GALAXY!    LOOP

   NO-OF-PLANETS 0
   DO
     4 RND-GALAXY!    ( set up planets)
     RANDOM1 4* 8 +  THIS PLANET C!  ( set up class of planet)
   LOOP

   NO-OF-B-HOLES 0 DO   8 RND-GALAXY!   LOOP ;

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
   1 FLEET# !               ( make fleet 1 current fleet)
   250 CREDIT !             ( players credit)

   0 MY-PLANETS !           ( no planets)
   0 C-PLANETS !            ( none for computer either)

   20 [MY SHIPS] !          ( player's fleets)
   20 [HIS SHIPS] !         ( computer's fleets)

   50 [MY LEGIONS] !
   50 [HIS LEGIONS] !       ( fleets have 50 legions each)

   DIFF @ 4* 0
  ?DO ( position computer's fleets)
       FOE NEWXY GALAXY C!
        15 THIS GARRISON C!
  LOOP
   16 22 18 GALAXY C!
   16 18 22 GALAXY C!       ( position fleets)

   22 [MY Y] C!             ( players Y)
   18 [MY X] FLEETS C!      ( players x)
   18 [HIS Y] C!            ( enemy y )
   22 [HIS X] C!            ( enemy x)

   29 3 DIFF @ * - NEW !    ( how often computer creates fleets)
   15 DIFF @ 4* * TROOPS !  ( initial no. of computer troops)
   20 DIFF @ * C-LEGIONS !  ( no. of spare computer legions)
   DIFF @ 4* C-FLEETS !     ( no. of computer fleets)
   SPEED TIMER !            ( how often computer moves)
   1 BUY-V !
;

\ ** re-factored score computation **
\ Computed Weighted score
\ part_score= (player# - computer#) * weight
: PLANET-DIFF ( -- n) MY-PLANETS @  C-PLANETS @ -   W1 *  ;
: FLEETS-DIFF ( -- n) [MY SHIPS]@   [HIS SHIPS]@  -  W2 * ;
: FLEETS-DIFF ( -- n) [MY LEGIONS]@   [HIS LEGIONS]@  -  W2 * ;
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
    2  1 AT-XY ." FLEETS:"   14 TAB ." PLANETS:"
    0  4 AT-XY ." EMPIRE"
    2  5 AT-XY ." FLEETS:"   14 TAB ." PLANETS:"
    0 21 AT-XY ." SHIPS  :"
    0 22 AT-XY ." LEGIONS:" 23 22 AT-XY ." CREDITS:"
    0 20 AT-XY ." COORDS:"
   25 20 AT-XY ." SCORE:"
;

: .LEGIONS     8 22 AT-XY  [MY LEGIONS]@  4 .R ;
: .SHIPS       8 21 AT-XY  [MY SHIPS]@    4 .R  ;

: DRAW-FIGURES  ( draw the stats)
    9  1 AT-XY   2  4 .R           22 TAB MY-PLANETS @ 4 .R
    9  5 AT-XY C-FLEETS @  4 U.R   22 TAB C-PLANETS  @ 4 .R

    7 20 AT-XY  [MY Y]@  [MY X]@  .(X,Y)
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
   [MY Y]@ + WRAP SWAP
   [MY X]@ + WRAP SWAP ;

\ : PRINT-IT  ( c  --- ) X @ CELLS 12 +  Y @ 8 +  AT-XY VPUT  ;

\ >VPOS computes video screen address. Does not affect cursor variables
\ VC! writes a byte to Video RAM
: PLOT  ( char row col -- )
  CELLS 12 + SWAP 8 + >VPOS ( c Vaddr) VC! ;

: DRAW-SCAN ( draw the screen display)
   [MY X]@ 5 -  [MY Y]@ 5 -
   11 0 DO ( rows)
      11 0 DO ( columns)
              OVER WRAP OVER WRAP GALAXY C@  J I PLOT
              1+
           LOOP
           11 - SWAP 1+ SWAP
        LOOP
   2DROP
;

: DRAW-DISPLAY  ( -- )
  DRAW-LABELS  DRAW-FIGURES  WINDOW  DRAW-SCAN ;

: REDRAW   PAGE  DRAW-DISPLAY ;

: FLEET-ICON (  )
    [MY SHIPS]@
    IF   PFLEET
    ELSE NOFLEET
    THEN 16 CHARDEF ;

: NEW-FLEET  ( fleet destroyed for some reason)
   LOPROMPT: ." OUR FLEET DESTROYED" HONK
   \ you can still move the fleet cursor around though
   \ and buy more ships and take on more legions
   0 [MY X]@  [MY Y]@ GALAXY C! ( erase colony symbol)
   0 [MY SHIPS] !                   ( no ships left)
     FLEET-ICON
   0 [MY LEGIONS] !                 ( no legions left)
;

: MOVE-FLEET (  X Y ---  )
   2DUP
   0 [MY X]@ [MY Y]@ GALAXY C!  ( remove old symbol)
   16 -ROT GALAXY C!                ( plot fleet at new x,y)
   [MY Y] C! [MY X] C! ;            ( update my coordinates)

: CHECK-POSITION  ( X Y --- )
   WRAP SWAP WRAP SWAP
   2DUP GALAXY C@
   CASE
      0  OF MOVE-FLEET              ENDOF ( empty space)

      8  OF LOPROMPT: ." FLEET SUCKED INTO BLACK HOLE"
            HONK DELAY
            MOVE-FLEET
            NEW-FLEET
            LOPROMPT:               ENDOF

      DROP DROP
   ENDCASE
   DRAW-DISPLAY ;

\ need to add death detector to end when FLEETS are exhausted
: OTHER-FLEET   ( make other fleet current fleet)
   FLEET# @ 1 =
   IF   2 FLEET# !
   ELSE 1 FLEET# !
   ENDIF
   DRAW-DISPLAY ;

: MOVE-LEFT  ( -- )   [MY X]@    [MY Y]@ 1- CHECK-POSITION ;
: MOVE-RIGHT ( -- )   [MY X]@    [MY Y]@ 1+ CHECK-POSITION ;
: MOVE-DOWN  ( -- )   [MY X]@ 1+ [MY Y]@    CHECK-POSITION ;
: MOVE-UP    ( -- )   [MY X]@ 1- [MY Y]@    CHECK-POSITION ;

: LEGION-COST    ( -- n) RANDOM1 8 / THEPLANET C@ 7 / + ; ( cost of 1 legion)
: .$$$         ( n --) ." $" . ;

: PLANET-LEGIONS ( -- n) THEPLANET C@ 6 / ;  ( no. of legions on planet)

: ENLIST    ( enlisting 1egions on a planet)
   BUY-V @ 0=
   IF  ( it's ok to buy)
       5 BUY-V !  ( can't buy for 5 more moves)

       PROMPT: ." COST PER LEGION =" LEGION-COST DUP >R .$$$
       0 12 AT-XY ." NO. OF LEGIONS AVAILABLE = " PLANET-LEGIONS 3 .R

       0 14 AT-XY ." HOW MANY DO YOU REQUIRE?"
       #INPUT
       PLANET-LEGIONS MIN DUP R@ * CREDIT @ >
       IF
         0 16 AT-XY ." NOT ENOUGH CREDIT"
       ELSE
         [MY LEGIONS]@  OVER + [MY LEGIONS] !  ( update legions)
         R@ * CREDIT @ SWAP - CREDIT ! ( update credit)
       ENDIF
   ELSE
       PROMPT: ." NO TROOPS AVAILABLE"
   ENDIF
   R> DROP
   .LEGIONS ;

: RND-DOLLARS ( -- n) RANDOM1 5 / THEPLANET C@ 10 / + 1+ ;

: BUY    ( purchasing of ships at planet)
   BUY-V @ 0=
   IF    ( it's ok to buy)
      5 BUY-V !               ( stop continous buying)

      PROMPT: ." COST PER SHIP = " RND-DOLLARS DUP >R 2 .R

      0 12 AT-XY ." HOW MANY DO YOU WANT?" #INPUT
      CREDIT R@  / MIN    ( no more than he can afford)
      DUP [MY SHIPS] +!

      CREDIT @  R@ * - 0 MAX  CREDIT !    ( update credit)
      16  [MY Y]@  [MY X]@ GALAXY C!  ( make sure fleet symbol there)

   ELSE
      PROMPT: ." NO SHIPS AVAILABLE"
   ENDIF
   R> DROP
   .SHIPS ;


: GATHER   ( pick up legions from garrison onto fleet)
   0 10 AT-XY ." HOW MANY DO YOU WISH TO TAKE?" #INPUT
   #LEGIONS C@ MIN >R  ( no more than are there)
   [MY LEGIONS]@   R@  + [MY LEGIONS] !  ( update legions on fleet)
   #LEGIONS C@  R>  - #LEGIONS C! ;      ( update on planet)

\ Orignal name: "LEAVE"
: DEPLOY   ( leave legions from fleet on planet as garrison)
   BEGIN
     PROMPT: ." HOW MANY DO YOU WISH TO LEAVE? "
     #INPUT [MY LEGIONS]@  OVER <
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
      CLEAR-MSG
      CASE
         49 ( 1) OF DEPLOY FALSE ( leave legions)  ENDOF
         50 ( 2) OF GATHER FALSE ( gather legions) ENDOF
         51 ( 3) OF BUY    FALSE ( buy ships)      ENDOF
         52 ( 4) OF ENLIST FALSE ( en1ist troops)  ENDOF
                           TRUE  ( the default: leave planet)
      ENDCASE DELAY
   UNTIL
    CLEAR-MSG DRAW-DISPLAY ;

: PLANET-STRENGTH ( -- n)
      THEPLANET C@ 8 / RANDOM1 1- 5 / 7 + * 10 / ;

: .LOSSES  ( n - ) ." WE LOST "  3 .R  ."  LEGIONS" ;

: RETREAT ( enemy-strength -- )
      DELAY
      0 12 AT-XY  2/ DUP .LOSSES
      [MY LEGIONS]@  SWAP -   0 MAX [MY LEGIONS] !
      PROMPT: ." OUR FORCES RETREATED"
      DELAY DELAY
;

: CAPTURE ( enemy-strength -- )
      PROMPT:  ." PLANET CAPTURED"
      0 12 AT-XY  DUP  .LOSSES
      [MY LEGIONS]@  SWAP -  0 MAX [MY LEGIONS] !   ( update legions in fleet)
      MY-PLANETS 1+!
      132 THEGALAXY C!
      DELAY DELAY
;

: COLONISE ( attack an uncolonised planet)
   CLEAR-MSG
   PLANET-STRENGTH
   DUP [MY LEGIONS]@  >
   IF   ( n) RETREAT
   ELSE ( n) CAPTURE FRIENDLY-PLANET
   THEN  DRAW-DISPLAY
   R> DROP ;

: EMPTY-PLANET   ( in orbit round uncolonised planet)
   CLEAR-MSG
   PROMPT:  ." UNCOLONISED CLASS " THEPLANET C@ 8 / 2 .R   ." PLANET"
   0 12 AT-XY ." DO YOU WISH TO ATTACK?"
   INKEY [CHAR] Y =
   IF
      COLONISE
   ENDIF
   CLEAR-MSG ;

: NOT-PLANET   ( there isn't a planet where he's trying to land)
   PROMPT:  ." NO PLANET THERE"
   DELAY  CLEAR-MSG ;

( calculate enemy garrisons effective strength)
: ENEMY-STRENGTH ( -- n) #LEGIONS C@ RANDOM1 1- 5 / 7 + * 10 / ;

: ATTACK       ( attack a planet controlled by the computer)
   CLEAR-MSG
   ENEMY-STRENGTH DUP [MY LEGIONS]@  >
   IF ( enemy garrison wins)
      RETREAT
   ELSE
      0 #LEGIONS C!           ( reduce legions on planet to 0)
      CAPTURE
      C-PLANETS 1-!           ( decrement computer planets)
      THEPLANET C@ 8 / NEGATE CLASS-TOTALS +!
      DELAY                    ( reduce classes of compo plnts)
      FRIENDLY-PLANET
   ENDIF
   R> DROP
   DELAY
   CLEAR-MSG ;

: ENEMY-PLANET   ( player orbits enemy planet)
   THEPLANET C@ 8 /
   PROMPT:  ." CLASS " 2 .R ."  PLANET" CR CR
   ." ENEMY GARRISON OF STRENGTH "
   #LEGIONS C@ 3 .R CR CR
   ." DO YOU WISH TO ATTACK?" INKEY  [CHAR] Y =
   IF
      ATTACK
   ENDIF
  CLEAR-MSG ;

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
   0 12 AT-XY ." PLANET AT " XY@  .(X,Y)  ." REVOLTS" DELAY
   THEPLANET C@ 8 / #LEGIONS C@ 2DUP >
   IF ( revolt succeeds)
      DROP 4 THEGALAXY C!            ( place planet symbol)
      8* 7 + THEPLANET C!            ( set revolt factor 7)
      0 #LEGIONS C!                  ( set legions to 0)
      MY-PLANETS 1-!                    ( reduce no.of planets we have )

      0 14 AT-XY ." SUCCEEDS"
      2 BEEPS                         ( ring bell)

   ELSE ( revolt fails)
      SWAP 2/ - #LEGIONS C!           ( reduce legions)
      THEPLANET C@ 7 OR THEPLANET C!  ( set revolt factor 7)
      0 14 AT-XY ." FAILS"
      HONK
   ENDIF
   DELAY
   0 12 AT-XY BLANKLN
   0 14 AT-XY BLANKLN ;             ( clear messages)

: TAX     ( collect taxes on players planets)
   0 VTAX !                           ( set tax to 0)
   PROMPT: ." COLLECTING ..."
   SIZE 1+ 1
   DO
     SIZE 1+ 1
     DO
         I J GALAXY C@ 132 =
         IF   ( it's a colony)
              I J PLANET C@ 3 * 5 /   VTAX +!  ( update tax)
              17 10 AT-XY 4 U.R
              I J PLANET C@ 7 AND ?DUP
              IF ( doesn't revolt)
                 I J PLANET DUP C@ 1- SWAP C!
              ELSE ( revolt)
                 I X ! J Y ! REVOLT?
              ENDIF
         ENDIF
      LOOP
    LOOP
    PROMPT:  ." TAX COLLECTED =" VTAX @ .$$$
    CREDIT @ VTAX @ + CREDIT !            ( update credit)
    CLEAR-MSG DRAW-DISPLAY ;

: CREATE-ENEMY-FLEET ( -- ?)
      3 BEEPS                           ( ring bell)
      C-FLEETS 1+!                     ( update comp. fleets)
      29 4 DIFF @ * - NEW !             ( reset NEW)
      CLASS-TOTALS @ 8 /
      DUP C-LEGIONS +! ( increase enemy legions )
      DUP TROOPS +!
      BEGIN
         NEWXY GALAXY C@ 0=        ( check random galaxies)
         IF ( empty )
            FOE  THIS GALAXY C!    ( place enemy fleet symbol)
                 THIS GARRISON C!  ( plus legions)
                 TRUE
         ELSE
            2DROP DROP
            FALSE
         ENDIF
      UNTIL
;

: ENEMY-COLONIZER
   DIFF @ 0
   DO ( see if computer colonises planet)
      NEWXY GALAXY C@
      CASE
         4 OF ( empty planet)
             \ 2DUP 2DUP
              5 THIS GALAXY C! ( place colony)
              C-LEGIONS @ 2/ DUP C-LEGIONS !
              ( -- n ) THIS GARRISON C!
              C-PLANETS 1+!
              THIS PLANET C@ 8 / CLASS-TOTALS +!
                                          ENDOF
       132 OF ( players planet)
              THIS GARRISON C@  C-LEGIONS @ 2/ <
              IF ( captures planet)
                 C-LEGIONS @ 3 / C-LEGIONS !
                 5 THIS GALAXY C! ( place colony)
                 THEPLANET C@ 8 / CLASS-TOTALS +!
                 C-PLANETS 1+!
                 MY-PLANETS 1-!
                 5 BEEPS
               ENDIF
                                          ENDOF
      ENDCASE
    LOOP
;

: COMPUTER-TURN   ( computers turn to do something)
   NEW 1-!                            ( decrement NEW)
   NEW @ 0= IF  CREATE-ENEMY-FLEET  ENDIF
   ENEMY-COLONIZER
   DRAW-DISPLAY ;

: RADAR ( -- x y )  \ scan for enemy ship, return coordinates
   [MY Y]@ 2 + DUP 3 -
   DO
      [MY X]@ 2 + DUP 3 -
      DO
         I WRAP J WRAP GALAXY C@  FOE =
         IF  ( there's a fleet in range)
            I WRAP X !
            J WRAP Y !
         ENDIF
      LOOP
   LOOP
;

: FIRE     ( players fleet attacks computer fleet)
   [MY SHIPS]@  0= IF
         PROMPT: ." WE HAVE NO SHIPS SIR ..."
         DELAY REDRAW EXIT
   ENDIF
   0 X !
   RADAR
   X @ 0=
   IF
      PROMPT:  ." NO ENEMY FLEET IN RANGE"
   ELSE
      PROMPT: ." ENEMY FLEET DETECTED AT "  XY@ .(X,Y) 6 BEEPS

      [MY SHIPS]@   #LEGIONS C@  OVER 4* 10 /
      OVER 4* 10 / DUP
      PROMPT:  ." WE LOST "  .  ." SHIPS"
      -ROT - 0 MAX DUP 0=
      IF ( computers fleet destroyed)
         DROP TROOPS @ #LEGIONS C@ - TROOPS !
         PROMPT: ." ENEMY FLEET DESTROYED!" DELAY
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
   DELAY DELAY
   REDRAW ;


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
  PAGE ."  Scanner Display Information"
  CR   ." -----------------------------"
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
  CR   ." Player FLEET"  25 TAB  16 (EMIT)
  CR
  CR   ." Enemy FLEET"   25 TAB  FOE (EMIT)
  CR PRESSANY
  REDRAW
;

: >FORTH  HONK  0 0 AT-XY ." *Forth*"   ABORT  ;

: OBEY-COMMAND ( c -- )
   BUY-V @  IF ( nonzero)  -1 BUY-V +!  ENDIF
   CASE
      [CHAR] A OF MOVE-LEFT  ENDOF
      [CHAR] S OF MOVE-RIGHT ENDOF
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
   TIMER DUP 1-! @
   IF ( <>0)
       FALSE
   ELSE
      SPEED TIMER !  \ reset countdown timer
      TRUE
   ENDIF ;

: GAME-END? ( -- ? ) LEN @ 0= ;    ( game end if LEN is zero)

: END-MSG   CLEAR-MSG  0 12 AT-XY ." END OF GAME COMMANDER" ;

: GAME       ( GAME LOOP )
   PAGE
   DRAW-LABELS DRAW-DISPLAY
   BEGIN
      RKEY? ?DUP
      IF ( player has pressed a key)
         OBEY-COMMAND
         LEN 1-!
         100 MS
      ENDIF
      COMPUTER?
      IF
         COMPUTER-TURN
      ENDIF
      GAME-END?
  \ debug line
   20 0 AT-XY ." Stk=" DEPTH 2 .R  5 SPACES  TIMER @ 3 .R
   UNTIL
   END-MSG ;

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
      #INPUT
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
   HELP INFORMATION
   GAME ;
