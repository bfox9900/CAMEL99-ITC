 \ clever version is taken from Win32For. No JUMPS!

NEEDS .S   FROM DSK1.TOOLS
NEEDS POP, FROM DSK1.ASM9900

\ : WITHIN ( u lo hi -- t ) OVER - -ROT - U> ;  \ -ROT is faster on 9900
                \ cx ax bx
\ CODE within    ( n lo hi -- flag )
\                ax pop.
\                cx pop.
\                bx ax sub.
\                cx ax sub.
\                cx bx sub.
\                bx bx sbb.
\                next.
\ end-code

\ translated to 9900 Forth Assembler
CODE WITHIN2    ( n lo hi -- flag )
               TOS R3 MOV,
               TOS SETO,
               R1 POP,     \ r1=lo
               R2 POP,     \ R2=n
               R2 R1 CMP,
               LT IF, TOS CLR, ENDIF,
               R2 R3  CMP,
               GTE IF, TOS CLR, ENDIF,
               NEXT,
               ENDCODE

DECIMAL
 5  1 10 WITHIN2 .
 1  1 10 WITHIN2 .
 9  1 10 WITHIN2 .

10  1 10 WITHIN2 .
-8  1 10 WITHIN2 .


             \  cx ax  bx
             \  R1 R0 tos
CODE WITHIN   ( n  lo  hi -- flag )
               R0  POP,
               R1  POP,
               R0  TOS SUB,
               R0  R1  SUB,
               TOS R1  SUB,
               NC  IF, TOS SETO,
               ELSE, TOS CLR, ENDIF,
               NEXT,
               ENDCODE
 DECIMAL
 5  1 10 WITHIN  .
 1  1 10 WITHIN  .
 9  1 10 WITHIN  .

10  1 10 WITHIN  .
-8  1 10 WITHIN  .

