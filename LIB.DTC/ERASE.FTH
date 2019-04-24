\ ERASE memory and fill mem with spaces. ALSO VDP memory equivalents

: ERASE     ( addr n --)  0 FILL ;
: BLANK     ( addr n --) BL FILL ;

: VERASE    ( VDP_addr n -- ) 0 VFILL ;
: VBLANK    ( VDP_addr n -- ) BL VFILL ;
