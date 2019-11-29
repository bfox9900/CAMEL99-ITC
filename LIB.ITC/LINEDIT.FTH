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

\ : -TRAILING  ( adr len -- adr len') \ remove trailing blanks (spaces)
\               BEGIN
\                 1-           \ shorten length
\                 DUP 0= IF EXIT THEN
\                 2DUP + C@    \ get last char
\                 BL <>        \ test for blank
\               UNTIL          \ until TRUE
\               1+ ;

: -TRAILING  ( adr len -- adr len') \ remove trailing blanks (spaces)
               BEGIN
                 2DUP + C@    \ get last char
                 BL =         \ test for blank
               WHILE
                  1-           \ shorten length
                  DUP 0= IF EXIT THEN
               REPEAT          \ until TRUE
               1+ ;

: (LINE) ( lin# -- addr) LWIDTH * SCR @ BLOCK +  ;
: (CP) ( L1 L2 -- ) (LINE) SWAP (LINE) SWAP LWIDTH CMOVE ;

\ : .LINE  ( lin# --) (LINE) SOL @ + SWID @ TYPE ; ( 40 COL version)
: .LINE  ( lin# --) (LINE) LWIDTH  -TRAILING TYPE ;
: LIST ( blk# -- ) SCR ! 16 0 ?DO   CR I 2 .R  I .LINE   LOOP CR ;

\ Line editor commands
: L  ( blk# --) PAGE DUP ." SCR# "  3 U.R  LIST ;
: EDIT ( -- ) SCR @ L ;  \ list current block
: >> ( -- ) 1 SCR +! EDIT ; \ list next block
: << ( -- ) SCR @ 1- 0 MAX  SCR ! EDIT ;  \ list previous block
: EL ( line# -- ) (LINE) LWIDTH BLANK ; \ erase line
: P  ( line# -- ) DUP EL  0 PARSE ROT (LINE) SWAP CMOVE UPDATE  EDIT ;
: DL ( line# -- )  EL  UPDATE EDIT ;      \ delete line & refresh
: CP ( L1 L2 -- ) (CP) UPDATE EDIT ;      \ copy line & refresh
: ML  ( L1 L2 -- ) OVER >R (CP) R> DL ; \ move line & refresh

\ : R  ( -- ) 28 SOL !  EDIT ;   \ list right side of block
\ : L  ( -- ) SOL OFF   EDIT ;   \ list left side of block

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
