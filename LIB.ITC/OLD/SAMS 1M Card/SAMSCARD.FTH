\ SAMS expanded memory card primitives

NEEDS DUMP  FROM DSK1.TOOLS
NEEDS SBO  FROM DSK1.CRU

HEX
     VARIABLE BANK#      \ current mapped bank
  10 CONSTANT 1STBANK    \ we don't use the lower 64K
1000 CONSTANT 4K         \ bytes per bank = 4K
3000 CONSTANT MBLOCK     \ paged memory block location

\ compute register address for mapping >3000..>3FFF
MBLOCK 0B RSHIFT 4000 +  CONSTANT SAMSREG

: >BANK  ( addr bank# -- addr)      \ must have 32bit address!!
         4K UM/MOD ( -- offset bank#)
         DUP BANK# @ =             \ are we using the same bank#
         IF
             DROP                  \ Yes!. Drop the bank# and get out
         ELSE \ MAP in a new bank
              DUP FF00 AND ABORT" SAMS Err!"
              DUP BANK# !           \ update bank#
              ><                    \ bank# must be in left byte
             1E00 CRU! 0SBO         \ enable SAMS card
            ( bank#) SAMSREG !      \ store bank in SAMS register
              0SBZ                  \ disable SAMS card
         THEN
         MBLOCK +              \ return the address in mapped block
;

\ direct access to 1M of memory space
: C@L    ( 32addr -- n)  >BANK C@ ;   \ fetch a byte
: C!L    ( n 32addr -- ) >BANK C! ;   \ store a byte

: @L     ( 32addr -- n)  >BANK @ ;    \ fetch an int
: !L     ( n 32addr -- ) >BANK ! ;    \ store an int

\ debug words
: ??     ( addr --) 2@ DU. ;    \ see contents of 32 bit variable


