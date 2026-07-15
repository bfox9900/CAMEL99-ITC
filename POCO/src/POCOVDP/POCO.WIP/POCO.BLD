\ POCO,MAK        FEB 2026 BJFOX

\ text editor build file for  VDP RAM file storage 20Feb26 BJF

\ library includes
NEEDS DUMP      FROM DSK1.TOOLS
NEEDS CASE      FROM DSK1.CASE
NEEDS MARKER    FROM DSK1.MARKER
NEEDS RKEY      FROM DSK1.RKEY
NEEDS -TRAILING FROM DSK1.TRAILING
NEEDS MARKER    FROM DSK1.MARKER

NEEDS 80COLS FROM DSK1.80COL
 80COLS

MARKER /POCO
INCLUDE DSK1.DIR   \ handy when you are editing files

HERE
\ Editor specific includes
NEEDS READ-FILE FROM DSK2.FILE2VDPB
INCLUDE DSK2.POCOUTILS
INCLUDE DSK2.POCODATA
INCLUDE DSK2.POCOSCREEN
INCLUDE DSK2.WRITEBACK
INCLUDE DSK2.TEXTCTRL
INCLUDE DSK2.COPYPASTE

INCLUDE DSK2.POCOEDITLN

INCLUDE DSK2.POCODISK

CR
CR .( >> POCO editor compiled normally)
CR
HERE SWAP - CR DECIMAL . .( Bytes used)

\ debugging stuff
\ : '   ' ;  \ debug tool
\ : WORDS  WORDS ;

DECIMAL
: POCO ( -- ) \ system startup word
    WARM 80COLS
\   ." Camel99 SUPERCART + Poco Editor 0.9"
    ." Camel99 FORTH + Poco Editor 0.9"
    ENDHEAP H ! \ set the heap memory pointer
    ABORT ;


   LOCK
\
\ everthing after LOCK will not be in the image
\

 HEX 2000 H ! \ reset heap so it won't save as a file
 DECIMAL
  CR

CR .(  Save the program for CAMEL99 FORTH)
INCLUDE DSK1.SAVESYS
' POCO  SAVESYS DSK1.POCOFORTH

DECIMAL
: COUNTDOWN  0 SWAP DO I .  500 MS  -1  +LOOP 100 MS ;

CR
CR .( Build complete. Restarting in ...)
CR 3 COUNTDOWN
COLD
