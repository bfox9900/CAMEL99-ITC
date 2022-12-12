\ Temp registers for use in Forth program    Dec 7 2022 
NEEDS R0  FROM DSK1.ASM9900

HERE
CODE REGS>R
     R0 RPUSH,
     R1 RPUSH,
     R2 RPUSH,
     R3 RPUSH,
     NEXT,
ENDCODE

CODE R>REGS
     R3 RPOP,
     R2 RPOP,
     R1 RPOP,
     R0 RPOP,
     NEXT,
ENDCODE

CODE R0!    ( n -- )   TOS R0 MOV,   TOS POP,  NEXT, ENDCODE
CODE R0@    ( -- n)    TOS PUSH,  R0 TOS MOV,  NEXT, ENDCODE

CODE R1!     ( n -- )  TOS R1 MOV,   TOS POP,  NEXT, ENDCODE
CODE R1@     ( -- n)   TOS PUSH,  R1 TOS MOV,  NEXT, ENDCODE

CODE R2!    ( n -- )   TOS R2 MOV,   TOS POP,  NEXT, ENDCODE
CODE R2@    ( -- n)    TOS PUSH,  R2 TOS MOV,  NEXT, ENDCODE

CODE R3!     ( n -- )  TOS R3 MOV,   TOS POP,  NEXT, ENDCODE
CODE R3@     ( -- n)   TOS PUSH,  R3 TOS MOV,  NEXT, ENDCODE

\ CODE DUP>R0 ( n -- n)  TOS R0 MOV,           NEXT, ENDCODE
\ CODE DUP>R1 ( n -- n)  TOS R1 MOV,           NEXT, ENDCODE
\ CODE DUP>R2 ( n -- n)  TOS R2 MOV,           NEXT, ENDCODE
\ CODE DUP>R3  ( n -- n) TOS R3 MOV,           NEXT, ENDCODE

HERE SWAP - DECIMAL . 
