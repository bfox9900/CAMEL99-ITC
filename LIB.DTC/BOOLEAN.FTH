\ BOOLEAN array creator and access words               Brian Fox  2018
\ Tested with  CAMEL99 Forth 16 bits, Gforth 32 bits, iForth 64 bits 

HEX
\ calculations based on CELL size
          1 CELLS CONSTANT CELL
                8 CONSTANT BITS/BYTE
 CELL BITS/BYTE * CONSTANT BITS/CELL

\ create bit array & erase memory area for 'n' bits                             
: BITS:      ( n -- )
      CREATE  BITS/BYTE /MOD SWAP >R   \ calc memory size
              HERE OVER 0 FILL         \ erase the memory
              R> CELLS +  ALLOT  ;     \ allocate the memory

\ compute bit# in a cell & cell address in memory
: BITFLD     ( bit# addr[] -- bit#' addr)
              SWAP BITS/CELL /MOD CELLS ROT +  ;

: BITMASK   ( bit# -- n )  \ convert bit# to a bit mask
             0001 SWAP LSHIFT ;

\ end user words
: BIT@      ( bit# addr[] -- ? )
              BITFLD @                \ compute bit# & fetch bits in cell
              SWAP RSHIFT             \ if bit#<>0 RSHIFT,
              0001 AND ;              \ return 1 bit

: BSET      ( bit# addr[] -- )
              BITFLD                  \ -- bit# addr
              SWAP BITMASK >R         \ save the mask
              DUP @                   \ -- addr bits
              R> OR SWAP ! ;          \ or mask into bit, store in addr

: BRST      ( bit# addr[] -- )
              BITFLD                  \ -- bit# addr
              SWAP BITMASK INVERT >R  \ invert and save mask
              DUP @                   \ -- addr bits
              R> AND SWAP ! ;         \ mask out bits, store back in addr

: BTOG      ( bit# addr[] -- )        \ toggle bit
              BITFLD                  \ -- bit# addr
              SWAP BITMASK >R         \ save the mask
              DUP @                   \ -- addr bits
              R> XOR SWAP ! ;         \ or mask into bit, store in addr


