\ blocks.fth  for CAMEL99 Forth     Dec 17 2018 BJFox
\ Based on ideas from HsForth by Jim Kalihan (RIP)

NEEDS .S         FROM DSK1.TOOLS
NEEDS OPEN-FILE  FROM DSK1.ANSFILES
NEEDS .R         FROM DSK1.UDOTR
NEEDS 80COLS     FROM DSK1.80COL
NEEDS INLINE[    FROM DSK1.INLINE

HEX
2                CONSTANT #BUFF     \ # of active buffers
400              CONSTANT B/BUF
B/BUF 2 CELLS +  CONSTANT B/REC     \ block-record has a 4 byte header

3FFF 1-          CONSTANT LIMIT      \ end of buffer memory
LIMIT B/REC #BUFF * - CONSTANT FIRST  \ first buffer record address

DECIMAL 128      CONSTANT B/SEC     \ bytes per sector on TI disk

VARIABLE BLK
VARIABLE PREV      FIRST  PREV !
VARIABLE USE       FIRST  USE  !
VARIABLE LOWBLK
VARIABLE HIGHBLK   79  HIGHBLK !    \ set the highest block
VARIABLE BHNDL                      \ block file handle

HEX
\ speed up words
 : CELL-   S" 2- " EVALUATE ; IMMEDIATE
CODE $7FFFAND   0244 , 7FFF ,         NEXT, ENDCODE
CODE DUP@       0646 , C584 , C114 ,  NEXT, ENDCODE

CODE DUP>R ( -- )
          0647 ,  C5C4 , \ TOS RPUSH,
          NEXT,
          ENDCODE

DECIMAL
CREATE ACTIVE  20 ALLOT    \ block file name
: ACTIVE$!  ( f$ len - f$) ACTIVE PLACE ;
: ACTIVE$   ( -- addr len) ACTIVE COUNT ;

: ERASE     ( addr len -- )  0 FILL ;
: BLANKS    ( addr len -- ) BL FILL ;

\ ===================================================
\ interface to ANS File system
HEX
: ?BLOCKS   ( -- )  BHNDL @ 0= ABORT" No open BLOCK file" ;

\ move file pointer to start of block
: SEEK   ( blk# -- )
         ?BLOCKS
         DUP BLK !
         8*   ( blk# x 8 = sector)
         BHNDL @ REPOSITION-FILE ABORT" SEEK err" ;

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
: UPDATE ( -- ) PREV @ @ 8000 OR  PREV ! ;

: +BUF    ( addr1-- addr2)
          B/REC + DUP LIMIT = IF DROP FIRST THEN ;

: BUFFER ( n -- addr )
        USE @ DUP>R       \ get current buffer record & Rpush
        @ 0<               \ has it been updated?
        IF                 \ if true ...
           R@ CELL+        \ get buffer address
           R@ @            \ get the block number
           $7FFFAND  WBLK  \ write data to disk
        THEN R@ !          \ store this in USE record
        R@ PREV !          \ set it as previous record
        R@ +BUF USE !      \ "use" next buffer
        R> CELL+ ;         \ return the buffer address

: BLOCK   ( block# --- addr )
        ?BLOCKS
       >R
        PREV @ DUP@  R@ - $7FFFAND
        IF
           BEGIN
              +BUF DUP PREV @ =
              IF
                 DROP R@ BUFFER  R@ RBLK CELL-
              THEN
              DUP@ R@ -  $7FFFAND
           0= UNTIL
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
           DUP@ 0<    \ is block updated?
           IF          \ yes, write to disk
              DUP@ $7FFFAND OVER 2DUP !
              CELL+ SWAP WBLK
           THEN +BUF   \ then goto next block record
        LOOP
        DROP ;

: EMPTY-BUFFERS ( -- )
        FIRST LIMIT OVER - ERASE
        #BUFF 0
        DO
           7FFF B/REC I * FIRST + !
        LOOP ;

DECIMAL
: DF128   DISPLAY RELATIVE  B/SEC FIXED ;

: OPEN-BLOCKS ( file$ len -- )
        2DUP ACTIVE$!
        EMPTY-BUFFERS
        DF128 R/W OPEN-FILE ?FILERR BHNDL ! ;

HEX
: CLOSE-BLOCKS ( -- )
        BHNDL @ ?DUP
        IF CLOSE-FILE ?FILERR
           BHNDL OFF
        THEN ;

\ Usage:  45 S" DSK1.MYBLOCKS" MAKE-BLOCKS
:  MAKE-BLOCKS ( n file len -- )
        OPEN-BLOCKS
        FIRST CELL+ B/BUF BLANKS
        DUP HIGHBLK !
        1+  1
        DO
           FIRST CELL+ I WBLK
        LOOP
        CLOSE-BLOCKS ;

\ ====================================================
\ block utils
VARIABLE SCR

: LOAD  ( n -- )
        DUP SCR !
        SOURCE-ID @ >R
        BHNDL @ SOURCE-ID !
        BLOCK B/BUF EVALUATE
        R> SOURCE-ID ! ;

: -->   ( n -- ) SCR @ 1+ LOAD ;

DECIMAL
64 CONSTANT LWIDTH

: .LINE  ( lin# scr# - ) \ .line direct to VDP RAM
         BLOCK  SWAP  LWIDTH * + LWIDTH VPOS SWAP VWRITE ;

: LIST   ( s# - )
         PAGE DUP SCR ! ." SCR# "  U.
         16 0 ?DO  CR  I 2 .R SPACE  I SCR @ .LINE  LOOP CR ;

\ single line editor
\ : PL    ( line# -- )    \ put line
\        0 PARSE ( line# addr len)
\        ROT SCR @ <LINE>  SWAP CMOVE UPDATE ;

\ : DL    ( line# -- ) \ delete line
\        SCR @ <LINE> C/L@ BLANKS UPDATE ;

EMPTY-BUFFERS




