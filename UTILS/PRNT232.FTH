\ Print the contents of a DV80 file using LINPUT

NEEDS DUMP FROM DSK1.TOOLS
NEEDS OPEN-FILE FROM DSK1.ANSFILES
NEEDS TTYEMIT   FROM DSK1.9902B


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

: TTY-TYPE   ( adr len -- ) BOUNDS DO I C@ TTYEMIT LOOP ;
: PRINT$     ( $ -- ) TTYCR COUNT TTY-TYPE
: BA=9600    ( -- )


: PRINTFILE ( addr len -- ) \
     	DISPLAY 80 VARI SEQUENTIAL R/O OPEN-FILE ?FILERR #1 !
        TTY1 OPEN-TTY
        BEGIN
          REC$ #1 @ LINPUT
          REC$ PRINT$
	  #1 @ EOF
        UNTIL
        #1 @ CLOSE-FILE ?FILERR
;


