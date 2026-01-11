\ Trolls by Julian Fondren from comp.lang.forth
\ Ported to CAMEL99 Forth for the TI-99 Brian Fox

\ dependencies:
NEEDS RND       FROM DSK1.RANDOM
NEEDS -TRAILING FROM DSK1.TRAILING
NEEDS CASE      FROM DSK1.CASE
NEEDS BUFFER:   FROM DSK1.BUFFER
NEEDS MOVE      FROM DSK1.MOVE

 1 CELLS CONSTANT CELL

: CHOOSE   ( n1 -- n2 ) RND ;

DECIMAL
64 CONSTANT -MAZE
64 CONSTANT |MAZE
-MAZE |MAZE * CONSTANT /MAZE

: | ( "LINE" -- )
  0 PARSE TUCK HERE SWAP DUP ALLOT MOVE
  -MAZE SWAP - HERE SWAP DUP ALLOT BL FILL ;

CREATE MAZE
  | #####################################
  | # #       #       #     #         # #
  | # # ##### # ### ##### ### ### ### # #
  | #       #   # #     #     # # #   # #
  | ##### # ##### ##### ### # # # ##### #
  | #   # #       #     # # # # #     # #
  | # # ####### # # ##### ### # ##### # #
  | # #       # # #   #     #     #   # #
  | # ####### ### ### # ### ##### # ### #
  | #     #   # #   # #   #     # #     #
  | # ### ### # ### # ##### # # # #######
  | #   #   # # #   #   #   # # #   #   #
  | ####### # # # ##### # ### # ### ### #
  | #     # #     #   # #   # #   #     #
  | # ### # ##### ### # ### ### ####### #
  | # #   #     #     #   # # #       # #
  | # # ##### # ### ##### # # ####### # #
  | # #     # # # # #     #       # #   #
  | # ##### # # # ### ##### ##### # #####
  | # #   # # #     #     # #   #       #
  | # # ### ### ### ##### ### # ##### # #
  | # #         #     #       #       # #
  | #X###################################

HERE /MAZE OVER MAZE - - DUP ALLOT BL FILL

VARIABLE PLAYER
MAZE -MAZE + 1 + PLAYER !

: TROLL, ( -- )
  BEGIN
    MAZE /MAZE -TRAILING DUP -MAZE / CHOOSE -MAZE * MAZE +
    -MAZE -TRAILING CHOOSE +

    DUP C@ BL =
    OVER PLAYER @ <> AND
  UNTIL DUP , [CHAR] T SWAP C! ;

CREATE TROLLS  TROLL, TROLL, TROLL,

: WHAT-TROLL ( A -- A' )
  TROLLS 3 CELLS BOUNDS DO
    DUP I @ = IF DROP I LEAVE THEN
  CELL +LOOP ;

: OFF ( A-TROLL -- )
  BL OVER @ C! 0 SWAP ! ;

: STAGGER ( N-DIR A-TROLL -- )
  2DUP @ +
    DUP PLAYER @ = IF CR ." A TROLL HAS FOUND YOU!" ABORT THEN
        C@ BL = IF
      BL OVER @ C!
      TUCK +!
      @ [CHAR] T SWAP C!
  ELSE 2DROP THEN ;

: MEANDER ( -- )
  TROLLS 3 CELLS BOUNDS DO I @ IF
    4 CHOOSE CASE
      0 OF 1 ENDOF
      1 OF -1 ENDOF
      2 OF -MAZE ENDOF
      3 OF -MAZE NEGATE ENDOF
    ENDCASE I STAGGER
  ELSE DROP THEN CELL +LOOP ;

/MAZE BUFFER: OUTPUT

: TYPE.FAST   VPOS SWAP VWRITE ; \ added direct to VDP type

: .MAZE ( -- )
  MAZE OUTPUT /MAZE MOVE
  [CHAR] @ PLAYER @ MAZE - OUTPUT + C!
  OUTPUT /MAZE -TRAILING BOUNDS
  DO
    I -MAZE -TRAILING CR TYPE.FAST
  -MAZE +LOOP ;


: PEEK ( N-DIR -- C )  PLAYER @ + C@ ;
: PEER ( N-DIR -- C )
  2* PLAYER @ + DUP MAZE < IF DROP [CHAR] # ELSE C@ THEN ;

: SHOVE ( N-DIR -- )
  DUP PLAYER @ + BL SWAP C!
  DUP PLAYER +!
      PLAYER @ + [CHAR] # SWAP C! ;

: CHARS( ( "CC" -- CC )
  [CHAR] ) PARSE DROP COUNT 8 LSHIFT SWAP C@ OR
  POSTPONE LITERAL ; IMMEDIATE

: STEP ( N-DIR -- )
  DUP PEEK 8 LSHIFT OVER PEER OR CASE
    CHARS(   ) OF PLAYER +! ENDOF
    CHARS(  #) OF PLAYER +! ENDOF
    CHARS( # ) OF SHOVE     ENDOF
    CHARS(  X) OF PLAYER +! ENDOF
    CHARS( X ) OF CR ." YOU'VE ESCAPED!" CR ABORT  ENDOF
    CHARS(  T) OF
      CR ." YOU FOOL! THE TROLL DEVOURS YOU."
      KEY ABORT ENDOF
    CHARS( T ) OF
      CR S" THE TROLL: 'OH! EXCUSE ME.'" TYPE KEY DROP
      DUP PLAYER +! NEGATE PLAYER @ BL OVER C! WHAT-TROLL +! ENDOF
    CHARS( #T) OF
      DUP 2* PLAYER @ + WHAT-TROLL OFF
      SHOVE PAGE .MAZE
      CR ." YOU CRUSH THE TROLL BEHIND THE WALL."
      KEY DROP ENDOF
  ENDCASE ;

: PLAY ( -- )
  PAGE
  BEGIN
     MEANDER
     0 0 AT-XY .MAZE
     KEY
     CASE
       [CHAR] H   OF -1 STEP           ENDOF
       [CHAR] J   OF -MAZE STEP        ENDOF
       [CHAR] K   OF -MAZE NEGATE STEP ENDOF
       [CHAR] L   OF 1 STEP            ENDOF
       15 ( TI-99 ESC )
                  OF CR ." Done" ABORT  ENDOF
     ENDCASE
  AGAIN ;
