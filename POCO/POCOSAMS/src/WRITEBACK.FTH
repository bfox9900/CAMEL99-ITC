\ WRITEBACK.FTH  line list manager  BJF 2026

: LASTNODE ( -- addr ) LASTLINE ]NODE ;

\ : ?MEMORY  LASTNODE @  $POOL-SIZE > ABORT" $POOL full" ;
\ : FREE-NODE ( n -- ) TRUE SWAP ]NODE ! ; \ mark node as free

: ]REMOVE-NODE ( n -- )
    DUP 1+ ]NODE SWAP ]NODE  LASTNODE OVER -  2 MAX  CMOVE ;

\ : ]ALLOT-NODE ( line# --) SAMS.HERE SWAP ]NODE ! ;
\ more complicated with SAMS. Must test page boundary for the new string
: ]ALLOT-NODE  ( addr len line# ) >R SAMS.HERE ?NEXTPAGE R> ]NODE ! ;

\ It's pretty fast to slide the node memory with CMOVE> to make space
: ]OPEN-NODE ( line#--)
    ]NODE DUP CELL+   ( src dst )
    LASTNODE [ 2 CELLS ] LITERAL +  OVER -  CMOVE>
;

: INSERT-NODE ( n --) DUP ]OPEN-NODE ]ALLOT-NODE ;

: SAMS.$PUT    ( addr len virtaddr -- ) OVER 1+ SAMS.ALLOT SAMS.PLACE ;
: ]NEW$        ( addr len line#--) ]ALLOT-NODE SAMS.HERE SAMS.$PUT ;

: ]INSERT$   ( addr len line#--) INSERT-NODE $POOL, ;

\ When the edit-buffer is edited we can save it back to the same $POOL address
\ IF the length of the edit-buffer is >= the POOL$ string.
\ Otherwise we must get a new memory (SAMS.HERE: empty space) and update the []NODE.

 : WRITE-BACK ( line# -- ) \ writeback a line buffer to the $pool
 \ must use C@L to read the length byte in SAMS memory
    DUP>R ]NODE @ C@L   \ Note: C@L maps in the SAMS page
    EDIT-BUFFER LEN >=  \ compare node len to buffer len
    IF
        $EDIT-BUFFER R> ]NODE @ PLACE \ re-use $pool address
    ELSE
        $EDIT-BUFFER  R> ]NEW$
        1 #LINES+!
    THEN
    updated OFF
;

: FORCE-WRITE-BACK  THELINE# WRITE-BACK ;

: ?WRITE-BACK ( -- ) updated @ IF  THELINE# WRITE-BACK  THEN ;
