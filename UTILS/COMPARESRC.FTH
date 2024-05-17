\ S= adapted from Camel Forth MSP430

NEEDS POP, FROM DSK1.ASM9900
NEEDS DUMP FROM DSK1.TOOLS

CODE S=  ( Caddr1 Caddr2 cnt -- n )
    R2 POP,                   \ Caddr2 -> R2
    R1 POP,                   \ Caddr1 -> R1
    TOS R0 MOV,               \ cnt    -> R0, sets CPU flags
    TOS CLR,                  \ clear output flag, does not alter CPU flags
    NE IF,                    \ if count<>0 do compare
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

: COMPARE   ROT MAX S= ;