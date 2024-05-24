\ BLOCK READ from serial port
\ from Texas Instruments 9902 Data Sheet, translated to Forth Assembler

CODE COM-ACCEPT ( addr len delimit -- len)
     *SP+ R3 MOV,    \ len  ->R3
     *SP+ R2 MOV,    \ addr ->R2
      TOS SWPB,      \ fix the byte order ... again
      R5 CLR,        \ byte counter register
      BEGIN,
        R5 R3 CMP,
      NE WHILE,
         BEGIN,
            21 TB, EQ    \ wait for RBRL=1
         UNTIL,
         *R2 8 STCR,     \ store char @ addr
          18   SBZ,
         *R2+ TOS CMPB,  \ is char the delimit
      NE WHILE,
          R5   INC,      \ count the char 
      REPEAT,
      ENDIF,
      R5 TOS MOV,        \ put byte counto into TOS 
      NEXT,
ENDCODE
