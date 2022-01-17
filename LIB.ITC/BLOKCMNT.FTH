\ Block comment
HEX
NEEDS DUMP   FROM DSK1.TOOLS
NEEDS MARKER FROM DSK1.MARKER
NEEDS MOV,  FROM DSK1.ASM9900

CHAR ) DUP SWAP FUSE CONSTANT '))'

DECIMAL
: REFILL   ( -- ?)
    SOURCE-ID @
    IF  2 FILEOP DUP ?FILERR  0=   EXIT THEN
    TIB 127 ACCEPT ; 

\ scanw.fth  like SCAN but searches for CELL match    Dec 30 2021  B Fox
CODE SCANW   ( addr len n -- addr' len' )    \ find matching n in string
             *SP+  R2 MOV,     \ len -> R2
              *SP  R2 ADD,     \ END addr is in R2
              *SP  R1 MOV,     \ start addr in R1
             BEGIN,
                TOS R1 *+ CMP,
             NE WHILE,
                R1 R2 CMP,
             EQ UNTIL,
             ENDIF,
             R2 TOS MOV,
             R1 TOS SUB,  \ len'  is in TOS
                TOS INCT,
                R1  DECT,
             R1 *SP MOV,  \ addr' is in NOS
             NEXT,
ENDCODE


: ((   ( flag -- )
      BEGIN  REFILL
      WHILE  RP0 100 - DUP FGET DUP 0=
      WHILE  '))' SCANW 0=
      REPEAT
      THEN INTERPRET    \ use what ever is left over in the line
;
