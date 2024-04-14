\ music lexicon to control the TMS9919 with ISR timers  Apr 2024 B Fox

\ **********************************************************************
\               Music code MUST be assigned to a task. 
\               Music USER variables will crash console task.
\ *********************************************************************
 
NEEDS DUMP FROM DSK1.TOOLS
NEEDS HZ   FROM DSK1.SOUND
NEEDS MASTER FROM DSK1.MUTINGISR \ *change dsk?. to where you put this file.

\ ===============  MULTI-TASKING STUFF =======================
NEEDS MALLOC FROM DSK1.MALLOC 
NEEDS FORK   FROM DSK1.MTASK99 

NEEDS WORDLIST FROM DSK1.WORDLISTS 


HEX 2000 H !  \ reset the heap for testing purposes 

\ create a task in heap, fork it, assign Execution token & name 
: SPAWN ( xt -- pid) USIZE MALLOC DUP>R FORK R@ ASSIGN R>  ;

: TASK: ( xt -- ) ['] PAUSE SPAWN CONSTANT ;

TASK: TASK1 
TASK: TASK2
TASK: TASK3 
TASK: TASK4

\ ===========================================================
VOCABULARY MUSIC   
ONLY FORTH ALSO MUSIC DEFINITIONS 

DECIMAL
\ duration control variables and values
VARIABLE TEMPO

VARIABLE TIMESIG     \ 2/4 3/4 4/4  6/4
VARIABLE MEASURE     \ 1 muscial measure of time in ticks (1/60 SECS)
 
48 USER  VOICE       \ thread local variable 
50 USER  ON_TIME
52 USER  OFF_TIME
54 USER  FEEL        \ controls the on/off time ratio
56 USER  VOLUME 

: ]T  ( timer# --) CELLS MASTER + ;

\ WAIT is in MUTINGISR.FTH . Waits unto a timer hits zero 
: DELAY ( n -- ) VOICE @ ]T DUP>R !  R> WAIT  ;

: ]DB ( voice -- ) CELLS MUTE4  + ;  \ 1..4 are valid 

\ create a 32 bit integer for UM/MOD. 
\ UM/MOD is the fastest division primitive in the kernel
: TIMEBASE  ( -- d) 3600 0 ; \ Number of ticks in one minute 

HEX 8400 CONSTANT SND_PORT 

\ DECIMAL 
\ Write a byte to the sound chip with no PAUSE critical to make this work.  
\ Macro is faster for this important function  
\ : SND!  ( c --) POSTPONE SND_PORT POSTPONE C! ;  IMMEDIATE 

\ But a code word is ~3x faster
 HEX 
 CODE SND!   
    06C4 ,            \ TOS SWPB,  
    D804 , SND_PORT , \ TOS SND_PORT @@ MOVB,  
    C136 ,            \ TOS POP,  
    NEXT, 
 ENDCODE 

DECIMAL 
: WHOLENOTE ( -- ticks) \ using tempo set the bpm for 1 whole note
      TIMEBASE TEMPO @  UM/MOD NIP  ( -- ticks_for_1_beat )
      TIMESIG @ * DUP  MEASURE ! ;  ( 1_beat X beats_per_bar = 1 measure )
 
\ Music needs notes to start and end in different ways.
\ this word adjust the on:off ratio using n
: EXPRESSION ( note_dur n --)
      OVER SWAP -  TUCK -   ( -- on-ms off-ms )
      0 MAX OFF_TIME !
      0 MAX ON_TIME ! ;  \ store times in variables
                                 
\ return full duration of current note
: NOTE      ( -- ticks) ON_TIME @ OFF_TIME @ + ;

: DURATION! ( ticks -- )  FEEL @ EXPRESSION ;
 
: %        ( N N2  -- N%) 100 */ ;    \ calculate n2% of n
: 50%       ( N -- N/2) POSTPONE 2/ ; IMMEDIATE 
: 50%+      ( N -- N+50%)  DUP 50% + ; \ dotted notes have 50% more time

\ === BAR LINES ===
: | ;  ( noop at this times )
: ||    MYSELF SLEEP  PAUSE  ;  \ DOUBLE bar line ends the music 


: PLAY      ( fcode -- )
            OSC @ OR  SPLIT  SND! SND!  \ send frequency 
   VOLUME @ ATT @ OR SND!               \ send volume 
                                        \ Note is now playing...            

\ DELAY function loads timer register. ISR begins decrementing. 
\ DELAY monitors timer register and runs PAUSE while waiting 
            ON_TIME  @ DELAY   \ set the ISR timer, which auto mutes   
            OFF_TIME @ DELAY   \ time between notes 
;

\ note object creator
: NOTE:   ( freq -- )
           CREATE          \ compile time: create a name in the dictionary
                 HZ>CODE , \ compile the 9919 code into the note
 
           DOES> @ PLAY ; \ run time:  fetch the number, play the note


\ ================[ API ]==============================
: SOPRANO   1 VOICE ! GEN1 ; SOPRANO 
: ALTO      2 VOICE ! GEN2 ;
: TENOR     3 VOICE ! GEN3 ;
: BASS      4 VOICE ! GEN4 ;

: 4/4    4 TIMESIG ! ;  4/4 
: 3/4    3 TIMESIG ! ;
: 2/4    2 TIMESIG ! ;

: 2X    2 0  ;


