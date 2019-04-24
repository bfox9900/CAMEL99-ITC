( The source for ROLL was Marshall Linker via George Smyth's Forth Forum)

 : ROLL ( [n]..[0] +n -- [n-1]..[0][n] )
        ?DUP
        IF  
           1- SWAP >R
           RECURSE
           R>  SWAP
        THEN  ;

