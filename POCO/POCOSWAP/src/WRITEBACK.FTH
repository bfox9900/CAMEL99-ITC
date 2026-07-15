\ WRITEBACK.FTH  line list manager  BJF 2026

CR .( WRITBACK  for POCO SWAPFILE version)
CR

: LASTNODE ( -- addr ) LASTLINE ]NODE ;

\ : ?MEMORY  LASTNODE @  $POOL-SIZE > ABORT" $POOL full" ;
\ : FREE-NODE ( n -- ) TRUE SWAP ]NODE ! ; \ mark node as free

: ]REMOVE-NODE ( n -- )
    DUP 1+ ]NODE SWAP ]NODE  LASTNODE OVER -  2 MAX  CMOVE ;

: ]ALLOT-NODE ( line# --) VM.HERE SWAP ]NODE !  ;

\ It's pretty fast to slide the node memory with CMOVE> to make space
: ]OPEN-NODE ( line#--)
    ]NODE DUP CELL+   ( src dst )
    LASTNODE [ 2 CELLS ] LITERAL +  OVER -  CMOVE>
;

: INSERT-NODE ( n --) DUP ]OPEN-NODE ]ALLOT-NODE ;

\ We need to test for 1K buffer boundaries with ?NEXTPAGE
: ]NEW$      ( addr len line#--)
    >R  VM.HERE ?NEXTPAGE   \ if string is too long, goto nextpage
    R> ]ALLOT-NODE $POOL, ;

: ]INSERT$   ( addr len line#--)
    >R  VM.HERE ?NEXTPAGE
    R> INSERT-NODE $POOL,  1 #LINES+! ;

\ When the edit-buffer is edited we can save it back to the same $POOL address
\ IF the length of the []node string is >= than the edit-buffer we re-use it.
\ Otherwise we must get a new memory (VM.HERE: empty space) and update the []NODE.
 : WRITE-BACK ( line# -- ) \ writeback a line buffer to the $pool
    DUP>R ]NODE @ LEN  EDIT-BUFFER LEN >=  \ compare node len to buffer len
    IF
        $EDIT-BUFFER R> ]POOL$.PUT    \ re-use $pool address
    ELSE
        $EDIT-BUFFER R> ]NEW$         \ add a new string
        1 #LINES+!
    THEN
    updated OFF
;

: ?WRITE-BACK ( -- ) updated @ IF  THELINE# WRITE-BACK  THEN ;
