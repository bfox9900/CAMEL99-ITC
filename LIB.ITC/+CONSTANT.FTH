\ +CONSTANT  an incrementing decrementing constants
: +CONSTANT     CREATE   ,  DOES> @ + ;

\  faster code below. Longer compile time to loading assembler etc.
\  NEEDS MOV, FROM DSK1.LOWTOOLS
\ ALSO ASSEMBLER

\ : +CONSTANT     CREATE   ,  ;CODE *W TOS ADD, NEXT, ENDCODE

\  REMOVE-TOOLS  ( removes wordlists and assembler)
