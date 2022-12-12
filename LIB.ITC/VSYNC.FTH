\ vsync.fth  adapted from code by @PeteE on Atariage.com   12JUL2022

NEEDS MOV, FROM DSK1.LOWTOOLS

HEX
\ 8802 CONSTANT VDPSTA

CODE VSYNC  ( -- )
      R12 RPUSH,
      R12 CLR,             \ CRU Address bit 0002 - VDP INT
      BEGIN,
        2 TB,              \ CRU bit 2 - VDP INT
      EQ UNTIL,            \ Loop until set
      8802 @@ R12 MOVB,    \ Clear interrupt flag manually since we polled CRU
      R12 RPOP,
      NEXT,
      ENDCODE

DETACH
