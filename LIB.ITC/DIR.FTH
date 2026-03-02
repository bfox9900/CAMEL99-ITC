\ read a TI disk directory
HEX

NEEDS OPEN-FILE FROM DSK1.ANSFILES

DECIMAL
: ?CR     ( n -- ) VCOL @ C/L@ 15 - > IF CR THEN ;

: TYPE.L  ( addr len n -- ) \ type left justified
           OVER - >R  TYPE   R> SPACES ;

DECIMAL
: DIR  ( <DSK?.> )   \  needs the '.' ONLY shows file name
          BL PARSE-WORD ?FILE

          RELATIVE 256 FIXED R/O BIN OPEN-FILE ?FILERR
          >R  \ push handle onto Return stack
          PAD 80 R@ READ-LINE ?FILERR 2DROP
          CR PAD COUNT TYPE
          CR
          LINES OFF
          BEGIN
             PAD DUP 80 R@ READ-LINE ?FILERR 2DROP
           ( PAD) C@
          WHILE \ do while length > 0
             PAD COUNT 12 TYPE.L ?CR
             ?TERMINAL
             IF
                R> CLOSE-FILE
                2DROP
                CR CR ." *BREAK*" ABORT
             THEN
             1 LINES +!
          REPEAT
          R> CLOSE-FILE ?FILERR
          DECIMAL
          CR LINES @ . ." files" CR
          HEX ;
