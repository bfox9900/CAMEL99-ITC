\ FIG Forth style VOCABULARY FOR CAMEL99
\ the simplest form of VOCABULARY.

\ Each new Vocabulary links back to Forth

INCLUDE DSK1.TOOLS

HEX
36 USER CURRENT
38 USER CONTEXT

VARIABLE VOCLINK

LATEST CURRENT !

: VOCABULARY
        CREATE  CURRENT @ ,
                HERE
                VOCLINK @ ,
                VOCLINK !

        DOES> CELL+ CONTEXT ! ;

: DEFINITIONS  ( -- ) CURRENT @ CONTEXT ! ;


: FIND2   CURRENT @ @ (FIND) ;



