\ FILES2SWAP.FTH  load/save text files into virtual memory  B Fox July 2026

\ Concepts:
\ Use a block file as virtual memory, 64K bytes in size.
\ Use the blocks to store "packed" counted strings
\ When allocating block space, don't let strings cross block boundaries.
\ (this will lead to some dead space but no worries)

\ Create an array of "nodes" that point to strings in the block file

\ DELETIONS:
\ Deletions are done by sliding the []NODE array up one cell.

\ INSERTIONS:
\ Insertions are done by sliding the []node array to open up 1 cell.
\ The next avaliable space in Virtual memory is used for the string
\ and the address is stored in the new node.


\ NAMING CONVENTIONS:;
\ 1. Words ending with $ return a stack string
\    i) Be aware: ]POOL$ is in virtual memory but pulls itself into a buffer

\ 2. Words starting with ] need an indexing argument


\ --------------------------------
NEEDS .S    FROM DSK1.TOOLS
NEEDS -TRAILING FROM DSK1.TRAILING
NEEDS MALLOC FROM DSK1.MALLOC
NEEDS BLOCK FROM DSK1.BLOCKS
NEEDS FILLW FROM DSK1.FILLW     \ 16 bit fast fill
NEEDS GETXY FROM DSK2.POCOUTILS

\ table2 creates fast array whereever you need it, in RAM or VDP RAM
HEX
: TABLE2: ( addr -- )  \ create a table of CELLS
     CREATE    ,             \ compile base address into this word
     ;CODE ( n -- addr')     \ RUN time
          0A14 ,  \ TOS 1 SLA,  ( tos = n x 2 )
          A118 ,  \ *W TOS ADD,
        NEXT,
     ENDCODE

\ ---------------------------------------------------------------
\          *** VIRTUAL MEMORY MANAGEMENT and Utilities ***

\                       swapfile management ...

DECIMAL
CREATE SWAPPATH  16 ALLOT
S" DSK8.$SWAP$" SWAPPATH PLACE

: $SWAPFILE  ( -- $ len) SWAPPATH COUNT ;

\ Config file command to set the swap file path
: ?PATH   2DUP [CHAR] . SCAN  NIP 0= ABORT" File path expected" ;
: SWAPFILE=   PARSE-NAME ?PATH  SWAPPATH PLACE ;

SWAPFILE= DSK8.$SWAP$

64 CONSTANT LASTBLK
VARIABLE #LINES  \ double duty: indexs into []NODES list

: NEW-SWAPFILE       LASTBLK $SWAPFILE MAKE-BLOCKS ;
: ?CLOSE-FILE        ?DUP IF CLOSE-FILE DROP THEN ;
: MISSING?  ( -- ior) DF128 R/O OPEN-FILE SWAP ?CLOSE-FILE 7 = ;

: OPEN/CREATE ( path len -- )
    BHNDL @ IF  CLOSE-BLOCKS  THEN \ PREVENT using wrong block file
    2DUP MISSING?
    IF  CR ." Creating " 2DUP TYPE SPACE LASTBLK . ." Kbytes"
        CR ." ( standby ...)"
        NEW-SWAPFILE
        CR ." Opening swapfile"
    THEN
    OPEN-BLOCKS
    #LINES OFF ;

: OPEN-SWAPFILE ( -- ) $SWAPFILE OPEN/CREATE ;

\ ==============================================================
\                NODE TABLE or Virtual Memory Pointers
DECIMAL
0000             CONSTANT []$POOL    \ Start of free virtual memory for strings
1000             CONSTANT MAXLINES
65535 82 -       CONSTANT ENDMEM     \ max segment space we can use
ENDMEM []$POOL - CONSTANT $POOL-SIZE

\ *FUTURE*  move []NODES to virtual memory to save dictionary space?
CREATE []NODES     MAXLINES CELLS CELL+ ALLOT

[]NODES TABLE2: ]NODE  \ gives fast indexed access to []NODES

[]NODES  MAXLINES CELLS +  CONSTANT LASTNODE

: ?NODES  ( -- )  #LINES @ ]NODE  LASTNODE > ABORT" No more nodes" ;

HEX
\ NODES are filled with $FFFF to indicate empty
: NEW-NODES ( -- ) []NODES MAXLINES CELLS  FF FILL   #LINES OFF ;

\ ==============================================================
\              ... virtual memory to real memory  ...

VARIABLE VMDP   \ virtual memory pointer

: VM.HERE   ( -- VMaddr) VMDP @ ;
: VM.ALLOT  VMDP +! ;
: VM.ALIGN  VM.HERE ALIGNED VMDP ! ;

: VIRT>REAL ( VMaddr -- addr ) 0  B/BUF UM/MOD BLOCK + ;

\ store and fetch operators for virtual memory
: !VM  ( n vmaddr -- ) VIRT>REAL ! ;
: C!VM ( c vmaddr -- ) VIRT>REAL C! ;

