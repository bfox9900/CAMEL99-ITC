\ CRU TEST replicates the ASM code in Forth   Feb 2024 B Fox 

\ *--------------------------------------------
\ * Quick-and-dirty check to see if a key is pressed. 
\ * If not return in a hurry, 
\ * else call the standard scanning routine.
\ * Uses R1, R2 and R12.
\ *--------------------------------------------
\ KCHECK CLR  R1                 Start with column 0
\ LP1    LI   R12,>0024          R12-address for column selection
\        LDCR R1,3               Select a column
\        LI   R12,>0006          R12-address to read rows
\        SETO R2                 Make sure all bits are 1
\        STCR R2,8               Get 8 row values
\        INV  R2                 Since pressed keys read as 0
\        JNE  KPR                A key was pressed
\        AI   R1,>0100           Next column
\        CI   R1,>0600           Are we done
\        JNE  LP1                Not yet
\        B    *R11               No key pressed: return (with EQ bit set)

NEEDS DUMP FROM DSK1.TOOLS
NEEDS LDCR FROM DSK1.CRU-SRC 
INCLUDE DSK1.FORGET 
\ LDCR ( data bits CRU-- )
\ STCR ( bits cru --- n )

HEX 
: COLUMN ( n -- )
    3 24 LDCR              \ Select a column
       6 CRUC@             \ Get 8 row values
     INVERT                \ Since pressed keys read as 0
     FF AND                \ we only read 8 bits. Mask off the rest
; 

: KCHECK ( -- n)
    0 COLUMN 
    7 1 \ columns 1 to 6 
    DO 
       I COLUMN OR  \ read each keyboard column, or results
    LOOP ;     

: TESTCHECK 
    BEGIN 
      KCHECK U.
      ?TERMINAL 
    UNTIL    
;

