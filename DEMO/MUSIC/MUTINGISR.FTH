\ MUTINGISR.FTH    Interrupt timers for music   Brian Fox Apr 2024
\ See: readme for explanation

\ Usage: (The ISR is active after this file is loaded into Forth)
\ 1. Send the frequency code + channel ID to the sound chip
\ 2. Load the timer for that channel ( T1..T4) with '!' operator 
\ 3. The note will play until the timer hits zero and the ISR mutes it

NEEDS DUMP  FROM DSK1.TOOLS
NEEDS MOV,  FROM DSK1.ASM9900

HERE
DECIMAL
CREATE MASTER  16 CELLS ALLOT  MASTER 16 CELLS 0 FILL
 
 
HEX
\ Declare timer status registers as constants
\ Use them just like normal variables in Forth. (9900 special feature)
: REGISTER: DUP CONSTANT   CELL+  ;  \ enumerator
 
MASTER
    REGISTER: T0   \ decrementing counter (future)
    REGISTER: T1   \ Soprano voice timer
    REGISTER: T2   \ Alto voice timer
    REGISTER: T3   \ Tenor voice timer
    REGISTER: T4   \ Noise voice timer
 
    REGISTER: MUTE1
    REGISTER: MUTE2
    REGISTER: MUTE3
    REGISTER: MUTE4
 
    REGISTER: VOL1 \ volume to set
    REGISTER: VOL2
    REGISTER: VOL3
    REGISTER: VOL4
 
: WAIT ( timer -- ) BEGIN DUP @ WHILE  PAUSE  REPEAT DROP ;
 
: RESET-TIMERS ( -- )  \ preload the workspace :-)
        T1 OFF
        T2 OFF
        T3 OFF
        T4 OFF
\ mute values kept in registers
        9F00 MUTE1 !
        BF00 MUTE2 !
        DF00 MUTE3 !
        FF00 MUTE4 !
;
 
HEX
CREATE TIMERISR  ( -- address)
    MASTER LWPI,
    R0 DEC,         \ continous counter for future
\ Soprano timer
    R1 0 CI,
    NE IF,
        R1 DEC,
        EQ IF,
            R5  8400 @@ MOVB, \ mute the channel
        ENDIF,
    ENDIF,
\ Alto timer
    R2 0 CI,
    NE IF,
        R2 DEC,
        EQ IF,
            R6  8400 @@ MOVB, \ mute the channel
        ENDIF,
     ENDIF,
\ Tenor timer
    R3 0 CI,
    NE IF,
        R3 DEC,
        EQ IF,
            R7  8400 @@ MOVB, \ mute the channel
        ENDIF,
    ENDIF,
\ Noise timer
    R4 0 CI,
    NE IF,
        R4 DEC,
        EQ IF,
            R8  8400 @@ MOVB, \ mute the channel
        ENDIF,
    ENDIF,
 
    83E0 LWPI,
    RT,
 
HEX
: INSTALL ( sub-routine -- )  83C4 ! ;
 
: COLD    0 INSTALL  COLD ;
HERE SWAP - .  .( bytes)
 
RESET-TIMERS
TIMERISR INSTALL
 
 