: @VM  ( vmaddr -- n ) VIRT>REAL @ ;
: C@VM ( vmaddr -- c ) VIRT>REAL C@ ;

: ,VM       VM.HERE !VM  2 VM.ALLOT ;
: C,VM      VM.HERE C!VM 1 VM.ALLOT ;

\ RAW place string in virtual memory. **no protection for page crossing"
: VM.PLACE   ( src n dst -- )
    VIRT>REAL 2DUP C! 1+ SWAP 1+ CMOVE ;

: BASE>R  S"  BASE @ >R" EVALUATE ; IMMEDIATE
: R>BASE  S" R> BASE ! " EVALUATE ; IMMEDIATE
\ ==============================================================
: PURGE ( -- )
    BASE>R
    DECIMAL
    OPEN-SWAPFILE
    FIRST CELL+ B/BUF ERASE \ erase a buffer
    CR ." Erasing node list"
    NEW-NODES
    CR ." Erasing " $SWAPFILE TYPE SPACE  GETXY
    LASTBLK 1+  0
    DO
       2DUP AT-XY I . [CHAR] K EMIT
       FIRST CELL+ (WBLK)  \ copy erased buffer to disk
    LOOP
    2DROP
    FLUSH
    VMDP OFF
    #LINES OFF
    R>BASE
;

HEX
B/BUF 1- INVERT CONSTANT PAGEMASK

\ advance virtual memory address to the next 1K boundary
: NEXTPAGE   ( dst -- dst')  PAGEMASK AND  B/BUF + ;

\ test if there is room in the block for len + VMaddr
: CROSSOVER? ( len VMaddr -- len VMaddr ?)
  2DUP + ( newdst) PAGEMASK AND  OVER PAGEMASK AND - 0> ;

DECIMAL
\ if len+VHERE is to big for this buffer, advance to next page
: VM.MALLOC ( len -- VIRTaddr)
    ALIGNED
    VM.HERE CROSSOVER?
    IF
        NIP NEXTPAGE DUP VMDP !
    ELSE
        SWAP VM.ALLOT
    THEN ;

\ compile a string into virtual memory, protected from page crossing
\ record VM address in a NODE at index = #LINES
: $POOL,     ( c-addr u -- )
    DUP 1+ VM.MALLOC ( -- VIRTaddr) \ a safe location for string
    DUP #LINES @ ]NODE !       \ store the location in a node. index=#lines
    VIRT>REAL PLACE            \ place the string in virtual memory
    UPDATE                     \ mark buffer for saving to disk
;

\ Access vm strings via the NODE list. Returns a stack string
DECIMAL
: ]POOL$  ( n -- Saddr len) ]NODE @ VIRT>REAL COUNT ;

: ?EOM     ( -- ) VM.HERE ENDMEM U> ABORT" SWAP-FILE full" ;

: READ.RECORD ( hndl -- addr len ior) >R PAD DUP 80 R> READ-LINE NIP ;

: .FSTATS
    CR #LINES @ U. ." lines, "
    CR VM.HERE  U. ." bytes in virtual memory" ;

DECIMAL
\ *****************************************************************
\ read a file into $pool at the current VMDP location
: APPEND-FILE  ( $addr len -- )
    OPEN-SWAPFILE
    DV80 R/O OPEN-FILE ?FILERR >R
    BEGIN
      R@ READ.RECORD
    0= WHILE
      ?EOM  ?NODES
    ( 2DUP CR TYPE)  $POOL,
      #LINES 1+!             \ count the line
    REPEAT
    2DROP                    \ last record is invalid.
    R> CLOSE-FILE DROP
    .FSTATS
;

\ ****************************************************************
\ After READ-FILE #lines will hold the number of lines in the file.
\ Since the File starts at line zero, the lastline is one less that #LINES.
: READ-FILE  ( $addr len -- )
    NEW-NODES   #LINES OFF  VMDP OFF   APPEND-FILE ;

\ for debugging
: .NODES
    #LINES @ 0
    ?DO
      I ]POOL$ CR TYPE
      SPACEBAR
      ?TERMINAL ABORT" *BREAK*"
    LOOP
;

\ usage:  S" DSK1.MYFILE" WRITE-FILE
\ write $pool back to disk via the node-list. Remove trailing spaces
: WRITE-FILE ( addr len -- )
    FLUSH     \ saves all updated buffers to swapfile ?needed?
    DV80 W/O  OPEN-FILE ?FILERR >R
    []NODES          \ base address of node array
    BEGIN
       DUP @ TRUE <> \ test for unallocated NODE
    WHILE
      DUP @      \ * fetch the "virtual" address from the NODE.
      VIRT>REAL  \ convert to REAL pulls swapfile page into a buffer
      COUNT -TRAILING R@ WRITE-LINE ?FILERR \ now regular Forth words
      CELL+      \ advance to next node ...
    REPEAT
    DROP
    R> CLOSE-FILE DROP ;
