\ iterators.fth   MAP REDUCE FILTER for cell data  16JUL2022  B Fox

INCLUDE DSK1.TOOLS
INCLUDE DSK1.VALUES
INCLUDE DSK1.DEFER
INCLUDE DSK1.MARKER

DECIMAL
\  ** EXPERIMENTAL DATA STRUCTURE ***
\    COUNTED ARRAYS IN FREE MEMORY

\ creator for counted arrays in empty memory
\ Data structure has a 2 cell header
\ Cell 1: LINK - to previous array or zero
\ Cell 2: size - SIZE in bytes of this array
\ Data .....

VARIABLE LAST[]
: DLINK,    HERE LAST[] @ , LAST[] ! ;

: CLEAN    LAST[] @ IF  LAST[] @ DP !  THEN ;

: [[   ( -- addr )
       DLINK,  HERE  0 ,  ; \ create header, return the address

: ]]   ( -- addr )
       HERE OVER - 2- OVER ! ; \ end array, fill in the size

: SIZE ( addr -- addr size) DUP CELL+ SWAP @ ; \ size is in BYTES
: LINK ( addr -- 'array[] | 0) 2- @ ;

\ a word to name a counted array and return the (addr,len) pair
: DATA:   CREATE
          ( addr --) ,
          DOES> @ SIZE ( -- addr size)  ;

\ Explanation:
\ ACTOR holds the execution token (XT) for the operation that will be done
\ to each data element. The XT is passed to ACTOR by the programmer.
VARIABLE ACTOR

\ ACTION is vector that holds code that does the ACTOR XT  and it also
\ runs EXTRA code that makes the difference between REDUCE, MAP or FILTER
DEFER ACTION

\ this code is run in a loop by FOREACH
: REDUCER  ( initial n -- n)  ACTOR PERFORM ; \ reduce and return a value

: MAPPER   ( initial n -- )  REDUCER  ,  ; \ reduce and compile value

: FILTRATION ( initial n -- ) \ reduce with conditional value compilation
     2DUP SWAP REDUCER ( -- n ? )
     IF  ,       \ if true compile n into array
     ELSE DROP   \ otherwise throw it away
     THEN  ;

DECIMAL
\ * changed argument order to allow sequential calls to foreach
: FOREACH  ( addr size initial xt-- n) \ primary iterator
         >R -ROT R>  \ ugly but it works
         OVER 0= ABORT" FOREACH: size=0"
         ACTOR @ >R  \ allow variable to be re-entrant
         ACTOR !     \ set the XT of action on each cell
         BOUNDS DO  I @ ACTION   2 +LOOP
         R> ACTOR !
;

: REDUCE  ( addr size inital xt-- n)
         ['] REDUCER IS ACTION  FOREACH  ;

\ Use REDUCE to do something
: ..  ( addr size -- ) 0 ['] .  REDUCE DROP ; \ print array signed
: U.. ( addr size -- ) 0 ['] U. REDUCE DROP ; \ print array un-signed
: SUM     ( addr len -- n) 0 ['] + REDUCE ;
: AVERAGE ( addr len -- n) DUP 2/ >R  SUM  R> / ;

\ MAP returns a new array as output
: MAP  ( addr size xt-- addr' size)
  0 SWAP \ add the intial value. Not used but need by FOREACH
  [[ >R   ['] MAPPER IS ACTION  FOREACH DROP  R> ]] SIZE ;

\ filter returns a new array as output that might be a different size
: FILTER  ( addr size inital xt-- addr' size')
 [[  >R   ['] FILTRATION IS ACTION  FOREACH  DROP R> ]]  SIZE ;
\ ======================= ITERATORS ENDS ===========================

\ TEST DATA
[[  20 CELLS ALLOT  ]] DATA: B[] ( un-initialzed data example)
[[  1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 , 10 , -1 , -2 , ]] DATA: A[]

\  TEST CODE
A[] ..
\ using REDUCE
A[] SUM .
A[] AVERAGE .

\ MAP * changed to require an initial value. '0' is most common.
A[]  ' 8* MAP ..
A[]  ' 2+  MAP ..

\ FILTER
\ filter functions must have a stack diagram ( n n -- ?)
\ The flag determines if the data will be added to the output or not.
 A[] 7 ' < FILTER ..
 A[] 4 ' > FILTER ..
 A[] 9 ' = FILTER ..

\ using the initial value 1, we can test for ODD/EVEN
: EVEN? ( initial n -- n ?)  AND 0= ;
: ODD?  ( initial n -- n ?)  AND 0> ;
 A[] 1 ' EVEN? FILTER ..

\ feed a filter into another filter :)
 A[] ' 2* MAP  3 ' > FILTER  16 ' < FILTER 2DUP CR .. CR SUM .
