\ small sound control lexicon (no interrupts used)
\ this version precomputes the 9919 frequency code
\ and compiles the value as a literal integer

: NOISE   ( n -- ) E0 OR SND! ; \ n selects the noise type 

\ noise envelope control
: NOISE-DB   ( db --) F MIN F0 OR SND! ;
: NOISE-OFF  ( -- )   F NOISE-DB ;

HEX
: NOISE-UP   ( speed  -- ) 2  F  DO  I NOISE-DB  DUP MS  -1 +LOOP DROP ;
: NOISE-DOWN ( speed -- )   F  2  DO  I NOISE-DB  DUP MS      LOOP DROP NOISE-OFF ;

\ channel 1 sound control words

DECIMAL
: f(clk) ( -- d) 46324 1  ;   \ this is 111,860 as 32 bit int.

\ >FCODE re-arranges freq. value nibbles (4bits) for the TMS9919
HEX
: >FCODE   ( 0abc -- 0cab)    \ ASM would make this much faster
           DUP 0F AND SWAP      ( -- 000c 0abc)
           4 RSHIFT             ( -- 000c 00ab)
           SWAP FUSE ;
           
: HZ>CODE  ( freq -- fcode )  f(clk) ROT UM/MOD NIP >FCODE 8000 OR  ;

\ [HZ] is macro that calcs 9919 chip frequency divisor code at 
\ compile time and compiles it as a literal 16 bit number.
: [HZ] ( freq -- fcode ) S" HZ>CODE ] LITERAL" EVALUATE ;  IMMEDIATE 

\ sound channel #1 control words
: FREQ!    ( fcode -- ) SPLIT SND! SND! ;
: ]HZ      ( freq -- ) [HZ] POSTPONE FREQ! ;       \ pre-compiled fcode version
: HZ       ( freq -- )  HZ>CODE SPLIT SND! SND! ;  \ runtime calculation version
: DB       ( n -- )    90 OR SND! ;
: MUTE     ( -- )      9F SND! ;
 HEX
: ATTACK   ( speed  -- ) 0  F  DO  I DB  DUP MS   -1 +LOOP DROP ;
: DECAY    ( speed -- )  F  0  DO  I DB  DUP MS       LOOP DROP MUTE ;

\ Example:

: TEST     [ 440 ]HZ 0 DB 500 MS  MUTE ;