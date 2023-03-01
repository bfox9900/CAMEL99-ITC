\ Indexers give use indexed Addressing operators in Forth 

\ indexed addressing macros for bytes 
\ fast byte array words
HEX 
: DROP, ( n --)       C136 , ;  
: ()C@, ( addr -- )   D124 , ( addr) , 0984 , ;
: ()C!, ( c addr --)  06D6 , D916 , ( addr ) ,  05C6 , DROP, ;


2000 CONSTANT FLAGS 
99 FLAGS C! 

CODE  ]FLAGSC@ ( ndx -- c)   FLAGS ()C@,  NEXT, ENDCODE 
CODE  ]FLAGSC! ( c ndx -- )  FLAGS ()C!,  NEXT, ENDCODE 


