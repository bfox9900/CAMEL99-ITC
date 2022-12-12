\ CMOVE CMOVE>  for compatbility with older Forth systems

NEEDS MOV,  FROM DSK1.ASM9900

CODE CMOVE  ( src dst n -- )   \ forward character move
             R0 POP,       \ pop DEST into R0
             R1 POP,       \ pop source into R1
             TOS TOS MOV,
             NE IF,
                BEGIN,
                  R1 *+ R0 *+ MOVB, \ byte move, with auto increment by 1.
                  TOS DEC,        \ we can test it before the loop starts
                EQ UNTIL,
             ENDIF,
             TOS POP,
             NEXT,
             ENDCODE

\ OCT 5 2020 Fixed computation for end of strings and inner loop.
CODE CMOVE>  ( src dst n -- )  \ move chars from end of string and go backwards
           *SP+ R2 MOV,    \ pop DEST into R2
           *SP+ R1 MOV,    \ pop source into R1
            TOS TOS MOV,
            NE IF,
                TOS W  MOV,    \ dup n
                W DEC,         \ compute n-1
                W R1 ADD,      \ point to end of source
                W R2 ADD,      \ point to end of destination
                BEGIN,
                   R1 ** R2 ** MOVB,
                   R1 DEC,     \ move the pointers back (NO auto decrement, damn)
                   R2 DEC,
                   TOS DEC,    \ decr the counter in TOS (R5)
                EQ UNTIL,
             ENDIF,
             TOS POP,
             NEXT,
             ENDCODE
