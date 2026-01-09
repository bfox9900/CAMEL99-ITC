
\ test programs
VARIABLE X
VARIABLE Y
VARIABLE Z

JIT: C@TEST \ pass
    X C@
;JIT

DECIMAL
CREATE Q 100 CELLS  ALLOT

JIT: ]Q \ pass
   2* Q +
;JIT

JIT: ]Q@ \ PASS
    ]Q @
;JIT

\ COMPILED LITERAL TEST
JIT: [2]Q
   2 ]Q
;JIT


\ with a literal and an addr, order does not matter
JIT: 8Q+
    8 Q +
;JIT

JIT: Q8+
   Q  8 +
;JIT


\ =====================================

JIT: FOLDTEST
    2 2 +
    3 +
    4 +
    5 +
    6 +
    7 +
    8 +
;JIT
\ Code output
\   DCCE  0646  dect R6                     (14)
\   DCD0  C584  mov  R4,*R6                 (30)
\   DCD2  0204  li   R4,>0025               (20)
\   DCD6  045A  b    *R10                   (16)
