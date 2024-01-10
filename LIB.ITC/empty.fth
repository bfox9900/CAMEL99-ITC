\ Empty.fth   clean the dictionary and make a new marker  
NEEDS MARKER FROM DSK1.MARKER
 
: EMPTY  S" *END*  MARKER *END*"  EVALUATE ;
 
MARKER *END*