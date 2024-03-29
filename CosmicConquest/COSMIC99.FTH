\ COSMIC CONQUEST TI-99 Native version                 Nov 2021 Brian Fox
\ Updated to create a binary program Feb 2023 

\ Original Fig-Forth version by  ALAN SARTORI-ANGUS for Apple][
\ The version based on Gforth version by Rick Carlino 
\ This version uses the Graphics features of TI-99 hardware

\ Change log from GForth verison: (This is a big re-write)

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

\ INCLUDE DSK1.TOOLS  \ for debugging only

\ Camel99 Forth Library requirements
INCLUDE DSK1.CASE
INCLUDE DSK1.UDOTR
INCLUDE DSK1.MARKER 

MARKER /REMOVE 

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
 VARIABLE TIMER        ( how quickly computer plays)

 VARIABLE DIFF         ( difficulty of game 1-4)
 VARIABLE FLEET#       ( Human player's fleet in use)
 VARIABLE LEG          ( the no. of legions available to buy)
 VARIABLE #MOVES          ( no. of moves remaining in game)
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
 VARIABLE CREDIT       ( players credit in dollars?)


CR .( utility words)
: ERASE    ( addr u --)    0 FILL ;
: VBLANK   ( Vaddr u --)   BL VFILL ;
: CENTERED ( addr len -- ) C/L@ OVER - 2/ 1- SPACES  TYPE ; \ print centered
: TAB      ( n -- )        VCOL ! ;
: XY@      ( -- col row)   X @ Y @ ;

\ safe variable decrementer, can't go below zero
: DECREMENT ( addr -- )  DUP @ 1-  0 MAX SWAP ! ;

HEX
: RKEY?   ( -- c ) 83C8 OFF  KEY? ;   \ enables repeating key for TI-99

DECIMAL
: BEEPS   ( n -- ) 0 ?DO BEEP 50 MS LOOP ;
: DELAY      delayms MS ;
: BLANKLN    VPOS C/L@ VBLANK ; \ FAST video memory write

\ These are now in the CAMEL99 kernel as CODE 
\ : 1+!   ( int-addr -- )  1 SWAP +! ;  \ like C  ++
\ : 1-!   ( int-addr -- ) -1 SWAP +! ;  \ like C  --

: ENDIF      POSTPONE THEN ; IMMEDIATE   \ FIG FORTH

: HOME ( --- )  0 0 AT-XY ;

\ % COMPUTING
: 10%  ( n -- n')  10 / ;
: 40%  ( n -- n')  4 10 */ ;

HEX
: ?LOWER  ( c -- ?)  [CHAR] a  [CHAR] z 1+  WITHIN ;
: TOUPPER ( c -- c') DUP ?LOWER IF 5F AND  THEN ;
: INKEY   ( -- c)    KEY 7F AND  TOUPPER ;  \ uppercase Alpha, 7 bit output

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
DECIMAL
CR .( Heap management and matrix creators)
\ \\\\\\\\\\\\\\\  TI99 CODE  \\\\\\\\\\\\\\\\\\
\ TI99 has 32K RAM total 
\ 24K Hi RAM, Forth uses 8K of this
\ 8K low RAM
\ Matrices need 7.3K
\ Using LOW RAM for matrices

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
         @  ROT OVER 1-  C@ *  + +
;

\ Changed to descriptive names for the data :-)
SIZE SIZE BYTE-MATRIX: GALAXY    ( the galactic MATRIX:)
SIZE SIZE BYTE-MATRIX: PLANET    ( planetary MATRIX:)
SIZE SIZE BYTE-MATRIX: GARRISON  ( strength MATRIX:)

\ This should be a cell matrix. Manually create one in the heap
HEAP CONSTANT FLEETS[]   2 CELLS 6 CELLS *   HALLOT
: FLEETS ( x y -- addr)  CELLS 6 * SWAP CELLS FLEETS[] + + ;

\ easier to understand this data by name
1 CONSTANT [MY   ( human side of matrix)
2 CONSTANT [HIS  ( enemy side of matrix)

: X]       ( n -- addr) 1 FLEETS ; \ byte
: Y]       ( n -- addr) 2 FLEETS ; \ byte

\ We can simplify the code and save space
: X]@    X] @ ;
: Y]@    Y] @ ;
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
: THIS   ( -- n n ) LASTXY 2@ ;  \ return last NEWXY generated

