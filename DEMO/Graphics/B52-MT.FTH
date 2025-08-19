\ translation of SteveB52 from Extended BASIC to Forth
\ Original concept on Atariage.com
\ Uses Multi-tasking for background sound


INCLUDE DSK1.TOOLS
INCLUDE DSK1.MARKER    \ need LOCK from this file
INCLUDE DSK1.CASE
INCLUDE DSK1.RANDOM
INCLUDE DSK1.GRAFIX
INCLUDE DSK1.DIRSPRIT
INCLUDE DSK1.AUTOMOTION
INCLUDE DSK1.RANDOM
INCLUDE DSK1.SOUND
INCLUDE DSK1.VALUES
INCLUDE DSK1.MALLOC
INCLUDE DSK1.MTASK99

\ some high level multi-tasker commands using primitives
: NEWTASK ( -- addr) USIZE MALLOC DUP FORK ; \ create task area in LOW RAM
: STOP    ( -- )     MYSELF SLEEP  PAUSE ;   \ go to sleep and pass control


\ names for the background tasks
\ we will create the task when the program starts
0 VALUE BOMBER
0 VALUE FIRE

\ ENDIF is easier to understand for Non-Forth speakers
: ENDIF   POSTPONE THEN ; IMMEDIATE

\ scoreboard manager
VARIABLE HITS
VARIABLE MISSES

: .HITS      6 0 AT-XY  HITS @ U. ;  \ U. prints numbers unsigned
: .MISSES   28 0 AT-XY  MISSES @ U. ;
: .SCORE    .HITS  .MISSES ;

\ numbered sprites like XB
0 CONSTANT #1
1 CONSTANT #2

\ name the characters for clarity
DECIMAL
124 CONSTANT bomber
128 CONSTANT bomb
132 CONSTANT building
133 CONSTANT ground
134 CONSTANT crater

136 CONSTANT fire

HEX
CREATE flame0   01C2 , 2246 , 2434 , 7EDE ,
CREATE flame1   40A0 , 3018 , 083E , 2FFA ,
CREATE flame2   020F , 0C0C , 1038 , 79FF ,
CREATE flame3   0000 , 2010 , 1438 , 6ECF ,

DECIMAL
\ animation sequence
CREATE FLAMES  flame0 ,  flame1 , flame2 , flame3 ,

\ choose a random flame pattern
: ]FLAME     ( n -- addr) CELLS FLAMES + ;
: [RND]FLAME ( -- addr) 4 RND ]FLAME ;

