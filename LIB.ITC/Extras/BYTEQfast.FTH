( Circular byte queue for general purpose stuff  21MAR94 FOX )
( Uses power of 2 size buffers only!.  2 4 8 16 32 64 etc. )
( Ported to Camel99 forth  11JUN2020, revised for ISO compliance June 13 2022 )
( Re-write in Assembler. It's 30% smaller and 20% faster. )

HERE
: ?PO2 ( n --) DUP 1- AND ABORT" Not power of 2" ;

HEX
: BYTEQ: ( n -- <text>)
    DUP ?PO2
    CREATE
        0 ,          ( write pointer {TAIL} )
        0 ,          ( read  pointer {HEAD} )
        DUP 1- ,     ( mask value    )
        ALLOT        ( data field    )
;

\ Circular pointers, head & tail calculators
HEX
CODE 'HEAD ( q -- addr) \ TOS holds base address of structure
0594 ,        \ *TOS INC,        \ bump head index
C024 , 0004 , \ 4 (TOS) R0 MOV,  \ mask for this channel to R0
0540 ,        \ R0 INV,          \ invert the mask
4500 ,        \ R0 *TOS SZC,     \ logical and
A114 ,        \ *TOS TOS ADD,    \ add the ndx to the base address
0224 , 0006 , \ TOS 6 AI,        \ add data field ofset
   NEXT,
ENDCODE

CODE 'TAIL ( q -- addr)
05A4 , 0002 , \ 2 (TOS) INC,
C024 , 0004 , \ 4 (TOS) R0 MOV,
0540 ,        \ R0 INV,
4900 , 0002 , \ R0 2 (TOS) SZC,
A124 , 0002 , \ 2 (TOS) TOS ADD,
0224 , 0006 , \ TOS 6 AI,
      NEXT,
ENDCODE

\ API
: QMORE? ( q -- ?) 2@ <> ;      \ is there room in the queue
: CLEARQ ( q -- ) 0 0 ROT 2! ;
: QC!    ( c q -- ) 'HEAD  C! ; \ store the byte
: QC@    ( q -- c ) 'TAIL  C@ ; \ fetch the byte

HERE SWAP - CR DECIMAL .  .( bytes)

\ --------------------------------
\ demo code
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
         DUP 2@ - ABS
      WHILE
         DUP QC@ EMIT
      REPEAT
      DROP ;

\ DEMO code
 DECIMAL 256 BYTEQ: Q1

: FILLQ
   BEGIN
      13 Q1 QC!
      S" Now is the time for all good men...  "  Q1 WRITEQ
    UNTIL
;

: TEST
    10 0 DO
       PAGE
       FILLQ
       CR Q1 PRINTQ
    LOOP
;
