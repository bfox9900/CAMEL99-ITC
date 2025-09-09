\ BIG chars from GROM with no Assembler
\ this program reads the character shapes from Graphics ROM (GROM)
\ that are used in the TI-99 title screen.

INCLUDE DSK1.GRAFIX
INCLUDE DSK1.CHARSET    \ sets BIG caps or standard charset

\ named colors for Graphics programs
: ENUM  ( 0 <text> -- n) DUP CONSTANT  1+ ;

1 ENUM TRANS    ENUM BLACK  ENUM MEDGRN ENUM LTGRN
  ENUM DKBLU    ENUM LTBLU  ENUM DKRED  ENUM CYAN
  ENUM MEDRED   ENUM LTRED  ENUM DKYEL  ENUM LTYEL
  ENUM DKGRN   ENUM MAGENTA ENUM GRAY   ENUM WHITE
DROP

HEX
CREATE BLK  FFFF , FFFF , FFFF , FFFF ,

: DEF-BLOCK ( char -- char ) BLK OVER CHARDEF ;

DECIMAL
: DEF-BLOCKS
    95  DEF-BLOCK
    8 + DEF-BLOCK
    8 + DEF-BLOCK
    8 + DEF-BLOCK
    8 + DEF-BLOCK
    8 + DEF-BLOCK
    8 + DEF-BLOCK
    8 + DEF-BLOCK
    8 + DEF-BLOCK
    8 + DEF-BLOCK
    8 + DEF-BLOCK
    8 + DEF-BLOCK
    8 + DEF-BLOCK
    8 + DEF-BLOCK
    8 + DEF-BLOCK
    8 + DEF-BLOCK
    DROP
;

: SET-COLORS
   95 SET# DUP
   DKRED 1 COLOR 1+ DUP
   LTGRN 1 COLOR 1+ DUP
   BLACK 1 COLOR 1+ DUP
   LTYEL 1 COLOR 1+ DUP
   DKGRN 1 COLOR 1+ DUP
 MAGENTA 1 COLOR 1+ DUP
   WHITE 1 COLOR 1+ DUP
   DKBLU 1 COLOR 1+ DUP
  MEDGRN 1 COLOR 1+ DUP
   LTRED 1 COLOR 1+ DUP
   GRAY  1 COLOR
   DROP
;

HEX
\ Load TI title page fonts from GROM
: BIGCAPS  ( -- ) 4B4 900 200 GVMOVE ;

DECIMAL
: (c)   10 EMIT ;

: TI.LOGO ( -- )
  [ HEX ]
( Load LOGO from GROM to VDP )
\    GROM     VDP     9 patterns
\   ------  -------   ----------
     950     1 ]PDT   9 8*  GVMOVE   \ GROM->VDP move
  [ DECIMAL ]
    14 5 AT-XY  1 (EMIT) 2 (EMIT) 3 (EMIT)
    14 6 AT-XY  4 (EMIT) 5 (EMIT) 6 (EMIT)
    14 7 AT-XY  7 (EMIT) 8 (EMIT) 9 (EMIT)
;

: .TITLE
     8  9 AT-XY     ." TEXAS INSTRUMENTS"
    10 11 AT-XY       ." HOME COMPUTER"
    10 13 AT-XY       ." CAMEL99 FORTH"
     2 16 AT-XY ." READY-PRESS ANY KEY TO BEGIN"
;

: .BAR  121 95 DO  I DUP EMIT EMIT  8 +LOOP ;

: .BANNER  .BAR CR .BAR CR .BAR  ;

\ : .CHARSET  256 0 DO I EMIT LOOP ;

: TITLEPAGE
    GRAPHICS
    CYAN SCREEN
    BIGCAPS DEF-BLOCKS SET-COLORS
    PAGE
    .BANNER
    TI.LOGO
    .TITLE
    CR
    .BANNER
     4 22 AT-XY (c) ." 2025" 3 SPACES ." BRIAN FOX"
    BEGIN
        ?TERMINAL
    UNTIL
    PAGE CHARSET
;

: TEST PAGE DEF-BLOCKS  SET-COLORS  .BAR .BAR .BAR ;
