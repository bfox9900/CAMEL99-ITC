\ Code in nested workspaces example  BFox 2026

ONLY FORTH ALSO ASSEMBLER ALSO FORTH DEFINITIONS

DECIMAL
CREATE WRKSP1    16 CELLS ALLOT
CREATE WRKSP2    16 CELLS ALLOT
CREATE WRKSP3    16 CELLS ALLOT

WRKSP1 PROG: PROG1
    LI   R0,>FFFF
    BEGIN
        INC R1
        INC R2
        INC R3
        INC R4
        INC R5
        MOV R5,@>2000
        MOV @>2000,@>2020
        MOV @>2020,R6

        DEC R0
    UNTIL EQ
    RTWP       \ return to previous workspace
;PROG


WRKSP2 PROG: PROG2
    BLWP @PROG1
    LI   R0,>FFFF
    BEGIN
        DEC R1
        DEC R2
        DEC R3
        DEC R4
        DEC R5
        MOV R5,@>2002
        MOV @>2002,@>2022
        MOV @>2022,R6


        DEC R0
    UNTIL EQ
    RTWP
;PROG


WRKSP3 PROG: PROG3
    BLWP @PROG2
    LI   R0,>FFFF
    BEGIN
        DECT R1
        DECT R2
        DECT R3
        DECT R4
        DECT R5
        MOV  R5,@>2004

        MOV  @>2004,@>2024
        MOV @>2024,R6

        DEC R0
    UNTIL EQ
    RTWP
;PROG


CODE NESTED
    BLWP @PROG3   \ vector3 calls vector2 which calls vector1
    RET/NEXT       \ return to Forth
ENDCODE
