\ DEVSYS.fth   build a big system on SUPERCART Forth  Nov 2022 Brian Fox

INCLUDE DSK1.MARKER

MARKER *REMOVE*

\ Load what you need here
INCLUDE DSK1.WORDLISTS
INCLUDE DSK1.ANSFILES

INCLUDE DSK1.TOOLS
INCLUDE DSK1.ELAPSE
INCLUDE DSK1.CATALOG
INCLUDE DSK1.DIR
INCLUDE DSK1.MORE


VOCABULARY ASSEMBLER
ONLY FORTH ALSO ASSEMBLER DEFINITIONS
INCLUDE DSK1.ASM9900
INCLUDE DSK1.ASMLABELS

ONLY FORTH ALSO ALSO ASSEMBLER ALSO FORTH DEFINITIONS
: REBOOT
  WARM  INIT-WORDLISTS
  ONLY FORTH ALSO ASSEMBLER ALSO FORTH DEFINITIONS
  CR CR ." Development System" CR  .FREE  
  CR ORDER 
  ABORT ;

LOCK
INCLUDE DSK1.SAVESYS

' REBOOT SAVESYS DSK7.CAMELFORTH
