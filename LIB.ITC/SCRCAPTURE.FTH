\ ti-99 screen capture utility for CAMEL99 Forth  BJF Jan 2019

NEEDS WRITE-LINE FROM DSK1.ANSFILES
NEEDS -TRAILING FROM DSK1.TRAILING

VARIABLE HNDL

: (CAPTURE) ( -- )
         VROW 2@ 2>R                       \ save screen xy
         L/SCR 0                           \ capture all lines
         DO                              
           0 I AT-XY                       \ position cursor
           VPOS PAD C/L@ VREAD             \ read VDP position->PAD
           PAD C/L@ -TRAILING
           ( addr len) HNDL @ WRITE-LINE ?FILERR
         LOOP
         HNDL @ CLOSE-FILE ?FILERR
         2R> AT-XY ;                      \ restore screen xy

: CAPTURE  ( <PATH> )
           BL PARSE-WORD ( -- caddr len )
           DV80  W/O OPEN-FILE ?FILERR HNDL !
           (CAPTURE) ;

\ usage:   
\   CAPTURE DSK1.MYSCREEN
\ Special case for Classic99:
\   CAPTURE CLIP ( copy screen into windows clip buffer)





