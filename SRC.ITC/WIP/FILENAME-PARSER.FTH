
INCLUDE DSK1.TOOLS

: A$  S" DSK1.MYFILE" ;

:  /FILENAME  ( addr len -- addr' len') [CHAR] . SCAN  ;
: /DEV.       ( addr len -- addr' len') 2DUP /FILENAME NIP - 1+ ;
