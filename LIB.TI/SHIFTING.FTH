\ shift right circular.  9900 native instruction

INCLUDE DSK1.ASM9900.F

\ IN KERNEL NOW
\ CODE SRA ( n bits -- n')  \ shift right arithimetic
\              TOS R0  MOV,            \ 14 the shift bits MUST be in R0 to do this
\             *SP+ TOS   MOV,          \ 22
\              R0 R0 MOV,              \ ANS:  1 0 LSHIFT -> 1
\              NE IF,                  \       so skip the shift if R0=1
\                 TOS R0 SRA,
\              ENDIF,
\              NEXT,
\              ENDCODE

HEX
CODE SRC ( n bits -- n')     \ non ANS Forth. Circular shift. Nice!
           C004 ,  \  TOS R0  MOV,
           C136 ,  \ *SP+ TOS MOV,
           0B04 ,  \  TOS R0  SRC,
           NEXT,
           ENDCODE

\ fast 1 instruction, 1 bit shifters
CODE SHL  ( u -- u') \ shift left 1 bit
          TOS 1 SLA,
          NEXT,
          ENDCODE

CODE SHR  ( u -- u') \ shift right 1 bit
          TOS 1 SRL,
          NEXT,
          ENDCODE

