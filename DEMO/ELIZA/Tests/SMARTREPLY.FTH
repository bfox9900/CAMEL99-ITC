
\ replys know the address and size of a string list. 
\ The also contain a local counter that is incremented after every invocation
\ When the counter>#items hits the end it wraps back to 0 

\ Base address of the defining word's data structure is held on the return stack.
\ these words give us access to the fields transparently 
: $[]     ( == addr) R@ @ ;         \ compact string array 
: #items  ( -- n)    R@   CELL+ @ ; \ a constant 
: last    ( -- addr) R@ 2 CELLS + ; \ a variable 

: REPLY:               \ strings  #items  lastused
       CREATE ( addr --) DUP ,     @ ,      1 ,
       DOES>  ( n -- $add len )
        >R    ( r: struct)
        $[] last @ NTH$ COUNT 
        last DUP 1+! @ ( -- n) #items > IF 1 last ! THEN  
        R> DROP ;

  ${ 
    $" reply 1"
    $" reply 2"
    $" reply 3"
    $" reply 4" 
    $" reply 5"
    $" reply 6"
    $" reply 7" }$ REPLY: TEST
