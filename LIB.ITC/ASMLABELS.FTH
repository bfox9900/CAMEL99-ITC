\ ASMLABELS.FTH   numbered labels for ASM9900           Apr 3 2021 Fox
\ Original idea from DxForth. Complete rewrite uses a stack for forward refs.
\ Feb 2023 FS> error resets label stack with NEWLABELS 

CR .( Enumerated labels)

NEEDS MOV, FROM DSK1.ASM9900

DECIMAL
        15 CONSTANT #LABELS
#LABELS 2* CONSTANT #FWD

\ Make a stack to handle jumps
CREATE FS0    #FWD CELLS ALLOT
CREATE LABELS   #LABELS CELLS ALLOT

: ]LBL  ( n -- addr) CELLS LABELS + ;  \ array of label addresses

FS0 CREATE FSP ,   \ fwd stack pointer, initialized to FS0

: NEWLABELS  ( -- )
    LABELS  #LABELS CELLS 0 FILL  \ clear label array
    FS0 FSP !   \ reset fwd stack pointer to base address
;

: FSDEPTH ( -- n) FS0 FSP @ -  2/ ;
: >FS     ( addr --) 2 FSP +!   FSP @ ! ;
: FS>     ( -- addr)
    FSP @  DUP FS0 = 
    IF NEWLABELS 
       TRUE ABORT" Label stack underflow"
    THEN              
    ( stkaddr) @  -2 FSP +! ;

: $:  ( n -- )  HERE SWAP ]LBL !  ;  \ code label creator
: $   ( n -- 0) HERE >FS  >FS  0  ;  \ jump label creator

: ?LABEL  ( addr -- addr) DUP 0= ABORT" Un-resolved jump" ;

: RESOLVER ( -- )
      BEGIN
        FSDEPTH 
      WHILE
        FS> ]LBL @ ?LABEL
        ( lbladdress ) FS> TUCK - RESOLVE
      REPEAT
;

\ use +CODE to jump across words within same label scope
: +CODE   ( <name> ) CODE ; 
: CODE    ( <name> ) NEWLABELS CODE ;  \ start new label scope 
: ENDCODE ( -- ) ?CSP RESOLVER ;
: L:      ( <text> ) CREATE ;
