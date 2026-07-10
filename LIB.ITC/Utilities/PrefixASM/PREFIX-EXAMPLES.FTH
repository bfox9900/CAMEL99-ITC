\ Examples for RAM prefix Assembler

\ structured looping ...
CODE LOOP1
    PUSH TOS
    LI   TOS,-1
    BEGIN
        INC R0
        INC R1
        MOV R1,R2
        ADD R0,R2
        DEC TOS
    UNTIL EQ
    TOS POP,
    RET/NEXT
ENDCODE

CODE LOOP2
    PUSH TOS
    LI TOS,-1
    BEGIN
        DEC TOS
    WHILE NE
        INC R0
        INC R1
        MOV R1,R2
        ADD R0,R2
    REPEAT
    POP TOS
    RET/NEXT
ENDCODE


\ label based looping for the same code as above
CODE LOOP3
        PUSH TOS
        LI  TOS,-1
1 $:    DEC TOS
        INC R0
        INC R1
        MOV R1,R2
        ADD R0,R2
        JNE 1 $
        TOS POP,
        RET/NEXT
ENDCODE

CODE LOOP4
        PUSH TOS
        LI TOS,-1
1 $:    DEC TOS
        JEQ 2 $
        INC R0
        INC R1
        MOV R1,R2
        ADD R0,R2
        JMP 1 $
2 $:    POP TOS
        RET/NEXT
ENDCODE

\ Forth primitve examples
CODE +
    ADD *SP+,TOS
    RET/NEXT
ENDCODE

CODE UM/MOD ( ud u1 -- u2 u3 ) \ numerator(32bits), divisor -- rem,quot
    MOV TOS,R0
    MOV *SP+,TOS
    MOV *SP,R5
    DIV R0,TOS
    MOV R5,*SP
    RET/NEXT
ENDCODE

CODE MOVE  ( src dst u -- ) \ u = no. of *CELLS* to move
    POP R0
    POP R1
    BEGIN
       DEC TOS
    WHILE OC
       MOV *R1+,*R0+
    REPEAT
    POP TOS
    RET/NEXT
ENDCODE

\ equate test
L: QADDR EQU >2000  \ accepts '>' for HEX

CODE TESTEQU
    PUSH TOS
    LI R0,BEEF   \ load a literal number
    LI R4,QADDR  \ load an Equate
    RET/NEXT
ENDCODE

\ memory access
VARIABLE X
VARIABLE Y

CODE VARTEST
        CLR  X @@
        SETO Y @@

1 $:    INC X @@
        DEC Y @@
        JNE 1 $

        MOV X @@,Y @@
        RET/NEXT
ENDCODE

CODE VARTEST2
        LI R0,X
        SETO Y @@

1 $:    INC *R0    \ incr. X indirectly
        DEC Y @@
        JNE 1 $

        MOV X @@,Y @@
        RET/NEXT
ENDCODE


FORTH