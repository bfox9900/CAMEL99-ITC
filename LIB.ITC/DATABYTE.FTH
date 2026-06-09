\ databyte.fth  multi-memory version     Sept 2022 B Fox
\ DATA and BYTE directive with comma delimiting
\ directable to RAM or VDP with directives
\ June 2026: Added ?HEX to interpret TI hex number form

NEEDS DEFER  FROM DSK1.DEFER
NEEDS V,     FROM DSK1.VDPMEM

DEFER BYTE,
DEFER WORD,
DEFER ?HEX

DECIMAL
: RAM    ['] C,  IS BYTE,   ['] ,   IS WORD, ;
: VDP    ['] VC, IS BYTE,   ['] V,  IS WORD, ;

HEX
: BYTE ( -- )
      BEGIN
         [CHAR] , PARSE-WORD  DUP
      WHILE
         ?HEX
         EVALUATE  DUP FF00 AND  ABORT" Not a byte"
         BYTE,
      REPEAT
      2DROP ;

: DATA ( -- )
      BEGIN
         [CHAR] , PARSE-WORD  DUP
      WHILE
         ?HEX
         EVALUATE WORD,
      REPEAT
      2DROP ;

: >HEX   ( addr len -- addr len)
      OVER C@ [CHAR] >  =
      IF    1 /STRING  HEX
      ELSE  DECIMAL
      THEN ;

: TI-HEX       ['] >HEX IS ?HEX ;
: FORTH-HEX    ['] PAUSE IS ?HEX ; \ ie: noop

\ defaults:
RAM       \ compile data into RAM
FORTH-HEX \ explict radix required

\ Usage:
\ TI-HEX
\ VDP DATA >DEAD,>BEEF,>AABB,0123
\ RAM DATA 0001,2200,3300,>ABBA

( this aborts on 'BEEF'. Not a BYTE)
\ VDP BYTE 00,01,02,03,>FF,>BEEF
