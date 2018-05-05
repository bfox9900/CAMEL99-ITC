\ common Forth array words
\ These work as expected but are a litte slow due to DOES> overhead

\ CARRAY  creates a byte size array.
: CARRAY ( n -- )
         CREATE  ALLOT  DOES> ( n -- a )  + ;


\ ARRAY  creates a cell size array.
: ARRAY ( n -- )
         CREATE  CELLS ALLOT  DOES> ( n -- a ) SWAP CELLS + ;
         
\ faster array uses INLINE.F to copy assembler code 
\ from the kernel to run SWAP CELLS +  2X faster
: FARRAY   CREATE CELLS ALLOT
           ;CODE  CODE[ SWAP CELLS + ]  NEXT, END-CODE
           
           
100 ARRAY ]Q
100 FARRAY ]W

