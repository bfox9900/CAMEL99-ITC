\ Simple line editor for Blocks and 80 col. mode     Brian Fox

\ Line editor Short commands

\ L  ( -- )  Re-list currect block
\ >>  ( -- )  List next block
\ <<  ( -- )  List previous block
\ P   ( l# -- <text>) Put <text> into line# ( 5 P This goes to line 5 )
\ DL  ( l# -- ) Delete line#
\ CP  ( l1 l2 -- ) Copy line1 to line2
\ M   ( l1 l2 -- ) Move line1 to line2. erase line1
\ O   ( <dsk?.path ) Open a block file
\ RO  ( -- )  RE-open a block file that has aborted
\ WIPE  ( blk# -- ) erase block

\ Line editor Word Commands

\ LIST ( n -- ) list block n
\ UNDO   empty all buffers and reload current block
\ EACH  ( blk1 blk2 XT ) Apply XT to each block in the range
\ INDEX ( blk1 blk2) show top line of blocks in the range given
\ LOAD  ( blk --) Load the given block
\ THRU  ( blk1 blk2) LOAD the blocks in the given range
\ WIPETHRU ( blk1 blk2) Erase the blocks in the given range
\ COPY  ( src dst -- ) copy src block to dst block
\ PASTE  Accept 16 lines of text into the current block
\ HELP   Show the short commands block

NEEDS DUMP       FROM DSK1.TOOLS
NEEDS VOCABULARY FROM DSK1.WORDLISTS
NEEDS BUFFER     FROM DSK1.BLOCKS
NEEDS 80COLS     FROM DSK1.80COL
NEEDS .R         FROM DSK1.UDOTR
NEEDS -TRAILING  FROM DSK1.TRAILING

80COLS

VOCABULARY EDITOR

ONLY FORTH ALSO EDITOR DEFINITIONS

HERE
DECIMAL
64 CONSTANT C/L  \ different than in Forth

\ utility words
: GETXY   ( -- X Y) VROW 2@ ;
: BLANK ( a n -) BL FILL ;
: ?BLK    DEPTH 0= ABORT" Block# expected" ;
: ?CLOSE-BLOCKS   BHNDL @ IF  CLOSE-BLOCKS THEN ;

\ list a block
: LINE    ( l# -- addr) C/L *  SCR @ BLOCK + ;
: ROW     ( l# -- l#') DUP LINE C/L -TRAILING TYPE 1+ ;
: .LINE   ( l# -- l#') DUP 2 .R  ." | " ROW CR ;
: 4LINES  ( l# -- l#') .LINE .LINE .LINE .LINE ;
: 16LINES ( -- )  0 4LINES 4LINES 4LINES 4LINES DROP ;

: .HEAD   ( n -- )   ." SCR#" 4 .R 50 SPACES  ACTIVE COUNT TYPE CR ;
: .NDX    ( blk# --) DUP SCR ! CR 3 .R SPACE  0 ROW DROP ;

\ display line# and edit it in block buffer
: ACCEPTLN ( l# -- ) LINE C/L ACCEPT DROP ;
: TYPELN   ( l# -- ) LINE C/L TYPE ;
: EDITLN ( line# -- ) >R  GETXY  R@ TYPELN  AT-XY R> ACCEPTLN ;

\ editor commands  Sept 2025 Changed to align with Starting Forth
: LIST ( n -- ) PAGE DUP SCR ! .HEAD  16LINES ;
: L    SCR @ LIST  ;
: >>  ( -- )  1 SCR +! L ;
: <<  ( -- )  SCR @ 1- 0 MAX  SCR ! L ;
: P   ( l# -- ) 1 PARSE ROT LINE SWAP CMOVE UPDATE  L ;
: EL  ( l# --) CR EDITLN  UPDATE  L ;

: DL   ( l# -- ) LINE C/L BLANK UPDATE L ;

: (CP) ( l1 l2 --) LINE SWAP LINE SWAP C/L MOVE ;
: CP   ( L1 L2 -- ) (CP)  UPDATE  L ;
: MV   ( L1 L2 -- ) OVER >R (CP) R> DL ;

: WIPE ( blk --) ?BLK  BLOCK B/BUF BLANK UPDATE ;
: UNDO ( -- )   EMPTY-BUFFERS L ;

: USE ( <path> )  BL PARSE-WORD  ?CLOSE-BLOCKS OPEN-BLOCKS ;
: RO  ( -- )    ACTIVE COUNT OPEN-BLOCKS ; \ re-open block file

: INDEX    ( n1 n2 --) 1+ SWAP ?DO  I .NDX  LOOP ;
: THRU     ( n1 n2 --) 1+ SWAP ?DO  I LOAD  LOOP ;
: WIPETHRU ( n1 n2 --) 1+ SWAP ?DO  I WIPE  LOOP ;

\ COPY PASTE HELP
: COPY   ( src dst -- ) FLUSH  SWAP  BLOCK 2- !  UPDATE ;

: PASTE  ( -- ) \ for pasting text into a block
    16 0
    DO
        I ACCEPTLN UPDATE
    LOOP
    FLUSH ;

: HELP   1 LIST ;

HERE SWAP - .
ONLY FORTH DEFINITIONS  ALSO EDITOR

USE DSK7.BLOCKS
0 LIST
