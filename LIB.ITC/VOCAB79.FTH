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
        CREATE  FORTH , CURRENT @ ,  HERE  VOCLINK @ , VOCLINK !

        DOES> CELL+ @ CONTEXT ! ;

: DEFINITIONS  ( -- ) CURRENT @ CONTEXT ! ;
