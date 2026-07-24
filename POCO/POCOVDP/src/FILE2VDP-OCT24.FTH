\ FILE2VDP.FTH with node table    July 2025 B Fox

\ READ FILE to VDP RAM as counted strings
\ Fill VDP address of each string in a []NODE TABLE

\ NEEDS .S        FROM DSK1.TOOLS
NEEDS READ-LINE FROM DSK1.ANSFILES
NEEDS VHERE     FROM DSK1.VDPMEM  \ VHERE VALLOT VC, V, VCOUNT VCREATE
NEEDS MALLOC    FROM DSK1.MALLOC  \ manage low RAM as a simple heap
NEEDS FILLW     FROM DSK1.FILLW   \ 16 bit fast fill

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

\ limit constants
HEX
 0C00 CONSTANT []$POOL       \ Start of free VDP ram for strings

DECIMAL
400              CONSTANT MAXLINES   \ IE: 400 lines of 25 bytes
VDPTOP 300 -     CONSTANT ENDMEM     \ max VDP we can use
ENDMEM []$POOL - CONSTANT $POOL-SIZE \ largest file size

MAXLINES CELLS CELL+ MALLOC   CONSTANT []NODES \ base address
[]NODES  MAXLINES CELLS +     CONSTANT LASTNODE

[]NODES TABLE2: ]NODE  \ indexed access to []NODES

: ?NODES  ( -- )  LINES @ ]NODE  LASTNODE > ABORT" No more nodes" ;

HEX
\ NODES are filled with $FFFF to indicate empty
: NEW-NODES  ( -- ) []NODES MAXLINES CELLS  TRUE FILLW ;

: NEW-$POOL   ( -- )
    []$POOL DUP VP !       \ reset vdp pointer to base address
    $POOL-SIZE 0 VFILL     \ erase VRAM
;
DECIMAL

\ ** words ending with $ return a stack string (addr,len) pair **
\ *** WARNING ***  ]POOL$ returns a VDP address,len

\ Access VDP strings via the NODE list. Returns VDP strack string
: ]POOL$  ( n -- Vaddr len) ]NODE @ VCOUNT ;

\ *DIFFERENT*
\ PAB buffer is set to a different VDP address for each file read
: FREAD    ( Vaddr -- ior) [PAB FBUFF] V!  2 FILEOP ;
: ?EOM     ( Vaddr -- Vaddr) DUP ENDMEM > ABORT" VDP RAM full" ;

  VARIABLE #LINES      \ no. of lines in file
: VDP.READLN ( Vaddr -- ior)
    ?EOM
    ?NODES
    DUP 1+ FREAD DUP>R      \ read string into VDP ram at Vaddr 1+
( *IMPORTANT*  don't allocate the space if READLN throws an error )
    0= IF
      DUP #LINES @ ]NODE !   \ record VDP address in a node
      0 VC,                  \ compile a count byte in VDP address
      [PAB CHARS] VC@ DUP VALLOT \ allocate VDP space for string length
      SWAP VC!               \ store the length in 1st byte of Vaddress
    THEN R> ;                \ return error #

HEX FF CONSTANT $FF

DECIMAL
\ ****************************************************************
\ After READ-FILE #lines will be the number of lines in the file.
\ sine the File starts at line zero, the LASTLINE = #LINES -1
\ ****************************************************************
: READ-FILE  ( $addr len -- ior)
    NEW-$POOL  NEW-NODES
    #LINES OFF
    DV80 R/O OPEN-FILE ?FILERR >R
    BEGIN
      VHERE VDP.READLN 0=
    WHILE
      #LINES 1+!             \ count the line
    REPEAT
    R> CLOSE-FILE DROP
;

: $POOL-USED  ( -- u) VHERE []$POOL -  ;

: .FSTATS CR  #LINES @ 1+ U. ." lines, "  $POOL-USED U. ." bytes" ;

: FWRITELN ( Vaddr len handle -- )
  SELECT  [PAB CHARS] VC!  [PAB FBUFF] V!  3 FILEOP ?FILERR ;

: VDP-TRAILING ( adr len -- adr len')
  1- BEGIN  2DUP + VC@ BL = WHILE  1-  REPEAT 1+  0 MAX ;

\ usage:  S" DSK1.MYFILE" WRITE-FILE
\ write $pool back to disk via the node-list. Remove trailing spaces
VARIABLE #out
: WRITE-FILE ( addr len -- )
    DV80 W/O  OPEN-FILE ?FILERR #out !
    #LINES @ 0
    DO
      I ]POOL$ VDP-TRAILING #out @ FWRITELN
    LOOP
    #out @ CLOSE-FILE DROP ;

\ for debugging
: VDP.TYPE  ( Vaddr len -- ) BOUNDS ?DO  I VC@ (EMIT)  LOOP ;

: .NODES
    #LINES @ 1+ 0
    ?DO
      I ]POOL$ CR  VDP.TYPE
      ?TERMINAL ABORT" *BREAK*"
    LOOP
;
