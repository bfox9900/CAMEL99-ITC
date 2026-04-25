\ experiment to compile direct from VDP RAM

\ for debugging

: VDP.TYPE  ( Vaddr len -- ) BOUNDS ?DO  I VC@ (EMIT)  LOOP ;

: VCOMP        \ VDP compile
    LINES OFF
    0 ]NODE
    BEGIN
        DUP @ TRUE <>
    WHILE
        DUP @ VCOUNT PAD VDP$.GET
        PAD COUNT EVALUATE
        LINES 1+!
        CELL+
    REPEAT
    DROP
;
