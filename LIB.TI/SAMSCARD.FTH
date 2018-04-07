\ SAMS expanded memory card primitives
\ Provides 940K of data space
HEX

\ 3000 H !    \ move CAMEL99 heap 4K above the mapped area
            \ SAMS uses the 4K page from >2000...2FFF

     VARIABLE BANK#      \ current mapped bank
  10 CONSTANT 1STBANK    \ we don't use the lower 64K
1000 CONSTANT B/BANK     \ bytes per bank = 4K
6000 CONSTANT MBLOCK     \ >6000 maps the memory to the cartidge port space

HEX
: >BANK  ( 32bit -- addr)           \ must have 32bit address!!
         B/BANK UM/MOD  1STBANK +   ( -- offset bank#+1STBANK)
         BANK# @ OVER =             \ are we using the same bank#
         IF   \ Yes!. Drop the bank# and get out
              DROP

         ELSE \ MAP in a new bank
              DUP FF00 AND ABORT" Bank# Err!"
              DUP BANK# !           \ update bank#
              DUP FUSE              \ Hi & lo bytes are now identical

         \ compute SAMS register for address=MBLOCK at compile time
            [ MBLOCK 0B RSHIFT 4000 + ] LITERAL

              1E00 CRU! 0SBO        \ enable SAMS card
            ( bank# register) !     \ store bank in SAMS register
              0SBZ                  \ disable SAMS card
         THEN MBLOCK OR             \ return the address in mapped block
;

\ direct access to 900K memory space
: C@L    ( 32addr -- n)  >BANK C@ ;   \ fetch a byte
: C!L    ( n 32addr -- ) >BANK C! ;   \ store a byte

: @L     ( 32addr -- n)  >BANK @ ;    \ fetch an int
: !L     ( n 32addr -- ) >BANK ! ;    \ store an int

\ debug words
 : UD.    ( d -- )   <#  #S  #>  TYPE SPACE ;
 : ??     ( addr --) 2@ UD. ;    \ see contents of 32 bit variable

