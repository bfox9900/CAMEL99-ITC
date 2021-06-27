\ Simple line editor for Blocks

NEEDS .S     FROM DSK1.TOOLS
NEEDS BUFFER FROM DSK1.BLOCKS
NEEDS -TRAILING FROM DSK1.TRAILING
NEEDS VTYPE  FROM DSK1.VTYPE

VARIABLE SCR
VARIABLE SOL


DECIMAL
64 CONSTANT LWIDTH

: BLANKS  ( addr len ) BL FILL ;
: BLKLINE ( lin# -- addr) LWIDTH * SCR @ BLOCK +  ;
: SCRLN   ( n -- vaddr ) C/L@ * TOPLN  + ;
: (LINE)  ( n -- addr len ) BLKLINE SOL @ + OVER C/L@ -TRAILING  ;
\ : .LINE   ( lin# --)
\     (LINE) SOL @ +  (SCRLN)  C/L@ -TRAILING VTYPE ;
\ displays partial line on screen. Set SOL to see more of the line.
: LIST ( -- )
        2 SCRLN     \ screen line, VDP address where text begins
        16 0
        DO
           I (LINE) VWRITE
           C/L@ +
        LOOP
        DROP
        0 18 AT-XY ;

\ Line editor commands
: L  ( blk# --)  DUP SCR !  PAGE  ." SCR# "   3 U.R  LIST ;

: RS  ( -- ) LWIDTH C/L@ - SOL ! SCR @ L ;   \ list right side of block
: LS  ( -- ) SOL OFF  SCR @ L ;   \ list left side of block

: EDIT ( -- ) SCR @ L ;  \ list current block

: >> ( -- ) 1 SCR +! EDIT ; \ list next block
: << ( -- ) SCR @ 1- 0 MAX  SCR ! EDIT ;  \ list previous block
: EL ( line# -- ) (LINE) LWIDTH BLANK ;   \ erase line
: P  ( line# -- ) DUP EL  0 PARSE ROT (LINE) SWAP CMOVE UPDATE  EDIT ;
: DL ( line# -- )  EL  UPDATE EDIT ;      \ delete line & refresh
: CP ( L1 L2 -- ) (CP) UPDATE EDIT ;      \ copy line & refresh
: ML  ( L1 L2 -- ) OVER >R (CP) R> DL ;   \ move line & refresh

: LOAD  ( n -- )
        SCR !
        16 0
        DO
           I LINES !
           I (LINE) EVALUATE
        LOOP ;

: -->   ( n -- ) SCR @ 1+ LOAD ;
: CLEAR ( blk# -- ) BUFFER B/BUF BLANK  UPDATE ;
: COPY  ( from to -- ) FLUSH  SWAP  BLOCK  2- !  UPDATE ;
