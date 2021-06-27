\ DBL#   converts text to a 32 bit in your code

: 2LITERAL ( d -- ) SWAP POSTPONE LITERAL POSTPONE LITERAL ; IMMEDIATE
: DNEGATE  ( d1 -- d2 )  SWAP INVERT SWAP INVERT 1 M+ ;

: DBL# ( "0123456789" -- n ) \ Simplified for easy porting.
    0 0 BL PARSE-WORD ( -- str len)         \ parse the string
    OVER C@ [CHAR] - = DUP >R               \ test for minus, push result
    IF 1 /STRING THEN                       \ remove minus sign
    BASE @ >R DECIMAL >NUMBER  R> BASE !    \ convert the number in BASE 16
    ( -- d d)
    NIP  ABORT" DBL# Err"  ( -- )   \ test conversion flag
    R> IF  DNEGATE  THEN            \ if minus, dnegate
    STATE @
    IF  POSTPONE 2LITERAL  \ if compiling, compile DOUBLE literal
    THEN ; IMMEDIATE
