\ Simple line editor for Blocks  Update for Camel99 V2.69

NEEDS BUFFER    FROM DSK1.BLOCKS
NEEDS -TRAILING FROM DSK1.TRAILING

HERE
VARIABLE SCR
VARIABLE SOL
VARIABLE SWID   C/L@ 4 - SWID !
DECIMAL
64 CONSTANT LWIDTH
LWIDTH 2/  1- CONSTANT LMASK

: BLANK  ( addr len -- ) BL FILL ;
: (LINE) ( lin# -- addr) SCR @ BLOCK SWAP  LWIDTH * + ;
\ : .LINE  ( lin# --) (LINE) SOL @ + SWID @ -TRAILING 1 MAX TYPE ;
: .LINE  ( lin# - ) (LINE) SOL @ + VPOS  SWID @ VWRITE ;
: (CP) ( L1 L2 -- ) (LINE) SWAP (LINE) SWAP LWIDTH MOVE ;

\ Line editor commands
: LIST   ( s# - )
  PAGE DUP SCR ! ." SCR# "  3 U.R
  CR ." Col" SOL @ 2 .R
  16 0 DO   CR I 2 .R ." |"  I .LINE   LOOP  CR QUIT ;

: ED ( -- ) SCR @ LIST ;

: ++ ( -- ) 1 SCR +! ED ;
: -- ( -- ) SCR @ 1- 0 MAX  SCR ! ED ;

: P  ( line# -- ) 0 PARSE ROT (LINE) SWAP MOVE UPDATE  ED ;
: D  ( line# -- ) (LINE) LWIDTH BLANK UPDATE ED ;
: CP ( L1 L2 -- ) (CP) UPDATE ED ;
: M  ( L1 L2 -- ) OVER >R (CP) R> D ;
: >> ( -- ) SOL DUP @ 8 + LMASK AND SWAP !  ED ; \ SHIFT list right
: << ( -- ) SOL DUP @ 8 - LMASK AND SWAP !  ED ; \ shifr list left

: LOAD  ( n -- )
        SCR !
        16 0
        DO
           I LINES !
           I (LINE) LWIDTH EVALUATE
        LOOP ;

: -->   ( n -- ) SCR @ 1+ LOAD ; IMMEDIATE
HERE SWAP - DECIMAL . .( bytes)