\ repeat bars  
: ||:      POSTPONE 2X POSTPONE DO  ; IMMEDIATE 
: :||      POSTPONE LOOP ; IMMEDIATE 

\ dynamics 

: ff        0  VOLUME ! ;
: forte     2  VOLUME ! ;
: mf        4  VOLUME ! ;
: mp        6  VOLUME ! ;
: piano     7  VOLUME ! ;
: pp       10  VOLUME ! ;

DECIMAL 
\ FREQ  NATURAL    FREQ  ACCIDENTAL    EN-HARMONIC
\ -------------    ----------------   ----------------
  110 NOTE: A2     117 NOTE: A#2       : Bb2 A#2 ;
  123 NOTE: B2
  131 NOTE: C3     139 NOTE: C#3       : Db3 C#3 ;
  147 NOTE: D3     156 NOTE: D#3       : Eb3 D#3 ;
  165 NOTE: E3
  175 NOTE: F3     185 NOTE: F#3       : Gb3 F#3 ;
  196 NOTE: G3     208 NOTE: G#3       : Ab3 G#3 ;
  220 NOTE: A3     233 NOTE: A#3       : Bb3 A#3 ;
  247 NOTE: B3
  262 NOTE: C4     277 NOTE: C#4       : Db4 C#4 ;
  294 NOTE: D4     311 NOTE: D#4       : Eb4 D#4 ;
  330 NOTE: E4
  349 NOTE: F4     370 NOTE: F#4       : Gb4 F#4 ;
  392 NOTE: G4     415 NOTE: G#4       : Ab4 G#4 ;
  440 NOTE: A4     466 NOTE: A#4       : Bb4 A#4 ;
  494 NOTE: B4
  523 NOTE: C5     554 NOTE: C#5       : Db5 C#5 ;
  587 NOTE: D5     622 NOTE: D#5       : Eb5 D#5 ;
  659 NOTE: E5
  698 NOTE: F5     740 NOTE: F#5       : Gb5 F#5 ;
  784 NOTE: G5     831 NOTE: G#5       : Ab5 G#5 ;
  880 NOTE: A5     932 NOTE: A#5       : Bb5 A#5 ;
  988 NOTE: B5
 1047 NOTE: C6

\ tempo control 
: BPM       ( BPM -- )  \ set tempo in beats per minute
            TEMPO !
            WHOLENOTE DURATION! ;
: RIT.      NOTE DUP 30 % + DURATION! ;
 
\ musical expression  
: NORMAL      NOTE 4 % FEEL ! ;
: LEGATO      NOTE   0 FEEL ! ;   \ notes run together
: STACCATO   NOTE 20 % FEEL ! ;   \ short notes
: MARCATO     NOTE 6 % FEEL ! ;   \ march feel
 

: 1/1      WHOLENOTE      DURATION! ;
: 1/2      WHOLENOTE 50%  DURATION! ;
: 1/2.     1/2  NOTE 50%+ DURATION! ;
: 1/4      1/2  NOTE 50%  DURATION! ;
: 1/4.     1/4  NOTE 50%+ DURATION! ;
: 1/8      1/4  NOTE 50%  DURATION! ;
: 1/8.     1/8  NOTE 50%+ DURATION! ;
: 1/16     1/8  NOTE 50%  DURATION! ;
: 1/32     1/16 NOTE 50%  DURATION! ;

: REST     NOTE DELAY ;
: /-/  WHOLENOTE REST ;
: //   1/2 REST ;
: /    1/4 REST ;


\    ==================[ BASS VOICE ]==================
\ Bass voice uses the TENOR oscillator and the noise channel
\ It also has a lower volume so you have to reduce volume of
\ the other channels if used in combination 

HEX
0B CONSTANT PERIODIC \ noise bits that set control by Chan. 3

DECIMAL 
: PLAY.BASS  ( fcode -- )
        OSC3 OR  SPLIT  SND! SND!  \ send frequency data to channel 3
            31 ATT3 OR  SND!       \ but chan 3 is silent 

      PERIODIC OSC4 OR SND!        \ select noise for output 
      VOLUME @ ATT4 OR SND!        \ send volume 
                                   \ BASS Note is now playing...    

            ON_TIME  @ DELAY   \ set the ISR timer, which auto mutes   
            OFF_TIME @ DELAY   \ time between notes 
;


DECIMAL
: BASS: ( freq -- )
    CREATE  15 * HZ>CODE ,  \ calibrate freq. & pre-calculate the code 
    DOES> @ PLAY.BASS ;
        
\ FREQ  NATURAL    FREQ  ACCIDENTAL    EN-HARMONIC
    41 BASS: E1 \ Lowest note of Bass guitar
    44 BASS: F1   46 BASS: F#1         
    : Gb0  F#1 ;
    49 BASS: G1   52 BASS: G#1         
    : Ab   G#1 ;
    55 BASS: A1   58 BASS: A#1         
    : Bb  A#1 ;     
    
    62 BASS: B1
    65 BASS: C2   69 BASS: C#2
    : Db1  C#2 ;
    73 BASS: D2   78 BASS: D#2
    : Eb1  D#2 ;
    82 BASS: E2 \ Lowest Note of Guitar
    87 BASS: F2   93 BASS: F#2         
    : Gb1  F#2 ;
    98 BASS: G2  104 BASS: G#2         
    : Ab1  G#2 ; 

ONLY FORTH ALSO MUSIC ALSO FORTH DEFINITIONS 
