\ FOR NEXT  demonstration  Small advantage over DO LOOP on 9900 CPU

NEEDS .S        FROM DSK1.TOOLS        \ debugging tool
NEEDS MOV,      FROM DSK1.ASM9900
NEEDS ELAPSE    FROM DSK1.ELAPSE       \ used for timing

 CODE  <NEXT>
       *RP DEC,                  \ decr top of R-stack
        OC IF,
\ Jump back 
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
