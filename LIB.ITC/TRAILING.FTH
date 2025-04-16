CR .( -TRAILING remove trailing blanks  Apr 2025 FOX)
 HEX
 CODE -TRAILING  ( addr len --)
0201 , 2000 ,   \ R1 2000 LI,         \ space char byte 
                \ BEGIN, 
0284 , 0000 ,   \   TOS 0 CI,         \ test string length
1302 ,          \ NE WHILE, 
C004 ,          \  TOS R0 MOV,        \ dup length 
A016 ,          \  *SP R0 ADD,        \ add string address
0600 ,          \      R0 DEC,        \ move back to last char in string 
9050 ,          \      R0 ** R1 CMPB, \ compare last byte to SPACE char 
1602 ,          \   EQ WHILE,         \ if space detected 
0604 ,          \       TOS DEC,      \ shorten string length by 1
10F4 ,          \   REPEAT, 
                \   ENDIF, 
NEXT, 
ENDCODE         

DECIMAL 
