\ vdp memory manager words
VARIABLE VP

HEX 1000 VP !   \ start of free VDP RAM

: VHERE   ( -- addr) VP @ ;   \ FETCH the value in VDP pointer
: VALLOT  ( n -- )   VP +! ;  \ add n to the value in VDP pointer
: VC,     ( n -- )   VHERE VC!  1 VALLOT ;

\ convert counted string to addr,len
: VCOUNT  ( vdp$adr -- vdpadr len ) DUP 1+ SWAP VC@ ; 

: VCREATE ( <text> -- addr) VHERE CONSTANT ;

DECIMAL

