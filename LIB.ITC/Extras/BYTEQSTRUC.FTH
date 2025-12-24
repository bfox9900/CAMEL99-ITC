( Circular byte queue using structure words Dec 2025)
( This version is safer as it counts bytes in and out)

NEEDS DUMP    FROM DSK1.TOOLS
NEEDS FIELD:  FROM DSK1.STRUC12

HERE
\ Queue data structure
0
FIELD: ->HEAD
FIELD: ->TAIL
FIELD: ->COUNT
FIELD: ->SIZE
FIELD: ->MSK
FIELD: ->DATA
CONSTANT QHEADER \ size of the header

: ?PO2 ( n --) DUP 1- AND ABORT" Not power of 2" ;

HEX
: BYTEQ: ( n -- <text>)
    DUP ?PO2
    CREATE
        0 ,       ( write pointer {head} )
        0 ,       ( read  pointer {tail} )
        0 ,       ( counter )
        DUP ,     ( Q size)
        DUP 1- ,  ( mask value    )
        ALLOT     ( allocate n bytes for data)
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

\ API
: CLEARQ  ( q -- )  3 CELLS  0 FILL ;
: QROOM?  ( q -- ?) DUP ->COUNT @ SWAP ->SIZE @ 1- <> ;

: QC!    ( c q -- ) DUP>R 'HEAD C!    R> ->COUNT 1+! ;  \ store the byte at head
: QC@    ( q -- c ) DUP   'TAIL C@  SWAP ->COUNT 1-! ;  \ fetch the byte at tail

HERE SWAP - CR DECIMAL . .( bytes)

\ ================================
\ DEMO code

: QPLACE  ( addr len queue -- ?)
\ ? = 0 means everthing went into the queue
   >R
   BEGIN
      R@ QROOM?
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
      DUP ->COUNT @
   WHILE
      DUP QC@ EMIT
   REPEAT
   DROP ;

 DECIMAL 256 BYTEQ: Q1

: FILLQ
   Q1 CLEARQ
   BEGIN
      13 Q1 QC!  ( CR put into queue)
      S" Now is the time for all good men...  " Q1 QPLACE
   UNTIL
;

: TEST
   PAGE
   BEGIN
      CR CR ." Filling..."
      FILLQ
      CR Q1 PRINTQ
      ?TERMINAL
   UNTIL
;
