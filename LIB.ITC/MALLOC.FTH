\ Minimalist heap memory manager  Updated mAY 2026 B Fox

\ 100 MALLOC VALUE MYBUFFER
\ MYBUFFER SIZEOF MFREE  0 TO MYBUFFER

: HEAP   ( -- addr) H @ ;
: HALLOT ( n --) H +! ;
: H,     ( n --) HEAP !  2 HALLOT ;

\ Allocates even number of bytes
: MALLOC  ( n -- addr ) ALIGNED DUP H, HEAP  SWAP HALLOT ;
: SIZEOF  ( addr -- u) 2- @ ;  \ 9900 cell size is 2
: MFREE   ( n -- ) NEGATE H +! ;
