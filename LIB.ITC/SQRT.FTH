\ integer square root in Forth.  Not too fast but small
\ *WARNING* The 16 bit limit is:  65000 SQRT . 254

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

\ By Albert Van der Horst, comp.lang.forth, Aug 29, 2017
\ For n return FLOOR of the square root of n.
DECIMAL
: SQRT ( n -- )
  DUP
  IF
     >R
     1  \ 1st seed
     R@ OVER U/ OVER + 2/ NIP ( DUP . ) \ debug viewing
     BEGIN
        R@ OVER U/ OVER + 2/  ( DUP .)
        2DUP >
     WHILE
        NIP
     REPEAT
     DROP
     R> DROP
  THEN ;
