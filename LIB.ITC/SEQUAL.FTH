\ S= adapted from Camel Forth MSP430
\ machine code version

HEX
CODE S= ( addr1 addr2 len)
    C0B6 , C076 , C004 , 04C4 , 130A , 9CB1 ,
    1306 , 1101 , 1002 , 0604 , 1001 , 0584 ,
    NEXT,  0600 , 16F6 , NEXT,
ENDCODE

\ CODE S=  ( Caddr1 Caddr2 cnt1 -- n )
\    R2 POP,                   \ adrs2 -> R2
\    R1 POP,                   \ adrs1 -> R1
\    TOS R0 MOV,               \ cnt -> R0
\    TOS CLR,                  \ clear output flag (0 means a match)
\    NE IF,                    \ if count<>0 do search
\       BEGIN,
\          R1 *+ R2 *+ CMPB,   \ compare bytes & auto increment
\          NE IF,              \ mismatch found,
\              LO IF, TOS DEC, \ $1<$2
\              ELSE,  TOS INC, \ $1>$2
\              ENDIF,
\              NEXT,           \ Return to Forth
\          ENDIF,
\          R0 DEC,             \ decr. loop counter
\       EQ UNTIL,              \ loop while R0 > 0
\   ENDIF,
\   NEXT,                      \ Return to Forth
\   ENDCODE

\ ALTERNATE
\ CODE SS=  ( Caddr1 Caddr2 cnt1 -- n )
\    R2 POP,                   \ adrs2 -> R2
\    R1 POP,                   \ adrs1 -> R1
\    TOS R0 MOV,               \ cnt -> R0
\    TOS CLR,                  \ clear output flag (0 means a match)
\    BEGIN,
\       R0 DEC,
\    OC WHILE,
\       R1 *+ R2 *+ CMPB,      \ compare & auto increment
\       NE IF,
\           LO IF, TOS DEC, \ $1<$2
\           ELSE,  TOS INC, \ $1>$2
\           ENDIF, NEXT,
\       ENDIF,
\    REPEAT,
\    NEXT,
\ ENDCODE
