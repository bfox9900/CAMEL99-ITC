\ TEMPORARY PERMANENT   relinking dictionary words

\ Used for loading the assembler in temp memory
\ then when assembling is complete, remove it from the dictionary

VARIABLE OLDDP
VARIABLE OLDLATEST
VARIABLE PERMDP
VARIABLE PERMLATEST

: TEMPORARY ( -- )
        LATEST @ OLDLATEST !
        DP @  OLDDP ! ;


: PERMANENT ( -- )
         LATEST @ PERMDP !
         DP @ PERMLATEST ! ;

: RELINK  ( -- )
         ;

