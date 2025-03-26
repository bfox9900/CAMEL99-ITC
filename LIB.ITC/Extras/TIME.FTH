\ TIME.FTH   time utilities for Camel99 Forth      Nov 24 2012 Brian Fox

\ 32 bit integer we can manage up to 2^32 seconds, or  119304 hrs.

\ INCLUDE DSK1.TOOLS  \ debugging

DECIMAL
: HRS>MINS  ( n -- d) 3600 UM* ;
: MINS>SECS ( n -- d) 60 UM* ;

\ stackcrobatics for 3 items (hours,minutes,seconds)
: >SSMMHH ( h m s -- s m h)  SWAP ROT ;
: >HHMMSS ( s m h -- h m s)  -ROT SWAP ;

: TIME>D  ( s m h -- d)     \ convert time format to DOUBLE (32bit int)
        HRS>MINS  2>R       \ push double to rstack
        MINS>SECS SWAP M+   \ add secs (single) to mins (double) with mixed +
        2R> D+ ;            \ add hrs to sub-total

: D>TIME  ( d -- s m h )    \ convert DOUBLE to time
        3600 UM/MOD ( -- rem hrs) >R
        60 /MOD     ( -- secs mins)
        R> ;        ( -- secs mins hrs)

\ Concept from Starting Forth, Brodie. Would have never thought of this :)
: SEXTAL   6 BASE ! ;
: <:>     [CHAR] : HOLD ;
: <.>     [CHAR] . HOLD ;
: ##:     # SEXTAL # DECIMAL <:> ;

: .TIME   ( d -- ) \ expects double int as time in seconds on stack
          BASE @ >R
          <#  ##: ##:  # #  #> TYPE
          R> BASE ! ;

: DU<  ( d d -- ?) ROT U> IF 2DROP TRUE   ELSE U<  THEN ;
: D=   ( d d -- ?) ROT = -ROT = AND ;

: REDUCE2  ( s m h s m h -- d1 d2) \ convert 2 times into 2 doubles
         TIME>D 2>R  \ convert top time and push
         TIME>D 2R>  \ convert and pop
;

: ISBEFORE ( s m h  s m h -- ?) REDUCE2 DU< ; \ is 1st time before 2nd time
: ISAFTER  ( s m h  s m h -- ?) REDUCE2 2SWAP DU< ; \ is 1st time after 2nd time
: SAMETIME ( s m h  s m h -- ?) REDUCE2 D= ;  \ are both times the same
