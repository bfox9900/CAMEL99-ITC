\ save VDP patterns as a binary font file

\ this method moves the VDP buffer pointer through VDP pattern table
\ to get at the data without copying it to a new buffer

INCLUDE DSK1.TOOLS.F
INCLUDE DSK1.ANSFILES.F
INCLUDE DSK1.CASE.F
INCLUDE DSK1.CATALOG.F


HEX

: WRITE-BLOCK ( blk# -- ior )
               8 [PAB CHARS] VC!     \ # chars to write ->PAB
                 [PAB FBUFF] V!      \ Set the VDP addr to write
                 3 FILEOP ( -- ior)  \ call write operation
                 (EOF) FUSE          \ fuse EOF and general file errors
;

: WRITE-PATTERNS ( -- )
            FF8 800                 \ PDT(end) PDT(start)
            DO
               I DUP .
                WRITE-BLOCK  DUP IF CR CR ." WRITE-BLOCK Err: "  . ABORT THEN
            FF +LOOP ;

: SAVE-FONT ( addr len -- )
           RELATIVE 100 FIXED W/O BIN CREATE-FILE ?FILERR >R
           WRITE-PATTERNS
           R> CLOSE-FILE ?FILERR ;
           
S" DSK2.TESTFILE"  100 FIXED W/O BIN CREATE-FILE