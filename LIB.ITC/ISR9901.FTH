\ Interrupt polled 9901 timer

NEEDS MOV,     FROM DSK1.LOWTOOLS
NEEDS INSTALL  FROM DSK1.ISRSUPPORT

DECIMAL
\ ISR workspace registers
\ R0,R1  32 bit timer variable
\ R2,    difference register
\ R3     temp
\ R4     previous time reading
CREATE IWKSP  16 CELLS ALLOT  IWKSP 16 CELLS 0 FILL

CODE READ9901
             0 LIMI,
             IWKSP LWPI,
             R2 CLR,
             R12 2 LI,      \ load 9901 Timer CRU address
            -1 SBO,         \ SET bit 0 TO 1, Enter timer mode
             R2 14 STCR,    \ READ TIMER (14 bits)
            -1 SBZ,         \ RESET bit 1, exit timer mode
            T
             2 LIMI,
             R4 R3 MOV,     \ old reading -> temp
             R2 R4 MOV,     \ save this read for next time
             R3 R2 SUB,     \ compute ticks since last read
             R2 ABS,
             R2 R1 ADD,     \ add ticks to timer registers
             OC IF,
                 R0 INC,    \ deal with overflow to make 32bit value
             ENDIF,
         HEX 83E0 LWPI,     \ return to GPL workspace
             RT,
ENDCODE

\ REMOVE-TOOLS

: T   ( -- ) IWKSP 2@  ;  \ read the workspace as memory

: COLD   0 INSTALL  COLD ;  \ disable interrupt before leaving Forth

ISR' READ9901 INSTALL

: TEST   PAGE  BEGIN  10 10 AT-XY  T DU.   ?TERMINAL UNTIL ;
