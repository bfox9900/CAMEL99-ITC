\ QUEUES    Sep 14 2019  B Fox

NEEDS DUMP   FROM DSK1.TOOLS

HEX
: FIFO:  ( n -- )   \ must be power of 2
\               TAIL  HEAD
         CREATE  0 ,   0 ,  CELLS ALLOT  ;

\ circular BYTE Q access words
: Q+!    ( fifo -- n) DUP @ 2+ 1F AND DUP ROT ! ;
: Q@     ( fifo -- n) DUP Q+! + CELL+ @ ;  \ bump tail and fetch data
: Q!     ( n fifo --) DUP CELL+ Q+! + CELL+ ! ;  \ bump head and add to FIFO
: Q?     ( fifo -- ?) 2@ <> ;              \ is data ready?

100 FIFO: QQ

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
