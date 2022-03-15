\ integer square root for Camel99 Forth                   Mar 2022 Brian Fox
\ By Albert Van der Horst, comp.lang.forth, Aug 29, 2017
\ For n return FLOOR of the square root of n.

\ *WARNING* The 16 bit limit is:  65535 SQRT . 254

\ This is 10x faster than linear method
\ : SQRT ( n -- n ) -1 TUCK DO   2+  DUP +LOOP   2/ ;
\
\ INCLUDE DSK1.TOOLS  \ for testing only
\ INCLUDE DSK1.ELAPSE \  "   "       "

\ : U/  ( u1 u2 -- u3 )  0 SWAP UM/MOD NIP ;
\ machine code is same size as Forth
HEX
CODE U/   ( u1 u2 -- u3 ) \ unsigned division
    C004 ,  \   TOS R0 MOV,   \ divisor->R0
    04C4 ,  \      TOS CLR,   \ high word in TOS = 0
    C176 ,  \ *SP+  R5 MOV,   \ MOVE low word to r5
    3D00 ,  \   R0 TOS DIV,
    NEXT,
ENDCODE

DECIMAL
: INIT-SEED ( n -- n n') DUP 10 RSHIFT 8 MAX ; \ for 16 bits only

: SQRT ( n -- )
  DUP
  IF
     DUP >R
  \    INIT-SEED   ( optimized seed value) \ 64516 SQRT : 5000x 16.4 seconds
      1   ( default seed value )          \ 64516 SQRT : 5000x 31.1 seconds
     R@ OVER U/ OVER + 2/ NIP ( DUP . ) \ debug viewing
     BEGIN
        R@ OVER U/ OVER + 2/  ( DUP .)
        2DUP >
     WHILE
        NIP
     REPEAT
     DROP
     NIP
     R> DROP
  THEN ;

\ speed testing
: ROOTS ( n1 cnt -- n) 0 ?DO  DUP SQRT DROP  LOOP DROP ;
