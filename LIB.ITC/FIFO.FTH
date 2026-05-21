( Circular byte queue for general purpose stuff  21MAR94 FOX )
( Ported to Camel99 forth  11JUN2020 )
\ fifo "first in, first out"
HERE
HEX
: BYTE-QUEUE: ( n -- <text>)
      DUP 1- AND ABORT" Queue size must be power of 2"
      CREATE
        0 ,          ( write pointer {TAIL} )
        0 ,          ( read  pointer {HEAD} )
        DUP 1- ,     ( mask value    )
        ALLOT        ( data          )
;

( Pointers to the Queue data structure )
\ change to text macros for speedup
: ->TAIL ( q -- adr ) ; IMMEDIATE
: ->HEAD              S" 2+" EVALUATE ; IMMEDIATE
: ->MSK  ( q -- adr ) S" 4 +" EVALUATE ; IMMEDIATE
: ->DATA ( q -- adr ) S" 6 +" EVALUATE ; IMMEDIATE

\ Circular pointer incrementing
: HEAD++ ( q -- addr)
      DUP>R ->HEAD @       \ get ndx,
      1+                   \ add 1
      R@ ->MSK @ AND       \ get mask. mask ndx value
      DUP R@ ->HEAD !      \ update tail field
      R> +                 \ add ndx to base address
      ->DATA ;             \ skip past the header field


: TAIL++ ( q --  addr)
      DUP>R ->TAIL @       \ get ndx,
      1+                   \ add 1
      R@ ->MSK @ AND       \ get mask. mask ndx value
      DUP R@ ->TAIL !      \ update tail field
      R> +                 \ add to base address
      ->DATA ;             \ skip past the header field

: QC@    ( q -- c ) TAIL++  C@ ;          \ fetch the byte
: QC!    ( c q -- ) HEAD++  C! ;

: QPLACE ( addr len queue -- ) \ same stack pic. as PLACE
      -ROT BOUNDS ?DO  I C@ OVER QC!  LOOP DROP ;

: QPRINT  ( queue -- ) \ print until Q is empty
        BEGIN
           DUP 2@ <>   \ 2@ reads head & tail. If not = we have data
        WHILE
           DUP QC@ EMIT
        REPEAT
        DROP ;
HERE SWAP -
DECIMAL CR . .( bytes )


\ DEMO code
\ HEX
\ 100 BYTE-QUEUE: QX

\ : TEST
\      100 0
\      DO
\        S" Now is the time for all good men..." QX QPLACE
\        QX QPRINT 3 SPACES
\      LOOP
\ ;
