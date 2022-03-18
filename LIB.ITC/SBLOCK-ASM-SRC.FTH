\ BLOCK using 2 pages of SAMS memory in Low RAM    Mar 18 2022 Brian Fox

\ For reference these
\ CREATE BLK#S       0 ,    0 ,      \ SAMS page in the buffer
\ CREATE WINDOWS  2000 , 3000 ,      \ windows in Low CPU RAM


CODE BLOCK ( bank# -- buffer)
\ FAST test if we already have the bank# in one of windows
          R0 BLK#S LI,       \ R0 hold array of banks in use
          R0 ** TOS CMP,     \ do we have the requested bank#
          EQ IF,             \ yes we do
                TOS 2000 LI, \ use window at >2000
                NEXT,        \ Return to Forth
          ENDIF,
                R0 INCT,     \ move to next array item
          R0 ** TOS CMP,     \
          EQ IF,
                TOS 3000 LI, \ use window at >3000
                NEXT,        \ Return to Forth
          ENDIF,

\ bank# is not in RAM. Need to get it

\ whatever blk# was last used, switch to the other one.
           W  0001 LI,    \ init W to 1
         USE @@  W XOR,   \ toggle it with the last buffer we used
         W  USE @@ MOV,   \ update the USE variable. Can only be 1 or 0
         W       W ADD,   \ "do CELLS" It now has the index we will use

     TOS BLK#S (W) MOV,   \ store the bank# in blks#s array
    WINDOWS (W) R1 MOV,   \ get the window to use
          R1    0B SRL,   \ divide by 2048
          R1  4000 AI,    \ convert to SAMS register address
          R12 1E00 LI,    \ cru address of SAMS
                 0 SBO,   \ SAMS card on
              TOS  SWPB,  \ swap bytes on bank value
         TOS R1 ** MOV,   \ load bank into SAMS card register
                 0 SBZ,   \ SAMS card off
   WINDOWS (W) TOS MOV,   \ return buffer on TOS
                   NEXT,
ENDCODE
