\ print TI code as loadable text code word

HEX

: ?NEWLINE    OUT @ C/L@ 6 - > IF CR THEN ;
: ?CODE ( cfa -- ) DUP @ 2- - ABORT" Not code word" ;  \ works only for ITC

: .CODE  ( addr -- )  \ print the machine code for a Forth code word
        DUP ?CODE
        DUP ."  ( " .#### ." )"  CR
        100 BOUNDS
        DO
           I @ DUP 045A =
           IF  DROP LEAVE
           ELSE  ?NEWLINE .#### ."  , "
           THEN  CELL+
        2 +LOOP
        CR ." NEXT,"
        CR ." END-CODE"  ;
