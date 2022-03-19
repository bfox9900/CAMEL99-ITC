\ BLOCK using 2 pages of SAMS memory in Low RAM    Mar 18 2022 Brian Fox

NEEDS .S    FROM DSK1.TOOLS
NEEDS MOV,  FROM DSK1.ASM9900
NEEDS ELAPSE FROM DSK1.ELAPSE 

NEEDS SAMSINI FROM DSK1.SAMSINI \ *NEW* common code for SAMS card

\ Note:
\ I realized that I was not using the WINDOWS array as the source
\ of data for the 1st tests. With this code the two windows can be anywhere

\ For reference this the data to manage what banks are in RAM
 VARIABLE USE                       \ index of the last bank# used
 CREATE BLK#S       0 ,    0 ,      \ SAMS bank# in the windows
 CREATE WINDOWS  2000 , 3000 ,      \ array of windows in CPU RAM

HEX
CODE BLOCK ( bank# -- buffer)
\ FAST test if we already have the bank# in one of windows
          W CLR,                   \ W is index register = 0
          BLK#S (W) TOS CMP,       \ do we have the requested bank#
          EQ IF,                   \ yes we do
             WINDOWS (W) TOS MOV,  \ use WINDOWS(0) ie: >2000
             NEXT,                 \ Return to Forth
          ENDIF,

          W INCT,                  \ bump index to next "cell"
          BLK#S (W) TOS CMP,
          EQ IF,
              WINDOWS (W) TOS MOV, \ use windows(2) ie: >3000
              NEXT,                \ Return to Forth
          ENDIF,

\ ** bank# is not in RAM. Get it

\ whatever blk# was last used, switch to the other one
           W  0001 LI,    \ init W to 1
         USE @@  W XOR,   \ toggle it with the last buffer we used
         W  USE @@ MOV,   \ update the USE variable. Can only be 1 or 0
         W       W ADD,   \ "do 2*" It now has the index we will use

     TOS BLK#S (W) MOV,   \ store the NEW bank# in blks#s array
    WINDOWS (W) R1 MOV,   \ get the window to use

\ compute address of SAMS card register for this window
          R1    0B SRL,   \ divide by 2048
          R1  4000 AI,    \ Add base address of SAMS registers

          R12 1E00 LI,    \ select CRU address of SAMS card
                 0 SBO,   \ SAMS card on
              TOS  SWPB,  \ swap bytes on bank value
         TOS R1 ** MOV,   \ load bank into SAMS card register
                 0 SBZ,   \ SAMS card off
   WINDOWS (W) TOS MOV,   \ return buffer on TOS
                   NEXT,
ENDCODE

SAMSINI CR .( SAMS card initialized)
DECIMAL
 : TEST   256 0 DO  I BLOCK DROP  LOOP ;
