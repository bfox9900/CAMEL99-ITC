\ P A R S E   W O R D
[CC] cr .( Parsing...)
TARGET-COMPILING

CODE DUP>R  ( n -- n) TOS RPUSH,  NEXT, ENDCODE  \ used 3 times

: SOURCE   ( -- addr len) 'SOURCE 2@ ;

: PARSE    ( char -- c-addr u )  \ gForth
            >R
            SOURCE  >IN @ OVER MIN /STRING
            OVER SWAP R>  SCAN >R
            OVER - DUP
            R> IF 1+ THEN  >IN +! ;

: PARSE-WORD  ( char -- c-addr n)  \ Camel/BFox common factor for WORD
            DUP SOURCE >IN @ /STRING
            ROT SKIP
            DROP SOURCE  -ROT -  MIN  0 MAX >IN !
            PARSE ;

: WORD     ( char -- c-addr)
            PARSE-WORD HERE PLACE
            HERE BL OVER COUNT + C!  \ append blank character
;
