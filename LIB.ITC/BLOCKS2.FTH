\ BLOCKSFAST.FTH  for CAMEL99 Forth     APR 28 2021 Brian Fox
\ Moved management fields into dictionary memory
\ Use simple FIFO  rather than last used algorythm

**NOTDONE***

NEEDS OPEN-FILE  FROM DSK1.ANSFILES
NEEDS .R         FROM DSK1.UDOTR

HEX
4                CONSTANT #BUFF       \ # of active buffers
400              CONSTANT B/BUF
3000             CONSTANT FIRST  \ first buffer record address
B/BUF #BUFF * FIRST + CONSTANT LIMIT       \ end of buffer memory

VARIABLE PREV      FIRST  PREV !
VARIABLE USE       FIRST  USE  !

\ create a 16 cell fifo to feed the sound player
VARIABLE BHEAD
VARIABLE BTAIL

\ blockq is an array of
CREATE BLOCKS   0 , 0 , 0 , 0 ,

\ circular Q access words
: BQ+!    ( fifo -- n) DUP @ 2+ 3 AND DUP ROT ! ;
: BQ@     ( fifo -- n) BTAIL BQ+! + @ ;      \ bump tail and fetch data
: BQ!     ( n fifo --) BHEAD Q+!  + ! ;      \ bump head and add to FIFO
: BQ?     ( fifo -- ?) BHEAD @ BTAIL @ <> ; \ is data ready?


DECIMAL
128 CONSTANT B/SEC     \ bytes per sector on TI disk
VARIABLE HIGHBLK    79 HIGHBLK !  \ default value
VARIABLE BHNDL                    \ block file handle

DECIMAL
CREATE ACTIVE  20 ALLOT   ACTIVE OFF   \ block file name

\ ===================================================
\ interface to ANS File system
HEX
: ?BLOCKS   ( -- ) BHNDL @ 0= ABORT" No open BLOCK file" ;
CODE MASK   ( n -- n)  0244 , 7FFF ,   NEXT, ENDCODE \ TOS 7FFF ANDI,

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

: UPDATE ( -- ) PREV @ @   8000 OR  PREV @ ! ;

: +BUF   ( addr1-- addr2)
         B/REC + DUP LIMIT = IF DROP FIRST THEN ;


: BUFFER ( n -- addr )
        USE @ DUP>R       \ get current buffer record & Rpush
        @ 0<               \ has it been updated?
        IF                 \ if true ...
           R@ CELL+        \ get buffer address
           R@ @            \ get the block number
           MASK WBLK       \ write data to disk
        THEN R@ !          \ store this in USE record
        R@ PREV !          \ set it as previous record
        R@ +BUF USE !      \ "use" next buffer
        R> CELL+ ;         \ return the buffer address

: BLOCK   ( block# --- addr )
        ?BLOCKS
       >R
        PREV @ DUP @  R@ - MASK
        IF
           BEGIN
              +BUF DUP PREV @ =
              IF
                 DROP R@ BUFFER  R@ RBLK 2- \ CELL-
              THEN
              DUP @ R@ -  MASK
           WHILE REPEAT   ( faster than 0= UNTIL)
           DUP PREV !
           DUP USE @ =
           IF
              DUP +BUF USE !
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
              DUP @ MASK  OVER 2DUP !
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
VARIABLE SCR
64 CONSTANT #64
: LINE   ( line# -- addr) #64 *  SCR @ BLOCK  + ; \ index into block
: LOAD  ( n -- )
        SCR !  LINES OFF
        16 0 DO  I LINES !
                 I LINE #64 EVALUATE
                 LINES 1+!
        LOOP ;

: -->   ( n -- ) SCR @ 1+ LOAD ;

EMPTY-BUFFERS
