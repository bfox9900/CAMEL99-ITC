\ S= adapted from Camel Forth MSP430

NEEDS POP, FROM DSK1.ASM9900
NEEDS DUMP FROM DSK1.TOOLS

CODE S=  ( Caddr1 Caddr2 cnt -- n )
    R2 POP,                   \ Caddr2 -> R2
    R1 POP,                   \ Caddr1 -> R1
    TOS R0 MOV,               \ cnt    -> R0, sets CPU flags
    TOS CLR,                  \ clear output flag, does not alter CPU flags
    NE IF,                    \ if count<>0 do search
       BEGIN,
         R1 *+ R2 *+ CMPB,    \ compare & auto increment
         NE IF,              \ mismatch found,
              LO IF, TOS DEC, \ $1<$2
              ELSE,  TOS INC, \ $1>$2
              ENDIF,
              NEXT,           \ Return to Forth
         ENDIF,
         R0 DEC,             \ decr. loop counter
       EQ UNTIL,              \ loop while R0 > 0
   ENDIF,
   NEXT,                      \ Return to Forth
ENDCODE

CODE COMPARE  ( Caddr1 len1 Caddr2 len2 -- n )
    TOS R0 MOV,               \ len2  -> R0
    R2 POP,                   \ adrs2 -> R2
    R1 POP,                   \ len1  -> R1
    R3 POP,                   \ Caddr1 -> R3
    TOS CLR,                  \ clear output flag (0 means a match)
    R1 R0 CMP,
     BEGIN,
         R0 DEC,            \ decr. len 2
     OC WHILE,
         R1 DEC,            \ decr. len 1
     OC WHILE,
         R1 *+ R2 *+ CMPB,    \ compare & auto increment
         NE IF, ( difference )
         LO IF, TOS DEC, \ $1<$2
         ELSE,  TOS INC, \ $1>$2
         ENDIF, NEXT,
    REPEAT,
    ENDIF,
    NEXT,                      \ Return to Forth
ENDCODE
