
\ INCLUDE  Forth 2012 word

: PARSE-NAME ( <text> -- adr len ) BL PARSE-WORD ; \ Forth 2012 word
: INCLUDE  ( <text> -- )  PARSE-NAME INCLUDED ;
 