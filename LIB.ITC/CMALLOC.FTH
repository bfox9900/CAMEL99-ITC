\ cmalloc.fth  allocate memory and init zero
NEEDS MALLOC  FROM DSK1.MALLOC

\ very fast erase using CELLS. see: DSK1.ERASEFAST for source code
HEX
CODE ERASEW    C076 , 04F1 , 0644 , 15FD , C136 ,  NEXT,  ENDCODE

\ always allocates an even number of bytes
: CMALLOC   ( n -- addr ) ALIGNED  DUP MALLOC SWAP  2DUP ERASEW ;
DECIMAL