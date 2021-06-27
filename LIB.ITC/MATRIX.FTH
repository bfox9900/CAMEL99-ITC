\ 2D matrix generator

NEEDS DUMP  FROM DSK1.TOOLS
MARKER /MATRIX
DECIMAL
: ERASE  0 FILL ;
: MATRIX: ( n n -- ) CREATE  DUP * HERE OVER ERASE ALLOT  ;
\ Matrix indexer    column     row
: []  ( n1 n2 addr ) +        SWAP 10 * +  ;

\ matrix fetch & store
: [@]  ( n i i --) [] C@ ;
: [!]  ( n i i --) [] C! ;

: FILLCOL  10 0 DO   I  I 0 S [!]   LOOP  ;
: FILLROW  10 0 DO   I  0 I S [!]   LOOP  ;
