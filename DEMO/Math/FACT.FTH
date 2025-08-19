\ factorial recursive code demo with tracing

NEEDS TRACE FROM DSK1.TRACE

\ redefine primitives that we want to trace makes them traceable
: DUP   DUP  ;
: SWAP  SWAP ;
: OVER  OVER ;
: *     *    ;
: 1     1  ;
: 1-    1- ;
: >     >  ;
: DROP  DROP ;
: IF  POSTPONE IF ; IMMEDIATE
: THEN POSTPONE THEN ; IMMEDIATE
: RECURSE  POSTPONE RECURSE ; IMMEDIATE

: FACTORIAL ( n -- )  \ n must be <= 8
    DUP 1 >
    IF
       DUP 1- RECURSE *
    THEN ;

\ iterative version (slightly faster)
: IFACTORIAL ( +n1 -- +n2)
    DUP 2 < IF  DROP 1 EXIT  THEN
    DUP
    BEGIN DUP 2 >
    WHILE
        1-  SWAP OVER *  SWAP
    REPEAT
    DROP ;

DECIMAL
CR .( Trace controls:
CR .( TRACE ON   -or-  TRACE OFF ) CR
CR
CR .( Usage:)
CR .( TRACE ON )
CR .( 4 FACTORIAL)
CR .( 4 IFACTORIAL)