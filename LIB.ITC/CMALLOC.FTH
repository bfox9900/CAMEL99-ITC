\ cmalloc.fth  allocate memory and init zero
NEEDS MALLOC  FROM DSK1.MALLOC

: CMALLOC   ( n -- addr )  DUP MALLOC TUCK 0 FILL ;
