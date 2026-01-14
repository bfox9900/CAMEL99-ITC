\ BG SOUND USING MULTI-TASKER

NEEDS SLEEP  FROM DSK1.MTASK99
NEEDS MALLOC FROM DSK1.MALLOC
NEEDS VALUE  FROM DSK1.VALUES
NEEDS HZ     FROM DSK1.SOUND

0 VALUE TASK1  \ holds tasks PID (program identifier)
0 VALUE TASK2

\ SPAWN dynamically allocates a task space in Low RAM,
\ "forks" it to create workspace and local variables,
\ "assign"s the execution token to run,
\ "wake"s it and returns the task's PID
: SPAWN  ( xt -- pid)
    USIZE MALLOC DUP>R FORK  R@ ASSIGN R@ WAKE  R> ;

\ inter-task messaging -------------------------
HEX
50 USER MAILBOX  \ mailbox is local to each task

\ SEND-MSG blocks if reciever mailbox is full
: SEND-MSG  ( n PID -- ) \ PID (process ID) is task's workspace address
   BEGIN
      DUP MAILBOX LOCAL @ \ is PID mailbox full?
   WHILE
      PAUSE               \ Yes. Pass control to the next task
   REPEAT
   MAILBOX LOCAL ! ;      \ store n into PID's mailbox

\ wait for a message in my local mailbox variable
: GET-MSG ( -- u )
    BEGIN  PAUSE MAILBOX @ ?DUP  UNTIL  MAILBOX OFF ;

\ -------------------------------------------------------
\ Sound DECAY shapers
DECIMAL \ max N = 9000
: DECAY  ( n -- )
    16 0 DO  I DB  DUP I +  TICKS   LOOP   TICKS   MUTE ;

: DECAY2 ( n -- )
    16 0
    DO
        GEN1 I DB   GEN2 I DB
        DUP TICKS
    LOOP
    TICKS
    GEN1 MUTE  GEN2 MUTE ;

: ATTACK ( speed  -- )
    1 16 DO  I DB  DUP TICKS  -1 +LOOP 0 DB ;

\ Sound words
: CLINK ( -- ) GEN1 1400 HZ   100 DECAY  ;
: PING  ( -- ) GEN3 2000 HZ   800 DECAY  ;
: PINGS ( n -- ) 20 0 ?DO  PING  LOOP ;
: BONK  ( -- ) GEN1 110 HZ  GEN2 111 HZ  500 DECAY2 ;
: BA-DING  GEN1 1400 HZ   100 DECAY  2000 HZ  500 DECAY  ;
: SWOOSH   ( -- ) GEN4 MUTE   4 NOISE  500 ATTACK  100 DECAY ;

: SQUEAK      ( -- )
          SILENT
          GEN1
          3800 HZ 200 DECAY
          3500 HZ 200 DECAY
          1300 HZ 200 DECAY
;

\ This task will execute the XT in its mailbox
\ ** NOT PROTECTED FROM BAD XTs **
DECIMAL
: BGPLAYER ( -- )
    MAILBOX OFF \ clear my mailbox
    BEGIN
        GET-MSG EXECUTE
        PAUSE
    AGAIN ;

: >SOUND  ( xt -- ) TASK1 SEND-MSG ;

\ multi-tasking sound words
: CLINKER   ['] CLINK >SOUND ;
: PINGER    ['] PING  >SOUND ;
: BONKER    ['] BONK  >SOUND ;
: BA-DINGER ['] BA-DING >SOUND ;
: SWOOSHER  ['] SWOOSH >SOUND ;
: SQUEAKER  ['] SQUEAK >SOUND ;

\ TESTING: Spawn task to run BGPLAYER
\ ' BGPLAYER SPAWN TO TASK1
\ MULTI
