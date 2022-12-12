\ SAMS memmory access as BLOCK from Forth.  Source code   Brian Fox

INCLUDE DSK1.TOOLS
INCLUDE DSK1.ASM9900

NEEDS SAMSINI  FROM DSK1.SAMSINI

HERE
\ ==========================================
\ BLOCK is the entire SAMS manager
HEX
VARIABLE USE
CREATE BLK#S       0 ,    0 ,      \ SAMS page in the buffer
CREATE WINDOWS  2000 , 3000 ,      \ windows in Low CPU RAM

CODE BLOCK ( bank -- buffer)
          R0 BLK#S LI,     \ handle 0 search
         R0 ** TOS CMP,
          EQ IF,
                TOS 2000 LI,
                NEXT,      \ Return to Forth
          ENDIF,
                R0 INCT,   \ handle 1 search
         R0 ** TOS CMP,
          EQ IF,
                TOS 3000 LI,
                NEXT,     \ Return to Forth
          ENDIF,
           W  0001 LI,
         USE @@  W XOR,
         W  USE @@ MOV,
         W       W ADD,   \ W holds offset
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
                   NEXT,
ENDCODE

: >REAL  ( addr seg -- virtual-address) 1000 UM/MOD BLOCK + ;

CODE 4K/MOD  ( 32bit -- offset page#)
       TOS R0 MOV,        \ segment# to R0
       R0 4 SLA,          \ page# segment starts
       TOS R5 MOV,        \ address to R5
       R5  0FFF AI,       \ page offset
       TOS 0C SRL,        \ page of current segment
       R0 TOS ADD,        \ bank#
ENDCODE

CODE >REAL ( low hi -- realaddr)
          R0 BLK#S LI,     \ handle 0 search
         R0 ** TOS CMP,
          EQ IF,
                TOS 2000 LI,
                NEXT,      \ Return to Forth
          ENDIF,
                R0 INCT,   \ handle 1 search
         R0 ** TOS CMP,
          EQ IF,
                TOS 3000 LI,
                NEXT,     \ Return to Forth
          ENDIF,
           W  0001 LI,
         USE @@  W XOR,
         W  USE @@ MOV,
         W       W ADD,   \ W holds offset
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
                   NEXT,
ENDCODE
