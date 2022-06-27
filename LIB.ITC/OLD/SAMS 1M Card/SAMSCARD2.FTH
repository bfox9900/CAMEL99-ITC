\ SAMS expanded memory card primitives
\ Provides 940K of data space
INCLUDE DSK1.TOOLS
INCLUDE DSK1.ELAPSE
INCLUDE DSK1.ASM9900

HEX
     VARIABLE BANK#      \ current mapped bank
  10 CONSTANT 1STBANK    \ we don't use the lower 64K
1000 CONSTANT B/BANK     \ bytes per bank = 4K

\ SAMS uses a 4K page
3000 CONSTANT SAMSPAGE   \ >6000 maps the memory to the cartidge port space

SAMSPAGE 0B RSHIFT 4000 + \ compute the SAMS register for the SAMS page
     CONSTANT SAMSREG    \ make it a constant

HEX
\ translated from TurboForth
 CODE MAP ( bank addr -- )
         0244 , F000 ,   \ TOS F000 ANDI, \ set to 4k boundary
         09B4 ,          \ TOS   0B SRL,  \ divide by 2048
         0224 , 4000 ,   \ TOS 4000 AI,   \ convert to SAMS register address
         C0B6 ,          \ *SP+  R2 MOV,  \ get bank
         0242 , 00FF ,   \ R2    FF ANDI, \ mask off any crap
         C002 ,          \ R2    R0 MOV,  \ keep a copy
         0A82 ,          \ R0    R2 XOR,  \ combine r0 & r2. Hi & lo bytes are now identical
         2880 ,          \ R2    08 SLA,  \ move to high byte
         020C , 1E00 ,   \ R12 1E00 LI,   \ cru address of SAMS
         1D00 ,          \       0 SBO,   \ enable SAMS card
         C502 ,          \ R2  *TOS MOV,  \ poke sams register
         1E00 ,          \        0 SBZ,  \ disable sams card
         C136 ,          \      TOS POP,
         NEXT,
         ENDCODE
HEX
: >BANK  ( 32bit -- addr)           \ must have 32bit address!!
         B/BANK UM/MOD 1STBANK +   ( -- offset bank#+1STBANK)
         DUP BANK# @ =               \ are we using the same bank#
         IF   \ Yes!. Drop the bank# and get out
              DROP

         ELSE ( offset bank# )      \ MAP in a new bank
              DUP FF00 AND ABORT" SAMS Err!"
              DUP BANK# !           \ update bank#
              DUP FUSE              \ Hi & lo bytes are now identical
              SAMSREG
              1E00 CRU! 0SBO        \ enable SAMS card
            ( bank# register) !     \ store bank in SAMS register
              0SBZ                  \ disable SAMS card
         THEN SAMSPAGE OR           \ return the address in mapped block
;

\ direct access to 900K memory space
: C@L    ( 32addr -- n)  >BANK C@ ;   \ fetch a byte
: C!L    ( n 32addr -- ) >BANK C! ;   \ store a byte

: @L     ( 32addr -- n)  >BANK @ ;    \ fetch an int
: !L     ( n 32addr -- ) >BANK ! ;    \ store an int

\ debug words
\ : UD.    ( d -- )   <#  #S  #>  TYPE SPACE ;
\ : ??     ( addr --) 2@ UD. ;    \ see contents of 32 bit variable

VARIABLE THE#

: 64KWRITE
          THE# OFF
          0 0            \ start address (32 bit#)
          BEGIN
            1 M+
            1 THE# +!
            2DUP THE# @ -ROT !L
            OVER FFFF =
            ?BREAK
          UNTIL
          2DROP ;

: 64KREAD
          0 0            \ start address (32 bit#)
          BEGIN
            1 M+
            2DUP @L U.
            OVER FFFF =
            ?BREAK
          UNTIL
          2DROP ;



