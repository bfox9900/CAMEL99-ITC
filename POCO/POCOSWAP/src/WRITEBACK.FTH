\ WRITEBACK.FTH  line list manager  BJF 2026

CR .( WRITBACK  for POCO SWAPFILE version)
CR

\ : ?MEMORY  LASTNODE @  $POOL-SIZE > ABORT" $POOL full" ;
: ERASE-NODE ( n -- ) TRUE SWAP ]NODE ! ; \ mark node as free

: ]REMOVE-NODE ( n -- )
    DUP 1+ ]NODE  ( -- src )
    SWAP ]NODE    ( -- src dst )
    LASTLINE ]NODE  OVER -  2 MAX  CMOVE ; ( should use MOVE )

\ It's pretty fast to slide the node memory with CMOVE> to make space
: ]OPEN-NODE ( line#--)
    ]NODE DUP CELL+   ( src dst )
    LASTLINE ]NODE [ 2 CELLS ] LITERAL +  OVER -  CMOVE>
;

: ]INSERT-NODE ( line# -- addr) DUP ]OPEN-NODE ]NODE ;

: ]$OVERWRITE ( addr len line# --) \ node must already be assiged
    ]NODE @ DUP TRUE = ABORT" $OVERWRITE to unassigned node"
    VIRT>REAL PLACE    \ place the string in virtual memory
    UPDATE                     \ mark buffer for saving to disk
;

: ]NEW$      ( addr len line#--)
    >R                         \ save line #
    DUP 1+ VM.MALLOC ( -- addr len VMaddr)
    DUP R> ]NODE !                   \ copy vm address into NODE
    VIRT>REAL PLACE            \ place the string in virtual memory
    1 #LINES+!
    UPDATE                     \ mark buffer for saving to disk
;

: ]INSERT$   ( addr len line#--)
    >R
    DUP 1+ VM.MALLOC
    DUP R> ]INSERT-NODE !
    VIRT>REAL
    1 #LINES+!
    UPDATE
;

\ When the edit-buffer is edited we can save it back to the same $POOL address
\ IF the length of the []node string is >= than the edit-buffer we re-use it.
\ Otherwise we must get a new memory (VM.HERE: empty space) and update the []NODE.

 : WRITE-BACK ( line# -- ) \ writeback a line buffer to the $pool
    DUP>R ]NODE @ C@VM  \ fetch the len byte in virtual memory
    EDIT-BUFFER LEN >=  \ compare node len to buffer len
    IF
        $EDIT-BUFFER R> ]$OVERWRITE    \ re-use $pool address
        UPDATE
    ELSE
        $EDIT-BUFFER R> ]NEW$         \ add a new string
        UPDATE
        1 #LINES+!
    THEN
    updated OFF
;

: ?WRITE-BACK ( -- ) updated @ IF  THELINE# WRITE-BACK  THEN ;


\ TEST CODE
\ :  PUT$   #LINES @ ]NEW$  ;
\ : .STRINGS   #LINES @  0 DO   CR  I ]POOL$ TYPE  LOOP ;

\ S" String #1 " PUT$
\ S" This is the second string to install." PUT$
\ S" So let's make this the 3rd string." PUT$
\ S" AND JUST FOR FUN LET'S ADD A FOURTH STRING TO THE PILE" PUT$

\ testing inserts
\ S" ... insert this where the sun don't shine"  3 ]INSERT$
