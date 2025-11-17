\ ELAPSE2.FTH  elapsed time measurement words
\ Thanks to Tom Zimmer for the good ideas in FPC circa 1990

\ Installs an independent 32 bit timer on the interrupt
\ so you can time programs for long periods or create
\ a time of day clock.

NEEDS INSTALL FROM DSK1.ISRSUPPORT
INCLUDE DSK1.TOOLS
INCLUDE DSK1.DOUBLE

 HEX
 CREATE TIME32 0 , 0 ,   \ 32 bit variable

 CODE COUNT32
      05A0 , TIME32 CELL+ ,  \ TIME32 CELL+ @@ INC,
      1702 ,                 \ OC IF,
      05A0 , TIME32 ,        \ TIME32 @@ INC, ENDIF,
      045B ,                 \ RT,
 ENDCODE

DECIMAL
: SEXTAL   6 BASE ! ;
: <:>     [CHAR] : HOLD ;
: <.>     [CHAR] . HOLD ;
: :00     DECIMAL # SEXTAL # <:> ;
: .00     DECIMAL # # <.> ;

CREATE TIME$  32 ALLOT
: D>TIME   ( d -- addr len) \ string output is more flexible
          BASE @ >R
          \  100ths secs  minutes  hours
          <# .00    :00   :00   DECIMAL # #  #> TIME$ PLACE
          R> BASE ! ;

: UD/MOD ( ud1 u2 -- u3 ud4) >R 0 R@ UM/MOD -ROT R> UM/MOD ROT ;

: TICKS>MS ( d -- ms) 166 UD/MOD ROT DROP    ;

: .ELAPSED ( -- )
           TIME32 2@ TICKS>MS 0 TIME$
           CR ." Elapsed time ="  TYPE ;

: RESET32  ( -- ) 0 0 TIME32 2! ;

: ELAPSE   ( -- <text> ) 1 PARSE  RESET32 EVALUATE .ELAPSED ;

: COLD    0 INSTALL  COLD ; \ redefined to stop interrupts 1st

 ISR' COUNT32 INSTALL
 CR .( 32bit counter interrupt installed)
