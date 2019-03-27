CR .( TOOLS for Camel99 Forth V2)
.( ..)
: ?      ( adr -- ) @ . ;
: DEPTH  ( -- n )   SP0 SP@ 2+ - 2/ ;

: .S        ( -- )
      ." |"
      DEPTH
      IF
         0 DEPTH 2-
         ?DO   I PICK  U.    -1 +LOOP
      THEN ;

.( ..)
\ ABORT if function 4 is pressed
: ?BREAK  ( -- ) ?TERMINAL ABORT" *BREAK*" ;
: ?CR     ( -- ) OUT @ 0A + C/L@ > IF CR THEN ;

.( ..)
: .ID     ( NFAaddr --) COUNT 1F AND TYPE ;
: WORDS   ( -- )
           CR
           0         ( word counter on stack)
           LATEST @
           BEGIN
             DUP ( -- nfa) .ID SPACE ?CR
             SWAP 1+ SWAP   \ inc. the counter
             NFA>LFA @ DUP
             ?BREAK
           0= UNTIL
           DROP
           CR  U. SPACE ." words" ;

\ BFox DUMP looks like dos debug, but without segment address
: .####   ( n --) 0 <# # # # # #> TYPE ;

: .ASCII  ( adr n --)
          BOUNDS
          DO
            I C@ DUP
            BL 1-  80 WITHIN
            0= IF DROP  [CHAR] .
            THEN EMIT
          LOOP ;

DECIMAL
: ?80    ( -- 16 | 8)  \ test for 80 or 40 column mode
          VMODE @ 80 = IF 16 ELSE 8 THEN ;

.( ..)
HEX
: DUMP   ( offset n -- )
         BASE @ >R
         HEX
         BOUNDS   ( -- endadr startadr)
         DO PAUSE
         CR  I  .####  [CHAR] : EMIT
             I  ?80  BOUNDS DO  SPACE I @ .####  2 +LOOP SPACE
             I  ?80  .ASCII
             ?BREAK
          ?80 +LOOP
          CR
          R> BASE ! ;

.( ..)
: UNUSED ( -- u) TIB HERE - ;   \ ANS Forth 94 word

: .FREE  ( -- )
         BASE @ >R
         DECIMAL
         CR ." Free Mem"
         CR ." Low Heap :  " 3F20 H @  - U.
         CR ." Upper mem: " UNUSED U.
         CR ." VDP mem  : " 8370 @ 1000 - .
         R> BASE ! ;

DECIMAL
.FREE
HEX
