\ TI LOGO read from GROM memory
INCLUDE DSK1.GRAFIX.F
INCLUDE DSK1.CHARSET.F

CR ." Loading LOGO from GROM to VDP"
\    GROM     VDP     9 patterns
\   ------  -------   ----------
  HEX 950   11 ]PDT      9 8*  GVMOVE  \ GROM->VDP move

: TI.LOGO ( -- )
        CR 11 EMIT 12 EMIT 13 EMIT
        CR 14 EMIT 15 EMIT 16 EMIT
        CR 17 EMIT 18 EMIT 19 EMIT ; 

CR CR  TI.LOGO CR

