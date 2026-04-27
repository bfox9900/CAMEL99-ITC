\ GRIDRUNNER   Apr 2026
\ From the talented people at atariage.com
\ SteveB's LSCROLL demo in TiCodEd
\ Features added by 2026 Brad Snyder
\ re-write in Forth by Brian Fox for Camel99 Forth

\ add some stuff to the kernel
INCLUDE DSK1.TOOLS
INCLUDE DSK1.VALUES
INCLUDE DSK1.GRAFIX
INCLUDE DSK1.AUTOMOTION
INCLUDE DSK1.COLORS
INCLUDE DSK1.RANDOM
INCLUDE DSK1.SOUND
INCLUDE DSK1.MALLOC  \ simple low ram allocator

\ utilities
: VBLANK  ( Vaddr n -- ) BL VFILL ; \ fill VDP memory with space char
: CLIP    ( n lo hi -- n') ROT MIN MAX ; \ CLIP n to lo  hi range

\ simple faster, case structure. EXITs as soon as match is found
: :CASE  ( n --) POSTPONE OVER=  POSTPONE IF  POSTPONE DROP ; IMMEDIATE
: BREAK; ( -- )  POSTPONE EXIT   POSTPONE THEN ; IMMEDIATE

: ENUM  ( 0 <text> -- n) DUP CONSTANT  1+ ;

1 ( set 1st color)
ENUM CLR      \ 1
ENUM BLACK    \ 2
ENUM GREEN    \ 3
ENUM LIME     \ 4
ENUM BLUE     \ 5
ENUM SKY      \ 6
ENUM RED      \ 7
ENUM CYAN     \ 8
ENUM RUST     \ 9
ENUM ORANGE   \ 10
ENUM YELLOW   \ 11
ENUM LEMON    \ 12
ENUM OLIVE    \ 13
ENUM PURPLE   \ 14
ENUM GRAY     \ 15
ENUM WHITE    \ 16
DROP
\ ======================================================================
\                  >>> GAME CODE BEGINS <<<

\ define variables.
\ Used VALUES because they are normally faster in games
DECIMAL
30 VALUE SPEEDSET
30 VALUE SPEED
32 VALUE SCROLLS
 0 VALUE score
 0 VALUE hiscore

\ name sprites
  0 CONSTANT #SHIP          \ ship Sprite. (sprite no.s start at zero)

\ name some characters
  1 CONSTANT Brick
  2 CONSTANT BRICK2
  8 CONSTANT BARCHAR

128 CONSTANT Shipchar
132 CONSTANT Debris

136 CONSTANT HIJET
140 CONSTANT LOJET

\ Camel99 CALLCHAR must have all 8 bytes for each character shape
: SHIP$
 S" 0000C0F3FF3F3FFF3F3FFFF3C00000000000000000C0FCFFFCC0000000000000" ;

: DEBRIS$
 S" 220884218A00248108104580144012001082005002A80011440008A200049200" ;

: JETHI$
  S" 01020705030100000000000000000000008040C0800000000000000000000000" ;

: JETLO$
  S" 0000000000000000000001020705030100000000000000000000008040C08000" ;

: BRICK$  S" FF818181818181FF" ;
: DAMAGE$ S" 1F1B090D0505091F" ;
: BAR$    S" FF81BDBDBDBD81FF" ;

: SHAPES
  SHIP$   Shipchar CALLCHAR
  DEBRIS$ Debris   CALLCHAR
  BRICK$  Brick    CALLCHAR
  DAMAGE$ BRICK2   CALLCHAR
  BAR$    BARCHAR  CALLCHAR
  JETHI$  HIJET    CALLCHAR
  JETLO$  LOJET    CALLCHAR
;

 \ Usage: RED BRICKS
: BRICKS ( color -- ) Brick SET# SWAP BLACK COLOR ;

: .BORDERS
  BARCHAR SET# WHITE GRAY COLOR
\ col row  char    cnt
  0    0  BARCHAR  31 HCHAR
  0   19  BARCHAR  31 HCHAR
;

: GameInit
  32 TO SCROLLS
   0 TO score
  GRAPHICS ( does clear as well)
  BLACK SCREEN
  4 19  WHITE BLACK COLORS  \ printable characters
  .BORDERS
  SHAPES
  CYAN BRICKS
  2 MAGNIFY
\ char      clr   x   y  spr#
  Shipchar WHITE 10 100  #SHIP SPRITE
;

: EndGame?   ( -- ?)
  0 23 AT-XY ." Press ENTER to play again"
  KEY 13 <> ; \ wait for key, return true or false

: RedFlash ( --  )
  RED SCREEN   RUST BRICKS
  400 MS
  BLACK SCREEN  CYAN BRICKS ; \ Flash screen red

\ access sprite attribute table as an array of 4 byte records
: ]SAT  ( n -- Vaddr) 4* SAT + ;

