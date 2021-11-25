
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
