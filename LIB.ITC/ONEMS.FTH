\ HARD millisecond timer.

NEEDS MOV,  FROM DSK1.ASM9900
NEEDS .S    FROM DSK1.TOOLS

MARKER REMOVE
DECIMAL
CREATE T     ( -- )         \ read the TMS9901 timer
    0 LIMI,
    R12 2 LI,      \ cru = 1 (honest, 2=1)
   -1 SBO,         \ SET bit 0 TO 1, Enter timer mode
    R0 14 STCR,    \ READ TIMER (14 bits)
   -1 SBZ,         \ RESET bit 1, exit timer mode
    RT,


DECIMAL
36 CONSTANT TICKS/MS

CODE 1MS ( -- )         \ read the TMS9901 timer
      T @@ BL,
      R0 R1 MOV,
      BEGIN,
          T @@ BL,
          R1 R0 SUB,
          R0 ABS,
          R0 TICKS/MS CI,
      GTE UNTIL,
      2 LIMI,
      NEXT,
      ENDCODE

: MS  ( n -- )  0 ?DO 1MS LOOP ;
