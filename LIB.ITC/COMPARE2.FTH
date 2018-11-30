\  case insensitive compare from Neil Baud's tools

: BETWEEN ( n min max -- ?)  1+ WITHIN ;

\ character testers (bf versions)
: LOWER?  ( char -- ?)  [CHAR] a [CHAR] z BETWEEN ;
: UPPER?  ( char -- ?)  [CHAR] A [CHAR] Z BETWEEN ;

\ single char converters (bf versions)
: >LOWER     ( c -- c ) DUP UPPER? IF  020 OR  THEN ;
: >UPPER     ( c -- c ) DUP LOWER? IF  05F AND THEN ;

: COMPARE(NC)                 ( a1 n1 a2 n2 -- -1|0|1 )
    ROT  2DUP - >R            ( a1 a2 n2 n1)( R: n2-n1)
    MIN                       ( a1 a2 n3)
    BOUNDS ?DO                ( a1)
        COUNT >UPPER I C@ >UPPER - ( a1 diff)
        DUP IF
            NIP  0< 1 OR      ( -1|1)
            UNLOOP
            R> DROP
            EXIT THEN         ( a1 diff)
        DROP                  ( a1)
    LOOP DROP                 ( )
    R>  DUP IF  0> 1 OR  THEN   \  2's complement arith.
    ;
