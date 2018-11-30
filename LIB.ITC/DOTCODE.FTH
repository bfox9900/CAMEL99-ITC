\ print TI code as loadable text code word

HEX
NEEDS .#### FROM DSK1.TOOLS

: TAB   4 SPACES ;

: ?NEWLINE ( -- )  OUT @ C/L@ 6 - > IF CR TAB THEN  ;

: ?CODE    ( cfa -- ) DUP @ 2- - ABORT" Not code word" ;

: .CODE  ( addr -- )  \ print the machine code for a Forth code word
        DUP ?CODE
        CR ." CODE " DUP ." ( CFA=" .#### ." )"  CR TAB
        >BODY  100 BOUNDS
        DO
           I @ DUP 045A =    \ test for NEXT
           IF  DROP LEAVE
           ELSE  ?NEWLINE .#### ."  , "
           THEN  CELL+
        2 +LOOP
        CR ." NEXT,"
        CR ." END-CODE"  
        CR ;
