\ Forth DATA in VDP memory

NEEDS ELAPSE FROM DSK1.ELAPSE
NEEDS VHERE  FROM DSK1.VDPMEM  ( VHERE VALLOT  VC,  V, VCOUNT VCREATE )

\ VDP RAM const and var
: VCONST ( n -- ) CREATE  VHERE ,    V,  DOES> @ V@ ;
: VVAR   ( -- )   CREATE  VHERE ,  0 V,  DOES> @ ;

\ make the same construct for vars and const in CPU RAM ( apples to apples)
: CONST           CREATE       ,        DOES> @ ;
: VAR             CREATE     0 ,        DOES> @ ;

\ compile stack string into VDP memory
: VS,     ( $adr len-- )  VHERE OVER CHAR+  VALLOT VPLACE ;

\ Print a VDP stack string
: VDPTYPE   ( vdp_addr len -- ) BOUNDS ?DO   I VC@ (EMIT)  LOOP ;

\ Compile a VDP string, that types itself
: V."   ( <text> )
        ?COMP                     \ Abort if not compiling
        VHERE                     \ free memory location in VDP RAM
        [CHAR] " PARSE VS,        \ compile <text> into VDP RAM upto quote

       \ Compile this code after the string so it prints itself
        ( vhere) POSTPONE LITERAL
        POSTPONE VCOUNT
        POSTPONE VDPTYPE ; IMMEDIATE

\ TESTS
DECIMAL
VAR X
VAR Y
: INT-TEST
      99  X !
      10000 0
      DO
          X @  Y !     \ transfer x -> y (RAM->RAM)
      LOOP ;

VVAR VX
VVAR VY
: VINT-TEST
      99 VX !
      10000 0
      DO
         VX V@ VY V!   \ transfer vx -> vy (VDP ->VDP )
      LOOP ;

HEX
994A CONST FTI
994A VCONST VTI

DECIMAL
: CONST-TEST  10000 0  DO  FTI DROP LOOP ;
: VCONST-TEST 10000 0  DO  VTI DROP LOOP ;

: TEXT-TEST  PAGE 60 0 DO ." Testing 1 2 3 "  LOOP ;
: VTEXT-TEST PAGE 60 0 DO V." Testing 1 2 3 " LOOP ;
