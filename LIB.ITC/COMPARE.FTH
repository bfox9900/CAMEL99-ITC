\ COMPARE.FTH  compare two stack strings  B Fox July 2026
HEX
 CODE COMPARE ( str1,n1,str2 n2 -- 0:SAME, 1:GT, -1:LT)
C004 , \    TOS R0 MOV, \ n2
04C4 , \    TOS CLR,
C0B6 , \    R2 POP,  \ str2
C0F6 , \    R3 POP,  \ n1
C076 , \    R1 POP,  \ str1
8003 , \    R3 R0 CMP,
1305 , \    NE IF,
1702 , \          OC IF,
0584 , \                TOS INC,    \ set flag to greater than
1002 , \          ELSE,
0604 , \                TOS DEC,    \ set flag to less than
C003 , \                R3 R0 MOV,  \ use the shorter length
       \          ENDIF,
       \    ENDIF,
       \ compare loop
       \    BEGIN,
0600 , \       R0 DEC,
1707 , \    OC WHILE,
9CB1 , \       R1 *+ R2 *+ CMPB, \ compare & auto increment
13FC , \    NE UNTIL,
       \ mistmatch chars
1402 , \       LO IF,
0704 , \            TOS SETO,  \ tos = -1
1002 , \       ELSE,
0204 , 0001 , \    TOS 1 LI,  \ tos =  1
       \       ENDIF,
       \   ENDIF, ( endwhile)
       \ perfect match. TOS is unchanged
    NEXT,
ENDCODE
DECIMAL

\ Tests
\ : s11 S" 0abc" ;
\ : s12 S" 0aBc" ;
\ : s13 S" 0abcdefg" ;
\ s11 s11 COMPARE . (  0 )
\ s11 s12 COMPARE . (  1 )
\ s12 s11 COMPARE . ( -1 )
\ s11 s13 COMPARE . ( -1 )
\ s13 s11 COMPARE . (  1 )
