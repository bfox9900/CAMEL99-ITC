\ Traditional Forth array words

\ These work as expected but are a litte slow due to DOES> overhead

\ CARRAY  creates a byte size array.
: CARRAY ( n -- )
         CREATE  ALLOT  DOES> ( n -- a )  + ;


\ ARRAY  creates a cell size array.
: ARRAY ( n -- )
         CREATE  CELLS ALLOT  DOES> ( n -- a ) SWAP CELLS + ;

\ 100 ARRAY ]Q

\ ALTERNATIVE Method: array operators
: []    ( ndx  addr -- addr[n]) SWAP CELLS + ;
: []@   ( ndx addr -- n') [] @ ;
: []!   ( n ndx addr -- ) [] ! ;

\ Usage examples
\ CREATE Q  200 CELLS ALLOT
\ 99 0  Q []!
\  Q []@  .

\ fastest Forth method: specific array operation
\ : ]Q ( n -- addr )  CELLS Q + ;

\ Usage examples
\ 99 6 ]Q !
\ 6 ]Q @ .


