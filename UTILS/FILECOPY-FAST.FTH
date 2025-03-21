\ copy text file

NEEDS DUMP       FROM DSK1.TOOLS 
NEEDS OPEN-FILE  FROM DSK1.ANSFILES
NEEDS VALUE      FROM DSK1.VALUES
NEEDS ELAPSE     FROM DSK1.ELAPSE 

HEX
0 VALUE #IN  \ these hold the file handles
0 VALUE #OUT

\ string helpers
 : ?PATH    ( addr len -- )
            2DUP [CHAR] . SCAN NIP
            0= IF CR TYPE TRUE ABORT" Path expected" THEN ;

 : ARG$     ( -- addr len ) PARSE-NAME ?PATH ;

: FREAD   ( hndl -- bytes ior) SELECT  2 FILEOP  [PAB CHARS] VC@  SWAP ;
: FWRITE  ( bytes hndl --)  SELECT [PAB CHARS] VC!  3 FILEOP ?FILERR ;

: .RESULTS
    BASE @ >R 
    DECIMAL
    CR ." Copy complete. " LINES @ . ." records"
    R> BASE !
;

: OPEN-FILES ( inpath outpath )
    ARG$ ARG$ ( inaddr len Outaddr len)
    DV80 W/O OPEN-FILE ?FILERR TO #OUT
    DV80 R/O OPEN-FILE ?FILERR TO #IN
; 

: CLOSE-FILES  
    #IN CLOSE-FILE ?FILERR  
    #OUT CLOSE-FILE ?FILERR ; 

\ Copy the address of the input pab's buffer to the output pab :-) 
: PIPE  ( in out )
    SWAP SELECT [PAB FBUFF] V@ 
    SWAP SELECT [PAB FBUFF] V! ;

HEX
\ : DV80    DISPLAY 50 VARI SEQUENTIAL ;
: COPY ( <filename>)
    OPEN-FILES 
    #IN #OUT PIPE 
    BEGIN
      #IN FREAD 
    0= WHILE  
      #OUT FWRITE 
      LINES 1+!  
    REPEAT
    CLOSE-FILES 
    .RESULTS 
;
 
