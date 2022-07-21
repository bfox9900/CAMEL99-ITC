\ A simple Clock based on the TI-99 Interrupt counter
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


: CLOCK  ( -- )
         BEGIN
            1SEC
            31 0 AT-XY SECONDS 2@ .TIME
         AGAIN
;

USIZE MALLOC CONSTANT BGCLOCK   BGCLOCK FORK
' CLOCK BGCLOCK ASSIGN
