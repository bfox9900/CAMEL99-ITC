\ VIRTUAL MEMORY LOADDV80/SAVEDV80

NEEDS FIDS   FROM DSK1.ANSFILES
NEEDS BLOCKS FROM DSK1.BLOCKS
NEEDS -TRAILING FROM DSK1.TRAILING

DECIMAL
128 CONSTANT RECSIZE
 79 CONSTANT WIDTH      \ SCREEN WIDTH = 80 cols

DECIMAL
CREATE FILENAME  32 ALLOT
 S" DSK1.UNTITLED"  FILENAME PLACE

\ compute address of 128 byte record in any block(n)
: ]RECORD  ( n -- addr) RECSIZE * B/BUF /MOD BLOCK + ;

: SWAPFILE ( -- addr len) S" DSK3.$$$$SWAP" ;

: ?OPENERR ( n -- ) ?DUP IF . TRUE ABORT" Open error" THEN ;
: ?R/WERR  ( n -- ) ?DUP IF . TRUE ABORT" R/W error" THEN ;
: ?CLOSERR ( N -- ) ?DUP IF . TRUE ABORT" Close error" THEN ;

VARIABLE LASTBLOCK
VARIABLE LASTLINE

: >LASTBLOCK ( linecnt -- ) RECSIZE * B/BUF / 1+  LASTBLOCK ! ;

: ERASE-SWAPFILE
      LASTBLOCK @ 0
      ?DO
        I BLOCK B/BUF 0 FILL UPDATE
      LOOP
      FLUSH
      LASTLINE OFF
;

\ Load DV80 file into virtual memory file
\ count # of lines (LASTLINE)
\ compute last block of virtual memory (LASTBLOCK)
DECIMAL
: LOADDV80 ( addr len -- )
       DUP ?FILE
       2DUP FILENAME PLACE
       DV80 R/O OPEN-FILE ?OPENERR >R
       LASTLINE OFF
       BEGIN
          LASTLINE @ ]RECORD 
          DUP WIDTH 0 FILL
          WIDTH R@ READ-LINE ?R/WERR NIP ( -- ?)
          LASTLINE 1+!
          UPDATE
       WHILE REPEAT
       FLUSH
       R> CLOSE-FILE ?CLOSERR
       LASTLINE @ >LASTBLOCK
;

\ ===================================================
\ TI-99 file sys. needed me to fill blocks with zeros
\ therefore we have to write to file minus ZEROS.
\ *** IT DID NOT WORK WITH SPACES AS FILLER ***
: -ZEROS   2DUP 0 SCAN NIP - ;  \ SCAN is fast ASM

VARIABLE SH ( save handle )
: SAVEDV80
      DUP ?FILE
      DV80 R/W OPEN-FILE ?OPENERR SH !
      CR
      LASTLINE @ 0
      DO
        I ]RECORD WIDTH -ZEROS SH @ WRITE-LINE ?R/WERR
      LOOP
      SH @ CLOSE-FILE ?CLOSERR
;

\ test code
: VIEW ( -- )
      CR
      LASTLINE @ 0
      ?DO
         CR I ]RECORD WIDTH -TRAILING TYPE
         ?TERMINAL ABORT" VIEW halted"
      LOOP
;

SWAPFILE OPEN-BLOCKS 

