\ TMS9919 SOUND CHIP DRIVER and CONTROL LEXICON     Jan 2017 BJF
\ Modified to use ISR timers to control durations   Mar 2 2019 BJF
 
 NEEDS DUMP FROM DSK1.TOOLS   \ debugging
 NEEDS MOV, FROM DSK1.ASM9900

\ frequency code must be ORed with these numbers to create a sound
HEX
  8000 CONSTANT OSC1      A000 CONSTANT OSC2   ( oscillators take 2 nibbles)
  C000 CONSTANT OSC3        E0 CONSTANT OSC4   ( noise takes 1 nibble)
 
\ Attenuation values are ORed with these values to change volume
( 0= max, 15 = off)
    90 CONSTANT ATT1         B0 CONSTANT ATT2
    D0 CONSTANT ATT3         F0 CONSTANT ATT4  ( OSC4 volume adjust)

\ timer array:  1 for each voice
CREATE TIMERS ( -- addr)  0 , 0 , 0 , 0 ,

\ names for each timer in the array
TIMERS   CONSTANT T1
T1 CELL+ CONSTANT T2
T2 CELL+ CONSTANT T3
T3 CELL+ CONSTANT T4

\ =====================================================
\ There are no 32 bit numbers in the CAMEL99 compiler
\ so we create a double variable with primtives
: >DOUBLE  ( addr len -- d ) 0 0 2SWAP >NUMBER 2DROP ;

DECIMAL
S" 111861" >DOUBLE CREATE f(clk) ( -- d)  ,  ,  \ 32 bit int.
 
\ >FCODE re-arranges freq. value nibbles (4bits) for the TMS9919
HEX
 CODE >FCODE ( 0abc -- 0cab) \ version by Farmer Potato Atariage
            0B44 ,  \ TOS 4  SRC,  \ C0AB
            C204 ,  \ TOS W  MOV,  \ DUP
            0948 ,  \   W 4  SRL,   \ 0C0A
            D108 ,  \  W TOS MOVB, \ 0CAB
            NEXT,
            ENDCODE   

\ we set the "ACTIVE CHANNEL" with these variables
 VARIABLE OSC       \ holds the active OSC value
 VARIABLE ATT       \ holds the active ATTENUATOR value
 VARIABLE T         \ hold active timer address

\ convert freq. to 9919 chip code
: HZ>CODE  ( freq -- fcode ) f(clk) 2@ ROT UM/MOD NIP >FCODE ;

HEX
\ **for testing**  echo sound data to screen AND make sound
\ : SND!  ( c -- )  ." >"  BASE @ >R  HEX DUP U. 8400 C! R> BASE ! ;

\ TMS9919 is a memory mapped device on the TI-99 @ >8400
\ : SND!    ( c -- ) 8400 C! ;

CODE SND! ( c -- )
           TOS SWPB,
           TOS 8400 @@ MOVB,
           TOS POP,
           NEXT, 
           ENDCODE

\ Set the sound "GENerator that is active by assigning
\ timer, attenuator and oscillator
\ : GEN! ( osc att tmr -- )  T !  ATT !  OSC !  ;

CODE GEN! ( osc att tmr -- )
          TOS    T @@ MOV,
         *SP+  ATT @@ MOV,
         *SP+  OSC @@ MOV,
          TOS POP,
          NEXT,
          ENDCODE

CREATE MUTE-ISR     \ creates a label for this sub-routine
     R1 TIMERS LI,  \ R1=timer array address
     R2 8400   LI,  \ R2=sound port address
     R3 9F00   LI,  \ R3=attenuator "off"  value
     R5 TIMERS 4 CELLS + LI,  \ compute last timer() address
     R0 CLR,                  \ need a zero value
     BEGIN,
       R1 ** R0 CMP,          \ timer <>0
       NE IF,
          R1 ** DEC,          \ decrement timer
          EQ IF,
             R3 R2 ** MOVB,   \ mute attenuator
          ENDIF,
       ENDIF,
       R1 INCT,         \ next timer
       R3 2000 AI,      \ next attenuator
       R1 R5 CMP,       \ is this the last timer?
     EQ UNTIL,          \ loop until true
     RT,
     ENDCODE

HEX
: INSTALL  ( sub-routine -- ) 83C4 ! ;

\ enable/disable background sound mute ISR
: BG-ON   ( -- ) MUTE-ISR INSTALL ;
: BG-OFF  ( -- ) 0 INSTALL ;
: COLD    ( -- ) BG-OFF COLD ;  \ disable ISR before re-booting Forth

\ ================================================================
\ S O U N D   C O N T R O L   L E X I C O N

\ sound "voice" selectors
: VOX1    ( -- )  OSC1  ATT1 T1 GEN! ;
: VOX2    ( -- )  OSC2  ATT2 T2 GEN! ;
: VOX3    ( -- )  OSC3  ATT3 T3 GEN! ;
: VOX4    ( -- )  OSC4  ATT4 T4 GEN! ;

\ convert input to correct values to send to sound chip
\ low level API
: HZ      ( f -- )  HZ>CODE  OSC @ OR  SPLIT SND!  SND! ;
: DB      ( level -- ) 2/  0F MIN ATT @ OR  SND! ;   \ Usage: -6 DB
: TICKS   ( t -- )  T @  ! ;        \ store 't' in active timer
: 16/     ( n -- n') 4 RSHIFT ;     \ converts mS -> ticks

: MUTE    ( -- ) 30 DB  ;
: SILENT  ( -- ) 9F SND!  BF SND!  DF SND!  FF SND! ;

: DURATION ( ms -- )
          DUP 0<                    \ negative value?
          IF   ABS 16/ TICKS        \ Yes. use background mute timer
          ELSE MS MUTE              \ No. Wait, then mute
          THEN ;

\ =============================================================
\ hi-level API for each voice

: PLAY ( dur vol -- ) DB DURATION ; \ common factor

( We set freq. before opening attenuator for cleanest sound)
: SND1  ( dur freq vol  -- ) VOX1 SWAP HZ PLAY ;
: SND2  ( dur freq vol  -- ) VOX2 SWAP HZ PLAY ;
: SND3  ( dur freq vol  -- ) VOX3 SWAP HZ PLAY ;

\ 1 1 1 0 0 w r r
\  >E      | | |
\          | 0 0 : 0  6991 Hz
\          | 0 1 : 1  3496 Hz
\          | 1 0 : 2  1748 Hz
\          | 1 1 : track freq of gen.3
\          1 0 0 : 4 low freq white noise
\          1 0 1 : 5 med freq white noise
\          1 1 0 : 6 hi  freq white noise
\          0 : Periodic noise
\          1 : White noise    7 = tracking white noise

: NOISETYPE ( n -- ) OSC4 OR SND! ;   \ faster create for noise byte

: NOISE ( dur freq vol  -- ) VOX4 SWAP 07 AND NOISETYPE PLAY ;

DECIMAL 
: >BASS ( n -- n') 14777 1000 */ ;

: BASS ( dur freq vol -- ) \ steal VOX3 & VOX4 to play low freq
         VOX3 SWAP >BASS HZ MUTE
         VOX4 3 NOISETYPE  PLAY ;

: WHITE ( dur freq vol -- ) \ steal VOX3 & VOX4. Pitched white noise
         VOX3 SWAP 4* HZ MUTE
         VOX4 7 NOISETYPE  PLAY ;


