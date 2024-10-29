\ SLITERAL.FTH    Not in Camel99 Forth kernel
: SLITERAL ( ca u --) POSTPONE (S")  S,  ; IMMEDIATE

\ demo

: S'  ( -- ) [CHAR] ' PARSE  POSTPONE SLITERAL  ; IMMEDIATE 