\ A simple Clock based on the TI-99 Interrupt counter  Updated Mar 10 2022 
\ Runs as a separate task

NEEDS FORK  FROM DSK1.MTASK99
NEEDS MALLOC FROM DSK1.MALLOC

CREATE SECONDS  0 , 0 ,   \ 2 CELLS holds a 32bit integer

: SECONDS++  ( -- )  SECONDS 2@ 1 M+  SECONDS 2! ;

HEX
8379 CONSTANT TICKER   \ interval is 1/60 second

\ wait until ticker changes. subtract old value from new value
: 1/60  ( -- )
        TICKER DUP @   \ dup ticker & fetch initial timer value
        BEGIN
             PAUSE    \ give up CPU to other tasks while we wait
             OVER @   \ read it again
             OVER -   \ subtract initial value
        UNTIL         \ loop until result is not zero
        2DROP ;        \ drop the initial value

DECIMAL
: 1SEC  ( -- )  60 0 DO  1/60  LOOP   SECONDS++  ;

: SEXTAL   6 BASE ! ;
: <:>     [CHAR] : HOLD ;
: <.>     [CHAR] . HOLD ;
: ##:     # SEXTAL # DECIMAL <:> ;

: .TIME   ( d -- )
          BASE @ >R
          <#  ##: ##:  # #  #> TYPE
          R> BASE ! ;

DECIMAL
: CLOCK  ( -- )
         BEGIN
            1SEC
            32 0 AT-XY SECONDS 2@ .TIME
         AGAIN
;

DECIMAL
: SETCLOCK  ( hrs mins -- )
      >R           \ move minutes out the way to return stack
      3600 UM*     \ compute hrs as seconds giving 32bit int
      R> 60 *      \ get mins back, as seconds giving 16bit int
      M+           \ MIXED addition: 32bit+16bit giving 32bit
      SECONDS 2! ; \ store in our 2 CELL variable

USIZE MALLOC CONSTANT BGCLOCK  \ allocate memory and name our task
BGCLOCK FORK                   \ make a copy of Forth's task memory

' CLOCK BGCLOCK ASSIGN         \ Assign execution token of CLOCK to our task

MULTI                          \ enable mutlti-tasker

CR .( Set clock example:  9 45 SETCLOCK )
CR .( Start clock with BGCLOCK WAKE )


BGCLOCK WAKE                   \ wake up BGCLOCK
