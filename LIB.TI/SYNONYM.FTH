\ Synonym from Forth 2012

: COMPILE, ( addr -- ) , ;

: IMMEDIATE?  ( addr -- ?) LATEST @ 1- C@ 0> ;

: SYNONYM ( "newname" "oldname" -- )
\ Create a new definition which redirects to an existing one. 
   CREATE  
     HIDE ' , REVEAL
   DOES>
     @
     STATE @ OVER IMMEDIATE? OR
     IF    COMPILE,
     ELSE  EXECUTE
     THEN ;
