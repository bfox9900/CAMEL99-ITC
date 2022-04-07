\ Simple line editor for Blocks and 80 col. mode     Brian Fox

\ Line editor Short commands

\ LS  ( n --) shortform for LIST
\ RL  ( -- )  Re-list currect block
\ >>  ( -- )  List next block
\ <<  ( -- )  List previous block
\ P   ( l# -- <text>) Put <text> into line# ( 5 P This goes to line 5 )
\ DL  ( l# -- ) Delete line#
\ CP  ( l1 l2 -- ) Copy line1 to line2
\ M   ( l1 l2 -- ) Move line1 to line2. erase line1
\ O   ( <dsk?.path ) Open a block file
\ RO  ( -- )  RE-open a block file that has aborted
\ EB  ( blk# -- ) erase block

\ Line editor Word Commands

\ LIST ( n -- ) list block n
\ UNDO   empty all buffers and reload current block
\ EACH  ( blk1 blk2 XT ) Apply XT to each block in the range
\ INDEX ( blk1 blk2) show top line of blocks in the range given
\ LOAD  ( blk --) Load the given block
\ THRU  ( blk1 blk2) LOAD the blocks in the given range
\ CLEANTHRU ( blk1 blk2) Erase the blocks in the given range
\ COPY  ( src dst -- ) copy src block to dst block
\ PASTE  Accept 16 lines of text into the current block
\ HELP   Show the short commands block

NEEDS DUMP       FROM DSK1.TOOLS
NEEDS BUFFER     FROM DSK1.BLOCKS
NEEDS 80COLS     FROM DSK1.80COL
NEEDS .R         FROM DSK1.UDOTR
NEEDS -TRAILING  FROM DSK1.TRAILING

80COLS

HERE
DECIMAL
\ B/L is the editor line len
64 CONSTANT B/L

: BLANK ( a n -) BL FILL ;
: ?BLK    DEPTH 0= ABORT" Block# expected" ;
: ROW   ( l# -- l#') DUP LINE VPOS B/L -TRAILING VWRITE 1+ ;
: .LINE   ( l# -- l#') DUP 2 .R  ." | " ROW CR ;
: 4LINES  ( l# -- l#') .LINE .LINE .LINE .LINE ;
: 16LINES ( -- )  0 4LINES 4LINES 4LINES 4LINES DROP ;
: (CP)    ( L1 L2 -- ) LINE SWAP LINE SWAP B/L CMOVE ;
: .HEAD   ( n -- )
   ." SCR#" 4 .R 50 SPACES  ACTIVE COUNT TYPE CR ;
: .NDX    ( blk# --)  BLOCK CR  0 .LINE ;

\ editor commands
: USE ( <path> )  BL PARSE-WORD  OPEN-BLOCKS ;
: LIST ( n -- ) PAGE DUP SCR ! .HEAD  16LINES ;
: LS   LIST ;
: RL  ( -- ) SCR @ LIST ;
: >>  ( -- )  1 SCR +! RL ;
: <<  ( -- )  SCR @ 1- 0 MAX  SCR ! RL ;
: P   ( l# -- ) 1 PARSE ROT LINE SWAP CMOVE UPDATE  RL ;
: DL  ( l# -- ) LINE B/L BLANK UPDATE RL ;
: CP  ( L1 L2 -- ) (CP) UPDATE  RL ;
: MV  ( L1 L2 -- ) OVER >R (CP) R> DL ;
: O   ( <TEXT> )  PARSE-NAME OPEN-BLOCKS ;
: RO  ( -- ) ACTIVE COUNT OPEN-BLOCKS ;
: EB  ( blk --) ?BLK  BLOCK B/BUF BLANK UPDATE ;
: UNDO ( -- ) EMPTY-BUFFERS RL ;

\ Higher order function maps function onto each line

: EACH ( n1 n2 XT --) \ MAP xt to range of blocks
      -ROT 1+ SWAP
      ?DO
        I OVER EXECUTE
        ?TERMINAL ABORT" Map halted"
      LOOP
      UPDATE
      DROP ;

: INDEX     ( n1 n2 --)  ['] .NDX EACH ;
: THRU      ( n1 n2 --)  ['] LOAD EACH ;
: CLEANTHRU ( n1 n2 --)  ['] EB   EACH ;

\ COPY PASTE HELP

: COPY   ( src dst -- ) FLUSH  SWAP  BLOCK 2- !  UPDATE ;

: PASTE  ( -- ) \ for pasting text into a block
      16 0
      DO
         I LINE B/L ACCEPT UPDATE
      LOOP
      FLUSH ;

: HELP   1 LIST ;

HERE SWAP - .

 USE DSK7.BLOCKS
 0 LIST
