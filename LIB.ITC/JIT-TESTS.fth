
\ test program
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

\ with a literal and an addr, order does not matter
JIT: 8Q+
    8 Q +
;JIT

JIT: Q8+
   Q  8 +
;JIT

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



JIT: [2]Q
   2 ]Q
;JIT

HEX
: FORTHTEST
    2000 0
    DO
       I X !
       X C@ Y !
       Y @ Z !
    LOOP
;

JIT: JITTEST
    2000 0
    DO
       I X !
       X C@ Y !
       Y @ Z !
    LOOP
;JIT

\ resulting code
   DCE8  0646  dect R6                     (14)
   DCEA  C584  mov  R4,*R6                 (30)
   DCEC  0204  li   R4,>2000               (20)
   DCF0  0646  dect R6                     (14)
   DCF2  C584  mov  R4,*R6                 (30)
   DCF4  0204  li   R4,>0000               (20)
\ Set up DO/LOOP
   DCF8  0200  li   R0,>8000               (20)
   DCFC  6036  s    *R6+,R0                (30)
>  DCFE  A100  a    R0,R4
   DD00  0647  dect R7
   DD02  C5C0  mov  R0,*R7
   DD04  0647  dect R7
   DD06  C5C4  mov  R4,*R7
   DD08  C136  mov  *R6+,R4
                                  \ DO begins
   DD0A  0646  dect R6            \ I
   DD0C  C584  mov  R4,*R6
   DD0E  C117  mov  *R7,R4
   DD10  6127  s    @>0002(R7),R4
   DD14  C804  mov  R4,@>dc90     \ X !
   DD18  D120  movb @>dc90,R4     \ X C@
   DD1C  0884  sra  R4,8                   (32)
>  DD1E  C804  mov  R4,@>dc9a     \ Y !
   DD22  C120  mov  @>dc9a,R4     \ Y @
   DD26  C804  mov  R4,@>dca4     \ Z !
   DD2A  C136  mov  *R6+,R4       \ drop

   DD2C  0597  inc  *R7           \ LOOP
   DD2E  19ED  jno  >dd0a
   DD30  0227  ai   R7,>0004
   DD34  045A  b    *R10

\ ' TEST1 >BODY
\ .S
SP@ SP!



\ DEBUG VERSION
: ;JIT ( JIT-XT -- )
    PREVIOUS          \ restore previous search order
    FORTH-COMPILER
    JSTATE OFF
    NEXT,            \ compile NEXT at end of new code word
    ARG? IF CR ." WARNING: LIT stack contains " CR ." >> ".ARGS THEN
    ?CS              \ check control flow stack
    CR .S
; IMMEDIATE


   : FORTHADD  2000 0 DO  2  3 +  DROP  LOOP ;
JIT: JITADD    2000 0 DO  2  3 +  DROP  LOOP ;JIT
