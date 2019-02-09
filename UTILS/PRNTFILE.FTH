\ Print the contents of a DV80 file using LINPUT

INCLUDE DSK1.TOOLS
INCLUDE DSK1.ANSFILES

\ linput reads file record into a counted string

: LINPUT  ( $ handle -- )
            >R DUP 1+ R>  ( -- $ $+1 handle)
            SELECT                        \ select the correct PAB
            2 FILEOP ?FILERR              \ read operation, test error#
            [PAB FBUFF] V@  SWAP [PAB RECLEN] VC@  VREAD
            [PAB CHARS] VC@ SWAP C!       \ update string length
;  

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


