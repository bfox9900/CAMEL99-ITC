\ scanw.fth  like SCAN but searches for CELL match    Dec 30 2021  B Fox
HEX
NEEDS DUMP   FROM DSK1.TOOLS
NEEDS MARKER FROM DSK1.MARKER
NEEDS MOV,  FROM DSK1.ASM9900

CREATE Q[]
  0000 , 1111 , 2222 , 3333 , 4444 , 5555 , 6666 , 7777 ,
  8888 , 9999 , AAAA , BBBB , CCCC , DDDD , EEEE , FFFF ,

CODE SCANW   ( addr len n -- addr' len' )    \ find matching n in string
             *SP+ R2 MOV,     \ len -> R2
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

CODE SCAN   ( addr len c -- addr' len' )    \ find matching n in string
                  TOS SWPB,
             *SP+  R2 MOV,     \ len -> R2
              *SP  R2 ADD,     \ END addr is in R2
              *SP  R1 MOV,     \ start addr in R1
             BEGIN,
                TOS R1 *+ CMPB,
             NE WHILE,
                R1 R2 CMP,
             EQ UNTIL,
             ENDIF,
             R2 TOS MOV,
             R1 TOS SUB,  \ len'  is in TOS
                TOS INC,
                R1  DEC,
             R1 *SP MOV,  \ addr' is in NOS
             NEXT,
ENDCODE
