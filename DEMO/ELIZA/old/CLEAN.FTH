\ CLEAN.FTH  removing characters from a stack string 
 
\ these stack strings are passed to CLEAN 
: NOISE$ ( -- addr len) S" ,.?!'@#$[]%^&*()_+-{}:<>" ;
: BL$   S"  " ;


: REMOVE  ( addr len char -- addr len) 
    >R 2DUP R> SCAN 
    DUP 0= IF 2DROP EXIT THEN   \ char not found, get out 
    SWAP DUP 1+ SWAP ROT MOVE 1- ;

\ remove all the chars in addr2 from addr 1

: CLEAN   ( addr len addr2 len-- addr len')  BOUNDS DO  I C@ REMOVE  LOOP ;
: FLATTEN ( addr len -- addr len')  BL$ CLEAN ;

CREATE A$  80 ALLOT 

S" This is a nois@y s,trin.g @#%^&*&^%$" A$ PLACE 

A$ COUNT NOISE$ CLEAN CR TYPE 

A$ COUNT FLATTEN CR TYPE 
