\ MOVE.FTH    Forth 2012                       Mar 29 2021 FOX
\ "address unit" CELL move, A.6.1.1900 MOVE
\ like CMOVE but 2x faster because it moves 2 bytes per iteration
\ TMS9900 does not like this for strings. 

NEEDS MOV,  FROM DSK1.ASM9900
NEEDS .S    FROM DSK1.TOOLS
NEEDS ELAPSE FROM DSK1.ELAPSE


CODE MOVE
   C036 , C076 , 0584 , 0244 ,
   FFFE , CC31 , CC31 , 0644 ,
   16FD , C136 , NEXT,
ENDCODE

CODE <MOVE16
    C036 , C076 , C104 , 130C , 0584 ,
    0244 , FFFE , A004 , 0640 , A044 ,
    0641 , C411 , 0641 , 0640 , 0644 ,
    15FB , C136 ,
NEXT,
ENDCODE

CODE MOVE  ( src dst n -- )    \ n= no. of CELLS to move
          *SP+ R0 MOV,       \ pop DEST into R0
          *SP+ R1 MOV,       \ pop source into R1
          TOS TOS MOV,
          NE IF,
             BEGIN,
                R1 *+ R0 *+ MOV,  \ mem to mem move, auto increment
                TOS DECT,         \ dect by two, moving 2 bytes at once
             EQ UNTIL,
          ENDIF,
          TOS POP,
          NEXT,
          ENDCODE

\ no improvement for 4K byte moves.  20% faster for 8K bytes
CODE MOVE32  ( src dst n -- )  \ n= no. of CELLS to move
            *SP+ R0 MOV,       \ pop DEST into R0
            *SP+ R1 MOV,       \ pop source into R1
            BEGIN,
                R1 *+ R0 *+ MOV,  \ memory to memory move, auto increment
                R1 *+ R0 *+ MOV,  \ memory to memory move, auto increment
                TOS -4 AI,        \ we are moving 4 bytes at once!
            LTE UNTIL,
            TOS POP,
            NEXT,
            ENDCODE

\ Speed test
\
HEX
\ 2000 3000 1000 ELAPSE CMOVE  15 ms
\ 2000 3000 1000 ELAPSE MOVE16  6 ms
\ 2000 3000 1000 ELAPSE MOVE32  6 ms

\ OVERLAP safe MOVE16
CODE <MOVE  ( src dst n -- )  \ n= no. of bytes to move
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
                  R1 ** R0 ** MOV,
                  R1 DECT,
                  R0 DECT,
                  TOS DECT,        \ we are moving 2 bytes at once!
                  LTE
                UNTIL,
             ENDIF,
             TOS POP,
             NEXT,
             ENDCODE
