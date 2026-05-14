\ Minimalist dynamic memory manager in the Forth dictionary

: CELL-   S" 2-" EVALUATE ; IMMEDIATE

: RESERVE ( n -- addr ) DUP , HERE  SWAP DP +! ;
: SIZEOF  ( addr -- u) CELL- @ ;
: RELEASE ( addr -- ) SIZEOF CELL+ NEGATE CELL- DP +! ;
