\ LOADER.FTH   E/A file loader for CAMEL99 Forth      Brian Fox Jan 28 2021

NEEDS MARKER     FROM DSK1.MARKER 

MARKER /LOADER

NEEDS LOAD-FILE  FROM DSK1.LOADSAVE

: LASTCHAR++  ( Caddr --) COUNT 1- +  1 SWAP C+! ;
: FIELD       ( n -- Vaddr) VP @ SWAP CELLS + ;

2000 CONSTANT DATASEG
: BLOAD  ( addr len -- ?)
  VP @ DATASEG 13 LOAD-FILE   \ VP default address is VDP>1000
  3 FIELD         \ -- codestart
  2 FIELD V@      \ -- codestart addr )
  1 FIELD V@      \ -- codestart addr size)
  VREAD           \ read VDP RAM to CPU RAM
  0 FIELD V@      \ return the multi-file flag
;

: LOADER  ( addr len -- )
  BEGIN
    2DUP BLOAD
  WHILE
    LASTCHAR++
    REPEAT
  2DROP ;

E000 CONSTANT CODESEG
: CODELOAD  ( addr len page# -- ?)    \ 4K max code size
  VP @ CODESEG 13 LOAD-FILE   \ VP default address is VDP>1000
  3 FIELD         \ -- codestart
  2 FIELD V@      \ -- codestart addr )
  1 FIELD V@      \ -- codestart addr size)
  VREAD           \ read VDP RAM to CPU RAM
  0 FIELD V@      \ return the multi-file flag
;

\ : SAMSLOAD  ( addr len -- ) \ idea: needs SAMSCODE with CMAP 
\   F0 >R
\   BEGIN
\     R@ CMAP
\     2DUP CODELOAD 
\   WHILE
\     LASTCHAR++
\   REPEAT
\   R> DROP
\   2DROP ;
