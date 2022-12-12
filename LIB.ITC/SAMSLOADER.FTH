\ SAMSLOADER.FTH   E/A file loader for CAMEL99 Forth  Nov 2022 Brian Fox

MARKER /LOADER
NEEDS FAR:       FROM DSK1.SAMSCODE
NEEDS LOAD-FILE  FROM DSK1.LOADSAVE

HEX 1000 VP !  \ beginning of free VDP RAM

\ define the file header fields in *VDP RAM*
VP @             CONSTANT MULTIFLAG
VP @   1 CELLS + CONSTANT PROGSIZE
VP @   2 CELLS + CONSTANT LOADADDR

VP @   3 CELLS + CONSTANT CODEBUFF    \ COPY 8K program chunks to here

              13 CONSTANT PROG     \ file mode for Program files
            1000 CONSTANT 4K
            3000 CONSTANT CSEG

: LASTCHAR++  ( Caddr --) 1- +  1 SWAP C+! ;

: HEADER  ( addr size ?) \ store header info in VDP RAM
    MULTIFLAG V!  PROGSIZE V!  LOADADDR V! ;

CREATE FILE$   20 ALLOT
: FILENAME ( -- addr len)  FILE$ COUNT ;


: SAMSAVE  ( page# -- )
      CR ." Writing SAMS page " .  ." to "  FILENAME TYPE
      PROG SAVE-FILE
      FILENAME LASTCHAR++
;

: SAVE-SAMS ( $adr len 1st last  -- )
     2SWAP FILE$ PLACE
     1+ SWAP
     DO
         I CMAP
        \ loadaddr     size       multiflag
          CSEG   4K 3 CELLS +   I _MAXBANK <> HEADER

          LOADADDR V@  CODEBUFF  PROGSIZE V@  VWRITE
          FILENAME      VP @     PROGSIZE V@  I SAMSAVE
     LOOP ;

\ sams loader --------------------------------------------------
: SLOAD  ( page# -- ?)     \ 4K max code size. FILE$ must be set
          CMAP
          FILENAME VP @  4K 6 + PROG LOAD-FILE   \ read into VDP RAM
          CODEBUFF  CSEG  PROGSIZE V@ 6 - VREAD  \ read VDP to CPU RAM
          FILENAME LASTCHAR++
          MULTIFLAG V@           \ return the multi-file flag
;

: LOAD-SAMS  ( addr len 1stpage -- )
          >R
          FILE$ PLACE
          BEGIN
             R@ SLOAD
          WHILE
            R> 1+ >R
          REPEAT
          R> DROP
;

\ TEST TOOLS
HEX
: FILLSAMS   100 0F0 DO  I CMAP  CSEG 4K I FILL  LOOP ;
: CLEARSAMS  100 0F0 DO  I CMAP  CSEG 4K 0 FILL   LOOP ;
