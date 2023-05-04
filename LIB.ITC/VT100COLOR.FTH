CR .( VT100COLR.FTH Display Attribute control BJF May 2020 )
NEEDS <##>  FROM DSK1.VT100
DECIMAL
0 CONSTANT BLK   1 CONSTANT RED  2 CONSTANT GRN
3 CONSTANT YEL   4 CONSTANT BLU  5 CONSTANT MAG
6 CONSTANT CYN   7 CONSTANT WHT
: <ATTRIB>   ( n -- )  <ESC>[ <##> ." m" ;
\ Usage:  BLK <FG> CYN <BG>
: <FG>  ( color -- )  30 + <ATTRIB> ;
: <BG>  ( color -- )  40 + <ATTRIB> ;
\ attributes
: <DEFAULT>    0 <ATTRIB> ;  : <BRIGHT>     1 <ATTRIB> ;
: <DIM>        2 <ATTRIB> ;  : <UNDERSCORE> 4 <ATTRIB> ;
: <BLINK>      5 <ATTRIB> ;  : <REVERSE>    7 <ATTRIB> ;
: <HIDDEN>     8 <ATTRIB> ;
