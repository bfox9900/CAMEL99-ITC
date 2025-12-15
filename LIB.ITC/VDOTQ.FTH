\ PRINT strings in your program that reside in VDP RAM.

NEEDS VHERE  FROM DSK1.VDPMEM

\ convert a VDP counted string to a stack string (in VDPMEM file)
\ : VCOUNT  ( vdp$adr -- vdpadr len ) DUP 1+ SWAP VC@ ;

\ compile stack string into VDP memory
: VS,     ( $adr len-- )  VHERE OVER CHAR+  VALLOT VPLACE ;
: VSLITERAL  VS, POSTPONE LITERAL ;

\ Print a VDP stack string
: VTYPE   ( vdp_addr len -- ) BOUNDS ?DO   I VC@ EMIT   LOOP ;

: V.$   ( V$ -- ) VCOUNT VTYPE ;

\ Compile a VDP string, that types itself
: V."  ( -- )
    ?COMP
    VHERE
    [CHAR] " PARSE  VSLITERAL
    POSTPONE V.$
; IMMEDIATE

: MENU   PAGE
         CR V." *** Main Menu ****"
         CR
         CR V." 1. DO Nothing"
         CR V." 2. DO Something"
         CR V." 3. Burn the VDP chip"
         CR  ;
