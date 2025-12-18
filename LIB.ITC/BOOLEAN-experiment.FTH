\ BOOLEAN array creator and access words               Brian Fox  2018
\ Tested with  CAMEL99 Forth 16 bits, Gforth 32 bits, iForth 64 bits
\ July 2019: Replaced Rstack juggling with OVER.  20% faster
\ Nov  2024: Replaced /MOD with UM/MOD. 28% faster that 2019

HEX
\ calculations based on CELL size
                   8 CONSTANT BITS/BYTE
 1 CELLS BITS/BYTE * CONSTANT BITS/CELL

\ create bit array & erase memory area for 'n' bits
: BITS:      ( n -- )
      CREATE  BITS/BYTE /MOD SWAP >R   \ calc memory size
              HERE OVER 0 FILL         \ erase the memory
              R> CELLS +  ALLOT  ;     \ allocate the memory

\ compute bit# in a cell & cell address in memory
\ Note: 28% in this usage with UM/MOD.( 5 instructions vs /MOD has 29
\ : BITFLD  ( bit# bits[] -- bit#' addr) SWAP 0 BITS/CELL UM/MOD CELLS ROT + ;

: BITFLD  ( bit# bits[] -- bit#' addr) SWAP 0 BITS/CELL UM/MOD ROT + ;

\ : BITMASK ( bit# -- n )  1 SWAP LSHIFT ;   \ use for BIG endian
 : BITMASK ( bit# -- n )  1 SWAP LSHIFT >< ; \ For TMS9900

\ Using these code words makes everything about 24% faster
\ ADDS 12 bytes
HEX
 CODE BITMASK ( bit# -- n)
      C004 ,        \ TOS R0 MOV,
      0204 , 0001 , \ TOS 1 LI,
      C000 ,        \ R0 R0 MOV,
      1301 ,        \ NE IF,
      0A04 ,        \   TOS R0 SLA,
                   \ ENDIF,
      06C4 ,        \ TOS SWPB,
      NEXT,
 ENDCODE

 CODE OVER@ ( addr mask --)
      *SP R0 MOV,
      TOS PUSH,
      R0 ** TOS MOV,
      NEXT,
 ENDCODE

\ API
: BIT@ ( bit# bits[] -- ?) BITFLD @ SWAP RSHIFT 0001 AND ;  \ return 1 bit
: BSET ( bit# bits[] -- )  BITFLD SWAP BITMASK        OVER@ OR  SWAP ! ;
: BRST ( bit# bits[] -- )  BITFLD SWAP BITMASK INVERT OVER@ AND SWAP ! ;
: BTOG ( bit# bits[] -- )  BITFLD SWAP BITMASK        OVER@ XOR SWAP ! ;

\ TEST CODE
 DECIMAL
2048 CONSTANT size \ # of bits we want
 size BITS: ]X      \ make array X of size bits

\ set and reset each bit using the BSET BRST BIT@ words.
 : FILLBITS   ." Setting all bits..." size 0 DO  I ]X BSET   LOOP ;
 : CLRBITS    ." Erasing..."          size 0 DO  I ]X BRST   LOOP ;
 : EVENBITS    CLRBITS ." Setting even bits..." size 0 DO  I ]X BSET   2 +LOOP ;
 : TOGGLEBITS  ." Toggling..." size 0 DO  I ]X BTOG  LOOP ;
 : SHOWBITS   CR  size 0 DO  I ]X BIT@ (.) TYPE LOOP ;
 : BITS.  ( n -- )    CR   0 DO  I ]X BIT@ (.) TYPE LOOP ;
