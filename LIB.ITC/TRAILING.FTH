CR .( -TRAILING remove trailing blanks  Apr 2025 FOX)
\ : -TRAILING
\    1-
\    BEGIN
\        2DUP + C@ BL =
\    WHILE
\        1-
\    REPEAT
\    1+  0 MAX ;

\ -TRAILING  *Faster* remove trailing blanks Aug 2025 FOX
HEX
CODE -TRAILING  ( addr n -- addr 'n)
A116 ,          \ *SP TOS  ADD,    compute end of string
0604 ,          \     TOS  DEC,     1-
0201 , 2000 ,   \  R1 2000 LI,      BL R1 !
                \  BEGIN
9054 ,          \  *TOS R1 CMPB,
1602 ,          \   EQ WHILE,
0604 ,          \      TOS DEC,     1-
10FC ,          \   REPEAT,
6116 ,          \   *SP TOS SUB,
0584 ,          \   TOS INC,        1+
C104 ,          \   TOS TOS MOV,
1401 ,          \   LO IF,  TOS CLR,  ENDIF,
04C4 ,
NEXT,
ENDCODE

DECIMAL
