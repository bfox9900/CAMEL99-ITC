\ Set Attribute Mode <ESC>[{attr1};...;{attrn}m
\ Sets multiple display attribute settings.
\ The following lists standard attributes:

NEEDS <ARG> FROM DSK1.VT100

0 CONSTANT RESET
1 CONSTANT BRIGHT
2 CONSTANT DIM
4 CONSTANT UNDERSCORE
5 CONSTANT BLINK
7 CONSTANT REVERSE
8 CONSTANT HIDDEN

DECIMAL
\ colour modifiers
: FG>  ( n -- n') 30 + ;
: BG>  ( n -- n') 40 + ;

\  Colours  MUST be used with FG>  BG>
\ Usage:  <BLK FG> <CYN BG> <COLOR>
0 CONSTANT <BLK
1 CONSTANT <RED
2 CONSTANT <GRN
3 CONSTANT <YEL
4 CONSTANT <BLU
5 CONSTANT <MAG
6 CONSTANT <CYN
7 CONSTANT <WHT

: <COLOR>  ( fg bg -- ) <ESC>[ <ARG> ." ;" <ARG> ." m"  ;
: <ATTRIB>  ( n -- ) <ESC>[ <ARG> ." ;m"   ;
