
\ reply: compiles a three cell data structure.
\ - base address of the array 
\ - the number of items in in the array 
\   (held in the first cell at base address)
\ - a counter
\ when invoked it returns the counter string and incs the counter. 
\ if the counter exceeds the number of items in the list the counter field
\ is reset.

\ make some syntax to handle the data structure
\ Not efficient but easier to understand 

VARIABLE BP  \ base pointer to data  

: [reply   ( -- Addr)  BP @ ;      \ return the base pointer to the structure

\ access the fields in the data structure
: strings] ( addr -- addr' ) @  ;  \ this is a constant
: last]  ( -- n)  @  @  ;          \ this is a constant 
: ndx]   ( -- addr) 2 CELLS + ;    \ this is a variable 

\ a REPLY returns the stack strings of a $ARRAY data sequentially
\ after the last string, it resets and starts over. 
: REPLY: ( $array -- )
\ COMPILE TIME
\        base addr, #strings,  counter 
  CREATE  DUP ,        @  ,      1 , 

\ RUN TIME when word is invoked
  DOES> ( -- addr len )  
    BP !                   \ set DP to the "CREATE" address 
  \ index into the data getting the "nth" string
    [reply strings] [reply ndx] @ NTH$ COUNT 
  \ update the ndx field 
    [reply ndx] DUP 1+!  
  \ test if we used the last reply and reset if true   
    @ [reply last] > IF  1 [reply ndx] ! THEN 
;
