\ faster erase using CLR instruction WORD wide. Oct 2022  Brian Fox
HEX
CODE ERASEW    C076 , 04F1 , 0644 , 15FD , C136 ,  NEXT,  ENDCODE
DECIMAL
\ NEEDS CLR,  FROM DSK1.ASM9900
\ CODE ERASEW  ( addr cnt  -- ) \ 2.5x faster than 0 FILL
\  *SP+ R1 MOV,
\     BEGIN,
\       R1 *+ CLR,
\       TOS DECT,
\     LTE UNTIL,
\     TOS POP,
\     NEXT,
\ ENDCODE

CODE []TRUE ( addr cnt -- ) \ set memory cells to TRUE ( -1 )
    C076 ,  \    *SP+ R1 MOV,
            \    BEGIN,
    0731 ,  \        R1 *+ SETO,
    0644 ,  \        TOS DECT,
    15FD ,  \    LTE UNTIL,
    C136 ,  \    TOS POP,
    NEXT,
ENDCODE
