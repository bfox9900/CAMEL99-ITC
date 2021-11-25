\ ASMLABELS.FTH   numbered labels for ASM9900           Apr 3 2021 Fox
\ Original idea from DxForth. Complete rewrite uses a stack for forward refs.
CR .( Enumerated labels)

NEEDS MOV, FROM DSK1.ASM9900

DECIMAL
25 CONSTANT #FWD
20 CONSTANT #LABELS

\ Make a stack to handle jumps
CREATE FS0    #FWD CELLS ALLOT
FS0 CREATE FSP ,   \ fwd stack pointer, initialzed to FS0
: FSDEPTH ( -- n) FS0 FSP @ -  2/ ;
: >FS     ( addr --) 2 FSP +!   FSP @ ! ;
: FS>     ( -- addr)
          FSP @  DUP FS0 = ABORT" Label stack underflow"
          @  -2 FSP +!  ;

CREATE LABELS   #LABELS CELLS ALLOT
: ]LBL  ( n -- addr) CELLS LABELS + ;  \ array of label addresses

: NEWLABELS  ( -- )
    LABELS  #LABELS CELLS 0 FILL  \ clear label array
    FS0 FSP !   \ reset fwd stack pointer to base address
;

: $:  ( n -- )  HERE SWAP ]LBL !  ;  \ code label creator
: $   ( n -- 0) HERE >FS  >FS  0  ;  \ jump label creator

: ?LABEL  ( addr -- addr) DUP 0= ABORT" Un-resolved jump" ;

: RESOLVER ( -- )
       BEGIN
       FSDEPTH WHILE
           FS> ]LBL @ ?LABEL 
         ( lbladdress ) FS> TUCK - RESOLVE
       REPEAT
;

: +CODE   ( <name> ) CODE ; \ used to jump across CODE words
: CODE    ( <name> ) NEWLABELS CODE ;
: ENDCODE ( -- ) ?CSP RESOLVER ;
: L:      ( <text> ) CREATE ;
