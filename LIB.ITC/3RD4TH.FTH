\ From Wil Baden's TOOLBELT  Thanks Wil. RIP
\ fast access to items deeper in the stack
\ works like OVER.  50% faster than PICK

\ *************************************************
\ *  Due to indexed addressing mode these are the *
\ *         SAME SPEED as a literal number        *
\ *************************************************
HEX
CODE 3RD  ( a b c d --  a b c d b)  \ ANS: 2 PICK
          0646 ,         \ TOS PUSH,         \ 28
          C584 ,
          C126 , 0004 ,  \ 4 (SP) TOS MOV,   \ 22
          NEXT,                             \ =50
          ENDCODE

CODE 4TH  ( a b c d e--  a b c d e a) \ ANS: 2 PICK
          0646 ,         \ TOS PUSH,         \ 28
          C584 , 
          C126 , 0006 ,  \ 6 (SP) TOS MOV,   \ 22
          NEXT,                             \ =50
          ENDCODE


CODE 5TH  ( a b c d e--  a b c d e a) \ ANS: 2 PICK
          0646 ,         \ TOS PUSH,         \ 28
          C584 , 
          C126 , 0008 ,  \ 8 (SP) TOS MOV,   \ 22
          NEXT,                             \ =50
          ENDCODE

CODE 6TH  ( a b c d e--  a b c d e a) \ ANS: 2 PICK
          0646 ,         \ TOS PUSH,         \ 28
          C584 , 
          C126 , 000A ,  \ A (SP) TOS MOV,   \ 22
          NEXT,                             \ =50
          ENDCODE

