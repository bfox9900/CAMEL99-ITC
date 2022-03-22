\ SBLOCK  a method to manage SAMS pages    Mar 21 2022  Brian Fox

\ for debugging
 NEEDS .S   FROM DSK1.TOOLS
 NEEDS MOV, FROM DSK1.ASM9900
 NEEDS ELAPSE FROM DSK1.ELAPSE

NEEDS SAMSINI FROM DSK1.SAMSINI \ Common lib for SAMS support

HERE
VARIABLE USE                       \ last SAMS block used
VARIABLE SEG                       \ current segment in use
CREATE BLK#S       0 ,    0 ,      \ SAMS pages in RAM
CREATE WINDOWS  2000 , 3000 ,      \ windows in Low CPU RAM

HEX
CODE SBLOCK ( blk# -- buffer)
\ test if block #1 is in RAM
          W CLR,                   \ W is index register = 0
          BLK#S (W) TOS CMP,       \ do we have the requested bank#
          EQ IF,                   \ yes we do
             WINDOWS (W) TOS MOV,  \ use WINDOWS(0) ie: >2000
             NEXT,                 \ Return to Forth
          ENDIF,
\ test if block #2 is in RAM
          W INCT,                  \ bump index to next "cell"
          BLK#S (W) TOS CMP,
          EQ IF,
              WINDOWS (W) TOS MOV, \ use windows(2) ie: >3000
              NEXT,                \ Return to Forth
          ENDIF,

\ ** bank# is not in RAM. Get it **

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

\ Faster than using Forth and UM/MOD
HEX
CODE >SAMS ( addr -- offset bank#)  \ 222 cycles!
      TOS  R0 MOV,
      R0 0FFF ANDI,   \ mask upper 4 bits
           R0 PUSH,   \ push offset to memory stack
     TOS F000 ANDI,
    SEG @@ R0 MOV,
         R0 4 SLA,    \ mult by 16
      TOS  0C SRL,    \ divide by 4096
      R0  TOS ADD,
              NEXT,
ENDCODE


\ safely set the 64K segment in use. doesn't allow 1st 64K
DECIMAL
 : SEGMENT ( 1..F -- )
         DUP 1 16 WITHIN 0= ABORT" SAMS segment err"
         SEG ! ;

1 SEGMENT

: PAGED ( virtual_address -- real_address ) >SAMS SBLOCK + ;

\ "long" memory operators work in a SAMS segment
: @L    ( addr -- )  PAGED @ ;
: !L    ( addr -- )  PAGED ! ;
: C@L   ( addr -- )  PAGED C@ ;
: C!L   ( addr -- )  PAGED C! ;

: SAMSFILL  ( addr size byte -- ) -ROT BOUNDS ?DO   DUP I C!L    LOOP ;
: SAMSFILLW ( addr size byte -- ) -ROT BOUNDS ?DO   DUP I !L    2 +LOOP ;

: SAMSMOVE ( addr1 addr2 size --)
  BOUNDS
   DO
      DUP @L   \ fetch from addr1
      I !L     \ store to addr2
      2+       \ bump addr1
   2 +LOOP
   DROP ;

: SAMSCMOVE ( addr1 addr2 size --)
  BOUNDS
   DO
      DUP C@L   \ fetch from addr1
      I C!L     \ store to addr2
      2+        \ bump addr1
   2 +LOOP
   DROP ;

HERE SWAP - DECIMAL  CR .  .( bytes)

\ test results with >SAMS (code)
\ 0 FFFF BEEF ELAPSE SAMSFILLW  20 secs
\ test results with forth
\ 0 FFFF BEEF ELAPSE SAMSFILLW  27 secs
