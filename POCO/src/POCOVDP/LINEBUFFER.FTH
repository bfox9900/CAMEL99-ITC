\ LINEBUFFER.FTH single line buffer model   Sept 20 2025

NEEDS ]NODE FROM DSK2.FILE2VDP
NEEDS -TRAILING FROM DSK1.TRAILING

DECIMAL
            80 CONSTANT TEXTLEN
TEXTLEN 2+     CONSTANT LINE-SIZE   \ contains text data only

LINE-SIZE MALLOC CONSTANT []BUFFER  \ in low RAM

\ words ending with $ return a stack string (addr,len) pair
HEX
7F CONSTANT $MASK

DECIMAL

VARIABLE updated   \ set to true when you change a buffer

: UPDATE  updated ON ;

: LEN  ( Caddr -- c)  C@ ;

\ $POOL does not use the update flag
: VLEN  ( Vaddr -- c) VC@ ;

BL DUP FUSE CONSTANT BLBL  \ two spaces

DECIMAL
: NEW-BUFFER  []BUFFER LINE-SIZE BLBL FILLW ;

: PURGE   NEW-$POOL NEW-NODES  NEW-BUFFER ;

\ store VDP stack string in RAM 'addr' as a counted string
: V$!   ( Vaddr len addr ) 2DUP C! 1+ SWAP  VREAD ;

VARIABLE topln# \ remember the 1st line# in the buffers

\ load 24 lines into the line buffers 0..24 for editing
DECIMAL
: LOAD-BUFFER ( topline -- )
    DUP topln# !          \ remember what is in the buffer
    NEW-BUFFER

;

\ load buffers only if needed
: ?LOAD-BUFFERS ( topline --)
    topln# @ OVER= IF  DROP EXIT  THEN LOAD-BUFFERS ;

\ ]LINE computes correct buffer to use for any file_line# that we select
: ?BUFFNDX ( n -- n)
  DUP 0 24 WITHIN 0= ABORT" Line buffer index out of range" ;

: >ndx   ( file_line# -- ndx ) topln# @ -  ?BUFFNDX  ;
: ]LINE  ( file_line# -- addr) >ndx ]BUFFER  ;
: ]LINE$ ( file_line# -- addr len) ]LINE COUNT ;

: .BUFFERS ( n - )
      L/SCR 0  DO   I OVER + ]BUFFER$  TYPE CR  LOOP ;

\ compile RAM string into VDP $pool
: VS,  ( addr len -- ) VHERE OVER 1+ VALLOT VPLACE ;
: <=   1+ < ;

\ When a line buffer is edited we can save it back to the same $POOL address
\ IF and only if the length of the edited buffer is >= the $pool.
\ Otherwise we must save it at VHERE and update its []NODE.

: WRITE-BACK ( line# -- ) \ writeback a line buffer to the $pool
    DUP>R                           \ copy line# to rstack
    ]LINE LEN  R@ ]NODE @ VLEN <=   \ compare VDP len  vs buffer len
    IF
        R@ ]LINE$  R> ]NODE @ VPLACE \ re-use $pool address
    ELSE
        VHERE
        R@ ]NODE !         \ record the new location in [i]node
        R> ]LINE$ VS,      \ compile the string into VDP memory
    THEN
    updated OFF
;
