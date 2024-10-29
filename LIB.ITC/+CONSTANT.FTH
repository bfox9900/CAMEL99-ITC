\ +CONSTANT creates incrementing or decrementing constants

\ Forth version 
\ : +CONSTANT     CREATE   ,  DOES> @ + ;
\ ;code version 
HEX
\ : +CONSTANT   CREATE   ,   ;CODE A118 , ( *W TOS ADD,) NEXT, ENDCODE

\ Faster versioin: Use Add Immediate instruction and build a code word. 
: +CONSTANT   CODE        TOS SWAP AI,   NEXT,  ;   

: +NOS        CREATE   ,   ;CODE A598 , ( *W *SP ADD,) NEXT, ENDCODE

CODE UNDER+   (  a b n -- a+n b)
          1984 , 0002 , \  TOS 2 (SP) ADD,
          C136 ,        \         TOS POP,
          NEXT,
ENDCODE

