\ POCOSC,MAK        FEB 2026 BJFOX
CR .( Compiling POCO VDP storage  editor)
CR .( for CAMEL99 SuperCart FORTH and expansion RAM.)

\ text editor build file for VDP RAM file storage 20Feb26 BJF

CR .( library includes ...)
CR
NEEDS DUMP      FROM DSK1.TOOLS
NEEDS CASE      FROM DSK1.CASE
NEEDS MARKER    FROM DSK1.MARKER
NEEDS RKEY      FROM DSK1.RKEY
NEEDS -TRAILING FROM DSK1.TRAILING
NEEDS COMPARE   FROM DSK1.COMPARE
NEEDS SEARCH    FROM DSK1.SEARCH
NEEDS MARKER    FROM DSK1.MARKER

NEEDS 80COLS FROM DSK1.80COL
 80COLS

MARKER /POCO
CR .( Reset HEAP to >2000)  HEX 2000 H !

DECIMAL

HERE
CR .( Editor specific includes...)
CR
INCLUDE DSK2.FILE2VDPB
INCLUDE DSK2.POCOUTILS
INCLUDE DSK2.POCODATA
INCLUDE DSK2.POCOSCREEN
INCLUDE DSK2.WRITEBACK
INCLUDE DSK2.TEXTCTRL
INCLUDE DSK2.COPYPASTE
INCLUDE DSK2.POCOEDITLN
INCLUDE DSK2.POCODISK
INCLUDE DSK2.DIR
INCLUDE DSK2.POCOFINDER

\ ' FNEXT IS FIND-TEXT

CR .( FIND and FNEXT commands are installed)
CR
CR .( >> POCO editor compiled normally)
CR
HERE SWAP - CR DECIMAL . .( Bytes used)

\ debugging stuff
\ : '   ' ;  \ debug tool
\ : WORDS  WORDS ;

DECIMAL
: .VER   ." Version  0.96" ;

: POCO ( -- ) \ system startup word
    WARM 80COLS
    ." Camel99 SuperCart Forth + Poco Editor " .VER
    DEBUG ON
    ENDHEAP H ! \ set the heap memory pointer
    ABORT ;

 LOCK
\ ** everything after LOCK does NOT go into the program image

 HEX 2000 H ! \ reset heap so it won't save as a file
 DECIMAL

CR .(  Save program for CAMEL99 SuperCart)
INCLUDE DSK1.SUPERSAVE
' POCO  SUPERSAVE DSK2.POCO-SC

DECIMAL
: COUNTDOWN  1 SWAP DO I .  500 MS  -1  +LOOP 100 MS ;

CR
CR .( Build complete. Restarting in ...)
CR 3 COUNTDOWN
COLD
