\ print TI code as loadable text code word utility

NEEDS .#### FROM DSK1.TOOLS

HEX
VARIABLE CODESIZE  50 CODESIZE !  \ maximum no. of bytes we will display

: TAB   4 SPACES ;

: ?NEWLINE ( -- )  OUT @ C/L @ 6 - > IF CR TAB THEN  ;

: ?CODE    ( cfa -- ) DUP @ 2- - ABORT" Not code word" ;

: .CODE  ( pfa -- )  \ print the machine code for a Forth code word
        CODESIZE @ BOUNDS
        DO
           I @ DUP 045A =    \ test for NEXT
           IF  DROP LEAVE
           ELSE  ?NEWLINE .#### ."  , "
           THEN
        2 +LOOP ;

: SEECODE ( <NAME>)
        CR CR ." CODE " BL WORD DUP COUNT TYPE
        DUP 4 SPACES ." ( CFA=" .#### ." )"  
        FIND 0= ABORT" not found"
        CR TAB DUP ?CODE >BODY .CODE
        CR ." NEXT,"
        CR ." END-CODE"
        CR ;

