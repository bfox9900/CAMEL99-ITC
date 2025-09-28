CR .( COMPARE two stack strings BFOX 2025)
\ Improved speed by 10% with length test

HEX
CODE COMPARE
    C076 , C036 , C0B6 , 8004 ,
    04C4 , 1604 , 0600 , 1706 ,
    9CB1 , 13FC , 1402 , 0584 ,
    1001 , 0604 , NEXT,
ENDCODE

\ CODE COMPARE ( str1,n,str2 n -- 0:SAME, 1:GT, -1:LT)
\    R1 POP,   \ str2
\    R0 POP,   \ len
\    R2 POP,   \ str1
\    TOS R0 CMP, \ compare lengths for fast escape
\    TOS CLR,    \ clear output flag does not change CPU status
\    1 $ JNE,    \ if lengths not same jump out
\ compare loop
\    BEGIN,
\    R0 DEC,
\     OC WHILE,
\       R1 *+ R2 *+ CMPB, \ compare & auto increment
\     NE UNTIL,
\ mistmatch found
\ 1 $: LO IF, TOS INC, \ $1<$2
\    ELSE,  TOS DEC, \ $1>$2
\    ENDIF,
\    ENDIF,  \ test all chars, match was good
\    NEXT,
\ ENDCODE

COMPARE MOV  *R6+,R1
        MOV  *R6+,R0
        MOV  *R6+,R2
        C    R4,R0
        CLR  R4
        JNE  >C0D0
C0C8    DEC  R0
        JNC  >C0D8
        CB   *R1+,*R2+
        JEQ  >C0C8
C0D0    JHE  >C0D6
        INC  R4
        JMP  >C0D8
C0D6    DEC   R4
C0D8    B    *R10
