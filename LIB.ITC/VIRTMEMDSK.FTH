\ VIRTUAL MEMORY LOADDV80/SAVEDV80

NEEDS DUMP        FROM DSK1.TOOLS 
NEEDS FIDS        FROM DSK1.ANSFILES
NEEDS BLOCKS      FROM DSK1.BLOCKS
NEEDS -TRAILING   FROM DSK1.TRAILING
NEEDS .R          FROM DSK1.UDOTR 

: SWAPFILE ( -- addr len) S" DSK3.$SWAP$" ;

DECIMAL
 80 CONSTANT RECSIZE 
 64 CONSTANT MAXBLK  \ 64K of virtual memory 

 B/BUF RECSIZE / CONSTANT LINES/BLK 
 LINES/BLK RECSIZE * CONSTANT BYTES/BLOCK \ 

DECIMAL
CREATE FILENAME  32 ALLOT  S" DSK1.UNTITLED" FILENAME PLACE

\ compute address of 80 byte record in any block(n)
: (LINE)  ( n -- offset blk#)  RECSIZE UM*  BYTES/BLOCK  UM/MOD ;
: RECORD  ( n -- addr) (LINE) BLOCK + ;

: ?OPENERR ( n -- ) ?DUP IF TRUE ABORT" Open error # " . THEN ;
: ?R/WERR  ( n -- ) ?DUP IF TRUE ABORT" R/W error # "  . THEN ;
: ?CLOSERR ( N -- ) ?DUP IF TRUE ABORT" Close error # " . THEN ;

VARIABLE LASTBLOCK
VARIABLE LASTLINE

: >LASTBLOCK ( linecnt -- ) RECSIZE * B/BUF / 1+  LASTBLOCK ! ;

: BLANK  BL FILL ;

: CLEAR ( n -- ) BUFFER B/BUF BLANK  UPDATE ;
: COPY  ( from to -- ) FLUSH  SWAP  BLOCK  2- ! UPDATE ;
: SMOVE ( from to n ) 1+ BOUNDS DO  DUP I COPY 1+  LOOP FLUSH ;

: CLEARBLOCKS ( start end -- )
    1+ SWAP 
    ?DO
       I CLEAR 
       [CHAR] . EMIT 
    LOOP
    FLUSH
    LASTLINE OFF
;

: PURGE   0 MAXBLK CLEARBLOCKS ;

\ Load DV80 file into virtual memory file as 80 byte records 
\ count # of lines (LASTLINE)
\ compute last block of virtual memory (LASTBLOCK)
DECIMAL
: LOADFILE ( addr len -- )
    2DUP DV80 R/O OPEN-FILE ?OPENERR >R
    FILENAME PLACE
    LASTLINE OFF
    BEGIN
        LASTLINE @ RECORD RECSIZE R@ READ-LINE NIP NIP 
    0= WHILE 
        LASTLINE 1+!
        UPDATE
    REPEAT
    FLUSH
    R> CLOSE-FILE ?CLOSERR
    LASTLINE @ >LASTBLOCK
;

: RECORD$  ( -- addr len) RECORD RECSIZE -TRAILING 1 MAX ;

\ test code
: VIEW ( -- )
    CR
    LASTLINE @ 0
    ?DO
        CR I 3 .R  SPACE  I RECORD$ TYPE
        SPACEBAR
        ?TERMINAL ABORT" VIEW halted"
    LOOP
;

VARIABLE SH ( save handle )

: SAVEDV80 ( addr len -- )
    DV80 R/W OPEN-FILE ?OPENERR SH !
    CR ." Saving..."
    LASTLINE @ 0
    DO
       I RECORD$ SH @ WRITE-LINE ?R/WERR
    LOOP
    SH @ CLOSE-FILE ?CLOSERR
;

: NEW-SWAPFILE    
    MAXBLK SWAPFILE MAKE-BLOCKS 
    SWAPFILE OPEN-BLOCKS ; 

