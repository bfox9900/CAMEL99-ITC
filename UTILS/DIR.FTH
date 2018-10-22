\ read a TI disk directory
HEX
NEEDS OPEN-FILE FROM DSK1.ANSFILES

DECIMAL
: ?CR     OUT @ 10 + C/L@ > IF CR THEN ; \ CR if near end of screen

HEX
: DIR  ( <DSK?.> )   \  needs the '.' ONLY shows file name
          BL PARSE-WORD DUP ?FILE

          RELATIVE 100 FIXED R/O BIN OPEN-FILE ?FILERR
          >R  \ push handle onto Return stack
          PAD 50 R@ READ-LINE ?FILERR 2DROP
          CR PAD COUNT TYPE CR
          LINES OFF
          BEGIN
             PAD 10 R@ READ-LINE ?FILERR NIP ( eof?)
          WHILE
             PAD COUNT DUP >R TYPE  C/L@ 2/ R>  - SPACES
             ?TERMINAL          
             IF R> CLOSE-FILE
                2DROP
                CR CR ." *BREAK*" ABORT
             THEN 1 LINES +!
          REPEAT
          R> CLOSE-FILE ?FILERR
          DECIMAL
          CR LINES @ . ." files" CR
          HEX ;
