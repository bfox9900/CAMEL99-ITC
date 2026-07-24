\ WRITEBACK.FTH  line list manager  BJF 2026

: LASTNODE ( -- addr ) LASTLINE ]NODE ;

\ : ?MEMORY  LASTNODE @  $POOL-SIZE > ABORT" $POOL full" ;
\ : FREE-NODE ( n -- ) TRUE SWAP ]NODE ! ; \ mark node as free

: ]REMOVE-NODE ( n -- )
    DUP 1+ ]NODE SWAP ]NODE  LASTNODE OVER -  2 MAX  CMOVE ;

: ]ALLOT-NODE ( line# --) VHERE SWAP ]NODE !  ;

\ It's pretty fast to slide the node memory with CMOVE> to make space
: ]OPEN-NODE ( line#--)
    ]NODE DUP CELL+   ( src dst )
    LASTNODE [ 2 CELLS ] LITERAL +  OVER -  CMOVE>
;

: INSERT-NODE ( n --) DUP ]OPEN-NODE ]ALLOT-NODE ;

: ]NEW$      ( addr len line#--) ]ALLOT-NODE VS,   ;
: ]INSERT$   ( addr len line#--) INSERT-NODE VS,  1 #LINES+! ;

\ When the edit-buffer is edited we can save it back to the same $POOL address
\ IF the length of the edit-buffer is >= the VDP string.
\ Otherwise we must get a new memory (VHERE: empty space) and update the []NODE.
 : WRITE-BACK ( line# -- ) \ writeback a line buffer to the $pool
    DUP>R ]NODE @ VLEN  EDIT-BUFFER LEN >=  \ compare node len to buffer len
    IF
        $EDIT-BUFFER R> ]VDP$.PUT    \ re-use $pool address
    ELSE
        $EDIT-BUFFER R> ]NEW$        \ add a new string
        1 #LINES+!
    THEN
    updated OFF
;

: ?WRITE-BACK ( -- ) updated @ IF  THELINE# WRITE-BACK  THEN ;
