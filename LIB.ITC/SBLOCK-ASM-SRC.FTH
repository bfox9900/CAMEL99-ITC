\ SAMS memmory access as BLOCK from Forth.  Source code   Brian Fox

NEEDS DUMP FROM DSK1.TOOLS
NEEDS MOV, FROM DSK1.ASM9900
NEEDS ELAPSE FROM DSK1.ELAPSE 

NEEDS SAMSINI  FROM DSK1.SAMSINI

HERE
\ ==========================================
\ BLOCK is the entire SAMS manager
HEX
VARIABLE USE
CREATE BLK#S       0 ,    0 ,      \ SAMS page in the buffer
CREATE WINDOWS  2000 , 3000 ,      \ windows in Low CPU RAM

CODE BLOCK+ ( offset page# -- real_addr)
         R0  BLK#S LI,     \ handle 0 search
         R0 ** TOS CMP,
          EQ IF,
                TOS 2000 LI,
                *SP+ TOS ADD, 
                NEXT,      \ Return to Forth
          ENDIF,

                R0 INCT,   \ handle 1 search
         R0 ** TOS CMP,
          EQ IF,
                TOS 3000 LI,
                *SP+ TOS ADD, 
                NEXT,     \ Return to Forth
          ENDIF,

         W    0001 LI,
         USE @@  W XOR,
         W  USE @@ MOV,
         W       1 SLA,   \ W 2* is index
     TOS BLK#S (W) MOV,   \ store the bank#

    WINDOWS (W) R1 MOV,   \ get the window to use
          R1    0B SRL,   \ divide by 2048
          R1  4000 AI,    \ convert to SAMS register address
          R12 1E00 LI,    \ cru address of SAMS
                 0 SBO,   \ SAMS card on
              TOS  SWPB,  \ swap bytes on bank value
         TOS R1 ** MOV,   \ load bank into register
                 0 SBZ,   \ SAMS card off

   WINDOWS (W) TOS MOV,   \ return buffer on TOS

          *SP+ TOS ADD, 
                   NEXT,
ENDCODE
 
VARIABLE SEG  1 SEG ! 

CODE >SEGMENT ( virtual -- offset page#)
      TOS PUSH, 
      SEG @@ TOS MOV,     \ segment# to R0
      TOS 4 SLA,          \ page# segment starts
      *SP R5 MOV,        \ low cell to R5 
      
      R5  R0 MOV,         \ dup in R0
      R0  0C SRL,         \ divide by 2048
      R0 TOS ADD,        \ bank# = R0 + tos 
      
      R5 0FFF ANDI,     \ page offset masked to 12 bits 
      R5 *SP MOV,       \ put back on stack 
      NEXT, 
ENDCODE 
: >REAL ( virtual -- offset page#) >SEGMENT BLOCK+ ;

: !L    ( virtual -- ) >REAL ! ;

DECIMAL
: TEST  
   65535 0 
   DO 
     [CHAR] %  I !L
   LOOP ;

\ seg @ 1000 um/mod 45 secs 
\ seg @ 4k/mod  41 secs 
\ >SEGMENT      37.1 secs
\ BLOCK+        35.58 
