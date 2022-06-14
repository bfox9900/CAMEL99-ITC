\ Simple integer QUEUE   Sep 14 2019  B Fox
\ can be used for bytes but wastes some space

\ NEEDS DUMP   FROM DSK1.TOOLS  \ debugging 

\ all FIFOs will be the same length. 
\ Must be power of 2: HEX 400,200,100,80,40,20,10

100 CONSTANT QSIZE
QSIZE 1- CONSTANT QMASK 

HEX
: FIFO:  ( -- )  
\               TAIL  HEAD
         CREATE  0 ,   0 ,  QSIZE CELLS ALLOT  ;

\ circular BYTE Q access words
: Q+!    ( fifo -- n) DUP @ CELL+  QMASK AND DUP ROT ! ;
: Q@     ( fifo -- n) DUP Q+! + CELL+ @ ;        \ bump tail and fetch data
: Q!     ( n fifo --) DUP CELL+ Q+! + CELL+ ! ;  \ bump head and add to FIFO
: Q?     ( fifo -- ?) 2@ <> ;                    \ is data ready?

FIFO: QQ

: LOADQ  ( ADR LEN -- )
        BOUNDS
        DO
           I C@  QQ Q!
        LOOP ;


: PRINTQ  BEGIN
             QQ Q?
          WHILE
             QQ Q@ EMIT
          REPEAT ;
