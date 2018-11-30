\ SMPLSND.F  minimal sound control, 1 OSC
\ fast for 1 FREQ at a time.

DECIMAL
\ we need a double integer. >NUMBER can do the text-># conversion
: >DOUBLE ( addr len -- d)  0 0 2SWAP >NUMBER 2DROP ;

\ create a double variable from primitives
S" 111860" >DOUBLE CREATE f(clk) SWAP  ,  ,  \ 111,860 Hz is the OSC clock

\ >FCODE re-arranges freq. value nibbles (4bits) for the TMS9919
HEX
: >FCODE   ( 0abc -- 0cab)    \ ASM would make this much faster
           DUP 0F AND SWAP      ( -- 000c 0abc)
           4 RSHIFT             ( -- 000c 00ab)
           SWAP ><  ( SWPB)     ( -- 00ab 0c00)
           + ;

: HZ>CODE  ( freq -- fcode )  f(clk) 2@ ROT UM/MOD NIP >FCODE 8000 OR  ;

\ [HZ] is macro that calcs 9919 chip frequency code at compile time
\  and then compiles it as a literal 16 bit number.
: [HZ] ( freq -- fcode ) S" HZ>CODE ] LITERAL" EVALUATE ;

\ sound channel #1 control words
: FREQ!    ( fcode -- ) SPLIT SND! SND! ;

: ]HZ      ( freq -- ) [HZ] COMPILE FREQ! ; IMMEDIATE

: ATT      ( n -- )    90 OR SND! ;  \ dB attenuation
: MUTE     ( -- )      9F SND! ;

HEX
 : WAIT     ( n -- )      0 ?DO LOOP ;   \ 100us delay
 : DECAY    ( speed -- )  0F  0  DO  I ATT  DUP WAIT  LOOP DROP  ;
 : ATTACK   ( speed -- )  0  0F  DO  I ATT  DUP WAIT  -1 +LOOP  DROP  ;
\
\ EXAMPLE code.  Notice ]HZ must be used in IMMEDIATE MODE [  ]HZ
\  DECIMAL
\ : BELL    ( -- ) [ 1445 ]HZ   0 ATT 50 WAIT   1000 DECAY 50 JIFFS MUTE ;
\ : CLINK   ( -- ) [ 1464 ]HZ  0 ATT 50 WAIT    150 DECAY MUTE ;
\ : CLUNK   ( -- ) [ 1300 ]HZ  0 ATT 100 WAIT    150 DECAY MUTE ;
\ : SWOOSH  ( -- ) [ 120 ]HZ   0 ATT  100 ATTACK 200 WAIT MUTE ;