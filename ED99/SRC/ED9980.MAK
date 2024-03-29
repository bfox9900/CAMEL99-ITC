\ ED99 SAMS memory file editor for CAMEL99 Forth Jan 24 2021 Brian Fox
\ Binary program created with SAVESYS at end of file
\ Revised JUN 3, 2022. New RKEY code. New SAVESYS

\ NEEDS .S        FROM DSK1.TOOLS
NEEDS 80COLS    FROM DSK1.80COL

( must switch mode to change the screen size variables)
   80COLS   

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ LOAD the common code for 40 and 80 column versions

INCLUDE DSK4.ED99COMMON

\ /////////////////////////////////////////////////////////////

\ Create the BOOT word for the editor program
DECIMAL
: EDITINIT      ( -- )
        80COLS
        CR ." ED99 Multi-file Editor V1.74 Mar2024"
        CR ." Built on Kernel " .VER
        1000 MS
        #CLIPS OFF  INIT-EVARS  DECIMAL
        CR S" ED99CONFIG" +PATH INCLUDED
        INVERTFONT    SAMS-ON
        SETUP PROMPT: ." Ready "
        ABORT ;

: EDSTART    WARM   EDITINIT ;


  CR ." ED99 loaded. "
  HERE SWAP - DECIMAL . .( bytes used)

LOCK

\ These lines will overwrite the existing binary program
  INCLUDE DSK1.SAVESYS
: LASTCHANCE 
  CR 
  CR ." *WARNING* Press capital 'Y' to OVERWRITE ED9980 program" 
  KEY [CHAR] Y <> ABORT" build aborted"
; 

LASTCHANCE 

' EDSTART SAVESYS DSK4.ED9980
