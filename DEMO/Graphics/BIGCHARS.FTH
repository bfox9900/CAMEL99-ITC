\ BIG chars from GROM with no Assembler
\ this program reads the character shapes from Graphics ROM (GROM)
\ that are used in the TI-99 title screen.

INCLUDE DSK1.GRAFIX
INCLUDE DSK1.CHARSET    \ sets BIG caps or standard charset

HEX
: BIGCAPS  ( -- ) 4B4 900 200 GVMOVE ;  \ TI title page fonts

DECIMAL
: (c)   10 EMIT ;

: .TITLE
        8  9 AT-XY    ." TEXAS INSTRUMENTS"
       10 11 AT-XY       ." HOME COMPUTER"
        2 16 AT-XY     ." READY-PRESS ANY KEY TO BEGIN"
        4 22 AT-XY (c) ." 1981  TEXAS INSTRUMENTS"

        0 0 AT-XY ." Press FCTN 4 to exit"  ;

: TEST
        GRAPHICS .TITLE
        BEGIN
          BIGCAPS
          250 MS
          CHARSET
          ?TERMINAL
        UNTIL ;


