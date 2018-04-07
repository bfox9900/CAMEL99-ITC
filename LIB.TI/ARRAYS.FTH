\ common Forth array words
\ These work as expected but are a litte slow due to DOES> overhead

\ CARRAY  creates a byte size array.
: CARRAY ( n -- )
         CREATE  ALLOT  DOES> ( n -- a )  + ;


\ ARRAY  creates a cell size array.
: ARRAY ( n -- )
         CREATE  CELLS ALLOT  DOES> ( n -- a ) SWAP CELLS + ;
         

: FARRAY   CREATE CELLS ALLOT
           ;CODE  INLINE[ SWAP CELLS + ]  NEXT, END-CODE
           
           
100 ARRAY ]Q
100 FARRAY ]W           

         
\ ALTERNATIVE Method: Create array operators
\ : []    ( ndx  addr -- addr[n]) SWAP CELLS + ;
\ : [@]   ( ndx addr -- n') [] @ ;
\ : [!]   ( n ndx addr -- ) [] ! ;

\ CREATE Q  400 ALLOT

\ Usage examples
\ 99 0  Q [!]
\  Q [@]  .

\ faster method, no swap required
\ : ]Q ( n -- addr )  CELLS Q + ;

\ Usage examples
\ 99 6 ]Q !
\ 6 ]Q @ .


