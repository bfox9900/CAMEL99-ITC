\ VT100.FTH  For Camel99 Forth by Brian Fox 2019
\ License: Public Domain with no Warranty, neither explicit nor implied

CR .( VT100 terminal control)
DECIMAL
\ type un-signed number, base 10, with no space and restore previous radix
: <ARG>   ( n -- ) BASE @ >R   0 <# DECIMAL #S #> TYPE   R> BASE ! ;

\ markup language for terminal control codes
: <ESC>[  ( -- )   27 EMIT  91 EMIT  ;
: <UP>    ( n -- ) <ESC>[ <ARG> ." A" ;
: <DOWN>  ( n -- ) <ESC>[ <ARG> ." B" ;
: <RIGHT> ( n -- ) <ESC>[ <ARG> ." C" ;
: <BACK>  ( n -- ) <ESC>[ <ARG> ." D" ;
: <HOME>  ( -- )   <ESC>[ ." 0;0H" ;
: <CLS>   ( n -- ) <ESC>[ ." 2J" ;
: <CLRLN> ( -- )   <ESC>[ ." K" ;

\ redefine Forth words using markup words
: AT-XY   ( col row --) 2DUP VROW 2!   <ESC>[ <ARG> ." ;" <ARG> ." f" ;
: PAGE ( -- ) <CLS>  <HOME> ;

CR .( PAGE, AT-XY set for VT100)

