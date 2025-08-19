\ TI LOGO read from GROM memory
INCLUDE DSK1.GRAFIX
INCLUDE DSK1.CHARSET

( Loading LOGO from GROM to VDP )
\    GROM     VDP     9 patterns
\   ------  -------   ----------
  HEX 950    11 ]PDT   9 8*  GVMOVE   \ GROM->VDP move

: TI.LOGO ( -- )
        CR 11 EMIT 12 EMIT 13 EMIT ."  CAMEL99 Forth"
        CR 14 EMIT 15 EMIT 16 EMIT
        CR 17 EMIT 18 EMIT 19 EMIT
        CR CR ;

PAGE TI.LOGO
