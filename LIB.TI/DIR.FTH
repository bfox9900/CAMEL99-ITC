\ read a TI disk directory
HEX

\ print string left justified
: $.LEFT  ( $ width -- ) 
          OVER C@ - >R  COUNT TYPE   R> SPACES ;

DECIMAL
: ?CR     OUT @ 10 + C/L@ > IF CR THEN ;

HEX
: DIR  ( <DSK?.> )   \  needs the '.' ONLY shows file name
          BL PARSE-WORD DUP ?FILE
          RELATIVE 100 FIXED R/O BIN OPEN-FILE ?FILERR
          >R                            \ push handle onto Return stack

          PAD 50 R@ READ-LINE ?FILERR
          CR PAD COUNT TYPE CR

          LINES OFF
          BEGIN
             PAD 50 R@ READ-LINE ?FILERR
          WHILE
             DROP                       \ don't need the byte count
             PAD 0C $.LEFT  ?CR
             ?TERMINAL                  \ check for *BREAK* key
             IF R> CLOSE-FILE           \ if detected we're done here
                2DROP
                CR CR ." *BREAK*" ABORT
             THEN 1 LINES +!
          REPEAT

          R> CLOSE-FILE
          2DROP 2DROP
          DECIMAL
          CR CR LINES @ . ." files"
          HEX ;
