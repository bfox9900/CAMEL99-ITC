\ Split a string into words

DECIMAL

: LASTCHAR ( addr len -- addr len c) 2DUP + 1- C@ ;

: ISPUNCT? ( char -- ? )  S"  []!@#$%^&*()_+{}:<>?'"  ROT SCAN NIP ;

: -PUNCT   ( adr len -- adr len')
            BEGIN  LASTCHAR ISPUNCT? WHILE   1-  REPEAT  ;

: -WHITE   ( addr len -- n)
            BEGIN  LASTCHAR ISPUNCT? 0= WHILE  1-   REPEAT ;

: /WORD    ( adr len -- adr len-len' adr' len')
            2DUP  -WHITE
            DUP 0>
            IF DUP >R +
               SWAP R@ -   R> 1-  -ROT
            ELSE
                DROP 0
            THEN
;

: SPLITSTR ( adr len -- adr len ... adr len cnt)
            -PUNCT
            0 >R
            BEGIN
               /WORD  DUP 
            WHILE
               2SWAP -PUNCT
               R> 1+ >R
            REPEAT
            2DROP
            R> 1+
;

: '"'   ( -- )  [CHAR] " EMIT ;

: .ITEM  ( addr len -- ) ?DUP IF  '"' TYPE '"'   ELSE  DROP  THEN ;
: .ITEMS ( addr len...adr' len' cnt --) CR 0 ?DO  .ITEM  SPACE LOOP ;

: TEXT S" [ foo ] [bar][fizz] [CAMEL99] [Forth]  " ;

\  usage:   TEXT SPLITSTR .ITEMS

