
CODE TICKS  ( n -- )         \ read the TMS9901 timer
             0 LIMI,
             R12 2 LI,      \ cru = 1 (honest, 2=1)
             -1 SBO,         \ SET bit 0 TO 1, Enter timer mode
             R1 0E STCR,     \ READ TIMER (14 bits)
             -1 SBZ,         \ RESET bit 1, exit timer mode
             R1 TOS ADD,     \ add R1 to n
             BEGIN,
               -1 SBO,         \ SET bit 0 TO 1, Enter timer mode
                R1 0E STCR,    \ READ TIMER (14 bits)
               -1 SBZ,         \ RESET bit 1, exit timer mode
                R1 TOS CMP,
             LTE UNTIL,
             2 LIMI,
             NEXT,
             ENDCODE
