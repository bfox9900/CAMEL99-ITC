\ VDP STRING with ." OVER-RIDE    2023 Brian Fox 

\ This version of ." puts all the text in VDP ram.
\ This save dictionary space for code. 

\ *WARNING* the VDP RAM is not save by SAVESYS, or SUPERSAVE 

NEEDS VHERE FROM DSK1.VDPMEM 

\ compile stack string into VDP memory
: VS,     ( $adr len-- )  VHERE OVER CHAR+  VALLOT VPLACE ;

\ Print a VDP stack string
: VTYPE   ( vdp_addr len -- ) BOUNDS ?DO   I VC@ EMIT   LOOP ;

\ Compile a VDP string, that types itself.
\ ### Overides regular ." word ###
: ."   ( <text> )
        ?COMP                 \ for compiling only
\ Do these compile time actions "immediately"
        VHERE [CHAR] " PARSE VS,

\ later, when we run the word, do these things
        POSTPONE LITERAL
        POSTPONE VCOUNT
        POSTPONE VTYPE ; IMMEDIATE

\ DEMO
\ : .MSG1  CR ." This text is stored in VDP RAM" ;        

\ : TEST  100 0 DO  .MSG1  LOOP ;

