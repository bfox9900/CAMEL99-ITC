\ Forth version of SteveB's LSCROLL demo translated from TiCodEd
\ 2026 Brad Snyder
\ Forth by Brian Fox for Camel99 Forth

\ add some stuff to the kernel
INCLUDE DSK1.TOOLS
INCLUDE DSK1.VALUES
INCLUDE DSK1.GRAFIX
INCLUDE DSK1.AUTOMOTION
INCLUDE DSK1.COLORS
INCLUDE DSK1.RANDOM
INCLUDE DSK1.SOUND
INCLUDE DSK1.UDOTR   \ flush left number printing

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
  1 CONSTANT #SHIP          \ ship Sprite
  1 CONSTANT Brick
128 CONSTANT Shipchar
132 CONSTANT Debris

\ Camel99 CALLCHAR must have all 8 bytes for each character shape
: SHIP$
 S" 0000C0F3FF3F3FFF3F3FFFF3C00000000000000000C0FCFFFCC0000000000000" ;

: DEBRIS$
 S" 220884218A00248108104580144012001082005002A80011440008A200049200" ;

: GameInit
  32 TO SCROLLS
   0 TO score
  GRAPHICS ( does clear as well)
  BLACK SCREEN
  4 19  WHITE BLACK COLORS  \ printable characters
  Brick SET#  CYAN BLACK COLOR
  SHIP$   Shipchar CALLCHAR
  DEBRIS$ Debris   CALLCHAR
  S" FF818181818181FF" Brick CALLCHAR

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

\ switch to text mode and restart interpreter
: END    STOPMOTION TEXT ." Camel99 Forth" CR ABORT ;

: kLoop   ( -- ?) KEY 13 <> ; \ wait for key, return true or false

: RedFlash ( --  ) RED SCREEN  160 MS  BLACK SCREEN ; \ Flash screen red

\ access sprite attribute table as an array of 4 byte records
: ]SAT  ( n -- Vaddr) 4* SAT + ;

: DELSPRITE  ( n -- ) ]SAT  4 VBLANK ;
: DELSPRITES ( n 1st -- ) ]SAT SWAP 4* VBLANK ;

\ Random motion vector -5 .. 5
: RNDV ( -- dx dy) 11 RND 5 - ;

: Explode ( -- )
    16 MOVING  \ sets the number of sprites for Automotion interrupt
    -2 NOISE  0 DB  200 MS
    RedFlash
    16 2 DO
        Debris ORANGE  #SHIP POSITION I SPRITE \ Use POSITION like a function
        RNDV RNDV I MOTION
        I DB 70 MS  \ set volume and hold
    LOOP
    500 MS
    SILENT
    16 2 DELSPRITES   \ delete 14 sprites starting at #2
    1 MOVING
;

: HIT \  Oh no, we crashed!
 \ Stop any ship motion and get its position, start explosion sound
  Explode      \ debris flying off of ship
  DELALL       \ Clean up all the sprites
  0 23 AT-XY ." Press ENTER to play again"
;

\ Camel99 exposes memory fields in VDP RAM each of sprite.
\ SP.Y      VDP address of the 'y' position field

\ Read and write to VDP RAM with special fetch and store operators
\   VC@  VDP char fetch  (VSBR in Assembler)
\   VC!  VDP char store  (VSBW in Assembler)

