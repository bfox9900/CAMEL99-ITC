( Circular byte queue for general purpose stuff  21MAR94 FOX )
( Uses power of 2 size buffers only!.  2 4 8 16 32 64 etc.
( Ported to Camel99 forth  11JUN2020, revised for ISO compliance June 13 2022 )

: ?POT ( n --) DUP 0> SWAP DUP 1- AND AND  ABORT" Not power of 2" ;  

HEX
: BYTEQ: ( n -- <text>)
    DUP ?POT 
    CREATE
        0 ,          ( write pointer {TAIL} )
        0 ,          ( read  pointer {HEAD} )
        DUP 1- ,     ( mask value    )
        ALLOT        ( data field    )
;

(Field offsets to the Queue data structure )
: ->HEAD ( q -- adr )      ;  \ syntax sugar
: ->TAIL ( q -- adr ) [ 1 CELLS ] LITERAL + ;
: ->MSK  ( q -- adr ) [ 2 CELLS ] LITERAL + ;
: ->DATA ( q -- adr ) [ 3 CELLS ] LITERAL + ;

\ Circular pointer incrementing
: HEAD++ ( q -- )  DUP>R ->HEAD @ 1+  R@ ->MSK @ AND R> ->HEAD ! ;
: TAIL++ ( q -- )  DUP>R ->TAIL @ 1+  R@ ->MSK @ AND R> ->TAIL ! ;
: QMORE? ( q -- ?) 2@ <> ; 

: QC@    ( q -- c )
       DUP>R TAIL++
       R@ ->DATA R> ->TAIL @ +  \ [data+tail]= adr
       C@ ;                     \ fetch the byte

: QC!    ( c q -- )
       DUP>R HEAD++
       R@ ->DATA R> ->HEAD @ +  \ [data+head]= adr
       C! ;                     \ store the byte

: WRITEQ  ( addr len queue -- )
          -ROT BOUNDS
          ?DO
             I C@ OVER QC!
          LOOP
          DROP ;

: PRINTQ  ( queue -- )
        BEGIN
           DUP QMORE? 
        WHILE
           DUP QC@ EMIT
        REPEAT
        DROP ;

\ DEMO code
\ DECIMAL 256 BYTEQ: Q1
\ : TEST
\      BEGIN
\        S" Now is the time for all good men..." Q1 WRITEQ
\        S" to come to the aid of their country." Q1 WRITEQ
\        Q1 PRINTQ 3 SPACES
\        KEY?
\      UNTIL ;
