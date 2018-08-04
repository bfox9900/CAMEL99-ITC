
CR .( TOOLS for Camel99 Forth V2)

HEX
: MARKER  ( -- )
          LATEST @ HERE
          ALIGN
          CREATE  ,   ,

          DOES>  2@  LATEST ! DP ! ;

CR .( MARKER )

.( ? DEPTH .S )
: ?         ( adr -- ) @ . ;

: DEPTH     ( -- n )   SP0 SP@ CELL+ - 2/ ;

\ .S is more complicated with TOS in a register
: .S        ( -- )
            ." |"
            DEPTH
            IF   0 DEPTH 2- DO   I PICK  U.  -1 +LOOP
            THEN ;

\ : RDEPTH    ( -- n )   RP0 RP@ - 2/ ;
\ : .RS       ( -- ) RP@ RP0  DO  I @ U.  -2 +LOOP ;

.( ?BREAK )
\ ABORT if function 4 is pressed
: ?BREAK    ( -- )
	    ?TERMINAL 
            IF BEGIN PAUSE ?TERMINAL 0= UNTIL
               CR ." *BREAK*" ABORT
            THEN ;

.( WORDS )

: .ID       ( addr --) COUNT 1F AND TYPE ;

: WORDS     ( -- )
             CR
             0         ( word counter on stack)
             LATEST @
             BEGIN
                DUP   ( -- nfa) .ID SPACE
                SWAP 1+ SWAP        \ inc. the counter
                NFA>LFA @ DUP
                ?BREAK
             0= UNTIL
            DROP
            CR  U. SPACE ." words" ;

\ BFox DUMP looks like dos debug, but without segment address
\ modified for TI-99 40 column screen

: .####       ( n --) 0 <# # # # # #> TYPE ;

2E CONSTANT '.'
3A CONSTANT ':'

: .ASCII      ( adr n --)
              BOUNDS
              DO
                 I C@ DUP
                 BL 1-  80 WITHIN
                 0= IF DROP  '.'
                 THEN EMIT
              LOOP ;

DECIMAL
: ?80         ( -- 16 | 8)  \ test for 80 or 40 column mode
               VMODE @ 80 = IF 16 ELSE 8 THEN ;

.( DUMP )
HEX
: DUMP        ( offset n -- )
               BASE @ >R
               HEX
               BOUNDS   ( -- endadr startadr)
               DO PAUSE
                  CR @
                  I  .####  ':' EMIT
                  I  ?80  BOUNDS DO  SPACE I @ .#### 2 +LOOP SPACE
                  I  ?80  .ASCII
                  ?BREAK
               ?80 +LOOP
               CR
               R> BASE ! ;

.( .FREE )
: UNUSED   ( -- u) TIB HERE - ;   \ ANS Forth 94 word

: .FREE      BASE @ >R
             DECIMAL
             CR ." Free Mem"
             CR ." Low Heap :  " 3F20 H @  - U.
             CR ." Upper mem: " UNUSED U.
             CR ." VDP mem  : " 8370 @ 1000 - .
             R> BASE ! ;

\ lock the current dictionary
: LOCK     DP @ ORGDP !   LATEST @ ORGLAST ! ; 

DECIMAL
.FREE
HEX

