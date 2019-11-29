\ VDP dot quote OVERRIDES ."
\ Replaces ." so that it compiles literal strings in VDP RAM.
\ Also adds PRINT." which is like BASIC print with leading CR

INCLUDE DSK1.VDPMEM

\ ====================================================
\ VDP string support
\ compile stack string into VDP memory
: VS,     ( $adr len-- )  VHERE OVER CHAR+  VALLOT VPLACE ;

\ convert a VDP counted string to a stack string (in DSK1.VDPMEM)
\ : VCOUNT  ( vdp$adr -- vdpadr len ) DUP 1+ SWAP VC@ ;

\ Print a VDP stack string
: VDPTYPE   ( vdp_addr len -- ) BOUNDS ?DO   I VC@ (EMIT)  LOOP ;

\ Compile a VDP string, that types itself. Overides regular ." word
: ."   ( <tex> )
        ?COMP                 \ Abort if not compiling
\ Do these compile time actions "immediately"
        VHERE [CHAR] " PARSE VS,

\ later.. when we run the word, do these things
        POSTPONE LITERAL
        POSTPONE VCOUNT
        POSTPONE VDPTYPE ; IMMEDIATE

: PRINT."  POSTPONE CR  POSTPONE ." ; IMMEDIATE
CR
CR .( ***  ."  HAS BEEN REPLACED *** )
CR
