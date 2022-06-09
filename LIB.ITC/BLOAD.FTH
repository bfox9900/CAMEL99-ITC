\ LOADER.FTH   E/A file loader                  Brian Fox

MARKER /LOADER

NEEDS LOAD-FILE  FROM DSK1.LOADSAVE

: LASTCHAR++  ( Caddr --) COUNT 1- +  1 SWAP C+! ;
: FIELD       ( n -- Vaddr) VP @ SWAP CELLS + ;

: BLOAD  ( addr len -- ?)
           VP @ 2000 13 LOAD-FILE   \ VP default address is VDP>1000
           3 FIELD         \ -- codestart
           2 FIELD V@      \ -- codestart addr )
           1 FIELD V@      \ -- codestart addr size)
           VREAD           \ read VDP RAM to CPU RAM
           0 FIELD V@      \ return the multi-file flag
;

: LOADER  ( addr len -- )
  BEGIN  2DUP BLOAD  WHILE LASTCHAR++  REPEAT 2DROP ;
