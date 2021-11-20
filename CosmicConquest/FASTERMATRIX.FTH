\ matrix computation in Assembler

INCLUDE DSK1.SUPERTOOLS

ONLY FORTH ALSO ASSEMBLER

: TASK ;

\ heap memory analogs to HERE ALLOT C,  and ,
: HEAP    H @ ;
: HALLOT  H +! ;
: HC,     HEAP C!  1 HALLOT ;
: H,      HEAP !   2 HALLOT ;
: ERASE  0 FILL ;

\ INIT heap pointer & clean up heap space
HEX  2000 H !
HEAP 2000 ERASE

: MATRIX: ( cols rows -- )
   CREATE HEAP ,
          DUP H,       \ compile row size (square matrix)
          * 2+ HALLOT  \ allocate the space in HEAP
   ;CODE ( n n -- addr )
\         @ ROT 1- OVER C@ * + +
              TOS DEC,    \  ROT 1-
          *W   R3 MOV,    \ heap address -> R2
          R3 ** R3 MOV,   \ get the size stored in 1st byte of matrix
          TOS  R3 MPY,    \  *
          W   TOS ADD,    \ +
         *SP+ TOS ADD,    \ +
          NEXT,
    ENDCODE

DECIMAL
30 30 MATRIX: Q
