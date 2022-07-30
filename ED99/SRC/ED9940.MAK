\ ED99 FILE editor, 40 columns, for CAMEL99 Forth Jan 24 2021 Brian Fox
\ Binary program created with SAVESYS at end of file
\ Revised JUN 3, 2022. New RKEY code. New SAVESYS

\ NEEDS .S        FROM DSK1.TOOLS

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
\ LOAD the common code for 40 and 80 column versions

INCLUDE DSK4.ED99COMMON

\ /////////////////////////////////////////////////////////////

\ Create the BOOT word for the editor program
DECIMAL
: EDSTART ( -- )
        WARM
        CR ." ED99 Multi-file Editor V1.73"
        CR ." Built on Kernel " .VER
        #CLIPS OFF
        INIT-EVARS
        DECIMAL
        CR S" DSK1.ED99CONFIG" INCLUDED
        INVERTFONT
        SAMS-ON
        SETUP PROMPT: ." Ready "
        ABORT ;

  CR ." ED99 loaded. "
  HERE SWAP - DECIMAL . .( bytes used)

LOCK

\ These lines will overwrite the existing binary program
 INCLUDE DSK1.SAVESYS
' EDSTART SAVESYS DSK4.ED9940
