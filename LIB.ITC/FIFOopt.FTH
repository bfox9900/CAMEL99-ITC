\ Circular byte queue optimized for TSM9900  May 2026 B Fox
\ fifo "first in, first out"

\ about 40% faster than Forth only version (DSK1.FIFO)

HERE
: -POWER-OF-2? ( u -- ? ) DUP 1- AND ; \ "not power of 2"
HEX
: BYTE-QUEUE: ( n -- <text>)
   DUP -POWER-OF-2? ABORT" Queue size must be power of 2"
      CREATE
        0 ,          ( write pointer {TAIL} )
        0 ,          ( read  pointer {HEAD} )
        DUP 1- INVERT ,  ( mask value. Inverted so it works with SZC instruction)
     \ start of q data is base + 3 cells
        HERE SWAP DUP ALLOT ERASE  ( data )
;

\ Circular pointer increments
CODE HEAD++ ( q --  addr)
   C024 , 0002 , \ 2 (TOS) R0 MOV,  \ fetch the HEAD ndx value to R0
   0580 ,        \         R0 INC,  \ advance the ndx by 1
   C064 , 0004 , \ 4 (TOS) R1 MOV,  \ fetch the mask value to R1
   4001 ,        \      R1 R0 SZC,  \ wrap the NDX
   C900 , 0002 , \ R0 2 (TOS) MOV,  \ save the new value in the structure
   A100 ,        \     R0 TOS ADD,  \ add new value to base address
   0224 , 0006 , \ TOS 3 CELLS AI,  \ skip past the header info
   NEXT,
ENDCODE  \ 20 BYTES

CODE TAIL++ ( q --  addr)
   C014 ,        \   *TOS R0 MOV,     \ fetch the TAIL ndx value to R0
   0580 ,        \        R0 INC,     \ advance the ndx by 1
   C064 , 0004 , \   4 (TOS) R1 MOV,  \ fetch the mask value to R1
   4001 ,        \   R1 R0 SZC,       \ wrap the NDX
   C500 ,        \   R0 *TOS MOV,     \ save the new value in the structure
   A100 ,        \   R0 TOS ADD,      \ add new value to base address
   0224 , 0006 , \ TOS 3 CELLS AI,  \ skip past the header info
   NEXT,
ENDCODE  \ 20 BYTES

: QC@    ( q -- c ) TAIL++ C@ ;
: QC!    ( c q -- ) HEAD++ C! ;

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
\ 100 BYTE-QUEUE: QX

\ : TEST
\      100 0
\      DO
\        S" Now is the time for all good men..." QX QPLACE
\        QX QPRINT 3 SPACES
\      LOOP
\ ;
