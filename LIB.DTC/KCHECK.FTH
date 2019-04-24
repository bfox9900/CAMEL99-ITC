\ *--------------------------------------------
\ * FAST key pressed check  5X faster
\ *--------------------------------------------

NEEDS  MOV,  FROM DSK1.ASM9900

CODE KCHECK ( -- 0 | n) \ 191 uS
       R12  RPUSH,             \ SAVE R12
       TOS PUSH,
       TOS CLR,                \ TOS is for output
       R1  CLR,                \ Start with column 0
       BEGIN,
          R12 0024 LI,         \ R12-address for column selection
          R1  3    LDCR,       \ Select a column
          R12 0006 LI,         \ R12-address to read rows
          TOS      SETO,       \ Make sure all bits are 1
          TOS 8    STCR,       \ Get 8 row values
          TOS      INV,        \ pressed keys read as 0
          NE IF,
               R1 500 LI,      \ A key was pressed, jmp out
          ENDIF,
          R1  0100 AI,         \ Next column
          R1  0600 CI,         \ test column
       EQ UNTIL,               \ loop until R1<0
       R12 RPOP,               \ restore R12
       NEXT,                   \ No key pressed: return (with EQ bit set)
       ENDCODE
       
