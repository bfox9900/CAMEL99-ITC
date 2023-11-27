\ Double#   converts text to a 32 bit no. in your code
 
: 2LITERAL ( d -- ) SWAP POSTPONE LITERAL POSTPONE LITERAL ; IMMEDIATE
: DNEGATE  ( d1 -- d2 )  SWAP INVERT SWAP INVERT 1 M+ ;
 
: DNUMBER? ( addr len -- d )
    OVER C@ [CHAR] - = DUP>R      \ test for minus, push result
    IF 1 /STRING THEN             \ remove minus sign
    0 0 2SWAP >NUMBER             \ convert the number
    ( -- d d) NIP  ABORT" D# Err" \ test conversion flag
    R> IF  DNEGATE  THEN          \ if minus, dnegate
 ;
 
: D#
    PARSE-NAME DNUMBER?
    STATE @
    IF  POSTPONE 2LITERAL  \ if compiling, compile DOUBLE literal
    THEN ; IMMEDIATE
 
 
