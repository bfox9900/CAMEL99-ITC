\ usigned star-slash. Faster than floored version in Kernel

CODE: U*/ ( n n n -- n )
              R4  R0 MOV,      \ move TOS cache register R0 (divisor)
             *SP+ R1 MOV,      \ POP multiplier to R1
             *SP+ R4 MOV,      \ multiplicand -> TOS
              R1  R4 MPY,      \ 32 bit multiply
              R5  R3 MOV,      \ low order word to R3
              R0  R4 DIV,      \ unsigned division
              NEXT,
              END-CODE
