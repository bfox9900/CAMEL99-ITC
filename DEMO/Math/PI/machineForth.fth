\ make some Machine Forth Instructions

HEX
: PUSH,     0646 , ;
: TOS>STK,   C584 ,  ;
: 2*,       0A14 ,  ;
: +,        A136 ,  ;
: @,        C114 ,  ;
: DROP,     C136 , ;
: R>TOS,    C117 , ;   \   *RP  TOS MOV,
: (R)-,     6127 , , ; \ 2 (RP) TOS SUB,

: 2DUP
    0226 , -4 , \ SP -4 ADDI,
    C5A6 ,  4 , \ 4 (SP) *SP MOV,
    C984 ,  2 . \ TOS  2 (SP) MOV,
;

\ Combine them to make higher level isntructions
: DUP,      PUSH,  TOS>STK, ;
: OVER,     0646 ,  C584 , C126 , 0002 , ;
: I,        DUP, R>TOS,  2 (R)-, ;

HEX
\ Now we can make Machine Forth Super instructions
CODE CELLS+     2*, +,      NEXT, ENDCODE
CODE CELLS+@    2*, +, @,   NEXT, ENDCODE
CODE DUP@       DUP,  @,    NEXT, ENDCODE
CODE 2DUP+@     2DUP +, @,  NEXT, ENDCODE
CODE I+,        I, +,       NEXT, ENDCODE ;
