\ Edit this script to build a Custom Forth system the way you want it

INCLUDE DSK1.MARKER

MARKER  Kernel   \ this will remove everything  except the kernel
\                  (case sensitive)

\ add the files you want in the final program
INCLUDE DSK1.ASM9900
INCLUDE DSK1.ELAPSE
INCLUDE DSK1.TOOLS
INCLUDE DSK1.SOUND

\ Add your favourite words here
: SCREEN  ( fg bg -- ) SWAP 4 LSHIFT SWAP OR  7 VWTR ;

\ make a new boot word to start the way you like things
HEX
: COLD
     WARM        \ Must have this to "warm" boot Forth first.
     F 1 SCREEN  \ white on black
     DECIMAL
     ABORT
;

LOCK  \ locks the dictionary to everything before this point on boot

INCLUDE DSK1.SAVESYS  \ Now this will not be saved in the final program

\ save your new forth system
' COLD SAVESYS DSK5.MYFORTH
