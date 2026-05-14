\ cmalloc.fth  allocate memory and init zero
TRUE ABORT" Deprecated: now part of DSK1.MALLOC"

 NEEDS MALLOC  FROM DSK1.MALLOC

\ very fast erase using CELLS. see: DSK1.ERASEFAST for source code
\ Moved ERASEW to Kernel V2.8 and called it ERASE
\ HEX
\ CODE ERASEW    C076 , 04F1 , 0644 , 15FD , C136 ,  NEXT,  ENDCODE

\ always allocates an even number of bytes
: CMALLOC   ( n -- addr ) ALIGNED  DUP MALLOC SWAP  2DUP ERASE ;
DECIMAL
