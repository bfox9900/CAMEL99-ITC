\ BASICSOUND.FTH  gives sound commands closer to BASIC  2024 BFOX

NEEDS ISRPLAY FROM DSK1.ISRSOUND

\ frequency code must be ORed with these numbers to create a sound
HEX
  8000 CONSTANT OSC1      A000 CONSTANT OSC2   ( oscillators take 2 nibbles)
  C000 CONSTANT OSC3        E0 CONSTANT OSC4   ( noise takes 1 nibble)

\ Attenuation values are ORed with these values to change volume
( 0= max, 15 = off)
    90 CONSTANT ATT1         B0 CONSTANT ATT2
    D0 CONSTANT ATT3         F0 CONSTANT ATT4  ( OSC4 volume adjust)

DECIMAL
\ f(clk) for sound chip is 111,860.8 Hz. Round it up to 111,861 works ok.
\ create a 32bit LITERAL from primitives
: f(clk) ( -- d)  [ 0 0  S" 111861" >NUMBER 2DROP SWAP ] LITERAL LITERAL ;

\ >FCODE re-arranges freq. value nibbles (4bits) for the TMS9919
HEX
 CODE >FCODE ( 0abc -- 0cab) \ version by Farmer Potato Atariage
             0B44 , \ TOS 4 SRC,    \ C0AB
             C204 , \ TOS W MOV,    \ DUP
             0948 , \  W 4 SRL,     \ 0C0A
             D108 , \  W TOS MOVB,  \ 0CAB
            NEXT,    \  28 uS
            ENDCODE

\ "ACTIVE CHANNEL" control with these USER variables, LOCAL to each task
\ These are in consecutive addresses in memory
 HEX
 42 USER ATT      \ holds the active ATTENUATOR value
 44 USER OSC      \ holds the active OSC value

\ convert freq. to 9919 chip code
DECIMAL
: HZ>CODE  ( freq -- fcode ) f(clk) ROT UM/MOD NIP >FCODE ;

HEX
\ Set Generator OSCILLATOR and Attenuator with 2!
: GEN! ( osc att -- ) ATT 2! ;

\ ================================================================
\ S C I E N T I F I C   S O U N D   C O N T R O L   L E X I C O N
\ sound generator selectors
: GEN1    ( -- )  OSC1  ATT1  GEN! ;
: GEN2    ( -- )  OSC2  ATT2  GEN! ;
: GEN3    ( -- )  OSC3  ATT3  GEN! ;
: GEN4    ( -- )  OSC4  ATT4  GEN! ;

: (NOISE)   ( n -- ) 0F AND  GEN4  OSC @ OR  ;

: (HZ)    ( f -- n)   HZ>CODE  OSC @ OR  ;          \ convert freq. add OSC
: (DB)    ( level -- c)  ABS 2/  0F MIN  ATT @ OR ; \ DB to attenuation

VHERE CONSTANT SNDBUFF  HEX 100 VALLOT
DECIMAL

: BUILDSND ( -- addr n )  HERE  C,   C,    C,  HERE OVER - DUP>R C,  R> ;
: VOX1 ( vol hz t -- )
  HERE
  BUILDSND  SNDBUFF SWAP VWRITE
;
