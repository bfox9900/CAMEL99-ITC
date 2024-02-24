\ FOR NEXT  demonstration  No real advantage over DO LOOP on 9900 CPU

INCLUDE DSK1.TOOLS        \ debugging tool
INCLUDE DSK1.ASM9900
INCLUDE DSK1.ELAPSE       \ used for timing

CODE  <NEXT>
       *RP DEC,                 \ decr top of R-stack
        OC IF,
            *IP IP ADD,          \ add offset (+ or -) to current IP
             NEXT,
        ENDIF,
\ EXIT the loop
        IP INCT,                  \ move IP past the offset parameter
        RP INCT,                  \ remove loop counter from Rstack
        NEXT,
        ENDCODE

: NEXT      POSTPONE <NEXT> <BACK ; IMMEDIATE

: FOR    ( n -- ) ?COMP  POSTPONE >R HERE ; IMMEDIATE
: NEXT   ( -- )   POSTPONE <NEXT> HERE - , ;   IMMEDIATE

HEX
: FORTEST  FFFF FOR NEXT ;   \ 3.26 
: DOTEST   FFFF 0 DO LOOP ;  \ 3.31

: FORTEST2  400  FOR  R@ .  NEXT ; \ 12.03
: DOTEST2   400 0 DO  I .   LOOP ; \ 12.03 

\ ELAPSE FORTEST
\ ELAPSE DOTEST
