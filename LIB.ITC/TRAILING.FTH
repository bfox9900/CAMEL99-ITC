CR .( -TRAILING remove trailing blanks  Apr 2025 FOX)
\ : -TRAILING
\    1-
\    BEGIN
\        2DUP + C@ BL =
\    WHILE
\        1-
\    REPEAT
\    1+ ; 

HEX
CODE -TRAILING ( addr len -- addr len') \ 8x FASTER than Forth
0604 , \    TOS DEC,
0201 , 2000, \ R1 2000 LI,      \ space char 
       \    BEGIN, 
C016 , \        *SP  R0 MOV, 
A004 , \         TOS R0 ADD, 
9050 , \         R0 **  R1 CMPB, 
1602 , \    EQ WHILE, 
0504 , \        TOS DEC, 
10FA , \    REPEAT, 
0584 , \    TOS INC,         
    NEXT,
ENDCODE       

DECIMAL 
