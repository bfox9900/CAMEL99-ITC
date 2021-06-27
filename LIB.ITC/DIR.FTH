\ read a TI disk directory
HEX
NEEDS OPEN-FILE FROM DSK1.ANSFILES

DECIMAL
: ?CR     ( n -- ) LINES @ 3 MOD 0= IF CR THEN ;   \ CR if near end of screen

HEX
: DIR  ( <DSK?.> )   \  needs the '.' ONLY shows file name
          BL PARSE-WORD ?FILE
          RELATIVE 100 FIXED R/O BIN OPEN-FILE ?FILERR
          >R  \ push handle onto Return stack
          PAD 50 R@ READ-LINE ?FILERR 2DROP
          CR PAD COUNT TYPE
          CR
          LINES OFF
          BEGIN
             PAD DUP 80 R@ READ-LINE ?FILERR 2DROP
           ( PAD) C@
          WHILE \ do while length > 0
             PAD COUNT DUP >R  TYPE 0D R> - SPACES
             ?TERMINAL
             IF
                R> CLOSE-FILE
                2DROP
                CR CR ." *BREAK*" ABORT
             THEN
             1 LINES +!
             ?CR
          REPEAT
          R> CLOSE-FILE ?FILERR
          DECIMAL
          CR LINES @ . ." files" CR
          HEX ;

