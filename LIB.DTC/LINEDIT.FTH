\ Simple line editor for Blocks

NEEDS .S     FROM DSK1.TOOLS
NEEDS BUFFER FROM DSK1.BLOCKS
\ NEEDS 80COLS FROM DSK1.80COL

VARIABLE SCR
VARIABLE SOL
VARIABLE SWID   C/L @ 4 - SWID !

DECIMAL
64 CONSTANT LWIDTH

: BLANK      ( addr len ) BL FILL ;

: -TRAILING  ( adr len -- adr len') \ remove trailing blanks (spaces)
               BEGIN
                 1-           \ shorten length
                 DUP 0= IF EXIT THEN
                 2DUP + C@    \ get last char
                 BL <>        \ test for blank
               UNTIL          \ until TRUE
               1+ ;

: (LINE) ( lin# -- addr) LWIDTH * SCR @ BLOCK +  ;
: (CP) ( L1 L2 -- ) (LINE) SWAP (LINE) SWAP LWIDTH CMOVE ;

\ : .LINE  ( lin# --) (LINE) SOL @ + SWID @ TYPE ; ( 40 COL version)
: .LINE  ( lin# --) (LINE) LWIDTH  -TRAILING TYPE ;
: LIST ( blk# -- ) SCR ! 16 0 ?DO   CR I 2 .R  I .LINE   LOOP  ;

\ Line editor commands
: LS ( blk# --) PAGE DUP ." SCR# "  3 U.R  LIST ;
: ED ( -- ) SCR @ LS ;    \ list current block
: >> ( -- ) 1 SCR +! ED ; \ list next block
: << ( -- ) SCR @ 1- 0 MAX  SCR ! ED ;  \ list previous block
: EL ( line# -- ) (LINE) LWIDTH BLANK ; \ erase line
: P  ( line# -- ) DUP EL  0 PARSE ROT (LINE) SWAP CMOVE UPDATE  ED ;
: DL ( line# -- )  EL  UPDATE ED ;      \ delete line & refresh
: CP ( L1 L2 -- ) (CP) UPDATE ED ;      \ copy line & refresh
: ML  ( L1 L2 -- ) OVER >R (CP) R> DL ; \ move line & refresh

\ : R  ( -- ) 28 SOL !  ED ;   \ list right side of block
\ : L  ( -- ) SOL OFF   ED ;   \ list left side of block

: LOAD  ( n -- )
        SCR !
        16 0
        DO
           I LINES !
           I (LINE) EVALUATE
        LOOP ;

: -->   ( n -- ) SCR @ 1+ LOAD ;
: CLEAR ( blk# -- ) BUFFER B/BUF BLANK  UPDATE ;
: COPY  ( from to -- ) FLUSH  SWAP  BLOCK  CELL-  !  UPDATE ;
