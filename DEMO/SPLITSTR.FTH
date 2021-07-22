\ String manipulations examples with stack strings  Jul 2021 Brian Fox

DECIMAL
: LASTCHAR ( addr len -- addr len c) 2DUP + 1- C@ ;

: ISPUNCT? ( char -- ? )  S"  []!@#$%^&*()_+{}:<>?'"  ROT SCAN NIP ;

\ Remove chars from a string
: -PUNCT  ( addr n -- adr n') BEGIN  LASTCHAR ISPUNCT? WHILE   1-  REPEAT ;
: -WHITE  ( addr n -- adr n') BEGIN  LASTCHAR ISPUNCT? 0= WHILE  1-   REPEAT ;

: 3RD  ( a b c -- a b c a ) 2 PICK ; \ dup 3rd stack item on top of stack

: DELIMIT ( addr len char -- str1 len1 str2 len2)
          >R  2DUP  R> SCAN  2SWAP  3RD - ;

: /WORD ( addr len char -- aword len endstr len )
   DELIMIT  2SWAP 1 /STRING   0 MAX ; \ len cannot go below zero

: /WORDS  ( addr len -- addr len ... addr[n] len[n] )
        BL SKIP           \ remove leading spaces
        BEGIN  DUP        \ test the length
        WHILE  BL /WORD   \ while there is length, cut a word
        REPEAT 2DROP ;    \ mom always said keep things tidy.

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
