\ -TRAILING  remove trailing blanks   added 0 length protection Mar 2021 FOX
HEX
CODE -TRAILING
    C216 , A204 , 0201 , 2000 ,
    0608 , 9058 , 1603 , 0608 ,
    0604 , 10FB , 0284 , 0000 ,
    1501 , 04C4 , NEXT,
ENDCODE

\ NEEDS .S   FROM DSK1.TOOLS
\ NEEDS MOV, FROM DSK1.ASM9900

\ CODE -TRAILING ( addr len -- addr len') \ 8x FASTER than Forth
\     *SP  W  MOV,   \ DUP addr in W
\      TOS W  ADD,   \ add len
\      R1 2000 LI,
\      W DEC,        \ w=address of last char
\      BEGIN,
\        *W R1 CMPB, \ compare to ascii >20
\      EQ WHILE,
\         W   DEC,   \ move back 1 char
\         TOS DEC,   \ dec len in TOS
\      REPEAT,
\      TOS 0 CI,
\      1 JGT,
\      TOS CLR,
\  NEXT,
\  ENDCODE
