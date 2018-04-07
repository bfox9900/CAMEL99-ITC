\ TMS9919 SOUND CHIP DRIVER and CONTROL LEXICON     Jan 2017 BJF

\ TMS9919 is a memory mapped device on the TI-99 @ >8400
\ SND! is in the CAMEL99 Kernel as  : SND!     8400 C! ;

\ frequency code must be ORed with these numbers to create a sound
HEX
  8000 CONSTANT OSC1      A000 CONSTANT OSC2
  C000 CONSTANT OSC3      E000 CONSTANT VOX4

\ Attenuation values are ORed with these values to change volume
( 0= max, 15 = off)
    90 CONSTANT ATT1         B0 CONSTANT ATT2
    D0 CONSTANT ATT3         F0 CONSTANT ATT4  ( VOX4 volume adjust)

\ There are no 32 bit numbers in the CAMEL99 compiler
\ so we create a constant manually, as 2 literal numbers.
DECIMAL
: f(clk) ( -- d) 46324 1  ;   \ this is 111,860 as 32 bit int.

\ >FCODE re-arranges freq. value nibbles (4bits) for the TMS9919
HEX
: >FCODE   ( 0abc -- 0cab)    \ ASM would make this much faster
           DUP 0F AND SWAP      ( -- 000c 0abc)
           4 RSHIFT             ( -- 000c 00ab)
           SWAP ><  ( SWPB)     ( -- 00ab 0c00)
           + ;

\ we set the "ACTIVE CHANNEL" with these variables
 VARIABLE OSC               \ holds the active OSC value
 VARIABLE ATT               \ holds the active ATTENUATOR value

\ convert freq. to 9919 chip code
: >9919 ( freq -- fcode ) f(clk) ROT UM/MOD NIP >FCODE ;

\ **for testing**  print sound data to screen AND make sound
\ : SND!  ( c -- )  ." >"  BASE @ >R  HEX DUP U. SND! R> BASE ! ;

\ Set the sound "GENerator that is active.
: GEN! ( osc att -- )  ATT !  OSC ! ;

\ ================================================================
\ S C I E N T I F I C   S O U N D   C O N T R O L   L E X I C O N
\ sound generator selectors
: GEN1    ( -- )  OSC1  ATT1  GEN! ;
: GEN2    ( -- )  OSC2  ATT2  GEN! ;
: GEN3    ( -- )  OSC3  ATT3  GEN! ;
: GEN4    ( -- )  VOX4  ATT4  GEN! ;

\ Noise control bits
\ value    3bits
\ ----	   - - -
\ 0        | 0 0 : 6991 Hz
\ 1        | 0 1 : 3496 Hz
\ 2        | 1 0 : 1748 Hz
\ 3        | 1 1 : freq set by generator 3
\          |
\          0 : Periodic noise
\          1 : White noise

: NOISE   ( n -- ) 0F AND    GEN4    OSC @ 8 RSHIFT OR  SND! ;

: (HZ)    ( f -- c c)   >9919  OSC @ OR  SPLIT ;   \ convert freq. add OSC
: (DB)    ( level -- c)  ABS 2/  0F MIN ATT @ OR ; \ convert DB to attenuation

: HZ      ( f -- ) (HZ) SND!  SND! ;
: DB      ( level -- ) (DB)  SND! ;   \ write level to 9919 chip. Usage: -6 DB
: MUTE    ( -- )  -30 DB ;
: SILENT  ( --)  9F SND!  BF SND!  DF SND!  FF SND! ;

\ TI sound list compilers
\ : HZ,     ( f -- )     (HZ) C, C, ;
\ : DB,     ( level -- ) (DB)  C, ;
\ : MUTE,   ( -- )       -30 DB, ;
\ : SILENT, ( --)        9F C,  BF C,  DF C,  FF C, ;

DECIMAL

\ EXAMPLES
\ Code the TI-99 sounds with our new words
\ : BEEP2  ( -- ) GEN1  900 HZ  -4 DB  70 MS  MUTE ;
\ : HONK  ( -- ) GEN1   218 HZ   0 DB  170 MS  MUTE  ;

