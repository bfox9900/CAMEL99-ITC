 \ clever version is taken from Win32For. No JUMPS!

NEEDS .S   FROM DSK1.TOOL
NEEDS POP, FROM DSK1.ASM9900

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
                    R1   POP,
                    R3   POP,
                R1  TOS  SUB,
                R1  R3   SUB,
                TOS R3   SUB,
                TOS TOS  SUB,
                OC IF,
                  TOS DEC,   \ emulate sbb instruction
                ENDIF,

               NEXT,
ENDCODE
