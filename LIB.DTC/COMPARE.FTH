\ Neil Baud's toolbelt: COMPARE in Forth
\ NOTE: this 40% faster in CAMEL99 than using Benschop version

: COMPARE                     ( a1 n1 a2 n2 -- -1|0|1 )
    ROT  2DUP - >R            ( a1 a2 n2 n1)( R: n2-n1)
    MIN                       ( a1 a2 n3)
    BOUNDS ?DO                ( a1)
        COUNT  I C@  -        ( a1 diff)
        DUP 
        IF
            NIP  0< 1 OR      ( -1|1)
            UNLOOP
            R> DROP
            EXIT              ( a1 diff)
         THEN  DROP           ( a1)
    LOOP 
    DROP                      ( )
    R>  DUP IF  0> 1 OR  THEN   \  2's complement arith.
 ;
