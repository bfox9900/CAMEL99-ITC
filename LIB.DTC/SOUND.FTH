\ TMS9919 SOUND CHIP DRIVER and CONTROL LEXICON     Jan 2017 BJF

 INCLUDE DSK1.TOOLS

\ TMS9919 is a memory mapped device on the TI-99 @ >8400
\ SND! is in the CAMEL99 Kernel as  : SND!     8400 C! ;

\ frequency code must be ORed with these numbers to create a sound
HEX
  8000 CONSTANT OSC1      A000 CONSTANT OSC2   ( oscillators take 2 nibbles)
  C000 CONSTANT OSC3        E0 CONSTANT OSC4   ( noise takes 1 nibble)

\ Attenuation values are ORed with these values to change volume
( 0= max, 15 = off)
    90 CONSTANT ATT1         B0 CONSTANT ATT2
    D0 CONSTANT ATT3         F0 CONSTANT ATT4  ( OSC4 volume adjust)

\ There are no 32 bit numbers in the CAMEL99 compiler
\ so we create a constant manually, as 2 literal numbers.
\ Compute 111,760 as 32bit int:  11176 10 UM* ( -- 46324 1)
DECIMAL
 : f(clk) ( -- d)  46225 1  ;   \ this is 111,761 as 32 bit int.

\ >FCODE re-arranges freq. value nibbles (4bits) for the TMS9919
HEX
\ : >FCODE ( 0abc -- 0cab)
\           4 LSHIFT  ( -- abc0 )
\           SPLIT     ( -- ab c0)
\           SWAP
\           4 LSHIFT  ( -- ab  c)
\           +     ;   ( -- 0cab)  \ 18 BYTES 400 uS

 CODE >FCODE ( 0abc -- 0cab) \ version by Farmer Potato Atariage
             0B44 , \ TOS 4  SRC,  \ C0AB
             C204 , \ TOS W  MOV,  \ DUP
             0948 , \   W 4  SRL,  \ 0C0A
             D108 , \  W TOS MOVB, \ 0CAB
            NEXT,   \ 8 BYTES, 28 uS :-)
            ENDCODE

\ we set the "ACTIVE CHANNEL" with these variables
 VARIABLE OSC               \ holds the active OSC value
 VARIABLE ATT               \ holds the active ATTENUATOR value

\ convert freq. to 9919 chip code
DECIMAL
: HZ>CODE  ( freq -- fcode ) f(clk) ROT UM/MOD NIP >FCODE ;

HEX
\ **for testing**  print sound data to screen AND make sound
\ : SND!  ( c -- )  ." >"  BASE @ >R  HEX DUP U. 8400 C! R> BASE ! ;

\ Set the sound "GENerator that is active.
: GEN! ( osc att -- )  ATT !  OSC ! ;

\ ================================================================
\ S C I E N T I F I C   S O U N D   C O N T R O L   L E X I C O N
\ sound generator selectors
: GEN1    ( -- )  OSC1  ATT1  GEN! ;
: GEN2    ( -- )  OSC2  ATT2  GEN! ;
: GEN3    ( -- )  OSC3  ATT3  GEN! ;
: GEN4    ( -- )  OSC4  ATT4  GEN! ;

: NOISE   ( n -- ) 0F AND  GEN4  OSC @ OR  SND! ;

: (HZ)    ( f -- n)   HZ>CODE  OSC @ OR  ;       \ convert freq. add OSC
: (DB)    ( level -- c)  ABS 2/  0F MIN ATT @ OR ; \ DB to attenuation

: HZ      ( f -- ) (HZ) SPLIT SND!  SND! ;
: DB      ( level -- ) (DB)  SND! ; \ Usage: -6 DB
: MUTE    ( -- )  -30 DB ;
: SILENT  ( --)  9F SND!  BF SND!  DF SND!  FF SND! ;

GEN1
DECIMAL
: WOOP   110 HZ 0 DB 500 111 DO I HZ LOOP MUTE ;

: SIREN
        110 HZ 0 DB
        BEGIN
            1100  111 DO   I HZ   2 +LOOP
            110  1100 DO   I HZ  -2 +LOOP
            ?TERMINAL
        UNTIL
        MUTE
;





