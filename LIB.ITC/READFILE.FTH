\ READ-FILE to VDP RAM for CAMEL99 Forth
\ It's your job to move the data where you want it :-)

NEEDS .S        FROM DSK1.TOOLS
NEEDS READ-LINE FROM DSK1.ANSFILES

HEX
: READ-REC    (  -- vadr len) 2 FILEOP ?FILERR [PAB FBUFF] V@ [PAB CHARS] VC@ ;

  0D CONSTANT ^M         \ carriage return
  1A CONSTANT ^Z         \ end of Text file marker

1138 CONSTANT REC#1      \ Free VDP ram after pattern table
2500 CONSTANT MEM-SIZE   \ 9,472 bytes is largest file

: NEXT-BUFFER ( vadr len -- ) + 1+ [PAB FBUFF] V! ;

: READ-FILE  ( $addr len mode -- ior)
             REC#1 MEM-SIZE ^M VFILL     \ fill space with
             OPEN-FILE ?FILERR  >R
             REC#1 [PAB FBUFF] V!        \ set VDP buffer address
             BEGIN
                R@ EOF 0=
             WHILE
                READ-REC
                NEXT-BUFFER
             REPEAT
             R> CLOSE-FILE ;

VARIABLE TOPLINE
: TEST ( $addr len  -- ior)
       TOPLINE OFF
       400 DUP MALLOC >R      \ screen buffer
       DV80 S" DSK1.GRAFIX" R/O READ-FILE
       BEGIN
          REC#1 TOPLINE @ +  R@ 3C0 VREAD \ to RAM
          R@  0 3C0 VWRITE    \ draw ram to screen mem
          3C0 TOPLINE +!
          KEY DROP
          ?TERMINAL
       UNTIL
       R> DROP
       MFREE  ;


