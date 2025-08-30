CR .( COMPARE two stack strings BFOX 2024)
HEX
CODE COMPARE
    C076 , C036 , C0B6 , 8004 ,
    1201 , C004 , 04C4 , 0600 ,
    1708 , 9CB1 , 1305 , 1402 ,
    0584 , 1001 , 0604 , NEXT,
    10F6 , NEXT,
ENDCODE
DECIMAL

\ source code for the above
\ CODE COMPARE ( str1,n,str2 n -- 0:SAME, 1:GT, -1:LT)
\    R1 POP,   \ str2
\    R0 POP,   \ len
\    R2 POP,   \ str1
\    TOS R0 CMP,     \ compare lengths
\    HI IF, ( tos U> R0)
\        TOS R0 MOV, \ use longest length
\    ENDIF,
\    TOS CLR,
\    BEGIN,
\        R0 DEC,
\    OC WHILE,
\        R1 *+ R2 *+ CMPB, \ compare & auto increment
\        NE IF, \ chars did not match
\           LO IF, TOS INC, \ $1<$2
\           ELSE,  TOS DEC, \ $1>$2
\           ENDIF, NEXT,    \ exit
\        ENDIF,
\    REPEAT,
\    NEXT, \ match was good
\ ENDCODE
