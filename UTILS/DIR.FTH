\ read a TI disk directory
HEX
CR .( Requires ANSFILES.F)
' OPEN-FILE DROP

\ print string left justified
: $.LEFT  ( $ width -- ) 
          OVER C@ - >R  COUNT TYPE   R> SPACES ;

DECIMAL
: ?CR     OUT @ 10 + C/L@ > IF CR THEN ; \ CR if near end of screen

HEX
: DIR  ( <DSK?.> )   \  needs the '.' ONLY shows file name
          BL PARSE-WORD DUP ?FILE
          RELATIVE 100 FIXED R/O BIN OPEN-FILE ?FILERR
          >R                            \ push handle onto Return stack

          PAD 50 R@ READ-LINE ?FILERR 2DROP
          CR PAD COUNT TYPE CR

          LINES OFF
          BEGIN
             PAD 50 R@ READ-LINE ?FILERR ( -- len flag) NIP
          WHILE ( flag=0)
             PAD 0C $.LEFT ?CR          \ print record
             ?TERMINAL                  \ check for *BREAK* key
             IF R> CLOSE-FILE           \ if detected we're done here
                2DROP
                CR CR ." *BREAK*" ABORT
             THEN 1 LINES +!
          REPEAT
          R> CLOSE-FILE ?FILERR
          DECIMAL
          CR LINES @ . ." files" CR
          HEX ;