\ :-) ommitted this in the SPRITE library
: DELSPRITE  ( n -- )     ]SAT  4 VBLANK ;

\ delete 'n' sprites with sequential numbers
: DELSPRITES ( n 1st -- ) ]SAT SWAP 4* VBLANK ;

\ divide by 8 using 3 shifts to the right (TEXT MACRO)
: 8/   ( n -- n') S" 3 RSHIFT" EVALUATE ; IMMEDIATE

\ Convert pixels to character coordinates
: >XY  ( pix piy -- x y)  8/ 1+  SWAP 8/ 1+ SWAP ;

\ Random motion vector -5 .. 5
: RNDV ( -- dx dy) 11 RND 5 - ;

: Explode ( -- )
    0 0 #SHIP MOTION  \ Stop ship
    1 DELSPRITE       \ delete retro rocket

    16 MOVING  \ sets the number of sprites for Automotion interrupt
    -2 NOISE  0 DB  200 MS \ loud explosion

    BRICK2 #SHIP POSITION >XY >VPOS VC!
    RedFlash

    \ 12 sprites flying in random directions
    14 2 DO
        Debris ORANGE  #SHIP POSITION I SPRITE \ Use POSITION like a function
        RNDV RNDV I MOTION
        I DB 70 MS  \ set volume and hold
    LOOP
    -28 DB
    200 MS
    SILENT
    12 2 DELSPRITES   \ delete 12 sprites starting at #2
    1 MOVING
;

: CRASH \  Oh no, we crashed!
  Explode      \ debris flying off of ship
  DELALL       \ Clean up all the sprites
;

HEX
83C8 CONSTANT RPTKEY \ magic address in TI-99 system

DECIMAL
: RETRO ( char -- ) \ fire retro-rocket
   -10 DB  \ engine volume up
 \ fire burst has no motion assigned. It follows the ship.
   ORANGE  #SHIP POSITION  1 SPRITE
;

: MOVE-UP     LOJET RETRO    1 -11 #SHIP MOTION ;
: MOVE-DOWN   HIJET RETRO    0 11  #SHIP MOTION ;


 DECIMAL
: MOVE-SHIP ( -- )
    RPTKEY ON
    KEY?              \ Scan for a key.move
    [CHAR] E :CASE  MOVE-UP     BREAK;  \ move ship up
    [CHAR] X :CASE  MOVE-DOWN   BREAK;  \ move ship down
  \ no key detected actions:
    DROP
    0 0 #SHIP MOTION         \ stop motion
    1 DELSPRITE
    -24 DB
;

\ : COLLISION?  ( -- ?) #SHIP POSITION >XY  GCHAR  BL <> ;

\ return true if ship position is over a space char (BL)
: SAFE?       ( -- ?) #SHIP POSITION >XY  GCHAR BL = ;

\ fast typing
: VTYPE  ( addr len ) DUP>R VPOS SWAP VWRITE  R> VCOL +!  ;

\ fast score printing
: .##### ( u --) ABS 0 <#  # # # # #  #> VTYPE ;

: .SCORE ( -- )
  score hiscore MAX  TO hiscore
  0 22 AT-XY  ." Score " score .#####  3 SPACES ." High " hiscore .##### ;

\ "tables" expose any memory as a table of records
\ The index calculation is at machine speed
HEX
: TABLE32: ( addr -- ) \ 32 bytes per record
    CREATE    ,         \ compile time: record the base address

    ;CODE ( n -- addr)  \ RUN time: do this machine code
          0A54 ,        \  R4 5 SLA,  ( TOS 32* )
          A118 ,        \ *W R4 ADD, \ *W holds the base address
          NEXT,         \ return to Forth interpreter
    ENDCODE

\ ****************************************************************
\                   horizontal scroll function
\  Camel99 didn't have horizontal scrolling so we had to make one
HEX 2000 H !  \ reset heap pointer to start of low ram
\ ****************************************************************
DECIMAL
20 C/L@ *          CONSTANT WINDOW_SIZE
WINDOW_SIZE MALLOC CONSTANT HEAP

\ exposes heap and screen memory as lines 0..23
  HEAP TABLE32: ]HEAPLN  \ 32 bytes by 20 lines in the heap
VTOP @ TABLE32: ]SCRLN   \ expose screen memory as an array of lines

\ copy lines 0 ..19 of screen to Low RAM
\                   src     dst      #bytes   read VDP
: SCRCAPTURE ( -- ) VTOP @  HEAP   WINDOW_SIZE VREAD ;

VARIABLE SPEED
\ copy screen and write 20 heap lines minus first char, back to screen
: SCROLL-LEFT ( -- )
    SCRCAPTURE
    19 1 DO
      I ]HEAPLN C/L@  1 /STRING  I ]SCRLN  SWAP VWRITE
    LOOP
  ;
