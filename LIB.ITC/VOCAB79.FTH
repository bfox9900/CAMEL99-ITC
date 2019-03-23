\ FIG Forth style VOCABULARY FOR CAMEL99
\ the simplest form of VOCABULARY.

\ Each new Vocabulary links back to Forth

NEEDS .S FROM  DSK1.TOOLS

HEX
\ 36 USER CURRENT
38 USER CONTEXT

VARIABLE VOCLINK

CREATE FORTH   0 , CURRENT @  , HERE VOCLINK @ ,  VOCLINK ! 

: VOCABULARY
        CREATE  FORTH , CURRENT @ ,  HERE  VOCLINK @ ,
                VOCLINK !

        DOES> CELL+ @ CONTEXT ! ;

: DEFINITIONS  ( -- ) CURRENT @ CONTEXT ! ;



\ Neil Baud vocab
\ : Do-Vocabulary               ( -- )

\     \  From Standard Forth Rationale A.16.6.2.0715.
\     DOES>  @ >R               ( )( R: widnew)
\         GET-ORDER  SWAP DROP  ( wid_n ... wid_2 n)
\     R> SWAP SET-ORDER ;

\ : VOCABULARY                  ( "name" -- )
\     WORDLIST CREATE ,  Do-Vocabulary ;