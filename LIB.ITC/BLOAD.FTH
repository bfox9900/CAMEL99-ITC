\ LOADER.FTH  Loads a E/A file or files into RAM              Brian Fox
\ Does not run the program. At this stage.

NEEDS LOAD-FILE  FROM DSK1.LOADSAVE

HEX
: LASTCHAR++  ( Caddr --) COUNT 1- +  1 SWAP C+! ;
: HEADER      ( n -- Vaddr) VP @ SWAP CELLS + ; \ access file header fields

: VLOAD  ( addr len -- ) \ Load program image into VRAM
     NEWPAB       \ create a temporary PAB
     VP @  2000  13  5 FILEOP     \ read 8K bytes into VDP RAM (VP= >1000)
     30 ^PAB +!   \ free the PAb
;

: BLOAD  ( addr len -- ?) \ ? is the multi-file flag
     VLOAD
\    VDP Addr    addr         size
     VP @     2 HEADER V@   1 HEADER V@ VREAD \ read VDP RAM to CPU RAM
     0 HEADER V@
;

: LOADER  ( addr len -- )
   BEGIN
     2DUP BLOAD ( ?)
   WHILE
     LASTCHAR++
   REPEAT
   2DROP ;
