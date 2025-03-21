\ copy text file

NEEDS OPEN-FILE  FROM DSK1.ANSFILES
NEEDS VALUE      FROM DSK1.VALUES
NEEDS PARSE-NAME FROM DSK1.PARSNAME

HEX
0 VALUE #IN  \ these hold the file handles
0 VALUE #OUT

: FNAME  ( -- addr len )  PARSE-NAME DUP ?FILE ;
: PIPE  #IN SELECT [PAB FBUFF] V@  #OUT SELECT [PAB FBUFF] V! 
;
: COPY ( <file1> <file2> )
        FNAME FNAME   ( -- addr len addr len )
        DV80 W/O OPEN-FILE ?FILERR TO #OUT
        DV80 R/O OPEN-FILE ?FILERR TO #IN
        52 DUP MALLOC >R
        LINES OFF
        BEGIN
          R@  50  #IN READ-LINE  ?FILERR   ( -- #bytes eof?)
        WHILE
          R@ SWAP #OUT WRITE-LINE ?FILERR
          LINES 1+!
        REPEAT
        R> DROP                 \ DROP buffer address from rstack
      ( 52) MFREE               \ release the buffer memory
        #OUT CLOSE-FILE ?FILERR
        #IN CLOSE-FILE ?FILERR
        BASE @ >R 
        DECIMAL
        CR ." Copy complete. " LINES @ . ." records"
        R> BASE !
;


