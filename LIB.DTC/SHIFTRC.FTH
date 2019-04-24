\ shift right circular.  9900 native instruction

HEX
CODE SRC  ( n bits -- n')     \ non ANS Forth. Circular shift. Nice!
           C004 ,  \  TOS R0  MOV,
           C136 ,  \ *SP+ TOS MOV,
           0B04 ,  \  TOS R0  SRC,
           NEXT,
           ENDCODE
