\ BIG characters and Quasi-particles in TI BASIC by sometimes99er
\ Converted to Camel99 Forth with Automotion  July 24 2019

\ A very clever character pattern method to create large characters
\ Pattern bytes are stretch vertically and two patterns are created
\ One for the upper case letter and one for the lower case letter.
\ When the re-structured upper/lower case letters are printed on
\ alternate lines, a large character appears.

\ The original version in TI-XBASIC made extensive use of string functions
\ to manipulate the character patterns.

\ 100 CALL CLEAR::CALL SCREEN(5)::FOR A=5 TO 12::CALL COLOR(A,16,1)::NEXT A
\ 110 N$="00030C0F30333C3FC0C300000000000000CCCFF0F3FCFF"::FOR A=65 TO 90
\ 120 CALL CHARPAT(A,C$)::PRINT CHR$(A)&CHR$(A+32);::FOR C=0 TO 1:: D$=""
\ 130 FOR R=0 TO 7::D$=D$&SEG$(N$,(ASC(SEG$(C$,C+R*2+1,1))-48)*2+1,2)::NEXT R
\ 140 CALL CHAR(A+C*32,D$)::NEXT C::NEXT A::PRINT::PRINT::N$="QUASIPARTICLES"
\ 150 FOR A=1 TO LEN(N$)::PRINT SEG$(N$,A,1)&CHR$(ASC(SEG$(N$,A,1))+32);::NEXT A
\ 160 FOR A=1 TO 28::CALL SPRITE(#A,46,16,1,124,8,RND*10-5)::NEXT A::GOTO 160

\
\ This alternative method reads data from VDP ram as HEX integers and cuts and
\ recombines the integers to create the new patterns.

\ Compile the libraries that we need.
INCLUDE DSK1.AUTOMOTION ( brings in grafix and sprites)
INCLUDE DSK1.RANDOM
INCLUDE DSK1.CHARSET

HEX
: ?BREAK   ?TERMINAL
           IF STOPMOTION 8 SCREEN
              DELALL CHARSET
              4 19  2 1 COLORS
              CR ." *BREAK*" HONK ABORT
           THEN ;


\ Manipulate bytes with SPLIT (integer->2 bytes) and FUSE (2 bytes->integer)
: STRETCH1 ( 00AA -- AAAA)  SPLIT DROP DUP FUSE ;   \ removes top pixels
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
: QUASI ( -- )
  AUTOMOTION
  MAX.SP MOVING   \ make all sprites auto movers
  BEGIN
     MAX.SP 0
     DO
       [CHAR] .  16 128 0  I SPRITE
       18 RND 8 -  15  I MOTION
                14 RND 3 +  I SP.COLOR

       50 MS
        ?BREAK
     LOOP
  AGAIN ;

: RUN
     CLEAR
     4 19 16 1 COLORS
     2 SCREEN
     CR S" GENERATING PATTERNS" TYPE.BIG
     CR CR
     CHANGE-PATTERNS
     CR S" ABCDEFGHIJKLMNOPQRSTUVWXYZ" TYPE.BIG CR
     CR S" FORTH. NO STRINGS ATTACHED" TYPE.BIG CR
     QUASI
;



RUN
