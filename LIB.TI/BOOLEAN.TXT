\ BOOLEAN array experiment

\ BOOLEAN data is one CELL (16 bits on TMS9900)
\ 1024 BITS only takes 64 bytes of space

HEX
\ create & erase memory area for 'n' bits
: BITS:     ( n -- )
              CREATE   8 /MOD SWAP >R   \ calc memory size
              HERE OVER 0 FILL          \ erase the memory
              R> CELLS +  ALLOT  ;      \ allocate the memory

\ compute bit# in a cell & cell address
: BITFLD     ( bit# addr[] -- bit#' addr)
              SWAP 10 /MOD CELLS ROT +  ;

: BIT@      ( bit# addr -- ? )
              BITFLD @                \ compute bit# & fetch bits in cell
              SWAP RSHIFT             \ if bit#<>0 RSHIFT,
              0001 AND ;              \ mask 1 bit

: BIT#>MASK ( bit# -- n )             \ convert bit# to a bit mask
              0001 SWAP LSHIFT  ;

: BSET      ( bit# addr[] -- )
              BITFLD                  ( -- bit# addr)
              SWAP BIT#>MASK >R       \ save the mask
              DUP @                   \ -- addr bits
              R> OR SWAP ! ;          \ or mask into bit, store in addr

: BRST      ( bit# addr[] -- )
              BITFLD                    ( -- bit# addr)
              SWAP BIT#>MASK INVERT >R  \ invert and save mask
              DUP @                     \ -- addr bits
              R> AND SWAP ! ;           \ mask out bits, store back in addr

\ test code
 DECIMAL
 1024 CONSTANT size \ # of bits we want
 size BITS: ]X      \ make array X of size bits

\ set and reset each bit using the BSET BRST BIT@ words.
: FILLBITS   ." Setting all bits..." size 0 DO  I ]X BSET   LOOP ;
: CLRBITS    ." Erasing..."          size 0 DO  I ]X BRST   LOOP ;
: EVENBITS    CLRBITS ." Setting even bits..." size 0 DO  I ]X BSET   2 +LOOP ;
: SHOWBITS    size 0 DO  I ]X BIT@ . LOOP ;

\ Read each of the 64, 16 ints and display as a binary number.
: SHOWPACKED
              BASE @ >R
              2 BASE !  size 16 /   0 DO I ]X @ U. LOOP
              R> BASE ! ;

