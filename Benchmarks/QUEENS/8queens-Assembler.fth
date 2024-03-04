\ http://www.forth.org/fd/FD-V02N1.pdf

\ SPECIAL CAMEL99 FORTH FEATURE DEMONSTRATION 
\ --------------------------------------------
\ made faster arrays with ;CODE  ENDCODE 
\ show how to use TRANSIENT PERMANENT and DETACH 
\ reset ARRAY items with OFF rather than 0 SWAP ! 
\ set ARRAY items with ON  
\ 27% SPEED IMPROVEMENT

\ Camel99 Forth HARNESS and Libary files 
INCLUDE DSK1.WORDLISTS 
INCLUDE DSK1.UDOTR
INCLUDE DSK1.ELAPSE 

: ++    POSTPONE 1+! ; IMMEDIATE 

INCLUDE DSK1.TRANSIENT

TRANSIENT  \ Assembler is only need temporarily. 
VOCABULARY ASSEMBLER 
ONLY FORTH ALSO ASSEMBLER DEFINITIONS 
INCLUDE DSK1.ASM9900 

PERMANENT  \ everything after this goes in regular dictionary
ONLY FORTH  ALSO ASSEMBLER  ALSO FORTH DEFINITIONS 

8 CONSTANT queens

\ Nqueen solution from FD-V02N1.pdf
 \ : 1array CREATE 0 DO 1 , LOOP DOES> SWAP CELLS + ;
 
 \ Make this array 8x faster with 2 assembler instructions 
 : 1array 
    CREATE 0 DO TRUE , LOOP   \ compile time: init array items 
\ Runtime will be this assembler code          
    ;CODE  
        TOS 1 SLA,  \ 1 SHIFT Left is 2*  ie: CELLS
        \ W register holds the data address of the word         
        W  R4 ADD,  \ data_address + tos = address(n)
        NEXT,
ENDCODE          

    queens 1array a \ a,b & c: workspaces for solutions
 queens 2* 1array b
 queens 2* 1array c
    queens 1array x \ trial solutions

: safe ( c i -- n )
  SWAP
  2DUP - queens 1- + c @ >R
  2DUP + b @ >R
  DROP a @ R> R> * * ;

: mark ( c i -- )
  SWAP
  2DUP - queens 1- + c 0 SWAP !
  2DUP + b OFF    \ 0 SWAP !
  DROP a OFF ;    \   0 SWAP ! ;

: unmark ( c i -- )
  SWAP
  2DUP - queens 1- + c 1 SWAP !
  2DUP + b ON   \ 1 SWAP !
  DROP a   ON ;  \ 1 SWAP ! ;

VARIABLE tries
VARIABLE sols

: .cols queens 0 DO I x @ 1+ 5 .R LOOP ;
: .sol ." Found on try " tries @ 6 .R .cols CR ;

: try
  queens 0
  DO 
    1 tries +!
    DUP I safe
    IF 
        DUP I mark
    	DUP I SWAP x !
        DUP queens 1- < 
        IF DUP 1+ RECURSE 
        ELSE sols ++  .sol 
        THEN DUP I unmark
     THEN
  LOOP 
  DROP ;

: GO 
  0 tries ! 
  CR 0 try 
  CR sols @ . ." solutions Found, for n = " queens . ;

DETACH  ( removes assembler and frees LOW RAM  HEAP )

CR .( Type:  ELAPSE GO )  
\ FD version in 54.8 seconds 
\ Optimized version in 43.1 seconds 