\ All that to explain this custom function
\ Adds 'n' sprite  Y position, auto clipped between pixel values
: SP.Y+!  ( n spr# -- )
  SP.Y DUP>R      \ get address of SPR#'s Y field and copy onto return stack
  VC@ +           \ fetch the byte from memory and add n to it
  7 144 CLIP      \ clip the sum to between 7 and 144 pixels
  R> VC! ;        \ get the saved VDP address and store the sum in it

\ Very different than BASIC code. Scan for a key, move as needed and get out
\ Not using AUTOMOTION
HEX 83C8 CONSTANT RPTKEY
DECIMAL
: MOVE-SHIP
     RPTKEY ON
     KEY?
     CASE
        [CHAR] E  OF  -1  #SHIP SP.Y+!  ENDOF
        [CHAR] X  OF   1  #SHIP SP.Y+!  ENDOF
     ENDCASE
;

\ divide by 8 using 3 shifts to the right (TEXT MACRO)
: 8/   ( n -- n') S" 3 RSHIFT" EVALUATE ; IMMEDIATE

\ Convert pixels to character coordinates
: >XY  ( pix piy -- x y)  8/ 1+ SWAP 8/ 1+ SWAP ;

\ return true if ship position is not over a space char (BL)
: COLLISION?  ( -- ?) #SHIP POSITION >XY  GCHAR  BL <> ;

\  Display score and high score
: .SCORE ( -- )
  score hiscore > IF  score TO hiscore THEN
  0 22 AT-XY ." Score " score 5 .R  2 SPACES ." High" hiscore 5 .R
;

\ ****************************************************************
\                   horizontal scroll function
\  Camel99 didn't have horizontal scrolling so we had to make one
\ ****************************************************************
: HEAP       ( -- addr) H @ ; \ H is Camel99 pointer to unused low RAM

\ Machine code "R4 5 SLA" is faster than mulitply
HEX
CODE 32*  ( n -- n') 0A54 ,  NEXT, ENDCODE

\ exposes heap as strings and screen memory lines 0..23
DECIMAL
: ]HEAPLN  ( n -- addr len) S" 32* HEAP +  C/L@ " EVALUATE ; IMMEDIATE
: ]SCRLN   ( n -- Vaddr)    S" 32*  VTOP @ +" EVALUATE ; IMMEDIATE

\ copy lines 0 ..19 of screen to Low RAM
19 C/L@ * CONSTANT WINDOW_SIZE
\                   src      dst    size (20 lines)
: SCRCAPTURE ( -- ) VTOP @   HEAP   WINDOW_SIZE VREAD ;

\ copy screen and write 20 heap lines minus first char, back to screen
: SCROLL-LEFT ( -- )
    SCRCAPTURE
    19 1 DO
      I ]HEAPLN 1 /STRING  I ]SCRLN  SWAP VWRITE

      MOVE-SHIP ( poll user input while scrolling )

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
:  ALTERED  ( n -- n')  5 RND 2- +  2 15 CLIP ;

\  // Make sure enough room for ship to pass current column
\  WHILE A+B>18
\    IF A>B THEN A=A-1 ELSE B=B-1
\  WEND
: MAKEGAP
  BEGIN
    A B + 16 >
  WHILE
     A B >
     IF   -1 +TO A
     ELSE -1 +TO B
     THEN
  REPEAT
;

\  // Make sure enough room for ship to pass between current column and previous column
\  // This is intentionally made to be a little tight sometimes
\  IF (lastA+B)>18 THEN B=B-(lastA+B)+18
\  IF (lastB+A)>18 THEN A=A-(lastB+A)+18
\  lastA=A::lastB=B
: ENOUGHROOM
   LastA B + DUP 18 >  IF  B SWAP - 18 +   TO B ELSE DROP THEN
   LastB A + DUP 18 >  IF  A SWAP - 18 +   TO A ELSE DROP THEN
   A TO LastA   B TO LastB
;

\ Using the same method as BASIC program
: .COLUMN
    31  1     BL    18 VCHAR      \ erase right side column
    31  1     Brick  A VCHAR      \ draw top
    31 20 B - Brick  B 1- VCHAR ; \ draw bottom

: NEXTCOLUMN
    A ALTERED TO A
    B ALTERED TO B
    MAKEGAP
    ENOUGHROOM
;

\  GameInit  0 1 AT-XY

15 VALUE SPEED

\ we can move the ship during the delay :-)
:  DELAY  ( -- ) 0 ?DO  MOVE-SHIP 500 TICKS LOOP ;

: RUN
    AUTOMOTION
    BEGIN
      GameInit
      .SCORE
      10 TO A  7  TO B
      BEGIN
        SCROLL-LEFT
        10 +TO score   \ 10 points for every good loop
        .SCORE
        NEXTCOLUMN
        MOVE-SHIP
        .COLUMN
         SPEED MS
        COLLISION?   ?TERMINAL OR
      UNTIL
      HIT
      kLoop
    UNTIL
    END ;
