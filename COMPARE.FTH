\ Neil Baud's toolbelt compare in Forth

: COMPARE                     ( a1 n1 a2 n2 -- -1|0|1 )
    ROT  2DUP - >R            ( a1 a2 n2 n1)( R: n2-n1)
    MIN                       ( a1 a2 n3)
    BOUNDS ?DO                ( a1)
        COUNT  I C@  - ( a1 diff)
        DUP IF
            NIP  0< 1 OR      ( -1|1)
            UNLOOP
            R> DROP
            EXIT THEN         ( a1 diff)
        DROP                  ( a1)
    LOOP DROP                 ( )
    R>  DUP IF  0> 1 OR  THEN   \  2's complement arith.
    ;

: A$ S" NOW IS THE TIME"  ;
: B$ S" THIS IS THE TIME" ;
: C$ S" now is the time" ; 
