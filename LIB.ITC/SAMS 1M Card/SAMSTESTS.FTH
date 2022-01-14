\ testing read write speeds to SAMS memory

NEEDS DUMP   FROM DSK1.TOOLS
NEEDS ELAPSE FROM DSK1.ELAPSE

HEX
7FFF CONSTANT 32K
FFFF CONSTANT 64K
1000 CONSTANT 4K

: ERASE    0 FILL ;
: BLANKS  BL FILL ;

VARIABLE SEG  10 SEG !

\ 64k single byte writes to paged memory

VARIABLE X
: 64KWRITE
     0 SEG @
     BEGIN
      X @  DUP SEG @ !L
      2 M+  \ bump the address
      X 1+! \ bump x
      X @ -1 =
    UNTIL ;
