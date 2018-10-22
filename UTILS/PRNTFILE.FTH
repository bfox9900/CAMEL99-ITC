\ Print the contents of a DV80 file using LINPUT

INCLUDE DSK1.TOOLS
INCLUDE DSK1.ANSFILES
INCLUDE DSK1.LINPUT

\ Print the contents of a DV80 file
DECIMAL
VARIABLE #1                 \ this variable will hold the file handle
VARIABLE REC$ 80 ALLOT        \ variable with 80 bytes of space

: SEEFILE ( addr len -- ) \
     	DISPLAY 80 VARI SEQUENTIAL R/O OPEN-FILE ?FILERR #1 !
        BEGIN
          REC$ #1 @ LINPUT
          REC$ COUNT CR TYPE
	  #1 @ EOF
        UNTIL
        #1 @ CLOSE-FILE ?FILERR
;


