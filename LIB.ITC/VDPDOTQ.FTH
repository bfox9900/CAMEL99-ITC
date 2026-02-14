\ VDP do     quote OVERRIDES ."
\ Replaces ." so that it compiles literal strings in VDP RAM.
\ Also adds PRINT." which is like BASIC print with leading CR

NEEDS VC, FROM DSK1.VDPMEM

\ compile stack string into VDP memory
: VS,     ( $adr len-- )  VHERE OVER CHAR+  VALLOT VPLACE ;

\ Print a VDP stack string
: VDPTYPE   ( vdp_addr len -- ) BOUNDS ?DO  I VC@ (EMIT)  LOOP ;
: .V$   ( Vaddr -- ) VCOUNT VDPTYPE ;

\ text strings will now be stored in VDP RAM
VARIABLE STR#   \ easiest to just use variable

: "     [CHAR] " PARSE VS,  STR# 1+!  ; \ compile string, bump counter

\ VDP dot quote OVERRIDES ."
\ Replaces ." so that it compiles literal strings in VDP RAM.
\ Also adds PRINT" which is like BASIC print with leading CR

\ Compile a VDP string, that types itself. Overrides regular ." word
: ."   ( <tex> )
    ?COMP  VHERE "   POSTPONE LITERAL  POSTPONE .V$ ; IMMEDIATE

: PRINT."  POSTPONE CR  POSTPONE ." ; IMMEDIATE
: AT" ( x y -- ) POSTPONE AT-XY  POSTPONE ."  ; IMMEDIATE

CR
CR .( ***  ."  HAS BEEN REPLACED *** )
CR