: WRAP   ( n --- ng) SIZE 1- + SIZE MOD 1+ ; ( wrap galaxy coordinate)

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
 CREATE NOENEMY 8244 , 2810 , 2844 , 8200 , \ enemy out of ships 

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

\ name the graphic characters used
DECIMAL
132 CONSTANT 'COLONY'  \ good guys live here
 16 CONSTANT 'FLEET'   \ our boys
 17 CONSTANT 'ENEMY'   \ enemy ship character
 02 CONSTANT 'STAR'
 04 CONSTANT 'PLANET'  \ empty planet
 05 CONSTANT 'ALIENS'  \ bad guys live on this planet
 08 CONSTANT 'BLKHOLE'
 00 CONSTANT 'VACUUM'  \ empty space

: DEF-CHARS
  ASTAR       'STAR' CHARDEF
  ACOLONY   'COLONY' CHARDEF
  OPLANET   'PLANET' CHARDEF
  EPLANET   'ALIENS' CHARDEF
  BLKHOLE  'BLKHOLE' CHARDEF
  PFLEET     'FLEET' CHARDEF  \ player's fleet icon
  EFLEET     'ENEMY' CHARDEF  \ enemy's fleet icon

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
   NO-OF-STARS 0 DO  'STAR'  RND-GALAXY!    LOOP

   NO-OF-PLANETS 0
   DO
     'PLANET' RND-GALAXY!    ( set up planets)
     RANDOM1 4* 8 +  THIS PLANET C!  ( set up class of planet)
   LOOP

   NO-OF-B-HOLES 0 DO   'BLKHOLE' RND-GALAXY!   LOOP

  'FLEET' [MY X]@  [MY Y]@ GALAXY C!  ( plot players fleet)
;

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
      [CHAR] 1 OF 250 #MOVES ! ( 350 moves) ENDOF
      [CHAR] 2 OF 400 #MOVES ! ( 700 moves) ENDOF
                  800 #MOVES ! ( 1500 moves otherwise)
   ENDCASE
;

