\ usigned star-slash. Faster than floored version in Kernel

NEEDS DUMP  FROM DSK1.TOOLS
NEEDS MOV,  FROM DSK1.ASM9900

CODE U*/ ( n n n -- n )
              R4  R0 MOV,      \ move TOS cache register R0 (divisor)
             *SP+ R1 MOV,      \ POP multiplier to R1
             *SP+ R4 MOV,      \ multiplicand -> TOS
              R1  R4 MPY,      \ 32 bit multiply
              R5  R3 MOV,      \ low order word to R3
              R0  R4 DIV,      \ unsigned division
              NEXT,
              ENDCODE


CODE U/ ( n n -- n ) \ unsigned divide. FASTER but be careful
              TOS  R0 MOV,     \ divisor->R0                 14
                  TOS CLR,
             *SP+  R5 MOV,     \ MOVE low word to r5         18
              R0  TOS DIV,     \ perform unsigned division  124
              NEXT,
              ENDCODE

CODE U/MOD ( u2 u1 -- u2 u3 ) \ numerator, divisor -- rem,quot
              TOS  R0 MOV,     \ divisor->R0                 14
              TOS  CLR,        \ high word =0 to TOS         10
             *SP   R5 MOV,     \ MOVE low word to r5         18
              R0  TOS DIV,     \ perform unsigned division  124
              R5  *SP MOV,     \ push remainder              22
              NEXT,            \                            178
              ENDCODE