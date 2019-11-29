\ QUEUES    Sep 14 2019  B Fox

NEEDS DUMP   FROM DSK1.TOOLS

HEX

: BYTEQ:  ( n -- )   \ must be power of 2
\               TAIL  HEAD
         CREATE  0 ,   0 ,  ALLOT  ;



\ circular BYTE Q access words
: Q+!    ( fifo -- n)  DUP @ 2+ 1F AND DUP ROT ! ;
: QC@     ( fifo -- n) DUP Q+! + C@ ;  \ bump tail and fetch data
: QC!     ( n fifo --) SHEAD Q+! + C! ;  \ bump head and add to FIFO
: Q?     ( fifo -- ?) 2@ <> ;              \ is data ready?

