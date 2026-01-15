\ databyte.fth  multi-memory version     Sept 2022 B Fox
\ DATA and BYTE directive with comma delimiting
\ directable to RAM or VDP with directives

\ Usage:
\ HEX
\ VDP DATA DEAD,BEEF,AABB
\ RAM DATA 0001,2200,3300,4440
\ VDP BYTE 00,01,02,03,FF,BEEF  (aborts on 'BEEF')

INCLUDE DSK1.DEFER
INCLUDE DSK1.VDPMEM

DEFER BYTE,
DEFER WORD,

: RAM    ['] C,  IS BYTE,   ['] ,   IS WORD, ;
: VDP    ['] VC, IS BYTE,   ['] V,  IS WORD, ;

\ Delimiter can now be changed
VARIABLE DELIMITER   CHAR ,  DELIMITER !

HEX
: BYTE ( -- )
         BEGIN
           DELIMITER @ PARSE-WORD  DUP
         WHILE
            EVALUATE  DUP FF00 AND  ABORT" Not a byte"
            BYTE,
         REPEAT
         2DROP ;

: DATA ( -- )
         BEGIN
            DELIMITER @ PARSE-WORD  DUP
         WHILE
            EVALUATE WORD,
         REPEAT
         2DROP ;
