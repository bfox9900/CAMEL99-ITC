\ sound envelope control demo

\ INCLUDE DSK1.TOOLS
INCLUDE DSK1.AUTOMOTION ( brings in grafix and sprites)
INCLUDE DSK1.RANDOM
INCLUDE DSK1.CHARSET
HEX
INCLUDE DSK1.SOUND

HEX
: ?BREAK   ?TERMINAL
           IF STOPMOTION SILENT
              8 SCREEN
              DELALL CHARSET
              4 19  2 1 COLORS
              CR ." *BREAK*" HONK ABORT
           THEN ;

\ Manipulate bytes with SPLIT (integer->2 bytes) and FUSE (2 bytes->integer)
: STRETCH1 ( 00AA -- AAAA)  SPLIT DROP DUP FUSE ;   \ removes top  pixels
: STRETCH  ( AABB -- AAAA BBBB)  SPLIT DUP FUSE SWAP DUP FUSE ;

\ Chop a pattern into 2 patterns. Top half & lower half
: SPLITPAT  ( n n n n  -- n n n n  n n n n )
             >R >R >R       \ push 3 args to rstack
             STRETCH1       \ 1st arg is special
             R> STRETCH     \ pop rstack & stretch
             R> STRETCH
             R> STRETCH
             0000  ;        \ CHARDEF need 4 args.

\ read and write character patterns to/from Forth data stack
: PATTERN@ ( ascii -- n n n n)   ]PDT 8 BOUNDS         DO  I V@   2 +LOOP ;
: PATTERN!  ( n n n n ascii -- ) ]PDT 8 BOUNDS SWAP 2- DO  I V!  -2 +LOOP ;

HEX
: UPPER?   ( char -- ?)  [CHAR] A [CHAR] Z 1+ WITHIN ;
: LOWER    ( c -- c )    DUP UPPER? IF  020 OR  THEN ;

\ create new patterns and re-write pattern description table
: CHANGE-PATTERNS ( -- )
     [CHAR] z [CHAR] A
      DO
        I PATTERN@ SPLITPAT  ( -- n n n n  n n n n )
        I LOWER PATTERN!     \ write lower case letter
        I PATTERN!           \ write upper case letter
     LOOP
;

\ got fancy here and made a word to print strings BIG
: TYPE.LOW ( adr len -- )  BOUNDS DO   I C@ LOWER EMIT  LOOP ;
: TYPE.BIG ( addr len -- ) 2DUP TYPE CR  TYPE.LOW  ;

DECIMAL
: uS      ( delay -- ) 0 ?DO LOOP ;   \ ~100uS loop speed
: ATTACK  ( delay endDB   --) 30 ?DO  I DB DUP uS  -2 +LOOP DROP ;
: DECAY   ( delay startDB --) 32 SWAP ?DO  I DB DUP uS   2 +LOOP DROP ;


: SQUIRT    4 NOISE   300 RND 300 +  14 ATTACK MUTE
            GEN1 112 4 RND + HZ
            2 DB 180 uS        \ on time
            60 2 DECAY ;

: SQUIRTS ( N -- )
       0 ?DO
            SQUIRT
            [CHAR] ! I +  13 10 RND -  128 0  I SPRITE
            8 6 RND 3 -  I MOTION
            100 RND 50 +  MS
            ?BREAK
       LOOP ;

: TINKON      GEN1 3700 500 RND + HZ ;
: TINKOFF     30 4 DECAY ;

: TINKS   ( N -- )
       0 ?DO
            TINKON
            [CHAR] .  16  128 0  I SPRITE
            18 16 RND 8 -  I MOTION
            TINKOFF
            ?BREAK
       LOOP ;

: PINGON      GEN2 1100 HZ 0 DB ;
: PINGOFF     700 uS  1200 2 DECAY ;

: PINGS ( N -- )
       0 ?DO
            PINGON
            [CHAR] @  16  128 0  I SPRITE
            9 20 RND 10 -  I MOTION
            PINGOFF
            ?BREAK
       LOOP ;

DECIMAL
20 CONSTANT SPRITE#

: QUASI ( -- )
  AUTOMOTION
  SPRITE# MOVING   \ make all sprites auto movers
  0 MAGNIFY
  BEGIN
      SPRITE# RND  SQUIRTS
      DELALL
      SPRITE# RND  TINKS
      5 RND PINGS
  AGAIN ;

: RUN
     CLEAR
     4 19 16 1 COLORS
     2 SCREEN
     CHANGE-PATTERNS
     CR S" CAMEL 9 FORTH" TYPE.BIG
     CR CR
     CR S" SOUND ENVELOPES " TYPE.BIG CR
     CR S" WITHOUT SOUND LISTS!" TYPE.BIG CR
     QUASI
;
CR .( Type RUN to start)
