\ FAST FETCH  for Camel99 Forth  July 14 2020  B Fox
\ compiles LIT@  code followed by the literal address of the variable
\  **** NO ADVANTAGE IN CAMEL FORTH BECAUSE @ IS IN FAST RAM ****

NEEDS MOV, FROM DSK1.ASM9900
HERE

MARKER /FETCH

CODE LIT@ ( addr -- )
      TOS PUSH, 
      *IP+ W MOV,
      *W TOS MOV,
      NEXT,
      ENDCODE

: @   ( addr -- n)
      STATE @
      IF  COMPILE LIT@   COMPILE,
      ELSE @
      THEN ;
