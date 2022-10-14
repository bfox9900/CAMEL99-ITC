\ faster erase using CLR instruction WORD wide.  

NEEDS CLR,  FROM DSK1.ASM9900

CODE ERASEW  ( addr cnt  -- ) \ 2.5x faster than 0 FILL
    *SP+ R1 MOV,
     BEGIN,
       R1 *+ CLR,
       TOS DECT,
     LTE UNTIL,
     TOS POP,
     NEXT,
 ENDCODE

CODE SETW  ( addr cnt  -- )
    *SP+ R1 MOV,
     BEGIN,
       R1 *+ SETO,
       TOS DECT,
     NC UNTIL,
     TOS POP,
     NEXT,
ENDCODE
