\ BIG chars from GROM with no Assembler
\ this program reads the LARGE FONT from Graphics ROM (GROM)
\ and the character patterns for the TI-LOGO
\ that are used in the TI-99 title screen.

INCLUDE DSK1.GRAFIX
INCLUDE DSK1.CHARSET    \ to get us BIG caps and TI-LOGO
INCLUDE DSK1.VTYPE      \ fast printing to screen

HERE
\ named colors for Graphics programs
: ENUM  ( 0 <text> -- n) DUP CONSTANT  1+ ;

1 ENUM TRANS   ENUM BLACK   ENUM MEDGRN ENUM LTGRN
  ENUM DKBLU   ENUM LTBLU   ENUM DKRED  ENUM CYAN
  ENUM MEDRED  ENUM LTRED   ENUM DKYEL  ENUM LTYEL
  ENUM DKGRN   ENUM MAGENTA ENUM GRAY   ENUM WHITE
DROP

HEX
CREATE BLK  FFFF , FFFF , FFFF , FFFF ,

: DEF-BLOCK ( char -- char ) BLK OVER CHARDEF ;

DECIMAL
: DEF-BLOCKS
    128 DEF-BLOCK    8 + DEF-BLOCK   8 + DEF-BLOCK
    8 + DEF-BLOCK    8 + DEF-BLOCK   8 + DEF-BLOCK
    8 + DEF-BLOCK    8 + DEF-BLOCK   8 + DEF-BLOCK
    8 + DEF-BLOCK    8 + DEF-BLOCK   8 + DEF-BLOCK
    8 + DEF-BLOCK    8 + DEF-BLOCK   8 + DEF-BLOCK
    8 + DEF-BLOCK
    DROP
;

: FG-COLOR ( C -- ) 1 COLOR ;
: NEXTSET#  ( n -- n') 8 + DUP SET# ;

: SET-COLORS
  128 DUP
  SET#     DKRED FG-COLOR
  NEXTSET# LTGRN FG-COLOR
  NEXTSET# BLACK FG-COLOR
  NEXTSET# LTYEL FG-COLOR
  NEXTSET# DKGRN FG-COLOR
  NEXTSET# MAGENTA FG-COLOR
  NEXTSET# WHITE FG-COLOR
  NEXTSET# DKBLU FG-COLOR
  NEXTSET# MEDGRN FG-COLOR
  NEXTSET# MAGENTA FG-COLOR
  NEXTSET# MEDRED FG-COLOR
  NEXTSET# GRAY  FG-COLOR
  NEXTSET# LTBLU FG-COLOR
  NEXTSET# LTRED FG-COLOR
  NEXTSET# DKYEL FG-COLOR
  NEXTSET# DKRED FG-COLOR
  DROP
;

HEX
\ Load TI title page font from GROM to VDP
: BIGCAPS  ( -- ) 4B4  BL ]PDT  200 GVMOVE ;

DECIMAL
: (c)   10 EMIT ;

\ TI LOGO chars as 3 byte strings
CREATE LOGO
    1 C, 2 C, 3 C,
    4 C, 5 C, 6 C,
    7 C, 8 C, 9 C,

: TI.LOGO ( -- )
  [ HEX ]
( Load LOGO from GROM to VDP pattern table at character #1)
\    GROM     VDP     9 patterns
\   ------  -------   ----------
     950     1 ]PDT   9 8*  GVMOVE   \ GROM->VDP move
  [ DECIMAL ]
    14 5 AT-XY   LOGO      3 VTYPE
    14 6 AT-XY   LOGO 3 +  3 VTYPE
    14 7 AT-XY   LOGO 6 +  3 VTYPE
;

: .TITLE
     8  9 AT" TEXAS INSTRUMENTS"
    10 11 AT" HOME COMPUTER"
    10 13 AT" CAMEL99 FORTH"
     2 15 AT" READY-PRESS ANY KEY TO BEGIN"
;

\ take byte. make into 2 bytes, compile 2 bytes and add 8
: 2bytes, ( c -- c' )  DUP  DUP FUSE ,  8 + ;

\ create a string of chars for 1 line of the color bar
CREATE BAR$
  128   ( 1st character)
  2bytes, 2bytes, 2bytes, 2bytes, 2bytes, 2bytes, 2bytes, 2bytes,
  2bytes, 2bytes, 2bytes, 2bytes, 2bytes, 2bytes, 2bytes, 2bytes,
  DROP

: .BAR    ( -- )  BAR$ 32 VTYPE ; \ draw single line of colored blocks
: .BANNER ( -- ) .BAR CR .BAR CR .BAR ; \ draw 3 lines

: VC+!  ( n Vaddr) DUP>R VC@ +   R> VC! ;

HEX
: KALEIDOSCOPE
   10 ]CTAB 10
   BOUNDS
   DO
      10 I VC+!
      65 TICKS
   LOOP
;

DECIMAL
: TITLEPAGE
    GRAPHICS
    CYAN SCREEN
    BIGCAPS  DEF-BLOCKS SET-COLORS
    PAGE
    .BANNER
    TI.LOGO
    .TITLE
    CR CR  .BANNER
    7 22 AT-XY (c) S"  2026 BRIAN FOX" VTYPE
    2000 MS
    BEGIN KALEIDOSCOPE KEY? UNTIL
    TEXT CHARSET
;

DECIMAL
HERE SWAP - . .( bytes)