( how often computer creates fleets)
: RESET-NEW-TIMER  29 3 DIFF @ * - NEW ! ; 

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

   DIFF @ 4* C-FLEETS !     ( no. of computer fleets)

   C-FLEETS @  0
   DO ( position computer's fleets)
       'ENEMY' NEWXY GALAXY C!  \ place an enemy planet
        15 THIS GARRISON C!     \ garrisons on the planet
   LOOP

   22 [MY Y] C!      ( players Y)
   18 [MY X] C!      ( players x)

  ( position players fleets)
   'FLEET' 22 18 GALAXY C!  \ primary fleet
   'FLEET' 18 22 GALAXY C!  \ 2nd fleet

   18 [HIS Y] C!            ( enemy y )
   22 [HIS X] C!            ( enemy x)

   RESET-NEW-TIMER   ( how often computer creates fleets)
   
   15 DIFF @ 4* * TROOPS !  ( initial no. of computer troops)
   20 DIFF @ * C-LEGIONS !  ( no. of spare computer legions)
   SPEED TIMER !            ( how often computer moves)
   1 BUY-V !
;

\ ** re-factored score computation **
\ Computed Weighted score
\ part_score= (player# - computer#) * weight
: PLANET-DIFF ( -- n) MY-PLANETS @    C-PLANETS @ -   W1 *  ;
: FLEETS-DIFF ( -- n) [MY SHIPS]@     [HIS SHIPS]@  -  W2 * ;
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
: .(X,Y)  ( x y -- )  ." ("  2 .R ." ,"  2 .R ." )" ; \ print coordinates

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
: .COORDS      7 20 AT-XY  [MY Y]@  [MY X]@ .(X,Y) ;

: DRAW-FIGURES  ( draw the stats)
    9  1 AT-XY   2  4 .R           22 TAB MY-PLANETS @ 4 .R
    9  5 AT-XY C-FLEETS @ 4 U.R    22 TAB C-PLANETS  @ 4 .R

    .COORDS
    .SHIPS
    .LEGIONS
    31 22 AT-XY CREDIT @    5 U.R
    31 20 AT-XY SCORE       5 U.R
;

: GET-DIRECTION     (  --- X Y )
( find out which square player means)
   LOPROMPT: ." WHICH DIRECTION? "
   INKEY
   CASE
      [CHAR] W ( up)    OF -1  0 ENDOF
      [CHAR] Z ( down)  OF  1  0 ENDOF
      [CHAR] S ( right) OF  0  1 ENDOF
      [CHAR] A ( left)  OF  0 -1 ENDOF
               ( default)   0  0
   ENDCASE
   LOPROMPT:   ( clear message )
   [MY Y]@ + WRAP SWAP
   [MY X]@ + WRAP SWAP ;

\ : PRINT-IT  ( c  --- ) X @ CELLS 12 +  Y @ 8 +  AT-XY VPUT  ;

\ Camel99 specific: 
\ >VPOS ( col row -- Vaddr)  computes video address. 
\ Screen Vaddr is 0..3C0
\ Does not affect cursor variables

\ VC! ( char Vaddr --) writes a byte to Video RAM

: PLOT  ( char row col -- ) CELLS 12 + SWAP 8 + >VPOS ( c Vaddr) VC! ;

\ This is slow, from original code 
 : DRAW-VIEWER  ( draw the screen display)
   [MY X]@ 5 -  [MY Y]@ 5 -
   11 0 DO ( rows)
      11 0 DO ( columns)
              OVER WRAP OVER WRAP GALAXY C@  J I PLOT
              1+
           LOOP
           11 - SWAP 1+ SWAP
        LOOP
    2DROP
   .COORDS
 ;

: DRAW-DISPLAY  ( -- )  DRAW-LABELS  DRAW-FIGURES  WINDOW  DRAW-VIEWER ;

: REDRAW   PAGE  DRAW-DISPLAY ;

: SET-FLEET-ICON (  )
   [MY SHIPS]@  IF PFLEET  ELSE NOFLEET THEN 'FLEET' CHARDEF ;

: SET-ENEMY-ICON (  )
   [HIS SHIPS]@ IF EFLEET  ELSE NOENEMY THEN 'ENEMY' CHARDEF ;


: NEW-FLEET  ( fleet destroyed for some reason)
   LOPROMPT: ." FLEET WAS DESTROYED! Goto a Colony!!" HONK
   \ you can still move the fleet cursor around though
   \ and buy more ships and take on more legions
   'VACUUM' [MY X]@  [MY Y]@ GALAXY C! ( erase colony symbol)
   0 [MY SHIPS] !                   ( no ships left)
   0 [MY LEGIONS] !                 ( no legions left)
    SET-FLEET-ICON
;

: MOVE-FLEET ( x y ---  )
   2DUP
   0 [MY X]@ [MY Y]@ GALAXY C!     ( remove old symbol)
   'FLEET' -ROT GALAXY C!          ( plot fleet at new x,y)
   [MY Y] C! [MY X] C!             ( update my coordinates)
   DRAW-VIEWER
;

: CHECK-POSITION  ( X Y --- )
   WRAP SWAP WRAP SWAP
   2DUP GALAXY C@
   CASE
      'VACUUM'  OF MOVE-FLEET         ENDOF

      'BLKHOLE' OF
                  LOPROMPT: ." FLEET SUCKED INTO BLACK HOLE"
                  HONK DELAY
                  MOVE-FLEET
                  NEW-FLEET
                  LOPROMPT:           
                  
                                       ENDOF

    ( default)    2DROP
   ENDCASE
;

\ need to add death detector to end when FLEETS are exhausted
: OTHER-FLEET   ( make other fleet current fleet)
   FLEET# @ 1 =
   IF   2 FLEET# !
   ELSE 1 FLEET# !
   ENDIF
   REDRAW ;

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

       PROMPT:    ." COST PER LEGION =" LEGION-COST DUP >R .$$$
       0 12 AT-XY ." NO. OF LEGIONS AVAILABLE = " PLANET-LEGIONS 3 .R
       BEGIN
          0 14 AT-XY ." HOW MANY DO YOU REQUIRE?"
          #INPUT
          DUP PLANET-LEGIONS U>
       WHILE ( true)
          DUP R@ *  CREDIT @ U>   ( cost/legion is on Rstack)
       WHILE ( true)
           0 16 AT-XY ." CAN'T DO THAT SIR" HONK DELAY
           0 16 AT-XY BLANKLN
          DROP
       REPEAT
       THEN
       DUP [MY LEGIONS] +!  ( update legions)
       R> * CREDIT @ SWAP -  0 MAX CREDIT ! ( update credit, limit to 0)
   ELSE
       PROMPT: ." NO TROOPS AVAILABLE"
   ENDIF
   .LEGIONS ;

: RND-DOLLARS ( -- n) RANDOM1 5 / THEPLANET C@ 10% + 1 MIN ;

: BUY-SHIPS ( purchase ships at planet)
   BUY-V @ 0=
   IF    ( it's ok to buy)
      5 BUY-V !               ( stop continous buying)
      CLEAR-MSG
      PROMPT: ." COST PER SHIP = " RND-DOLLARS DUP >R .$$$
      BEGIN
         0 12 AT-XY BLANKLN ." HOW MANY DO YOU WANT?"
         #INPUT
         DUP R@ *  CREDIT @ >  ( is our order bigger than our bank acc't?)
      WHILE
          LOPROMPT: ." YOU CAN'T AFFORD THAT!"
          HONK DELAY LOPROMPT:
      REPEAT
      DUP [MY SHIPS] +!   \ add ships to the fleet
      ( #ships) R> * NEGATE  CREDIT +!    ( deduct credits)
      'FLEET'  [MY Y]@ [MY X]@ GALAXY C!  ( place our fleet symbol)
   ELSE
      PROMPT: ." NO SHIPS AVAILABLE"
      HONK DELAY
      REDRAW
   ENDIF SET-FLEET-ICON 
;

: GATHER   ( pick up legions from garrison onto fleet)
   0 10 AT-XY ." HOW MANY DO YOU WISH TO TAKE?"
   #INPUT  #LEGIONS C@ MIN                ( no more than are there)
   >R                                     ( push onto Rstack)
   [MY LEGIONS]@  R@ +  [MY LEGIONS] !    ( update legions on fleet)
   #LEGIONS C@  R> -    #LEGIONS C!       ( update on planet)
;

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

: PCLASS ( -- n) THEPLANET C@ 8 / ;

: LANDING-MENU ( -- ?)  ( options upon landing at colony)
   BEGIN
      CLEAR-MSG
      PROMPT: ." CLASS " PCLASS .  ."  PLANET"
           CR ." LOCAL GARRISON HAS " #LEGIONS C@ . ."  LEGIONS"
      0 12 AT-XY ." DO YOU WISH TO:"
      CR ." 1.  LEAVE LEGIONS ON PLANET"
      CR ." 2.  GATHER LEGIONS FROM PLANET"
      CR ." 3.  BUY SHIPS"
      CR ." 4.  ENLIST TROOPS"
      CR ." 5.  LEAVE" CR
      INKEY              ( get reply)
      CLEAR-MSG
      CASE
        [CHAR] 1 OF DEPLOY    FALSE ( leave legions)  ENDOF
        [CHAR] 2 OF GATHER    FALSE ( gather legions) ENDOF
        [CHAR] 3 OF BUY-SHIPS FALSE ( buy ships)      ENDOF
        [CHAR] 4 OF ENLIST    FALSE ( en1ist troops)  ENDOF
                              TRUE  ( the default: leave planet)
      ENDCASE DELAY
   UNTIL
;


: .LOSSES  ( n - ) ." WE LOST " . ."  LEGIONS"  DELAY  ;

: RETREAT ( enemy-strength -- )
      PROMPT: ." OUR FORCES RETREATED"  DELAY
      0 12 AT-XY  2/ DUP .LOSSES
      [MY LEGIONS]@  SWAP  -   0 MAX [MY LEGIONS] !
      DELAY
;

: CAPTURE ( enemy-strength -- )
      PROMPT:  ." PLANET WAS CAPTURED"
      DELAY
      0 12 AT-XY  DUP  .LOSSES
      [MY LEGIONS]@  SWAP 2/ -  0 MAX [MY LEGIONS] !   ( update legions in fleet)
      MY-PLANETS 1+!
      .LEGIONS
      CLEAR-MSG
      'COLONY' THEGALAXY C!
;

: PLANET-STRENGTH ( -- n) PCLASS RANDOM1 1- 5 / 7 + * 10% ;

: COLONISE  ( attack an uncolonised planet)
   PLANET-STRENGTH
   DUP [MY LEGIONS]@  >
   IF   ( n) RETREAT
   ELSE ( n) CAPTURE
        LANDING-MENU
   THEN
;

: EMPTY-PLANET   ( in orbit round uncolonised planet)
   CLEAR-MSG
   PROMPT:  ." UNCOLONISED CLASS " THEPLANET C@ 8 / 2 .R   ." PLANET"
   0 12 AT-XY ." DO YOU WISH TO ATTACK?"
   INKEY [CHAR] Y =
   IF
      COLONISE
   ENDIF
   REDRAW ;

: NOT-PLANET   ( there isn't a planet where he's trying to land)
   PROMPT:  ." NO PLANET THERE"
   DELAY  CLEAR-MSG  DRAW-DISPLAY ;

( calculate enemy garrisons effective strength)
: ENEMY-STRENGTH ( -- n) #LEGIONS C@ RANDOM1 1- 5 / 7 + * 10% ;

: ATTACK       ( attack a planet controlled by the computer)
   CLEAR-MSG
   ENEMY-STRENGTH DUP [MY LEGIONS]@  >
   IF ( enemy garrison wins)
       PROMPT: ." THE PLANET WAS WELL GARRISONED"
       DELAY
       ( -- strength) RETREAT
   ELSE
      0 #LEGIONS C!           ( reduce legions on planet to 0)
      CAPTURE
      C-PLANETS DECREMENT     ( decrement computer planets)
      PCLASS NEGATE CLASS-TOTALS +!
      DELAY
      LANDING-MENU
   ENDIF
   R> DROP
   DELAY
   CLEAR-MSG ;

: P-CLASS ( -- n) THEPLANET C@ 8 / ; \ compute planet's class

: ENEMY-PLANET   ( player orbits enemy planet)
   PROMPT: ." CLASS "  P-CLASS 2 .R  ."  PLANET"
   CR
   CR ." ENEMY GARRISON OF STRENGTH "   #LEGIONS C@ 3 .R
   CR
   CR ." DO YOU WISH TO ATTACK?" INKEY
   [CHAR] Y =
   IF
      ATTACK
   ENDIF
   CLEAR-MSG ;

: LAND   ( land on adjacent planet)
   GET-DIRECTION
   2DUP Y ! X !  GALAXY C@
   CASE
      'PLANET'  OF EMPTY-PLANET    ENDOF
      'ALIENS'  OF ENEMY-PLANET    ENDOF
      'COLONY'  OF LANDING-MENU ENDOF
                 NOT-PLANET
   ENDCASE ;

: REVOLT? ( planet at X,Y revolts)
   0 12 AT-XY ." PLANET AT " XY@  .(X,Y)  ." REVOLTS" DELAY
   THEPLANET C@ 8 / #LEGIONS C@ 2DUP >
   IF ( revolt succeeds)
      DROP 'PLANET' THEGALAXY C!            ( place planet symbol)
      8* 7 + THEPLANET C!            ( set revolt factor 7)
      0 #LEGIONS C!                  ( set legions to 0)
      MY-PLANETS DECREMENT           ( reduce no.of planets we have )

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
         I J GALAXY C@ 'COLONY' =
         IF   ( it's a colony)
              I J PLANET C@ 3 * 5 /   VTAX +!  ( update tax)
              17 10 AT-XY  VTAX @ .$$$
              I J PLANET C@ 7 AND ?DUP
              IF ( doesn't revolt)
                 I J PLANET DUP C@ 1- SWAP C!
              ELSE ( revolt)
                 I X ! J Y ! REVOLT?
              ENDIF
         ENDIF
      LOOP
    LOOP
    PROMPT:  ." TAX COLLECTED =" VTAX @ .$$$ DELAY
    VTAX @ CREDIT +!   ( update credit)
    CLEAR-MSG
    DRAW-DISPLAY ;


\ ========[ ENEMY STUFF ]============
: CREATE-ENEMY-FLEET ( -- ?)
      3 BEEPS                         \ ring bell to warn player
      C-FLEETS 1+!                    \ update comp. fleets
      SET-ENEMY-ICON
      RESET-NEW-TIMER     
      CLASS-TOTALS @ 8 / ( -- n)
      DUP C-LEGIONS +!   ( -- n)      \ increase enemy legions 
      DUP TROOPS +!      ( -- n)  
      BEGIN
         NEWXY GALAXY C@ 0=           \ check random galaxy location
         IF ( empty )
            'ENEMY' THIS GALAXY C!    \  place enemy fleet symbol)
             ( n)   THIS GARRISON C!  \  plus legions
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
         'PLANET' OF ( empty planet)
             \ 2DUP 2DUP
              'ALIENS' THIS GALAXY C! ( place colony)
              C-LEGIONS @ 2/ DUP C-LEGIONS !
              ( -- n ) THIS GARRISON C!
              C-PLANETS 1+!
              THIS PLANET C@ 8 / CLASS-TOTALS +!
                                          ENDOF
       'COLONY' OF ( players planet)
              THIS GARRISON C@  C-LEGIONS @ 2/ <
              IF ( captures planet)
                 C-LEGIONS @ 3 / C-LEGIONS !
                 'ALIENS' THIS GALAXY C! ( place colony)
                 THEPLANET C@ 8 / CLASS-TOTALS +!
                 C-PLANETS 1+!
                 MY-PLANETS DECREMENT
                 5 BEEPS
               ENDIF
                                          ENDOF
      ENDCASE
    LOOP
;

: COMPUTER-TURN   ( computers turn to do something)
   NEW 1-!                         ( decrement NEW)
   NEW @ 0= IF  CREATE-ENEMY-FLEET  ENDIF
   ENEMY-COLONIZER
   DRAW-DISPLAY ;

: RADAR ( -- x y )  \ scan for enemy ship, return coordinates
   [MY Y]@ 2 + DUP 3 -
   DO
      [MY X]@ 2 + DUP 3 -
      DO
         I WRAP J WRAP GALAXY C@  'ENEMY' =
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

      [MY SHIPS]@   #LEGIONS C@ OVER 40%  OVER 40%  DUP
      PROMPT: .LOSSES
      -ROT - 0 MAX DUP 0=
      IF ( computers fleet destroyed)
         DROP TROOPS @ #LEGIONS C@ - TROOPS !
         PROMPT: ." ENEMY FLEET DESTROYED!" DELAY
        ( reduce computers troops)
         'VACUUM' THEGALAXY C!      ( destroy fleet symbol)
          C-FLEETS DECREMENT        ( reduce computer's fleets)
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


: ANYKEY   LOPROMPT: ." Press a key to return" KEY DROP ;


: INFO
  PAGE ."  Scanner Display Information"
  CR   ." -----------------------------"
  CR
  \ use (EMIT) to print control char values. 
  CR   ." A STAR"        25 TAB  'STAR'   (EMIT) 
  CR
  CR   ." A COLONY"      25 TAB  'COLONY' (EMIT)
  CR
  CR   ." Empty PLANET"  25 TAB  'PLANET' (EMIT)
  CR
  CR   ." Enemy PLANET"  25 TAB  'ALIENS' (EMIT)
  CR
  CR   ." Black hole"    25 TAB  'BLKHOLE' (EMIT) 
  CR
  CR   ." Player FLEET"  25 TAB  'FLEET'  (EMIT)
  CR
  CR   ." Enemy FLEET"   25 TAB  'ENEMY'  (EMIT)
  CR ANYKEY
;

: HELP
  PAGE ." Key controls:
  CR
  CR ." W, Z  up,down"
  CR ." A, S  left,right"
  CR
  CR ." L - Land on a planet"
  CR ." T - Tax your planets"
  CR ." I - SCANNER screen legend"
  CR ." F - Fire / attack enemy"
  CR ." O - Switch to Other fleet"
  CR ." ESC/FCTN 9  escape to Forth"

  CR ." H - show this HELP screen"
  CR ANYKEY
;

: >FORTH  PAGE  0 0 AT-XY ." *Camel99 Forth*" CR  ABORT  ;

: OBEY-COMMAND ( c -- )
   BUY-V @  IF ( nonzero)  -1 BUY-V +!  ENDIF
   CASE
      [CHAR] A OF MOVE-LEFT   ENDOF
      [CHAR] S OF MOVE-RIGHT  ENDOF
      [CHAR] W OF MOVE-UP     ENDOF
      [CHAR] Z OF MOVE-DOWN   ENDOF
      [CHAR] O OF OTHER-FLEET ENDOF
      [CHAR] I OF INFO REDRAW ENDOF
      [CHAR] L OF LAND        ENDOF
      [CHAR] T OF TAX         ENDOF
      [CHAR] F OF FIRE        ENDOF
      [CHAR] H OF HELP REDRAW ENDOF
      [CHAR] I OF INFO        ENDOF 
       15      OF >FORTH      ENDOF  \ escape key for debugging
   ENDCASE
;

DECIMAL
: COMPUTER? ( -- ?)   ( is it the computers turn or not)
   TIMER DUP DECREMENT @
   IF ( <>0)
       FALSE
   ELSE
      SPEED TIMER !  \ reset countdown timer
      TRUE
   ENDIF ;

: GAME-END? ( -- ? ) 
   [MY SHIPS]@ 0=    \ out of ships 
   CREDIT @ 0=  AND  \ and out of money 

   #MOVES @ 0=  OR   \ OR out of moves 
;  

: END-MSG   
   CLEAR-MSG  
   0 12 AT-XY ." END OF GAME COMMANDER" 
   LOPROMPT: ." TYPE RUN TO PLAY AGAIN"
   ABORT
;   

: GAME       ( GAME LOOP )
   REDRAW
   BEGIN
      RKEY? ?DUP
      IF ( player has pressed a key)
         OBEY-COMMAND
         #MOVES DECREMENT
         100 MS
      ENDIF
      COMPUTER?
      IF
         COMPUTER-TURN
      ENDIF
      \ debug line
      20 0 AT-XY ." Stk=" DEPTH 2 .R  5 SPACES  TIMER @ 3 .R
      GAME-END?
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
   CR S" ALAN SARTORI-ANGUS" CENTERED
   CR
   CR
   CR S" APPLE ][, 1982" CENTERED
   CR
   CR
   CR
   CR S" Re-write for TI-99 " CENTERED
   CR S" Brian Fox 2021" CENTERED
   DELAY
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
   HELP
   GAME ;

: STARTER   WARM  RUN  ;

\ ************************************************************
\ Un-comment the 3 lines below to save as a binary image program 

LOCK 
INCLUDE DSK1.SAVESYS
' STARTER SAVESYS DSK3.CONQUEST
