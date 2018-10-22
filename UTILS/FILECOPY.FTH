\ copy text file

NEEDS OPEN-FILE  FROM DSK1.ANSFILES
NEEDS VALUE      FROM DSK1.VALUES
NEEDS PARSE-NAME FROM DSK1.PARSNAME

HEX
0 VALUE #1  \ these hold the file handles
0 VALUE #2

: FNAME  ( -- addr len )  PARSE-NAME DUP ?FILE ;

: COPY ( <file1> <file2> )
        FNAME FNAME   ( -- addr len addr len )
        DV80 W/O OPEN-FILE ?FILERR TO #2
        DV80 R/O OPEN-FILE ?FILERR TO #1
        52 DUP MALLOC >R
        LINES OFF
        BEGIN
          R@  50  #1 READ-LINE  ?FILERR   ( -- #bytes eof?)
        WHILE
          R@ SWAP #2 WRITE-LINE ?FILERR
          LINES 1+!
        REPEAT
        R> DROP                 \ DROP buffer address from rstack
      ( 52) MFREE               \ release the buffer memory
        #2 CLOSE-FILE ?FILERR
        #1 CLOSE-FILE ?FILERR
        BASE @ >R 
        DECIMAL
        CR ." Copy complete. " LINES @ . ." records"
        R> BASE !
;


