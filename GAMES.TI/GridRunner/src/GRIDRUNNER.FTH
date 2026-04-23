\ GRIDFUNNER   Apr 2026
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

\ define variables before use
DECIMAL
30 VALUE SPEEDSET
30 VALUE SPEED
32 VALUE SCROLLS
 0 VALUE score
 0 VALUE hiscore

\ name some characters
  0 CONSTANT #SHIP          \ ship Sprite. (sprite no.s start at zero)
  1 CONSTANT Brick
  2 CONSTANT BRICK2
128 CONSTANT Shipchar
132 CONSTANT Debris

\ Camel99 CALLCHAR must have all 8 bytes for each character shape
: SHIP$
 S" 0000C0F3FF3F3FFF3F3FFFF3C00000000000000000C0FCFFFCC0000000000000" ;

: DEBRIS$
 S" 220884218A00248108104580144012001082005002A80011440008A200049200" ;

: BRICK$  S" FF818181818181FF" ;
: DAMAGE$ S" 01152B11212B1501" ;

: BRICKS ( color -- ) Brick SET# SWAP BLACK COLOR ;

: GameInit
  32 TO SCROLLS
   0 TO score
  GRAPHICS ( does clear as well)
  BLACK SCREEN
  4 19  WHITE BLACK COLORS  \ printable characters
  CYAN BRICKS
  SHIP$   Shipchar CALLCHAR
  DEBRIS$ Debris   CALLCHAR
  BRICK$  Brick CALLCHAR
  DAMAGE$ BRICK2 CALLCHAR

\ Draw top and bottom borders
\ col row  char  cnt
  0    0  Brick  32 HCHAR
  0   19  Brick  32 HCHAR

  2 MAGNIFY  RANDOMIZE
\ char      clr   x   y  spr#
  Shipchar WHITE 10 100  #SHIP SPRITE
;

\ utilities
: VBLANK  ( Vaddr n -- ) BL VFILL ; \ fill VDP memory with space char
: CLIP    ( n lo hi -- n') ROT MIN MAX ; \ CLIP n to lo  hi range

: EndGame?   ( -- ?)
  0 23 AT-XY ." Press ENTER to play again"
  KEY 13 <> ; \ wait for key, return true or false

: RedFlash ( --  )
  RED SCREEN   RUST BRICKS
  250 MS
  BLACK SCREEN  CYAN BRICKS  ; \ Flash screen red

\ adjust the volume of the active sound generator
: DECAY   ( n -- ) 16 0 DO  I DB DUP MS  LOOP DROP ;

\ access sprite attribute table as an array of 4 byte records
: ]SAT  ( n -- Vaddr) 4* SAT + ;

: DELSPRITE  ( n -- ) ]SAT  4 VBLANK ;
: DELSPRITES ( n 1st -- ) ]SAT SWAP 4* VBLANK ;

\ divide by 8 using 3 shifts to the right (TEXT MACRO)
: 8/   ( n -- n') S" 3 RSHIFT" EVALUATE ; IMMEDIATE

\ Convert pixels to character coordinates
: >XY  ( pix piy -- x y)  8/ 1+ SWAP 8/ 1+ SWAP ;

\ Random motion vector -5 .. 5
: RNDV ( -- dx dy) 11 RND 5 - ;

: Explode ( -- )
    0 0 #SHIP MOTION

    16 MOVING  \ sets the number of sprites for Automotion interrupt
    -2 NOISE  0 DB  200 MS
    BRICK2 #SHIP POSITION >XY >VPOS VC!
    RedFlash

    \ 12 sprites flying in random directions
    14 2 DO
        Debris ORANGE  #SHIP POSITION I SPRITE \ Use POSITION like a function
        RNDV RNDV I MOTION
        I DB 70 MS  \ set volume and hold
    LOOP
    200 MS
    SILENT
    12 2 DELSPRITES   \ delete 12 sprites starting at #2
    1 MOVING
;

: CRASH \  Oh no, we crashed!
 \ Stop any ship motion and get its position, start explosion sound
  Explode      \ debris flying off of ship
  DELALL       \ Clean up all the sprites
;


\ simple faster, case system. EXITs as soon as match is found
: :CASE  ( n --) POSTPONE OVER=  POSTPONE IF  POSTPONE DROP ; IMMEDIATE
: BREAK; ( -- )  POSTPONE EXIT   POSTPONE THEN ; IMMEDIATE

\             *** moving a sprite with AUTOMOTION ***
HEX 83C8 CONSTANT RPTKEY \ magic address in TI-99 system

: RETRO   GEN4 -10 DB ; \ retro rocket noise

 DECIMAL
: MOVE-SHIP ( -- )
    RPTKEY ON
    KEY?              \ Scan for a key.move
    [CHAR] E :CASE  RETRO  1 -11 #SHIP MOTION   BREAK;  \ move ship up
    [CHAR] X :CASE  RETRO  0  11 #SHIP MOTION   BREAK;  \ move ship down
    DROP                                        \ drop the key char
    0 0 #SHIP MOTION                            \ stop motion
    GEN4 -20 DB
;

\ return true if ship position is not over a space char (BL)
: COLLISION?  ( -- ?) #SHIP POSITION >XY  GCHAR  BL <> ;

\  Display score and high score
: (#####)    ( n -- addr len ) ABS 0 <#  # # # # #  #> ;

\ fast typing
: VTYPE  ( addr len ) DUP>R VPOS SWAP VWRITE R> VCOL +!  ;

: .#####  (#####) VTYPE ; \ FASTER score printing

: .SCORE ( -- )
  score hiscore > IF  score TO hiscore THEN
  0 22 AT-XY  ." Score " score .#####  3 SPACES ." High " hiscore .##### ;

\ ****************************************************************
\                   horizontal scroll function
\  Camel99 didn't have horizontal scrolling so we had to make one
\ ****************************************************************
HEX 2000 H !  \ reset heap pointer to start of low ram
\ expose memory as a table of 32 byte records
HEX
: TABLE32: ( addr -- )
     CREATE    ,
     ;CODE ( n -- Vaddr')     \ RUN time
          0A54 ,  \ TOS 5 SLA,  ( TOS 32* )
          A118 ,  \ *W TOS ADD,
          NEXT,
    ENDCODE

DECIMAL
19 C/L@ *          CONSTANT WINDOW_SIZE
WINDOW_SIZE MALLOC CONSTANT HEAP

\ exposes heap as strings and screen memory lines 0..23
  HEAP TABLE32: ]HEAPLN  \ 32 bytes by 20 lines in the heap
VTOP @ TABLE32: ]SCRLN   \ expose screen memory as an array of lines

\ copy lines 0 ..19 of screen to Low RAM
\                   src     dst  size (20 lines)
: SCRCAPTURE ( -- ) VTOP @  HEAP   WINDOW_SIZE   VREAD ;

\ copy screen and write 20 heap lines minus first char, back to screen
: SCROLL-LEFT ( -- )
    SCRCAPTURE
    19 1 DO
      I ]HEAPLN C/L@  1 /STRING  I ]SCRLN  SWAP VWRITE
    LOOP
  ;

