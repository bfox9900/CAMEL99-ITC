\ 16bit CELL move, A.6.1.1900 MOVE
\ like CMOVE but 2x faster because it moves 2 bytes per iteration

NEEDS MOV,  FROM DSK1.ASM9900
NEEDS .S    FROM DSK1.TOOLS

CODE MOVE16  ( src dst n -- )  \ n= no. of CELLS to move
            *SP+ R0 MOV,       \ pop DEST into R0
            *SP+ R1 MOV,       \ pop source into R1
             TOS TOS MOV,
             NE IF,               \ if n=0 get out
                TOS INC,          \ make sure n is even
                TOS -2 ANDI,
                BEGIN,
                  R1 *+ R0 *+ MOV,  \ memory to memory move, auto increment by 2. :-)
                  TOS DECT,         \ we are moving 2 bytes at once!
                  LTE
                UNTIL,
             ENDIF,
             TOS POP,
             NEXT,
             ENDCODE

\ OVERLAP safe MOVE16
CODE <MOVE16  ( src dst n -- )  \ n= no. of bytes to move
            *SP+ R0 MOV,       \ pop DEST into R0
            *SP+ R1 MOV,       \ pop source into R1
             TOS TOS MOV,
             NE IF,               \ if n=0 get out
                TOS INC,          \ make sure n is even
                TOS -2 ANDI,
                TOS R0 ADD,       \ compute end of dest
                R0 DECT,
                TOS R1 ADD,       \ compute end of src
                R1 DECT,
                BEGIN,
                  R1 ** R0 ** MOV,  \ memory to memory move, auto increment by 2. :-)
                  R1 DECT,        \
                  R0 DECT,
                  TOS DECT,         \ we are moving 2 bytes at once!
                  LTE
                UNTIL,
             ENDIF,
             TOS POP,
             NEXT,
             ENDCODE

CODE MOVE16
    C036 , C076 , C104 , 1306 , 0584 ,
    0244 , FFFE , CC31 , 0644 , 15FD ,
    C136 ,
NEXT,
END-CODE

CODE <MOVE16
    C036 , C076 , C104 , 130C , 0584 ,
    0244 , FFFE , A004 , 0640 , A044 ,
    0641 , C411 , 0641 , 0640 , 0644 ,
    15FB , C136 ,
NEXT,
END-CODE



CREATE Q    A , B , C , D , E , F , 0 , 0 , 0 , 0 ,