: BURNTASK
       0 ( 1st flame #)
       BEGIN
         [RND]FLAME @ fire CHARDEF
         fire SET#
         DUP  9 1 COLOR 2000 RND 400 + TICKS
         DUP  7 1 COLOR 2000 RND 300 + TICKS
             11 1 COLOR 2000 RND 600 + TICKS
       AGAIN ;

DECIMAL
: InitGraphics
  S" 2810383838100000000000000000000000000000000000000000000000000000"
  bomb CALLCHAR ( 80 char line limit in DV80 files)
  S" 00000080C0E070FFFF070F1C3800000000000000000000FEFFC0000000000000"
  bomber CALLCHAR

  S" FE929292FE929292" building CALLCHAR
  S" FFFFFFFF00000000" ground CALLCHAR
  S" 8183E7FF00000000" crater CALLCHAR
  S" 01C2224624347EDE"  fire CALLCHAR

  2 MAGNIFY  AUTOMOTION   2 MOVING
;

: ScrInit ( fg bg -- )
  DUP SCREEN         \ use bg color for screen
  DELALL
  1 17 2SWAP COLORS  \ does the range of color sets 1..19
  fire SET# 9 1 COLOR
  CLEAR
;


: FlyPlane   ( -- ) bomber 13 1 12 #1 SPRITE  16 0  #1 MOTION  ;
: DrawGround ( -- ) 0 20 ground 32 HCHAR ;
: SkyScraper ( col row ) building  OVER 20 SWAP - 0 MAX VCHAR ;

: RNDY       ( -- n) 7 RND 14 + ;
: DrawCity   ( -- ) DrawGround  22 8 DO  I RNDY SkyScraper   LOOP ;

: STARTUP
   16  2 ScrInit
   HITS OFF   MISSES OFF
   10 23 AT-XY ." Foxy's B52"
   0 0 AT-XY ." Hits:" .HITS    20 0 AT-XY ." Misses:"
   InitGraphics
   DrawCity
   FlyPlane
;

: VC+!  ( n Vaddr -- ) TUCK VC@  +  SWAP VC! ; \ add 'n' to VDP byte

: DescendPlane
      #1 SP.X VC@  250 >
      IF
         1 #1 SP.X VC!  \ reset sprite to left side
         4 #1 SP.Y VC+! \ plane falls down 2 pixels
      ENDIF ;

: 8/  ( n -- n' ) 3 RSHIFT ;  \ divide by 8
: PIX>CHAR  ( col row -- col' row')  8/ SWAP  8/ 1+ SWAP ;

\ test if sprite is over a character that is not a blank (space)
: COLLISION?  ( spr# -- ?) POSITION PIX>CHAR GCHAR  BL <>  ;

: DELSPRITE ( spr# -- ) DUP>R  SP.Y 4 BL VFILL  0 0 R> MOTION ;

\ volume fader
: FADER   ( speed -- ) \ fades down to -28 DB. Does not MUTE
  29 0
   DO
     I DB  DUP TICKS \ MS passes to next task while it waits
     PAUSE
  LOOP
  DROP
;

\ ***************************************************************
\                       background sounds
\
: Whistler   \ factored our as a word for testing.
     GEN4 MUTE   ( make any previous bomb quiet)
     GEN1 4600 DUP HZ ( -- freq)
     -8 DB                     \ volume
     400 0                     \ finite # iterations with 10 HZ reduction
     DO
        ( freq)  20 - DUP HZ    \ reduce freq in each loop.
        #2 COLLISION? IF LEAVE THEN
     LOOP
     MUTE
    ( freq) DROP
;

: Exploder    -2 NOISE 400 FADER 500 TICKS MUTE  ;
\ ***************************************************************

: WAIT-COLLISION ( char -- )  BEGIN  PAUSE #2 COLLISION?   UNTIL  ;

: DIRECT-HIT    fire VPUT  HITS 1+!  ;
: RE-HIT        BL VPUT  VROW 1+!   fire VPUT   HITS 1+! ;
: GROUND-HIT       crater VPUT  MISSES 1+! ;

: END    2 8 ScrInit ." ** DONE ** "  ;  \ imitate BASIC'S END  :)

: DRAW-DAMAGE
     #2 POSITION PIX>CHAR 2DUP AT-XY \ set cursor for (EMIT)
     GCHAR
     CASE
       building  OF  DIRECT-HIT   ENDOF
       fire      OF  RE-HIT       ENDOF
       ground    OF  GROUND-HIT   ENDOF
    ENDCASE
;

\ This background task must end with STOP. It puts itself to sleep
\ and passes control back to the console task.
: DropBomb
\  char  colr     x        y   spr#
   bomb  11   #1 POSITION 12 +  #2 SPRITE  \ make sprite at bomber position
   #1 ]SMT.X VC@ 24  #2 MOTION   \ fall with automotion, uses plane horz speed
    Whistler                \ start the falling bomb sound
    0 0 #2 MOTION           \ stop bomb sprite when whistler collides
   #2 DELSPRITE
   Exploder                 \ run the explosion
   STOP
;

HEX
\ multi-tasking friendly KEY with no cursor
: GKEY ( -- c | 0)  BEGIN PAUSE DescendPlane  KEY? ?DUP UNTIL ;

DECIMAL
: GameLoop
  DrawCity
  FlyPlane
  BEGIN
     GKEY BL =
     IF
       BOMBER RESTART
       WAIT-COLLISION
       DRAW-DAMAGE
     ENDIF
     PAUSE .SCORE
     #1 COLLISION? ?TERMINAL OR
  UNTIL
  0 0 #1 MOTION   #2 DELSPRITE
;

: RUN
   NEWTASK TO BOMBER
   NEWTASK TO FIRE
   ['] DropBomb BOMBER ASSIGN
   ['] BURNTASK FIRE ASSIGN   FIRE WAKE
   GRAPHICS     \ switch VDP mode
   MULTI        \ enable multi-tasking
   BEGIN
      STARTUP
      GameLoop
      8 10 AT-XY ." Game Over"
      12 8 AT-XY ." Play again? (Y/N)"
      KEY [CHAR] N =
   UNTIL
   SINGLE      \ turn off multi-tasking
   END
;

\ /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

\ This is only needed if you want to make a binary program
: B52   WARM         \ Boot Forth machine (40 column mode )
        RUN          \ word to start the program
        BYE          \ exits Forth system to title screen
;
