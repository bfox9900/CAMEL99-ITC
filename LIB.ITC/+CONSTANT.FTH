\ +CONSTANT creates incrementing or decrementing constants
\ : +CONSTANT     CREATE   ,  DOES> @ + ;
HEX
\ : +CONSTANT   CREATE   ,   ;CODE A118 , ( *W TOS ADD,) NEXT, ENDCODE
\ Faster +constant: Use Add Immediate instruction and build a code word. 
: +CONSTANT   CODE        TOS SWAP ADDI,   NEXT,  ;   

: +NOS        CREATE   ,   ;CODE A598 , ( *W *SP ADD,) NEXT, ENDCODE

CODE UNDER+   (  a b n -- a+n)
          1984 , 0002 , \  TOS 2 (SP) ADD,
          C136 ,        \         TOS POP,
          NEXT,
ENDCODE

