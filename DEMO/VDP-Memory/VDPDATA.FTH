\ Forth DATA in VDP memory
\ Conclusion:  
\   Keeping text data in VDP RAM is almost as good as CPU RAM

NEEDS .S     FROM DSK1.TOOLS 
NEEDS ELAPSE FROM DSK1.ELAPSE
NEEDS VHERE  FROM DSK1.VDPMEM  ( VHERE VALLOT  VC,  V, VCOUNT VCREATE )

\ VDP RAM const and var
: CONST ( n -- )  CREATE  VHERE ,    V,  DOES> @ V@ ;
: VAR   ( -- )    CREATE  VHERE ,  0 V,  DOES> @ ;

\ compile stack string into VDP memory
: VS,     ( $adr len-- )  VHERE OVER CHAR+  VALLOT VPLACE ;

\ compile string into VDP RAM upto quote
: VS"       ( <text>" ) 
      ?COMP 
      VHERE               \ get address of free VDP ram
      [CHAR] " PARSE VS,  \ parse the string, compile to VDP ram 
      POSTPONE LITERAL    \ compile the VDP address as a literal 
      POSTPONE VCOUNT ;   \ compile VCOUNT 
IMMEDIATE 

\ Print a VDP stack string
: VDPTYPE   ( vdp_addr len -- ) BOUNDS ?DO   I VC@ (EMIT)  LOOP ;

\ Compile a VDP string, that types itself
: V."   ( -- ) ?COMP  POSTPONE VS"   POSTPONE VDPTYPE ; IMMEDIATE
\ --- 

\ TESTS
: V$   
 VS" This string is in VDP RAM. It returns a Vaddr and length" ;
: R$  
  S" This string is in CPU RAM. It returns an addr and length" ;

DECIMAL
VARIABLE X  VARIABLE Y
: INT-TEST
      99  X !
      10000 0
      DO
          X @  Y !     \ transfer x -> y (RAM->RAM)
      LOOP ; \ 2.38 SECS

VAR VX  VAR VY
: VINT-TEST
      99 VX !
      10000 0
      DO
         VX V@ VY V!   \ transfer vx -> vy (VDP ->VDP )
      LOOP ; \ 6.23 SECS 

: TEXT-TEST  PAGE 60 0 DO  R$ TYPE     LOOP ; \ 6.68 
: VTEXT-TEST PAGE 60 0 DO  V$ VDPTYPE  LOOP ; \ 6.91 
