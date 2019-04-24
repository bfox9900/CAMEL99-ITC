\ ELAPSE.FTH  elapsed time measurment words
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
: ##:     # SEXTAL # DECIMAL <:> ;

: .TIME   ( n -- )
          BASE @ >R
          0 <#  DECIMAL # #  <.> ##:  #S  #> TYPE
          R> BASE ! ;

: .ELAPSED ( -- )  CR ." Elapsed time =" TICKER @ 5 6 */ .TIME ;

: ELAPSE   ( -- <text> ) 1 PARSE  TICKER OFF  EVALUATE .ELAPSED ;

