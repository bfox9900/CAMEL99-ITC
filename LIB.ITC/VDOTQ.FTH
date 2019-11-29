\
NEEDS VHERE  FROM DSK1.VDPMEM

\ compile stack string into VDP memory
: VS,     ( $adr len-- )  VHERE OVER CHAR+  VALLOT VPLACE ;

\ convert a VDP counted string to a stack string
: VCOUNT  ( vdp$adr -- vdpadr len ) DUP 1+ SWAP VC@ ;

\ Print a VDP stack string
: VTYPE   ( vdp_addr len -- ) BOUNDS ?DO   I VC@ EMIT   LOOP ;

\ Compile a VDP string, that types itself
: V."          ( -- )
        VHERE
        [CHAR] " PARSE VS,
        POSTPONE LITERAL
        POSTPONE VCOUNT
        POSTPONE VTYPE ; IMMEDIATE

: MENU   PAGE
         CR V." *** Main Menu ****"
         CR
         CR V." 1. DO Nothing"
         CR V." 2. DO Something"
         CR V." 3. Burn the VDP chip"
         CR  ;
