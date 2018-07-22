\ comma quote creates string literals at compile time
\ Parse input stream until '"' and compile into memory

: ,"          ( -- ) [CHAR] " PARSE  S,  ;  IMMEDIATE
 
\ USAGE:   CREATE A$ ," This is a counted string. The first byte is the length"
\          A$ COUNT TYPE
