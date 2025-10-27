\ hardtime.fth  very un-cooperative but accurate

NEEDS MOV,  FROM DSK1.ASM9900
NEEDS .S    FROM DSK1.TOOLS

HERE
DECIMAL
CREATE _TMR     ( -- )         \ read the TMS9901 timer
    0 LIMI,
    R12 2 LI,       \ cru address for timer 
    -1 SBO,         \ SET bit 0 TO 1, Enter timer mode
    R0 14 STCR,     \ read timer (14 bits)
    -1 SBZ,         \ reset bit 1, exit timer mode
    RT,

CODE 1MS ( -- )   
    _TMR @@ BL,     \ read time to R0
    R0 R1 MOV,      \ dup time into R1 
    BEGIN,
        _TMR @@ BL, \ read time again 
        R1 R0 SUB,  \ subtract from dupped read
        R0 ABS,     
        R0 46 CI,   \ compare to 46. ~= 1000uS
    GTE UNTIL, 
    2 LIMI,
    NEXT,
ENDCODE

: HARDMS ( n -- ) 0 ?DO 1MS LOOP ; 

HERE SWAP -  . .( bytes)


