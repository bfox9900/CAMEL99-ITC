\ COMPARE.FTH  compare two stack strings  B Fox oCT 2025
\ Added early jump out if len1<>len2
HEX
CODE COMPARE
    C076 , C036 , C0B6 , 8004 ,
    04C4 , 1604 , 0600 , 1706 ,
    9CB1 , 13FC , 1402 , 0584 ,
    1001 , 0604 , NEXT,
ENDCODE
DECIMAL

\CODE COMPARE ( str1,n,str2 n -- 0:SAME, 1:GT, -1:LT)
\    R1 POP,   \ str2
\    R0 POP,   \ len
\    R2 POP,   \ str1
\    TOS R0 CMP, \ compare lengths for fast escape
\    TOS CLR,    \ clear output flag does not change CPU status
\    1 $ JNE,    \ if lengths not same jump out
\ compare loop
\    BEGIN,
\       R0 DEC,
\    OC WHILE,
\       R1 *+ R2 *+ CMPB, \ compare & auto increment
\    NE UNTIL,
\ mistmatch found
\ 1 $: LO IF, TOS INC, \ $1<$2
\      ELSE,  TOS DEC, \ $1>$2
\      ENDIF,
\    ENDIF,  \ test all chars, match was good
\    NEXT,
\ ENDCODE
