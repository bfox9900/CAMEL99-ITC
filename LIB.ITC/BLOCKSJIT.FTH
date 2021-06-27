\ blocks.fth  for CAMEL99 Forth     Dec 17 2018 BJFox
\ Based on ideas from HsForth by Jim Kalihan (RIP)
\ Oct 9 2019 reduced compiled size from 930 bytes to 860 (-13%)
\            OPEN-BLOCKS sets active only if successful
\            Added DF128 word, Make blocks uses CREATE-FILE

NEEDS OPEN-FILE  FROM DSK1.ANSFILES
NEEDS .R         FROM DSK1.UDOTR
NEEDS INLINE[    FROM DSK1.INLINE     \ assumes INLINE7.fth
HERE
HEX
3                CONSTANT #BUFF       \ # of active buffers
400              CONSTANT B/BUF
B/BUF 2 CELLS +  CONSTANT B/REC       \ block-record has a 4 byte header

3FFF 1-          CONSTANT LIMIT       \ end of buffer memory
LIMIT B/REC #BUFF * - CONSTANT FIRST  \ first buffer record address

DECIMAL
128 CONSTANT B/SEC     \ bytes per sector on TI disk

VARIABLE PREV      FIRST  PREV !
VARIABLE USE       FIRST  USE  !
VARIABLE LOWBLK
VARIABLE HIGHBLK    78 HIGHBLK !  \ default value
VARIABLE BHNDL                    \ block file handle

DECIMAL
CREATE ACTIVE  20 ALLOT   ACTIVE OFF   \ block file name

\ ===================================================
\ interface to ANS File system
HEX
: ?BLOCKS   ( -- ) BHNDL @ 0= ABORT" No open BLOCK file" ;

\ move file pointer to start of block (One BLOCK= 8 sectors)
: SEEK   ( blk# -- )
         ?BLOCKS  8* BHNDL @ REPOSITION-FILE ABORT" SEEK err" ;

\ READ/WRITE TI records for 1 block
: RBLK  ( adr blk# -- adr)
          SEEK
          DUP B/BUF BOUNDS ( end-addr,start-addr)
          DO  
             I B/SEC BHNDL @ READ-LINE ?FILERR  2DROP   
          B/SEC +LOOP ;

: WBLK  ( adr blk# -- )
          SEEK
          B/BUF BOUNDS ( end-addr,start-addr)
          DO
             I B/SEC BHNDL @ WRITE-LINE ?FILERR
          B/SEC +LOOP ;

\ ===================================================
HEX
: UPDATE ( -- ) INLINE[ PREV @ @   8000 OR  PREV @ ! ]  ;

: +BUF   ( addr1-- addr2)
      INLINE[ B/REC + DUP LIMIT ] =
      IF DROP FIRST THEN ;

: BUFFER ( n -- addr )
    INLINE[ USE @ DUP >R ] \ get current buffer record & Rpush
        @ 0<               \ has it been updated?
        IF                 \ if true ...
           R@ CELL+        \ get buffer address
           R@ @            \ get the block number
      INLINE[ 7FFF AND ]  WBLK  \ write data to disk
        THEN R@ !          \ store this in USE record
        R@ PREV !          \ set it as previous record
        R@ +BUF USE !      \ "use" next buffer
        R> CELL+ ;         \ return the buffer address

: BLOCK   ( block# --- addr )
        ?BLOCKS
       >R
  INLINE[ PREV @ DUP @  R@ - 7FFF AND ]
        IF
           BEGIN
              +BUF INLINE[ DUP PREV @ = ]
              IF
                 DROP R@ BUFFER  R@ RBLK 2- \ CELL-
              THEN
            INLINE[ DUP @ R@ -  7FFF AND ]
           WHILE REPEAT   ( faster than 0= UNTIL)
      INLINE[ DUP PREV ! ]
      INLINE[ DUP USE @ ] =
           IF
              DUP +BUF INLINE[ USE ! ]
           THEN
      THEN
      R> DROP CELL+ ;

HEX
: FLUSH ( -- )
        ?BLOCKS
        FIRST           \ start at 1st block record
        #BUFF 0
        DO
           DUP @ 0<     \ is block updated?
           IF          \ yes, write to disk
              DUP @ 7FFF AND  OVER 2DUP !
              CELL+ SWAP WBLK
           THEN +BUF   \ then goto next block record
        LOOP
        DROP ;

: EMPTY-BUFFERS ( -- )
        FIRST LIMIT OVER - 0 FILL
        #BUFF 0
        DO
          7FFF B/REC I * FIRST + !
        LOOP ;

DECIMAL
: DF128   DISPLAY RELATIVE  B/SEC FIXED ;

: OPEN-BLOCKS ( file$ len -- )
        2DUP
        EMPTY-BUFFERS
        DF128 R/W OPEN-FILE ?FILERR BHNDL !
        ACTIVE PLACE ; \ if successfule store ACTIVE file name

HEX
: CLOSE-BLOCKS ( -- )
       ?BLOCKS FLUSH
       BHNDL @ CLOSE-FILE ?FILERR
       BHNDL OFF
       ACTIVE OFF ;

\ Usage:  45 S" DSK1.MYBLOCKS" MAKE-BLOCKS
:  MAKE-BLOCKS ( n file len -- )
        DF128  R/W  CREATE-FILE ?FILERR BHNDL !
        FIRST CELL+ B/BUF BL FILL
        DUP HIGHBLK !
        1+  1
        DO
           FIRST CELL+ I WBLK
        LOOP
        CLOSE-BLOCKS ;

HERE SWAP - DECIMAL  CR .  .( bytes)
EMPTY-BUFFERS

\ compiling support
DECIMAL
64 CONSTANT LWIDTH
: LINE   ( lin# -- addr) LWIDTH *  SCR @ BLOCK  + ; \ index into block
: LOAD  ( n -- )
        SCR !  LINES OFF
        16 0 DO  I LINES !
                 I LINE LWIDTH EVALUATE
                 LINES 1+!
        LOOP ;

: -->   ( n -- ) SCR @ 1+ LOAD ;

EMPTY-BUFFERS
HERE SWAP - DECIMAL  CR .  .( bytes)
