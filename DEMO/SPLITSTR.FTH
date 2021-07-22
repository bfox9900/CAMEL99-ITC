\ String manipulations examples with stack strings  Jul 2021 Brian Fox

INCLUDE DSK1.TOOLS \ provides: .S FORGET WORDS  DUMP

DECIMAL
: LASTCHAR ( addr len -- addr len c) 2DUP + 1- C@ ;

: PUNCT$  S"  []!@#$%^&*()_+{}:<>?'"  ;

: VALIDATE ( char addr len -- ? )  \ find char in the stack string
        ROT SCAN NIP ;

: -PUNCT  ( addr n -- adr n') \ Remove trailing punctuation
        BEGIN DUP
        WHILE ( len<>0)
        LASTCHAR PUNCT$ VALIDATE
        WHILE ( lastchar is punct.)
          1-      \ reduce length by one
        REPEAT
        THEN ;

: /PUNCT  ( addr n -- addr n') \ remove leading punctuation
        BL SKIP
        BEGIN DUP
        WHILE ( len<>0)
           OVER C@ PUNCT$ VALIDATE
        WHILE
           1 /STRING 0 MAX \ cut first char
        REPEAT
        THEN ;

: SCRUB  ( addr len -- addr len' )  -PUNCT  /PUNCT ;

: TEST$    S"  #$%^&*()Testing 1 2 3!%)_+{}:<>?' " ;

: 3RD  ( a b c -- a b c a ) 2 PICK ; \ dup 3rd stack item on top of stack

: DELIMIT ( addr len char -- str1 len1 str2 len2)
        >R  2DUP  R> SCAN  2SWAP  3RD - ;

: /WORD ( addr len char -- aword len endstr len )
        DELIMIT  2SWAP 1 /STRING  0 MAX ;

: /WORDS  ( addr len -- addr len ... addr[n] len[n]  n )
        0 >R              \ counter on return stack
        BL SKIP           \ remove leading spaces
        BEGIN  DUP        \ test the length
        WHILE             \ while there is length
           BL /WORD       \ cut a word at blank char
           R> 1+ >R       \ inc the counter
        REPEAT
        2DROP             \ mom always said keep things tidy.
        R>  ;             \ return the count

: "TYPE"   ( -- ) CR  [CHAR] " EMIT   TYPE   [CHAR] " EMIT ;

: .ITEM  ( addr len -- ) ?DUP IF  SCRUB  "TYPE"   ELSE  DROP  THEN ;

: .ITEMS ( addr len...adr' len' cnt --) CR 0 ?DO  .ITEM  SPACE LOOP ;

: TEXT$   S" [ foo ] [bar] [fizz] [CAMEL99] [Forth]  " ;

\  usage:   TEXT /WORDS .ITEMS
