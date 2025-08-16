\ unsigned star-slash. Faster than signed version in Kernel
HEX
CODE U*/ ( n n n -- n )
    C004 , C076 , C136 , 3901 , C0C5 , 3D00 ,  NEXT,
\   R4  R0 MOV,      \ move TOS cache register R0 (divisor)
\  *SP+ R1 MOV,      \ POP multiplier to R1
\  *SP+ R4 MOV,      \ multiplicand -> TOS
\   R1  R4 MPY,      \ 32 bit multiply
\   R5  R3 MOV,      \ low order word to R3
\   R0  R4 DIV,      \ unsigned division
   NEXT,
ENDCODE

\ unsigned divide. FASTER but be careful
CODE U/ ( n n -- n )
    C004 , 04C4 , C176 , 3D00 ,
\   TOS  R0 MOV,     \ divisor->R0                 14
\       TOS CLR,
\  *SP+  R5 MOV,     \ MOVE low word to r5         18
\   R0  TOS DIV,     \ perform unsigned division  124
    NEXT,
ENDCODE
