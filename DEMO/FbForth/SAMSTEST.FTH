\ testing read write to SAMS memory SEGMENTS 1 TO 15 only

DECIMAL 16 LOAD

HEX
1000 CONSTANT  4K
6000 CONSTANT 24K

1 SEGMENT  \ select the segment we will use

: SDUMP ( addr n -- ) SWAP PAGED SWAP DUMP ;  \ 4K limits

: ?BREAK   ?TERMINAL  ABORT" *BREAK*" ;

HEX
\ write 24k sequential integers to the segment
: 24KWORDS    24K 0 DO   I  I PAGED !   2 +LOOP ;

\ ERASE 6 4K blocks in 1 second
: 24KERASE    24K 0 DO   I PAGED 4K ERASE   4K +LOOP ;