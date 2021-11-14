( COSMIC CONQUEST TARGET SPECIFIC WORDS for TI-99 )

\ Camel99 Forth Library requirements
INCLUDE DSK1.CASE
INCLUDE DSK1.UDOTR

\ FIG FORTH isms
\ HELPFUL RESOURCE: https://dwheeler.com/6502/fig-forth-glossary.txt
\ Helpful book: Forth Fundamentals Vol. 2, C. Kevin McCabe,
\ dilithium Press 1983, ISBN 0-88056-092-4
: ENDIF      POSTPONE THEN ; IMMEDIATE

\ implement home, hclr and vhtab using ANSI commands
\ SEE: https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797

: HOME ( --- )  0 0 AT-XY ; ( set cursor to home position)

HEX
: ?LOWER  ( c -- ?)  [CHAR] a  [CHAR] z 1+  WITHIN ;
: TOUPPER ( c -- c') DUP ?LOWER IF 5F AND  THEN ;
: INKEY   ( -- c)    KEY 7F AND  TOUPPER ;  \ uppercase Alpha, 7 bit output

DECIMAL
