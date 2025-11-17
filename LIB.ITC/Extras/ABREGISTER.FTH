 \ ABREGISTER.FTH    for Camel99 Forth    Brian Fox 2025

 \ Source:
 \ Updating the Forth Virtual Machine, EuroForth 2008
 \ Stephen Pelc
 \ MicroProcessor Engineering

\  A and B REGISTERS
\  The A and B registers provide source and destination address pointers
\  as well as providing scratch storage.

NEEDS DUMP  FROM DSK1.TOOLS
NEEDS ELAPSE FROM DSK1.ELAPSE
NEEDS MOV,  FROM DSK1.ASM9900

R1 CONSTANT AREG
R2 CONSTANT BREG

\ x --  Writes to the A register.
CODE >A    TOS AREG MOV,     TOS POP, NEXT, ENDCODE
\ x --  Writes to the B register.
CODE >B    TOS BREG MOV,     TOS POP, NEXT, ENDCODE

\ -- x  Reads the A register.
CODE A>    TOS PUSH, AREG    TOS MOV, NEXT, ENDCODE
\ -- x  Reads the B register.
CODE B>    TOS PUSH, AREG    TOS MOV, NEXT, ENDCODE

\ -- x  Read the memory pointed to by the A register.
CODE A@    TOS PUSH, AREG ** TOS MOV, NEXT, ENDCODE
\ x --   Write the memory pointed to by the A register
CODE A!    TOS AREG ** MOV,  TOS POP, NEXT, ENDCODE

CODE A@    TOS PUSH, AREG ** TOS MOV, NEXT, ENDCODE \ -- x
CODE A!    TOS AREG ** MOV,  TOS POP, NEXT, ENDCODE \ x --

\ -- x  Read memory pointed to by A, increment A by one cell. A post-inc.
CODE A@+   TOS PUSH, AREG *+ TOS MOV, NEXT, ENDCODE
\ -- x  Read memory pointed to by B, increment B by one cell. A post-inc.
CODE B@+   TOS PUSH, BREG *+ TOS MOV, NEXT, ENDCODE

\ -- x  Read memory pointed to by A, decrement A by one cell. A post-dec.
CODE A@-   TOS PUSH, AREG TOS MOV, AREG DECT, NEXT, ENDCODE
\ -- x  Read memory pointed to by B, decrement B by one cell. A post-dec.
CODE B@-   TOS PUSH, BREG TOS MOV, BREG DECT, NEXT, ENDCODE

\ x -   Write to the memory pointed to by A, and update A.
CODE A!+   TOS AREG *+ MOV,  TOS POP, NEXT, ENDCODE
\ x -   Write to the memory pointed to by B, and update B.
CODE B!+   TOS BREG *+ MOV,  TOS POP, NEXT, ENDCODE

\ Not always needed, but it is safer to save registers before using
CODE {   AREG RPUSH,  BREG RPUSH,  NEXT, ENDCODE \ Save A & B
CODE }   BREG RPOP,   AREG RPOP,   NEXT, ENDCODE \ restore A & B

\ TEST CODE
HEX
: INITMEM ( c -- ) >R 2000 1000 R> FILL ;

: FORTHCOPY  ( addr addr len --)
    BOUNDS
    DO
        DUP @ I !
        2+
    2 +LOOP
;

: ABCOPY ( addr addr len --)
  {
    -ROT >B >A
    2/ 0 DO  \ iterate len/2 times because auto-incr. moves 2 bytes
       A@+ B!+
    LOOP
  }
;

\ COPY 8k bytes
HEX
: TEST1  A000 2000 2000 FORTHCOPY ; \ 1.36
: TEST2  A000 2000 2000 ABCOPY ;    \ 0.65

\ better way to use A & B registers for the 9900
CODE A@+>B!+   AREG *+ BREG *+ MOV,  NEXT, ENDCODE

: FASTCOPY ( addr addr len --)
  {
    -ROT >B >A
    2/ 0 DO   \ interate len/2 times
       A@+>B!+
    LOOP
  }
;

: TEST3   A000 2000 2000 FASTCOPY ; \ 0.40

\ 16 bit Assembly language
: TEST4   A000 2000 2000 MOVE ; \ .25
