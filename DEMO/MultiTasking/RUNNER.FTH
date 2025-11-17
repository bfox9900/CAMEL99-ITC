\ RUNNER.FTH   A Task that will run whatever you give Nov 2025 Brian Fox

NEEDS DUMP   FROM DSK1.TOOLS
NEEDS MALLOC FROM DSK1.MALLOC
NEEDS FORK   FROM DSK1.MTASK99
NEEDS .TASKS FROM DSK1.MTOOLS

INIT-MULTI
HEX 2000 2000 FF FILL

\ *WARNING* EACH SPAWNED task grabs low RAM memory and never gives it back
DECIMAL
\ create a task in heap, fork it, assign Execution token and run it
: SPAWN  ( xt -- ) USIZE MALLOC DUP>R FORK  R@ ASSIGN  R> WAKE ;

\ Tasks assigned to RUN must end with the word HALT
: HALT   MYSELF SLEEP PAUSE ;


: TEST1  10000 0 DO  PAUSE I  DROP LOOP  HALT ;

VARIABLE X
: TEST2  X ON   BEGIN  X @  WHILE  PAUSE  X 1-!  REPEAT  ;

: RUN    '  SPAWN  ;


MULTI
