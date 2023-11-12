\ MAP REDUCE FILTER for cell data

INCLUDE DSK1.TOOLS
INCLUDE DSK1.VALUES
INCLUDE DSK1.DEFER

DECIMAL
\  ** EXPERIMENTAL DATA STRUCTURE ***
\    COUNTED ARRAYS IN FREE MEMORY


1 CELLS CONSTANT CELL 

VARIABLE OLDDP
VARIABLE LAST[]


\ creator for counted arrays in empty memory
\ Data structure has a 2 cell header
\ Cell 1: LINK - to previous array or zero
\ Cell 2: size - SIZE in bytes of this array
\ DATA .....
: DLINK,    HERE LAST[] @ , LAST[] ! ;

: CLEAN    LAST[] @ IF  LAST[] @ DP !  THEN ;

\ create header, return the address
: [[   ( -- addr )
        HERE OLDDP ! DLINK,  HERE  0 ,  ; 

\ end array, fill in the size
: ]]   ( -- addr )
       HERE OVER - CELL -   OVER ! ; 

\ given and array pair, compute address at ndx
: [] ( addr bytes ndx -- addr) 
    CELLS TUCK SWAP CELL - > ABORT" index error"  + ;

\ Fetch array item at index 
: ]@ ( addr len ndx -- n) [] @ ;       

\ store n in array at ndx 
: ]! ( n addr len ndx) [] ! ;

: SIZE ( addr -- addr size) DUP CELL+ SWAP @ ; \ size is in BYTES
: LINK ( addr -- 'array[] | 0) 2- @ ;

\ a word to name a counted array and return the (addr,len) pair
: DATA:   CREATE
          ( addr --) ,
          DOES> @ SIZE ( -- addr size) ;

\ Explanation:
\ ACTOR holds the execution token (XT) for the operation that will be done
\ to each data element. The XT is passed to ACTOR by the programmer.
VARIABLE ACTOR

\ ACTION is vector that holds code that does the ACTOR XT  and it also
\ runs EXTRA code that makes the difference between REDUCE, MAP or FILTER
DEFER ACTION

\ this code is run in a loop by FOREACH
: REDUCER  ( initial n -- n)   ACTOR PERFORM ; \ reduce and return a value

: MAPPER   ( initial n -- )  REDUCER  ,  ; \ reduce and compile value

: FILTRATION ( initial n -- ) \ reduce with conditional value compilation
    2DUP SWAP REDUCER ( -- n ? )
    IF  ,       \ if true compile n into array
    ELSE DROP   \ otherwise throw it away
    THEN  ;

DECIMAL
: FOREACH  ( inital addr size xt-- n) \ primary iterator
    OVER 0= ABORT" REDUCE: size=0"
    ACTOR @ >R  \ allow variable to be re-entrant
    ACTOR !     \ set the XT of action on each cell
    BOUNDS DO  I @ ACTION   CELL +LOOP
    R> ACTOR !
;

: REDUCE ( inital addr size xt-- n)
    ['] REDUCER IS ACTION  FOREACH ;

\ Use REDUCE to do something real
: ..  ( 0 addr size -- )  ['] .  REDUCE ; \ print array signed
: U.. ( 0 addr size -- )  ['] U. REDUCE ; \ print array un-signed
: SUM     ( addr len ) 0 -ROT  ['] + REDUCE ;
: AVERAGE ( addr len ) DUP 2/ >R  SUM  R> / ;

\ MAP returns a new array as output 
: MAP ( initial addr size xt-- addr' size')
  [[ >R  ['] MAPPER IS ACTION  FOREACH  R> ]] SIZE ;

\ filter creates a temp counted array that might be a different size
: FILTER ( initial addr size xt-- addr' size')
 [[  >R  ['] FILTRATION IS ACTION  FOREACH  DROP R> DUP ]] DROP SIZE ;


\ TEST DATA
\ ==========================================================
\ Exmaple Usage:
[[  20 CELLS ALLOT  ]] DATA: B[] ( un-initialzed data example)
[[  1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 , 10 , ]] DATA: A[]


\  test code
A[] ..
\ using REDUCE
A[] SUM .
A[] AVERAGE .

\ MAP
A[] ' 8* MAP ..
A[] ' 1- MAP ..

\ FILTER
\ filter functions must have a stack diagram ( n n -- ?)
\ The flag determines if the data will be added to the output or not.
7 A[] ' < FILTER ..
4 A[] ' > FILTER ..
9 A[] ' = FILTER ..

\ using the initial value 1, we can test for ODD/EVEN
: EVEN ( initial n -- n ?)  AND 0= ;
: ODD  ( initial n -- n ?)  AND 0> ;
1 A[] ' EVEN FILTER ..
1 A[] ' ODD  FILTER ..

\ filter based on array element 
A[] 3 ]@  A[] ' > FILTER ..

\ SEQUENTIAL actions 
1 A[] ' ODD FILTER  ' 8* MAP  SUM . 


