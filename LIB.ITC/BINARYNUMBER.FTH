\ B#  (binary number) based on Neil Baud's Toolbelt
\ Get the next word in the input stream as a hex single-number literal.
: BINARY   2 BASE ! ;

: B#  ( "hexnumber" -- n )
    0 0 PARSE-NAME ( -- str len)
    BASE @ >R
    BINARY >NUMBER   \ convert the number in BASE 16
    R> BASE !
    ( -- n flag)
    ABORT" Not binary" 2DROP  ( -- n)      \ test conversion flag
    STATE @ IF  POSTPONE LITERAL  THEN   \ if compiling, compile literal no.
    ; IMMEDIATE
