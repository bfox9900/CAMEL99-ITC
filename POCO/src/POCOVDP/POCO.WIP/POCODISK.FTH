\ POCODISK.FTH   disk manager functions for poco editor Frb 2026 BJF

DECIMAL
: GET-PATH ( -- addr len ?)
  PARSE-NAME DUP 0= ABORT" File name expected"
  2DUP FILENAME PLACE ;

HEX
: INIT-MEMORY
 \   2000 H !
 \   MAXLINES ALLOCATE-NODES
 \   BUFFSIZE MALLOC TO EDIT-BUFFER

    0 0 ROW/COL 2!  \ resets "CURPOS"
    SOL OFF
    TOPLINE OFF  updated OFF
    EDIT-BUFFER CLEAN
    PURGE
    EMPTY$ THELINE# ]NEW$
    1 #LINES+!
;

DECIMAL
: ?READ-FILE
    PARSE-NAME DUP 0>
    IF 2DUP FILENAME PLACE
       INIT-MEMORY
       READ-FILE
    RETURN;
    2DROP ;

: LOAD ( <path> )
    INIT-MEMORY
    DECIMAL
    GET-PATH READ-FILE
    CR .FSTATS
;

: READ  GET-PATH (READ-FILE) CR .FSTATS ;

: EDIT ( -- )
    ?READ-FILE
    MYCOLOR @ SCREEN
\ set up cursor speed values from DSK1.RKEY
     2 FASTKEY !
    41 SLOWKEY !
    INSERT OFF
    [CHAR] _ CURS !
    (EDIT)
;

: FLOAD ( $addr len -- ior) \ compile source from VDP memory
    CR ." Compiling editor file ..."
    HERE >R
    #LINES @  0
    ?DO
        I ]POOL$ TBUFF  VDP$.GET
        TBUFF COUNT EVALUATE
    LOOP
    CR  #LINES @ . ." lines "
    CR  HERE R> -  DECIMAL . ." bytes"
    TOPLINE OFF
;

: SAVEAS ( <path> ) GET-PATH  WRITE-FILE ;

: NEW ( <text> ) INIT-MEMORY  GET-PATH EDIT ;

 HEAP BUFFSIZE + CONSTANT ENDHEAP \ remember where HEAP memory ends
