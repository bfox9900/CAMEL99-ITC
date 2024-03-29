\ forth-94 version of klaus schleisiek's dynamic memory allocation
\ (forml'88) uh 2016-10-28 

\ This is a full implementation using 780 bytes. Rather big for TI-99.

\ CAMEL Forth does not have CATCH and THROW. Use ?MEM to catch IOR
: ?MEM ( ior -- ) ?DUP IF DUP .  S" MEM error" ?ABORT THEN ;

NEEDS MALLOC FROM DSK1.MALLOC
NEEDS MOVE   FROM DSK1.MOVE

HERE
VARIABLE ANCHOR  0 ANCHOR !

DECIMAL 050 CONSTANT WASTE

-1 1 RSHIFT CONSTANT #MAX   \ biggest signed integer
#MAX INVERT CONSTANT #FREE  \ sign bit

: SIZE      ( mem -- size ) [ 1 CELLS ] LITERAL - @ #MAX AND ;
: ADDR&SIZE ( mem -- mem size ) DUP SIZE ;
: ABOVE     ( mem -- >mem ) ADDR&SIZE + 2 CELLS + ;
: USE       ( mem size -- ) DUP >R SWAP  2DUP 1 CELLS - !  R> #MAX AND + ! ;

: RELEASE ( mem size -- )  #FREE OR USE ;

: FITS? ( size -- mem | false ) >R ANCHOR @
   BEGIN
      ADDR&SIZE  R@ U< 0=
      IF R> DROP EXIT THEN
      @ DUP ANCHOR @ =
   UNTIL
   0= R> DROP ;

: LINK ( mem >mem <mem -- )
       >R 2DUP CELL+ !  OVER !  R> 2DUP !  SWAP CELL+ ! ;

: @LINKS ( mem -- <mem mem> )  DUP @  SWAP CELL+ @ ;
: SETANCHOR ( mem -- mem ) DUP ANCHOR @ = IF  DUP @ ANCHOR ! THEN ;
: UNLINK ( mem -- ) SETANCHOR  @LINKS 2DUP !  SWAP CELL+ ! ;

: ALLOCATE ( size -- mem ior )
   3 CELLS MAX DUP >R  FITS? ?DUP 0= IF R> -8 EXIT THEN ( "dictionary overflow" )
   ADDR&SIZE R@ -  DUP WASTE U<
   IF  DROP  DUP @ OVER UNLINK  OVER ADDR&SIZE USE
   ELSE 2 CELLS -   OVER R@ USE
        OVER ABOVE   DUP ROT RELEASE
        2DUP SWAP @LINKS LINK
   THEN R> DROP  ANCHOR ! 0 ;

: FREE ( mem -- ior )
   ADDR&SIZE  OVER 2 CELLS -  @ DUP 0<
   IF #MAX AND 2 CELLS +  ROT OVER - ROT ROT +
   ELSE  DROP  OVER ANCHOR @  DUP CELL+ @  LINK THEN
   2DUP + CELL+ DUP @ DUP 0<
   IF  #MAX AND SWAP CELL+ UNLINK  +  2 CELLS +  RELEASE 0 EXIT THEN
   2DROP RELEASE 0 ;

: RESIZE ( mem newsize -- mem' ior )
    OVER SWAP  OVER SIZE  2DUP >
    IF ( MEM MEM SIZE NEWSIZE )  SWAP ALLOCATE ?DUP
        IF >R DROP 2DROP R>  EXIT THEN
        DUP >R SWAP MOVE FREE R> SWAP EXIT THEN
    2DROP DROP 0 ;

: EMPTY-MEMORY ( addr size -- )
   >R  CELL+ DUP ANCHOR !   DUP 2 CELLS USE  DUP 2DUP LINK
   DUP ABOVE  SWAP OVER  DUP LINK
   DUP R> 7 CELLS -  RELEASE  ABOVE 1 CELLS -  0 SWAP ! ;

CR
CR .( DYNAMIC MEMORY ALLOCATION:)
CR .( use  "addr size EMPTY-MEMORY"  to initialize,)
CR .( Use ALLOCATE FREE RESIZE to manage memory.)

NEEDS MALLOC FROM DSK1.MALLOC
HEX 2000 DUP MALLOC SWAP ( addr len ) EMPTY-MEMORY
CR .( HEAP size is ) H @ 2000 - . .( bytes)
HERE SWAP - DECIMAL . .( bytes)
