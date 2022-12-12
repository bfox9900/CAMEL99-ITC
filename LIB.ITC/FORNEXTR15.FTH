\ FOR NEXT  demonstration: 7% faster versus DO LOOP on 9900 CPU

INCLUDE DSK1.TOOLS        \ debugging tool
INCLUDE DSK1.ASM9900
INCLUDE DSK1.ELAPSE       \ used for timing

CODE <FOR>
       R15 RPUSH,
       TOS R15 MOV,
       TOS POP,
       NEXT,
       ENDCODE

CODE  <NEXT>
        R15 DEC,                  \ decr top of R-stack
        OC IF,
            *IP IP ADD,          \ add offset (+ or -) to current IP
             NEXT,
        ENDIF,
       \ EXIT the loop
        IP INCT,                  \ move IP past the offset parameter
        R15 RPOP,                 \ restore R15
        NEXT,
        ENDCODE

CODE X       TOS PUSH,   R15 TOS MOV,  NEXT, ENDCODE

: NEXT      POSTPONE <NEXT> <BACK ; IMMEDIATE

: FOR    ( n -- ) ?COMP  POSTPONE <FOR>  HERE ; IMMEDIATE
: NEXT   ( -- )   POSTPONE <NEXT> HERE - , ;   IMMEDIATE

HEX
: FORTEST  FFFF FOR NEXT ;   \ down count from FFFF to 0
: DOTEST   FFFF 0 DO LOOP ;

: FORTEST2  400  FOR  X .  NEXT ;
: DOTEST2   400 0 DO  I .  LOOP ;
: FTYPE    ( addr len --) 1- FOR COUNT (EMIT) NEXT DROP ;

: A$ S" NOW IS THE TIME FOR ALL GOOD MEN TO COME TO THE AID OF THEIR COUNTRY" ;

: DOPRINT  100 0 DO 0 0 AT-XY A$ TYPE LOOP ;  \ 7:15  !!! LOL
: FORPRINT 100 FOR 0 0 AT-XY A$ FTYPE  NEXT ; \ 8:13



\ ELAPSE FORTEST
\ ELAPSE DOTEST
\ ETC...
