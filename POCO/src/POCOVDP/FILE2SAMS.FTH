\ FILE2SAMS.FTH with node table    Nov 26, 2025 B Fox

\ READ FILE to SAMS 64k segment as counted strings
\ Put the "virtual" address of each string in a []NODE TABLE

\ ** NAMING CONVENTIONS **
\ 1. Words ending with $ return a stack string
\    i) Be aware.  ]POOL$ is in SAMS  memory.  You have been warned

\ 2. Words starting with ] need an indexing argument

NEEDS .S        FROM DSK1.TOOLS
NEEDS READ-LINE FROM DSK1.ANSFILES
NEEDS VIRT>REAL FROM DSK1.SAMSFTH
NEEDS -TRAILING FROM DSK1.TRAILING
NEEDS FILLW     FROM DSK1.FILLW   \ 16 bit fast fill
NEEDS ERASEW    FROM DSK1.ERASEW  \ fast cell erase


HEX 2000 H !   CR .( ** HEAP has been reset ** ) CR

\ table2 creates fast integer array whereever you need it, RAM or VDP RAM
HEX
: TABLE2: ( addr -- )        \ create a table of CELLS
     CREATE    ,             \ compile base address into this word
     ;CODE ( n -- addr')     \ RUN time
          0A14 ,  \ TOS 1 SLA,  ( tos = n x 2 )
          A118 ,  \ *W TOS ADD,
        NEXT,
     ENDCODE

1 SEGMENT

\ ---------------------------------------------------------------
\          *** SAMS MEMORY MANAGEMENT and Utilities ***
VARIABLE SDP   \ sams dictionary pointer

: SAMS.HERE   SDP @ ;
: SAMS.ALLOT  SDP +! ;
: SAMS.ALIGN  SAMS.HERE ALIGNED SDP ! ;

: ,L       SAMS.HERE !L  2 SAMS.ALLOT ;
: C,L      SAMS.HERE C!L 1 SAMS.ALLOT ;

HEX
: NEXTPAGE   ( dst -- dst')  F000 AND 1000 + ;
: CROSSOVER? ( len Saddr -- len Saddr ?) 2DUP + F000 AND  OVER F000 AND - ;

DECIMAL
: ?NEXTPAGE  ( len dst -- len dst') CROSSOVER? IF NEXTPAGE THEN ;

\ : SAMS.PARA  ( n -- addr)  16 * VIRT>REAL ;
\ : SAMS.WRITE ( addr len Virtaddr) VIRT>REAL ?NEXTPAGE SWAP MOVE ;
\ : SAMS.READ  ( Virtaddr len addr ) >R  SWAP VIRT>REAL ?NEXTPAGE  R> MOVE ;

\ SLOW versions. But with 1 byte resolution
\ : SAMS.MOVE   ( a1 a2 u -- ) BOUNDS DO  DUP @L  I !L   2 +LOOP DROP ;
\ : SAMS.CMOVE  ( a1 a2 u -- ) BOUNDS DO  DUP C@L I C!L     LOOP DROP ;

: SAMS.PLACE   ( src n dst -- )
  VIRT>REAL 2DUP C! 1+ SWAP 1+ CMOVE ( SAMS.ALIGN) ;


\ clears 4k pages at a time. *NO PROTECTION*
HEX 1000 CONSTANT 4K

: SAMS.ERASE  ( addr len --) BOUNDS DO  I VIRT>REAL 4K ERASEW  4K +LOOP ;

\ ---------------------------------------------------------------
HEX
 0000 CONSTANT []$POOL       \ Start of free ram for strings

DECIMAL
1000             CONSTANT MAXLINES
65535 82 -       CONSTANT ENDMEM     \ max segment space we can use
ENDMEM []$POOL - CONSTANT $POOL-SIZE \ largest file size

\ *FUTURE*  move []NODES to a SAMS page to save dictionary space
CREATE []NODES     MAXLINES CELLS CELL+ ALLOT

[]NODES TABLE2: ]NODE  \ gives fast indexed access to []NODES

[]NODES  MAXLINES CELLS +  CONSTANT LASTNODE

: ?NODES  ( -- )  LINES @ ]NODE  LASTNODE > ABORT" No more nodes" ;

HEX
\ NODES are filled with $FFFF to indicate empty
: NEW-NODES ( -- ) []NODES MAXLINES CELLS  FF FILL ;
: NEW-$POOL ( -- ) []$POOL $POOL-SIZE SAMS.ERASE  SDP OFF ;


\ ** words ending with $ return a stack string (addr,len) pair **
DECIMAL
\ Access SAMS strings via the NODE list. Returns a stack string
: ]POOL$  ( n -- Saddr len) ]NODE @  VIRT>REAL COUNT ;

: ?EOM     ( -- ) SAMS.HERE ENDMEM U> ABORT" SAMS buffer full" ;

VARIABLE #LINES      \ no. of lines in file

: READ.RECORD ( hndl -- addr len ior) >R PAD DUP 80 R> READ-LINE NIP ;
\ compile a string into SAMS string pool and record addres in a NODE
\ never allows a string to cross a page boundary
: $POOL,       ( c-addr u -- )
\ if there is NOT room in the SAMS page move to next page
  SAMS.HERE ?NEXTPAGE SDP !

  SAMS.HERE DUP #LINES @ ]NODE !    \ store the location in a node
  OVER 1+ SAMS.ALLOT SAMS.PLACE     \ place the string in SAMS memory
;

HEX FF CONSTANT $FF

DECIMAL
\ *****************************************************************
\ read a file into $pool but do not initialize the system
: APPEND-FILE  ( $addr len -- )
    DV80 R/O OPEN-FILE ?FILERR >R
    BEGIN
      R@ READ.RECORD
    0= WHILE
      ?EOM
      ?NODES $POOL,
      #LINES 1+!             \ count the line
    REPEAT
    2DROP                    \ last record is invalid.
    R> CLOSE-FILE DROP
;

\ ****************************************************************
\ After READ-FILE #lines will be the number of lines in the file.
\ Since the File starts at line zero, the lastline is one less that #LINES.
: READ-FILE  ( $addr len -- ) NEW-$POOL  NEW-NODES  #LINES OFF  APPEND-FILE ;

\ for debugging
: .NODES
    #LINES @ 0
    ?DO
      I ]POOL$ CR TYPE
      SPACEBAR
      ?TERMINAL ABORT" *BREAK*"
    LOOP
;

: .FSTATS  CR #LINES @ U. ." lines, "  SAMS.HERE U. ." bytes" ;

\ usage:  S" DSK1.MYFILE" WRITE-FILE
\ write $pool back to disk via the node-list. Remove trailing spaces
: WRITE-FILE ( addr len -- )
    DV80 W/O  OPEN-FILE ?FILERR >R
    0 ]NODE          \ address of first node
    BEGIN
       DUP @ TRUE <> \ test for unallocated NODE
    WHILE
    \ * fetch the SAMS "virtual" address from the NODE.
      DUP @
    \ convert to REAL address which pulls the sams page into CPU memory
      VIRT>REAL
    \ now use regular Forth words
      COUNT -TRAILING R@ WRITE-LINE ?FILERR
    \ advance to next node ...
      CELL+
    REPEAT
    DROP
   R> CLOSE-FILE DROP ;
