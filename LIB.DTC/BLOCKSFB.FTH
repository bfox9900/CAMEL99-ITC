\ FbForth version from comments of Resident dictionary file

NEEDS .S         FROM DSK1.TOOLS
NEEDS OPEN-FILE  FROM DSK1.ANSFILES
NEEDS .R         FROM DSK1.UDOTR
INCLUDE DSK1.TRACE

HEX
2                CONSTANT #BUFF     \ # of active buffers
400              CONSTANT B/BUF
B/BUF 2 CELLS +  CONSTANT B/REC     \ block-record has a 4 byte header
1 CELLS          CONSTANT CELL

3FF0             CONSTANT LIMIT      \ end of buffer memory

LIMIT B/REC #BUFF * - CONSTANT FIRST \ first buffer record address

DECIMAL 128      CONSTANT B/SEC      \ bytes per sector on TI disk

VARIABLE BLK
VARIABLE PREV      FIRST  PREV !
VARIABLE USE       FIRST  USE  !
VARIABLE LOWBLK
VARIABLE HIGHBLK   79  HIGHBLK !    \ set the highest block
VARIABLE BHNDL
VARIABLE SCR 

HEX
7FFF CONSTANT $7FFF

DECIMAL
CREATE ACTIVE  20 ALLOT    \ block file name

: ACTIVE$!  ( f$ len - f$) ACTIVE PLACE ;
: ACTIVE$   ( -- addr len) ACTIVE COUNT ;

: ERASE     ( addr len -- )  0 FILL ;
: BLANKS     ( addr len -- ) BL FILL ;

: ?BLOCKS   ( -- )  BHNDL @ 0= ABORT" No open BLOCK file" ;
: ?BLKRANGE ( n --) 0 HIGHBLK WITHIN INVERT ABORT" block range err" ;

DECIMAL
: DF128 ( -- ) DISPLAY RELATIVE  B/SEC FIXED ;

:  OPEN-BLOCKS ( file$ len -- )
        2DUP ACTIVE$!
        DF128 R/W OPEN-FILE ?FILERR BHNDL ! ;

HEX
: CLOSE-BLOCKS ( -- )
        BHNDL @ ?DUP
        IF CLOSE-FILE ?FILERR
           BHNDL OFF
        THEN ;

\ ===================================================
\ interface to ANS File system
HEX
: BLK>SECTR ( blk# -- sect) 8* ;  \ 8* is a CODE word

: SEEK   ( blk# -- )
         ?BLOCKS
         DUP BLK !
         BLK>SECTR BHNDL @ REPOSITION-FILE ABORT" SEEK err" ;

\ READ/WRITE TI records for 1 block
: RBLK  ( bufaddr block# --- )
          SEEK
          B/BUF BOUNDS ( end-addr,start-addr)
          DO    
            I B/SEC BHNDL @ READ-LINE ?FILERR  2DROP
          B/SEC +LOOP ;

: WBLK  ( bufaddr block# --- )
          SEEK
          B/BUF BOUNDS ( end-addr,start-addr)
          DO   
            I B/SEC BHNDL @ WRITE-LINE ?FILERR
          B/SEC +LOOP ;

 : R/W   ( bufaddr block# flag --- )  \ this seems a waste?
    IF
       RBLK
    ELSE
       WBLK
    THEN  ;

\ ===============================================
\ FBFORTH CODE

HEX
 : +BUF   ( addr1 --- addr2 flag )
    B/REC + DUP LIMIT =
    IF                                                    
       DROP FIRST
    THEN
    DUP PREV @ -  ;

 HEX
 : BUFFER   ( block# --- addr )
    USE @ DUP >R
    BEGIN +BUF UNTIL
    USE ! R@ @ 0< IF
       R@ 2+ R@ @ $7FFF AND 0 R/W
    THEN
    R@ ! R@ PREV ! R> 2+  ;

: UPDATE   ( --- )
    PREV @ @ 8000 OR PREV @ !  ;

 HEX
 : FLUSH   ( --- )
    LIMIT FIRST - B/BUF 4 + / 1+  0
    DO
       $7FFF BUFFER DROP
    LOOP  ;

: EMPTY-BUFFERS   ( --- )
    FIRST LIMIT OVER - ERASE FLUSH FIRST USE ! FIRST PREV ! ;

 : CLEAR   ( block# --- )
    DUP SCR ! FLUSH BUFFER B/BUF BLANKS UPDATE ;

 : BLOCK   ( block# --- addr )
    >R PREV @ DUP @ R@ - DUP + IF
       BEGIN
          +BUF 0= IF
             DROP R@ BUFFER DUP R@ 1 R/W 2-
          THEN
          DUP @ R@ - DUP + 0=
       UNTIL
       DUP PREV !
    THEN
   R> DROP 2+ ;
\ * end of FbForth code
\ ===============================================

\ Usage:  45 S" DSK1.MYBLOCKS" MAKE-BLOCKS
:  MAKE-BLOCKS ( n file len -- )
        OPEN-BLOCKS
        FIRST CELL+ B/BUF BLANKS
        DUP HIGHBLK !
        1+  1
        DO
           FIRST CELL+ I WBLK
        LOOP
        BHNDL @ CLOSE-FILE ?FILERR
        BHNDL OFF ;


HEX
: -TRAILING ( adr len -- adr len')  \ remove trailing blanks (spaces)
         BEGIN  2DUP + 1-       \ last char (adr+len-1)
                C@  BL =        \ test for blank
         WHILE  1-              \ while it's a blank, decrement length
         REPEAT ;

: <LINE> ( lin# blk# - addr ) BLOCK  SWAP  C/L@ * + ;

: .LINE  ( l# s# - ) <LINE> C/L@ 6 - -TRAILING TYPE ;

: LIST   ( s# - )
         PAGE
         DUP SCR ! ." SCR# "  U.
         10 0 ?DO   CR  I 2 .R SPACE  I SCR @ .LINE   LOOP CR ;

: LS    SCR @ LIST ;

\ single line editor
: PL    ( line# -- )    \ put line
        0 PARSE ( line# addr len)
        ROT SCR @ <LINE>  SWAP CMOVE UPDATE ;

: DL    ( line# -- ) \ delete line
        SCR @ <LINE> C/L@ BLANKS UPDATE ;

EMPTY-BUFFERS
