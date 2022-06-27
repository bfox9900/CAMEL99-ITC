\ SAMS expanded memory card primitives
\ Provides 940K of data space

NEEDS MOV, FROM DSK1.ASM9900
NEEDS .S   FROM DSK1.TOOLS
NEEDS SBO  FROM DSK1.CRU 

HEX
     VARIABLE BANK#      \ current mapped bank
  10 CONSTANT 1STBANK    \ we don't use the lower 64K
1000 CONSTANT 4K         \ bytes per bank = 4K
3000 CONSTANT MBLOCK     \ $3000 maps the memory to the cartidge port space

\ adapted from TurboForth for TOS in register
 CODE MAP ( bank addr -- )
         TOS  F000 ANDI, \ set to 4k boundary
         TOS    0B SRL,  \ divide by 2048
         TOS  4000 AI,   \ convert to SAMS register address
         *SP+   R2 MOV,  \ get bank
          R2    FF ANDI, \ mask off any crap
          R2    R0 MOV,  \ keep a copy
          R0    R2 XOR,  \ Hi/lo bytes are identical
          R2    08 SLA,  \ move to high byte
          R12 1E00 LI,   \ cru address of SAMS
                 0 SBO,  \ enable SAMS card
          R2  *TOS MOV,  \ poke sams register
                 0 SBZ,  \ disable sams card
               TOS POP,
         NEXT,
         ENDCODE         \ 34 bytes

: >PAGE ( 32bit -- addr)            \ must have 32bit address!!
         4K UM/MOD  1STBANK +  ( -- offset bank#+1STBANK)
         BANK# @ OVER =             \ are we using the same bank#
         IF   DROP                  \ Yes!. Drop the bank# and get out
         ELSE MAP
         THEN MBLOCK OR             \ return the address in mapped block
;

\ direct access to 900K memory space
: C@L    ( 32addr -- n)  >PAGE C@ ;   \ fetch a byte
: C!L    ( n 32addr -- ) >PAGE C! ;   \ store a byte

: @L     ( 32addr -- n)  >PAGE @ ;    \ fetch an int
: !L     ( n 32addr -- ) >PAGE ! ;    \ store an int

\ debug words
 : ??     ( addr --) 2@ DU. ;    \ see contents of 32 bit variable

: CYCLESAM     FF 0 DO  I 0 MAP LOOP ; 
: LOADSAMS     7FFF 0 DO    I  0 MAP    LOOP ;
: READSAMS     7FFF 0 DO    I 0 C@L .     LOOP ;

