( Circular byte queue for general purpose stuff  21MAR94 FOX )
( Ported to Camel99 forth  11JUN2020 )
\ fifo "first in, first out"

HEX
: BYTE-QUEUE: ( n -- <text>)
    CREATE
        DUP 10 MOD ABORT" Queue size must be power of 2"
        0 ,          ( write pointer {TAIL} )
        0 ,          ( read  pointer {HEAD} )
        DUP 1- ,     ( mask value    )
        ALLOT        ( data          )
;

( Pointers to the Queue data structure )
: ->HEAD ( q -- adr )      ;  \ syntax sugar
: ->TAIL ( q -- adr ) 2+   ;
: ->MSK  ( q -- adr ) 4 +  ;
: ->DATA ( q -- adr ) 6 +  ;

\ Circular pointer incrementing
: HEAD++ ( q -- )  DUP >R  ->HEAD @ 1+  R@ ->MSK @ AND R> ->HEAD ! ;
: TAIL++ ( q -- )  DUP >R  ->TAIL @ 1+  R@ ->MSK @ AND R> ->TAIL ! ;

: QC@    ( q -- c )
       DUP>R TAIL++
       R@ ->DATA
       R> ->TAIL @ +       \ [data+tail]= adr
       C@ ;                \ fetch the byte

: QC!    ( c q -- )
       DUP>R HEAD++
       R@ ->DATA
       R> ->HEAD @ +       \ [data+head]= adr
       C! ;                \ store the byte

: WRITEQ  ( addr len queue -- )
          -ROT BOUNDS
          ?DO
             I C@ OVER QC!
          LOOP
          DROP ;

: PRINTQ  ( queue -- )
        BEGIN
           DUP 2@ <>   \ 2@ reads head & tail. If not = we have data
        WHILE
           DUP QC@ EMIT
        REPEAT
        DROP ;

\ DEMO code
100 BYTE-QUEUE: QX

: TEST
      BEGIN
        S" Now is the time for all good men..." QX WRITEQ
        QX PRINTQ 3 SPACES
        ?TERMINAL
      UNTIL ;
