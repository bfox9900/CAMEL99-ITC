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

: FOR    ( n -- ) ?COMP  POSTPONE >R HERE ; IMMEDIATE
: NEXT   ( -- )   POSTPONE <NEXT> HERE - , ;   IMMEDIATE

HEX
: FORTEST  FFFF FOR NEXT ;   \ 3.26 
: DOTEST   FFFF 0 DO LOOP ;  \ 3.31 

DECIMAL 
: FORTEST2  32000  FOR  R@ DROP  NEXT ; \ 4.33
: DOTEST2   32000 0 DO  I  DROP  LOOP ; \ 4.71  

\ ELAPSE FORTEST
\ ELAPSE DOTEST
\ ETC...
