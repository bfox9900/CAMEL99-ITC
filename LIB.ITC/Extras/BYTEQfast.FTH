( Circular byte queue for general purpose stuff  21MAR94 FOX )
( Uses power of 2 size buffers only!.  2 4 8 16 32 64 etc. )
( Ported to Camel99 forth  11JUN2020, revised for ISO compliance June 13 2022 )
( Re-write in Assembler. It's smaller and 3x faster. )

 NEEDS DUMP    FROM DSK1.lowTOOLS

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

\ Circular pointer incrementing
\ this word replaces HEAD++  and HEAD
HEX
CODE 'HEAD ( q -- addr) \ TOS holds base address of structure
0594 ,        \ *TOS INC,
C024 , 0004 , \ 4 (TOS) R0 MOV,  \ mask for this channel to R0
0540 ,        \ R0 INV,          \ invert the mask
4500 ,        \ R0 *TOS SZC,     \ logical and
A114 ,        \ *TOS TOS ADD,    \ add the ndx to the data address
0224 , 0006 , \ TOS 6 AI,        \ index to the data field
   NEXT,
ENDCODE

CODE 'TAIL ( q -- addr) \ tos holds base address of structure
05A4 , 0002 ,  \ 2 (TOS) INC,      \ bump tail index
C024 , 0004 , \  4 (TOS) R0 MOV,    \ fetch mask for this channel to R0
0540 ,        \  R0 INV,
4900 , 0002 , \  R0 2 (TOS) SZC,    \ logical AND masks index
A124 , 0002 , \  2 (TOS) TOS ADD,
0224 , 0006 , \  TOS 6 AI,
      NEXT,
ENDCODE


\ Circular pointer incrementing
: QMORE? ( q -- ?) 2@ <> ;

: QC!    ( c q -- ) 'HEAD  C! ; \ store the byte
: QC@    ( q -- c ) 'TAIL  C@ ; \ fetch the byte

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
 DECIMAL 256 BYTEQ: Q1

: FILLQ
   13 Q1 QC!  \ write a CR into Q1
   S" Now is the time for all good men...  "  Q1 WRITEQ
   S" to come to the aid of their country.  " Q1 WRITEQ
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
