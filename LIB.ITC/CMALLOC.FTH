\ cmalloc.fth  allocate memory and init zero
NEEDS MALLOC  FROM DSK1.MALLOC

: CMALLOC   ( n -- addr )  DUP MALLOC SWAP 2DUP 0 FILL ;
