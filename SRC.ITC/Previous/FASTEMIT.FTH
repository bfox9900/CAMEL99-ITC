\ FAST EMIT  (needs IF CR THEN )
INCLUDE DSK1.ASM9900
INCLUDE DSK1.TOOLS

MARKER REMOVE
HEX
8C00 CONSTANT VDPWD
' V! 3 CELLS + @ CONSTANT WMODE

CODE <EMIT> ( c -- ? ) \ hi-speed repeating emit, tests for EOL
     TOS SWPB,
     TOS VDPWD @@ MOVB,  \ write c to screen
     TOS CLR,           \ set false flag
     34 R1 () INC,      \ bump VCOL
     34 R1 () 2E R1 () CMP,  \ compare VCOL >= C/L
     EQ IF,
        TOS SETO,      \ set true flag
     ENDIF,
     NEXT,
     ENDCODE

CODE VADDR!  ( addr -- )
             TOS R0 MOV,
             WMODE @@ BL,
             TOS POP,
             NEXT,
             ENDCODE

: TYPE   ( addr cnt -- )
         PAUSE VPOS VADDR!
         BOUNDS ?DO I C@  VDPDW C! VCOL 1+@  C/L@ >= IF CR THEN  LOOP ;

: TEST  1000 0 DO  S" This is a only a test. " TYPE
       ?TERMINAL ABORT" STOP"
       LOOP ;
