\ ELAPSE.FTH  elapsed time measurment words
\ Thanks to Tom Zimmer for the good ideas in FPC circa 1990
\ Ported to HsForth 08MAR91  Brian Fox Canada

\ Ported to CAMEL99 Nov 29 2017
\ Good for 9 minutes maximum duration

\ *** YOU CANNOT CALL KSCAN ( KEY? KEY ) WHILE TIMING ***

HEX                                                                                                     
83D6 CONSTANT TICKER   \ screen timeout counter increments by 2 /16mS

DECIMAL
: ##      ( n -- )  0 <#  # #  #> TYPE ;

: .MINS   ( h S M  -- )
          BASE @ >R   
          DECIMAL  ## [CHAR] : EMIT  ##  [CHAR] . EMIT ##
          R> BASE ! ;

\ 1 TICK = .008333 mS
: REALTIME ( -- n )  TICKER @  5 6 */ ;  \ ratio fixed by Lee Stewart

: >TIME  ( n -- .hh secs mins  )  \ convert n to time
          6000 /MOD   ( -- rem mins) >R  \ push minutes
          100  /MOD   ( -- ms secs)      \ calculate seconds & hundredths
          R> ;                           \ pop minutes

: .ELAPSED ( -- ) CR ." Elapsed time ="  REALTIME >TIME .MINS ;

: ELAPSE  ( -- <forth words> )
           1 PARSE
           TICKER OFF
           EVALUATE
          .ELAPSED ;

