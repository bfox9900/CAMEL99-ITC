\ PARSE-NAME    Forth 2012
\
\ Skip leading space delimiters. Parse name delimited by a space.
\ c-addr is the address of the selected string within the input buffer and 
\ u is its length in characters. If the parse area is empty or contains only 
\ white space, the resulting string has length zero.

: PARSE-NAME ( "<spaces>name<space>" -- c-addr u ) BL PARSE-WORD ; 
