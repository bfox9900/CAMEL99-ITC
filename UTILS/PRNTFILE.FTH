\ Print the contents of a DV80 file
INCLUDE DSK1.TOOLS.F
INCLUDE DSK1.ANSFILES.F
INCLUDE DSK1.LINPUT.F

\ Print the contents of a DV80 file
DECIMAL
VARIABLE #1                 \ this variable will hold the file handle
VARIABLE A$ 80 ALLOT        \ variable with 80 bytes of space

: SEEFILE ( addr len -- ) \
     	DISPLAY 80 VARI SEQUENTIAL R/O OPEN-FILE ?FILERR #1 !
        BEGIN
          A$ #1 @ LINPUT 
          A$ COUNT CR TYPE
	  EOF
        UNTIL
        #1 @ CLOSE-FILE ?FILERR
;


