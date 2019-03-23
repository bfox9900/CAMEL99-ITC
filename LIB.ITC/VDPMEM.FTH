\ vdp memory manager words

VARIABLE VP

HEX 1000 VP !   \ "VDP pointer" start of free VDP RAM

: VHERE   ( -- addr) VP @ ;   \ FETCH the value in VDP pointer
: VALLOT  ( n -- )   VP +! ;  \ add n to the value in VDP pointer
: VC,     ( n -- )   VHERE VC!  1 VALLOT ;
: V,      ( n -- )   VHERE V!   2 VALLOT ;

DECIMAL
