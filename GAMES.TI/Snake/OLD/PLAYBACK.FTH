\ BG SOUND USING MULTI-TASKER

NEEDS SLEEP  FROM DSK1.MTASK99
NEEDS MALLOC FROM DSK1.MALLOC
NEEDS VALUE  FROM DSK1.VALUES
NEEDS HZ     FROM DSK1.SOUND


0 VALUE PLAYER

\ Use primitives to create a word that dynamically creates a task
\ wakes it and returns the task PID (program identifier)
: SPAWN  ( xt -- pid) USIZE MALLOC DUP>R FORK  R@ ASSIGN R@ WAKE R>  ;

: HALT     MYSELF SLEEP   PAUSE ;

: PLAY   ( xt -- ) PLAYER ASSIGN  PLAYER RESTART  ;

\ create some sounds with Forth words HZ DB TICKS MUTE
DECIMAL \ max N = 10000
: DECAY  ( n -- )
    16 0
    DO
        I DB  DUP I +  TICKS
    LOOP
    TICKS
    MUTE ;


: DECAY2 ( n -- )
    16 0
    DO
        GEN1 I DB   GEN2 I DB
        DUP TICKS
    LOOP
    TICKS
    GEN1 MUTE  GEN2 MUTE ;

\ SOUND words
: CLINK ( -- ) GEN1 1400 HZ   100 DECAY HALT  ;
: PING  ( -- ) GEN3 2000 HZ   800 DECAY HALT  ;
: BONK  ( -- ) GEN1 110 HZ  GEN2 111 HZ  500 DECAY2  HALT ;
: BA-DING  GEN1 1400 HZ   100 DECAY  2000 HZ  500 DECAY  HALT ;

\ make multi-tasking friendly
: CLINKER   ['] CLINK PLAY  HALT ;
: PINGER    ['] PING  PLAY  HALT ;

\ put them all together

' HALT SPAWN TO PLAYER


MULTI
