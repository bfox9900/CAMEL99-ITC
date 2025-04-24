\ Minimalist heap memory manager in dictionary 

1 CELLS CONSTANT CELL 

: RESERVE ( n -- addr ) DUP , HERE  SWAP DP +! ;

: SIZEOF  ( addr -- u) CELL - @ ;  

: RELEASE ( addr -- ) SIZEOF CELL+ NEGATE 2- DP +! ;
