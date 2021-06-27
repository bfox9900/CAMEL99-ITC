\ H#  (hex number) from Neil Baud's Toolbelt
\ Get the next word in the input stream as a hex single-number literal.
\ Adopted from Open Firmware by Mitch Bradley
\ Changed to use PARSE-WORD. Faster in CAMEL99 Forth (no copying)

: H#  ( "hexnumber" -- n )  \  Simplified for easy porting.
    0 0 BL PARSE-WORD ( -- str len)      \ parse the string
    BASE @ >R  HEX  >NUMBER  R> BASE !   \ convert the number in BASE 16
    ( -- n flag)
    ABORT" Not Hex " 2DROP  ( -- n)      \ test conversion flag
    STATE @ IF  POSTPONE LITERAL  THEN   \ if compiling, compile literal no.
    ; IMMEDIATE