\ ******************************************************************

0 VALUE A
0 VALUE B
0 VALUE LastA
0 VALUE LastB

\ BASIC code
\ Generate one column of cave by adding or subtracting from last column
\  A=A+INT(RND*5)-2 :: IF A<2 THEN A=2 ELSE IF A>15 THEN A=15
\  B=B+INT(RND*5)-2 :: IF B<2 THEN B=2 ELSE IF B>15 THEN B=15

\ Factored this out of all of the above
:  RND2+/-  ( n -- n')  5 RND 2- +  2 15 CLIP ;

\  // Make sure enough room for ship to pass current column
\  WHILE A+B>18
\    IF A>B THEN A=A-1 ELSE B=B-1
\  WEND
 16 CONSTANT MAXGAP \ use a constant to save space

: MAKEGAP ( A B -- A' B')
  BEGIN
    2DUP + MAXGAP 1- >
  WHILE
     2DUP >
     IF   SWAP 1- SWAP
     ELSE 1-
     THEN
  REPEAT
;

\ Make sure enough room for ship to pass between current column and previous column
\ This is intentionally made to be a little tight sometimes
\ IF (lastA+B)>18 THEN B=B-(lastA+B)+18
\ IF (lastB+A)>18 THEN A=A-(lastB+A)+18
\ lastA=A::lastB=B

\ We could write the above expressions using values in Forth.
\ Example:
\ : ENOUGHROOM
\     lastA B +  18 > IF  B lastA B + -  18 + TO B  THEN
\     lastB A +  18 > IF  A lastB A + -  18 + TO A  THEN
\     A TO lastA  B TO lastB
\ ;

\ But... this is bad form in Forth :-)

\ If we use the data stack and factor out the common code,
\ we get one function.
\ The new function can test the A and B values with the same code. :-)

: TESTGAP ( n Lastn -- n')
   OVER + ( a n )
   DUP MAXGAP > ( a n ? )
   IF   -  MAXGAP +   EXIT THEN  \ fix it and get out
   DROP                          \ otherwise just drop it
;

: GAPCALCS
    A RND2+/-  B RND2+/- MAKEGAP ( -- a b)
    LastA TESTGAP  DUP TO B  TO LastB
    LastB TESTGAP  DUP TO A  TO LastA
;

: .COLUMN
\    X   y      char  len
    31   1      Brick  A       VCHAR   \ draw top
    31   A      BL     20 B -  VCHAR   \ draw GAP
    31  20 B - 1-  Brick  B    VCHAR  \ draw bottom
;

: NEXTCOLUMN  SCROLL-LEFT  GAPCALCS   .COLUMN ;

: SPEED--
    SPEED @ 0= IF EXIT THEN

    SPEED DUP @ 500 - 0 MAX DUP 0=
    IF  ORANGE BRICKS  THEN
    SWAP !
;

: SCROLL-COUNTER ( n -- )
    1+ DUP 32 >   \ have we scrolled 32 times?
    IF ( yes)
      DROP 0      \ reset the loop counter
      SPEED--     \ decr the speed variable (goes faster)
    THEN ( continue...)
;

: GET-READY
    \ first moves get no points
    31 0 DO
      NEXTCOLUMN
      SPEED @ TICKS  \ the ticks counter for fast durations
      MOVE-SHIP
      .SCORE
    LOOP
    GREEN BRICKS
;

: ENGINES    -2 NOISE -24 DB ;  \ background engine noise

: GAMELOOP
    ENGINES
    GET-READY
    0   \ scroll counter on data stack
    BEGIN
      SAFE?
    WHILE
      SCROLL-COUNTER
      10 +TO score  \ 10 points for every good loop
      .SCORE
      SPEED @ TICKS
      NEXTCOLUMN
      MOVE-SHIP
    REPEAT
    DROP
;

\ switch to text mode and restart interpreter
: END
  STOPMOTION
  CLEAR ." Camel99 Forth" 500 MS CR ." Bye!"  1000 MS  BYE ;

: RUN
    AUTOMOTION
    BEGIN
      GameInit
      .SCORE
      7 TO A   9 TO B
      4000 SPEED !
      GAMELOOP
      CRASH
      EndGame?
    UNTIL
    END ;

\ =============================================================
\ Save program as binary program for Editor/Assembler Loader
\ Menu selection 5.

: START   WARM DECIMAL  RUN ; \ 1ST Forth word that will RUN

  HEX 2000 H !         \ set heap to default value so it won't be saved
DECIMAL
  DP @      ORGDP !    \ save the booting dictionary pointer
  LATEST @  ORGLAST !  \ save the booting last word in the dictionary

INCLUDE DSK1.SAVESYS
' START SAVESYS DSK3.GRIDRUNNER
