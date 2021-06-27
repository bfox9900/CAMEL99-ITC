\ Minimalist heap memory manager
\ 100 MALLOC VALUE MYBUFFER
\ 100 MFREE 0 TO MYBUFFER

: MALLOC ( n -- addr ) H @  SWAP H +! ;
: MFREE  ( n -- ) NEGATE H +! ;
