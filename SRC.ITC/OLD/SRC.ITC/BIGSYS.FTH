\ Edit this script to build a Custom Forth system the way you want it

INCLUDE DSK1.MARKER
INCLUDE DSK1.WORDLISTS

MARKER  Kernel   \ this will remove everything  except the kernel
\                  (case sensitive)

\ add the files you want in the final program
VOCABULARY ASSEMBLER
ONLY FORTH ALSO ASSEMBLER DEFINITIONS
INCLUDE DSK1.ASM9900

ONLY FORTH DEFINITIONS
INCLUDE DSK1.ELAPSE
INCLUDE DSK1.TOOLS
INCLUDE DSK1.DIR
INCLUDE DSK1.SOUND

\ Add your favourite words here
: SCREEN  ( fg bg -- ) SWAP 4 LSHIFT SWAP OR  7 VWTR ;

\ make a new boot word to start the way you like things
HEX
: START
     WARM           \ Must have this to "warm" boot Forth first.
     INIT-WORDLISTS \ must have this if we include wordlists/vocabulary
     1 E SCREEN     \ black on grey
     DECIMAL
     CR ." GD Forth for GDMike"
     ABORT          \ reset the interpreter with ABORT
;

LOCK  \ locks the dictionary to everything before this point on boot

INCLUDE DSK1.SAVESYS  \ Now this will not be saved in the final program

\ save your new forth system
' START SAVESYS DSK5.GDFORTH
