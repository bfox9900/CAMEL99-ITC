( Circular byte queue for general purpose stuff  21MAR94 FOX )
( Uses power of 2 size buffers only.  2 4 8 16 32 64 etc. )
( Ported to Camel99 forth  11JUN2020)
( Re-write using structure words DEc 2025)

\ NEEDS DUMP    FROM DSK1.TOOLS
NEEDS FIELD:  FROM DSK1.STRUC12

HERE
\ Queue data structure
0
FIELD: ->HEAD
FIELD: ->TAIL
FIELD: ->MSK
FIELD: ->DATA
CONSTANT QHEADER \ size of the header

: ?PO2 ( n --) DUP 1- AND ABORT" Not power of 2" ;

HEX
: BYTEQ: ( n -- <text>)
    DUP ?PO2
    CREATE
        0 ,          ( write pointer {head} )
        0 ,          ( read  pointer {tail} )
        DUP 1- ,     ( mask value    )
        ALLOT   ( header size + data space)
;

\ Circular pointer incrementing head & tail
: 'HEAD ( q -- addr)
      DUP ->HEAD DUP>R     \ get head field addr and save a copy
      @ 1+                 \ fetch head ndx and inc.
      OVER ->MSK @ AND     \ fetch mask and wrap ndx
      DUP R> !             \ DUP new head ndx & store in head field
      SWAP ->DATA + ;      \ advance to data addr and add ndx

: 'TAIL ( q -- addr)
      DUP ->TAIL DUP>R     \ get tail field addr and save a copy
      @ 1+                 \ fetch tail ndx and inc.
      OVER ->MSK @ AND     \ fetch mask and wrap ndx
      DUP R> !             \ DUP new tail ndx & store in tail field
      SWAP ->DATA  + ;     \ advance to data addr and add ndx


: CLEARQ  ( q -- ) 0 0 ROT 2! ;
: QMORE?  ( q -- ?) 2@ <> ;
: QC!    ( c q -- ) 'HEAD C! ;  \ store the byte at head
: QC@    ( q -- c ) 'TAIL C@ ;  \ fetch the byte at tail

HERE SWAP - CR DECIMAL . .( bytes)
\ /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

\ DEMO code

: WRITEQ  ( addr len queue -- ?) \ ?=0 means all good
   >R
   BEGIN
      R@ QMORE?
   WHILE
      OVER C@  R@ QC!
      1 /STRING
   DUP WHILE
   REPEAT
   THEN
   R> DROP
   NIP ;

: PRINTQ  ( queue -- )
      BEGIN
         DUP QMORE?
      WHILE
         DUP QC@ EMIT
      REPEAT
      DROP ;

 DECIMAL 256 BYTEQ: Q1

: FILLQ
   13 Q1 QC!  \ write a CR into the queue
   S" Now is the time for all good men...  "  Q1 WRITEQ ?ERR
   S" to come to the aid of their country.  " Q1 WRITEQ ?ERR
   13 Q1 QC!
;

: SEEQ   Q1 PRINTQ ;

: TEST
    BEGIN
       FILLQ FILLQ FILLQ
       CR SEEQ
       ?TERMINAL
    UNTIL
;
