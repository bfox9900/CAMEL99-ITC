\ SAMS memory dump utility
NEEDS @P   FROM DSK1.SAMS
NEEDS MEM@ FROM DSK1.TOOLS

: SDUMP  ['] @P IS MEM@    ['] C@P IS MEMC@ (DUMP) ;
