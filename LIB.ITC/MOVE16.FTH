\ MOVE.FTH    Forth 2012                       Mar 29 2021 FOX
\ "address unit" CELL move, A.6.1.1900 MOVE
\ like CMOVE but 2x faster because it moves 2 bytes per iteration
\ TMS9900 does not like this for strings.

INCLUDE DSK1.ELAPSE
INCLUDE DSK1.TOOLS
INCLUDE DSK1.ASM9900

\ Test results
\ A000 2000 2000 ELAPSE CMOVE
\ Elapsed time =0:00.21 ok

\ A000 2000 2000 ELAPSE MOVE16
\ Elapsed time =0:00.11 ok

\ A000 2000 2000 ELAPSE MOVE32
\ Elapsed time =0:00.8 ok

HEX
CODE MOVEW  ( src dst n -- ) \ n= no. of bytes to move
   *SP+ R0 MOV,
   *SP+ R1 MOV,
    BEGIN,
       R1 *+ R0 *+ MOV,
       TOS DECT,
    NC UNTIL,
    TOS POP,
    NEXT,
ENDCODE

\ 2.5x FASTER than CMOVE for 16K byte moves
CODE MOVE32  ( src dst n -- )  \ n= no. of bytes to move
       TOS 2 SRA,        \ divide by 4
      *SP+ R0 MOV,       \ pop DEST into R0
      *SP+ R1 MOV,       \ pop source into R1
      BEGIN,
          R1 *+ R0 *+ MOV,  \ memory to memory move, auto increment
          R1 *+ R0 *+ MOV,  \ memory to memory move, auto increment
          TOS DEC,
      NC UNTIL,
      TOS POP,
      NEXT,
ENDCODE

CODE MOVE64  ( src dst n -- )  \ n= no. of bytes to move
       TOS 3 SRA,        \ divide by 8
      *SP+ R0 MOV,       \ pop DEST into R0
      *SP+ R1 MOV,       \ pop source into R1
      BEGIN,
          R1 *+ R0 *+ MOV,  \ memory to memory move, auto increment
          R1 *+ R0 *+ MOV,  \ memory to memory move, auto increment
          R1 *+ R0 *+ MOV,  \ memory to memory move, auto increment
          R1 *+ R0 *+ MOV,  \ memory to memory move, auto increment
          TOS DEC,
      NC UNTIL,
      TOS POP,
      NEXT,
ENDCODE

\ OVERLAP safe MOVE16
CODE MOVE>  ( src dst n -- )  \ n= no. of bytes to move
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
