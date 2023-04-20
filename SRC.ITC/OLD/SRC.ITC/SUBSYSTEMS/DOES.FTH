\ D O E S   S U P P O R T
: (;CODE) ( -- )  R> LATEST @ NFA>CFA !  ;

\ 06A0 = BL   0460 = B
: DOES>    ( -- )
           COMPILE (;CODE)
           06A0 COMPILE,  PFA' DODOES COMPILE,   \ compiles: BL @DODOES
           ; XIMMEDIATE
