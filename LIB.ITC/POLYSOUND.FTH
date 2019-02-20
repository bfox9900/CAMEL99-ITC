\ TMS9919 SOUND CHIP DRIVER and CONTROL LEXICON     Jan 2017 BJF
\ Modified to use ISR timers to control durations   Feb 16 2019 BJF

 NEEDS DUMP FROM DSK1.TOOLS   \ debugging
 NEEDS MOV, FROM DSK1.ASM9900

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

\ timer array:  1 for each voice
CREATE TIMERS ( -- addr)  0 , 0 , 0 , 0 ,

\ names for each timer in the array
TIMERS   CONSTANT T1
T1 CELL+ CONSTANT T2
T2 CELL+ CONSTANT T3
T3 CELL+ CONSTANT T4
\ There are no 32 bit numbers in the CAMEL99 compilerBYE

\ so we create a double variable with primtives
: >DOUBLE  ( addr len -- d ) 0 0 2SWAP >NUMBER 2DROP ;

DECIMAL
S" 111761" >DOUBLE CREATE f(clk) ( -- d)  ,  ,  \ 32 bit int.

\ >FCODE re-arranges freq. value nibbles (4bits) for the TMS9919
HEX
 CODE >FCODE ( 0abc -- 0cab) \ version by Farmer Potato Atariage
             0B44 , \ TOS 4  SRC,  \ C0AB
             C204 , \ TOS W  MOV,  \ DUP
             0948 , \   W 4  SRL,  \ 0C0A
             D108 , \  W TOS MOVB, \ 0CAB
            NEXT,   \ 8 BYTES, 28 uS :-)
            ENDCODE

\ we set the "ACTIVE CHANNEL" with these variables
 VARIABLE OSC       \ holds the active OSC value
 VARIABLE ATT       \ holds the active ATTENUATOR value
 VARIABLE T         \ hold active timer address

\ convert freq. to 9919 chip code
DECIMAL
: HZ>CODE  ( freq -- fcode ) f(clk) 2@ ROT UM/MOD NIP >FCODE ;

HEX
\ **for testing**  print sound data to screen AND make sound
\ : SND!  ( c -- )  ." >"  BASE @ >R  HEX DUP U. 8400 C! R> BASE ! ;

\ Set the sound "GENerator that is active by assigning
\ timer, attenuator and oscillator
: GEN! ( osc att tmr -- )  T !  ATT !  OSC !  ;

\ ================================================================
\ S C I E N T I F I C   S O U N D   C O N T R O L   L E X I C O N
\ sound generator selectors
: VOX1    ( -- )  OSC1  ATT1 T1 GEN! ;
: VOX2    ( -- )  OSC2  ATT2 T2 GEN! ;
: VOX3    ( -- )  OSC3  ATT3 T3 GEN! ;
: VOX4    ( -- )  OSC4  ATT4 T4 GEN! ;

: NOISE   ( n -- ) 0F AND VOX4  OSC @ OR  SND! ;

: (HZ)    ( f -- n)   HZ>CODE  OSC @ OR  ;       \ convert freq. add OSC
: (DB)    ( level -- c)  ABS 2/  0F MIN ATT @ OR ; \ DB to attenuation

: HZ      ( f -- ) (HZ) SPLIT SND!  SND! ;
: DB      ( level -- ) (DB)  SND! ; \ Usage: -6 DB
: TICKS   ( time  -- ) T @  ! ;     \ DURATION

: MUTE    ( -- )  -30 DB  0 T @ ! ;
: SILENT  ( --)  9F SND!  BF SND!  DF SND!  FF SND! ;

CREATE TIMER-ISR
     R1 TIMERS LI,  \ timer array addres
     R2 8400   LI,  \ sound port address
     R3 9F00   LI,  \ attenuator #1 off  value
     R5 TIMERS 4 CELLS + LI,  \ compute last timer address
     R0 CLR,
     BEGIN,
       R1 ** R0 CMP,           \ timer <>0
       NE IF,
          R1 ** DEC,          \ decrement timer
          EQ IF,
             R3 R2 ** MOVB,   \ mute attenuator 1
          ENDIF,
       ENDIF,
       R1 INCT,         \ select timer 2
       R3 2000 AI,      \ bump attenuator
       R1 R5 CMP,
     EQ UNTIL,
     RT,
    ENDCODE

HEX
: INSTALL   83C4 ! ;

: BG-ON   TIMER-ISR INSTALL ;
: BG-OFF          0 INSTALL ;

\ DECIMAL
\ : TEST
\   VOX1 120 HZ 0 DB  500 TICKS
\   VOX2 241 HZ 0 DB  550 TICKS
\   VOX3 482 HZ 0 DB  600 TICKS ;
