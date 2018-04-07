

: COMPILE, ( addr -- ) , ;

: IMMEDIATE?  ( addr -- ?)  LATEST @ 1- C@ 0> ;

: SYNONYM ( "newname" "oldname" -- )
\ Create a new definition which redirects to an existing one. 
   CREATE   \ IMMEDIATE
     HIDE ' , REVEAL 
   DOES> 
     @ 
     STATE @  \ OVER IMMEDIATE? OR
     IF    COMPILE,
     ELSE  EXECUTE
     THEN ;
