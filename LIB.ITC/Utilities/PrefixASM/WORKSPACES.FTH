\ L: and workspace example


CODE TEST1
    LI   R0,-1
    BEGIN
        INC R1
        INC R2
        INC R3
        INC R4
        INC R5

        DEC R0
    UNTIL EQ
    RET/NEXT
    \ RTWP  \ return to previous workspace

L: WRKSP1  16 CELLS ALLOT  WRKSP1 16 CELLS ERASE
L: VECTOR1   WRKSP1 , TEST1 ,

\ CODE words can be called directly from Forth
CODE WORKSPACE-FUN
    BLWP VECTOR1 @@

    RET/NEXT
ENDCODE



L:  TEST2
    BLWP VECTOR1 @@

    LI   R0,-1
    BEGIN
        DEC R1
        DEC R2
        DEC R3
        DEC R4
        DEC R5

        DEC R0
    UNTIL EQ
    RTWP

L: WRKSP2    16 CELLS ALLOT
L: VECTOR2   WRKSP2 , TEST2 ,



L: TEST3
    BLWP VECTOR2 @@

    LI   R0,-1
    BEGIN
        DECT R1
        DECT R2
        DECT R3
        DECT R4
        DECT R5

        DEC R0
    UNTIL EQ
    RTWP

L: WRKSP3    16 CELLS ALLOT
L: VECTOR3   WRKSP3 , TEST3 ,


L: ?TERMINAL EQU >0020    \ ROM "break" key reader sub-routine
