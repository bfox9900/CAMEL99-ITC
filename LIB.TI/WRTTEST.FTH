\ Demo to generate a text file from CAMEL99
\ load the more utility to view the file created by this program
\ OR load it into the Editor.
\ default is DV80 files

HEX
: NUM$  ( n -- addr len)  DUP ABS 0  <# #S ROT SIGN #>  ;

VARIABLE HDL

CREATE CR$ ( -- $adr)  02 C,  0D C,  0A C,

: CR/LF  ( -- )  CR$ COUNT HDL @ WRITE-LINE . ;
: REC!   ( addr len -- )   HDL @ WRITE-LINE . CR/LF ;

: WRITETEST  ( adr len -- )
          W/O CREATE-FILE ?FILERR  HDL !
          S" This a test file"  HDL @ WRITE-LINE ?FILERR
          20 0
          DO
             S" This line will repeat 32 times."  HDL @ WRITE-LINE ?FILERR
          LOOP
          HDL @  CLOSE-FILE
;

