\ ELAPSE.FTH  elapsed time measurement words
\ Thanks to Tom Zimmer for the good ideas in FPC circa 1990
\ Ported to HsForth 08MAR91  Brian Fox Canada

\ Ported to CAMEL99 Nov 29 2017,
\ Simplified with SEXTAL Dec 6 2018
\ Good for 9 minutes maximum duration

\ *** YOU CANNOT CALL KSCAN WHILE TIMING ***

HEX
83D6 CONSTANT TICKER   \ screen timeout counter increments by 2 /16mS

DECIMAL
: SEXTAL   6 BASE ! ;
: <:>     [CHAR] : HOLD ;
: <.>     [CHAR] . HOLD ;
: TIME$   ( n -- addr len) \ string output is more flexible
          BASE @ >R
          \         100ths        secs           minutes
          0 <#  DECIMAL # # <.> # SEXTAL # <:> DECIMAL #S  #>
          R> BASE ! ;

: .ELAPSED ( -- )
           TICKER @ 5 6 */ TIME$
           CR ." Elapsed time ="  TYPE ;

: ELAPSE   ( -- <text> ) 1 PARSE  TICKER OFF  EVALUATE .ELAPSED ;
