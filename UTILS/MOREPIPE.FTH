\ more.fth  simple file viewer
\ default is DV80 files but you can change it with TI-99 file commands

HEX
\ : DV80    DISPLAY 50 VARI SEQUENTIAL ;  \ moved to ANSFILES

NEEDS OPEN-FILE  FROM DSK1.ANSFILES

HEX
\ : DV80    DISPLAY 50 VARI SEQUENTIAL ;  \ moved to ANSFILES
VARIABLE INPUT
VARIABLE OUTPUT

: OPEN-INPUT  ( addr len -- ) OPEN-FILE ?FILERR  INPUT ! ;
: OPEN-OUTPUT ( addr len -- ) OPEN-FILE ?FILERR  OUTPUT ! ;

: FREAD  ( hndl --)  SELECT  2 FILEOP ?FILERR ;
: FWRITE ( hndl --)  SELECT  3 FILEOP ?FILERR ;
: FCLOSE ( hndl --)  CLOSE-FILE ?FILERR ;

: FBUFFER ( address hndl -- ) SELECT [PAB FBUFF] V! ;
: PIPE:  PARSE-NAME DV80 OPEN-OUTPUT ;

: ?INPUT  INPUT @ 0= ABORT" No input defined" ;

\ makes input [PAB FBUFF] the output [PAB FBUFF]
\ Read data is written from the input [pab  :-) 
: FPIPE  (  hndl -- ) 
    DUP 
    IF 
      INPUT @ SELECT 
      [PAB FBUFF] V@ SWAP SELECT [PAB FBUFF] V! 
    THEN 
;

\ PIPE: DSK2.MYOUTPUT MORE DSK6. 

: INPUT.TYPE ( -- ) INPUT @ SELECT PAD DUP FGET TYPE ;

: FILE.TYPE  ( -- )  
  INPUT @  SELECT [PAB CHARS] VC@ ( -- n )
  OUTPUT @ SELECT [PAB CHARS] VC!  
  FWRITE 
;

: WRITE.OUTPUT ( HNDLE)
  0= IF INPUT.TYPE 
  ELSE  FILE.TYPE 
  THEN 
;

: MORE ( <filename>)
    PARSE-NAME DV80 OPEN-INPUT 
    OUTPUT @ PIPE 
    BEGIN
     INPUT @ FREAD  OUTPUT @ WRITE.OUTPUT 
      
      KEY? BL =
      IF KEY DROP
      ELSE
         ?TERMINAL
         IF  INPUT  @ FCLOSE
             OUTPUT @ FCLOSE
             CR ." ^C" ABORT
         THEN
      THEN
      R@ EOF
    UNTIL
    DROP
    R> CLOSE-FILE
;
