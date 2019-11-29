\ BOOLEAN array creator and access words               Brian Fox  2018
\ Tested with  CAMEL99 Forth 16 bits, Gforth 32 bits, iForth 64 bits
\ July 2019, removed Rstack juggling BSET, BRST, BTOG. Relaced with OVER. 20% faster

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
\ usage:  42 MYARRAY BITFLD
: BITFLD  ( bit# bits[] -- bit#' addr) SWAP BITS/CELL /MOD CELLS ROT + ;

\ convert bit# to a bit mask
: BITMASK ( bit# -- n )  0001 SWAP LSHIFT ; 

\ API
: BIT@ ( bit# bits[] -- ?) BITFLD @ SWAP RSHIFT 0001 AND ;  \ return 1 bit
: BSET ( bit# bits[] -- )  BITFLD SWAP BITMASK        OVER @  OR SWAP ! ;
: BRST ( bit# bits[] -- )  BITFLD SWAP BITMASK INVERT OVER @ AND SWAP ! ;
: BTOG ( bit# bits[] -- )  BITFLD SWAP BITMASK        OVER @ XOR SWAP ! ;


