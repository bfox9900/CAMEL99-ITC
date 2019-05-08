\ read a TI disk directory
HEX
NEEDS OPEN-FILE FROM DSK1.ANSFILES

\ print string left justified
: $.LEFT  ( $ width -- )
          OVER C@ - >R  COUNT TYPE   R> SPACES ;

DECIMAL
: ?CR     OUT @ 10 + C/L@ > IF CR THEN ; \ CR if near end of screen

HEX
: DIR  ( <DSK?.> )   \  needs the '.' ONLY shows file name
          BL PARSE-WORD DUP ?FILE
          RELATIVE 100 FIXED R/O BIN OPEN-FILE ?FILERR >R
          PAD 50 R@ READ-LINE ?FILERR 2DROP
          CR PAD COUNT TYPE CR
          LINES OFF
          BEGIN
             PAD 50 R@ READ-LINE NIP NIP 0=
          WHILE ( flag=0)
             ?TERMINAL IF R> CLOSE-FILE DROP ABORT THEN
             PAD 0C $.LEFT ?CR          \ print record
             1 LINES +!
          REPEAT
          R> CLOSE-FILE ?FILERR
          DECIMAL
          CR LINES @ . ." files" CR
          HEX ;