\ ******************************************************************

\  // Generate one column of cave by adding or subtracting from last column
0 VALUE A
0 VALUE B
0 VALUE LastA
0 VALUE LastB

\  A=A+INT(RND*5)-2 :: IF A<2 THEN A=2 ELSE IF A>15 THEN A=15
\  B=B+INT(RND*5)-2 :: IF B<2 THEN B=2 ELSE IF B>15 THEN B=15

\ Factored this out of all of the above
:  RND2+/-  ( n -- n')  5 RND 2- +  2 15 CLIP ;

\  // Make sure enough room for ship to pass current column
\  WHILE A+B>18
\    IF A>B THEN A=A-1 ELSE B=B-1
\  WEND
: MAKEGAP ( A B -- A' B')
  BEGIN
    2DUP + 16 >
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
: ENOUGHROOM
   LastA B + DUP 17 >  IF  B SWAP - 17 +   TO B ELSE DROP THEN
   LastB A + DUP 17 >  IF  A SWAP - 17 +   TO A ELSE DROP THEN
   A TO LastA   B TO LastB
;

\ Using the same method as BASIC program
: .COLUMN
\    X   y        char   len
    31   1        BL     18   VCHAR      \ erase right side column
    31   1        Brick  A    VCHAR      \ draw top
    31  20 B - 1+ Brick  B 1- VCHAR ; \ draw bottom

: NEXTCOLUMN
    SCROLL-LEFT
    A RND2+/-  B RND2+/- MAKEGAP TO B  TO A
    ENOUGHROOM
    .COLUMN
;

VARIABLE SPEED

: SPEED--  SPEED @ 0= IF EXIT THEN
           SPEED DUP @ 10 - 0 MAX SWAP !  ;

: ANTICIPATION
     \ first moves get no points
      31 0 DO
        NEXTCOLUMN
        SPEED @ MS
        MOVE-SHIP
        .SCORE
      LOOP
      GREEN BRICKS
;

: ENGINES   -2 NOISE -24 DB ;

: GAMELOOP
      ENGINES
      ANTICIPATION
      0   \ loop counter on data stack
      BEGIN
        1+ DUP 32 >   \ have we scrolled 32 times?
        IF ( yes)
           DROP 0     \ reset the loop counter
           SPEED--    \ decr the speed variable (goes faster)
        THEN ( continue...)
        10 +TO score   \ 10 points for every good loop
        NEXTCOLUMN
        SPEED @ MS
        MOVE-SHIP
        .SCORE
        COLLISION? \ ?TERMINAL OR
      UNTIL
      DROP
;

\ switch to text mode and restart interpreter
: END  STOPMOTION TEXT ." Camel99 Forth" 500 MS CR ." Bye!"  1000 MS  BYE ;

: RUN
    AUTOMOTION
    BEGIN
      GameInit
      .SCORE
      10 TO A  7 TO B
      100 SPEED !
      GAMELOOP
      CRASH
      EndGame?
    UNTIL
    END ;

: START  WARM DECIMAL  RUN ;

  HEX 2000 H !         \ set heap to default value so it won't be saved
DECIMAL
  DP @      ORGDP !    \ save the booting dictionary pointer
  LATEST @  ORGLAST !  \ save the booting last word in the dictionary

INCLUDE DSK1.SAVESYS
' START SAVESYS DSK3.GRIDRUNNER
