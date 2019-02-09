CR .( VT100 terminal control)
DECIMAL
: .#      ( n -- ) 0 <#  #S  #>  TYPE ;  ( type number with no space)
: <PARM>  ( n -- ) BASE @ >R  DECIMAL .#  R> BASE ! ; ( output decimal number)

\ create markup language for terminal control codes
: <ESC>[  ( -- )   27 EMIT  91 EMIT  ;
: \PARM   ( c -- ) <ESC>[ <PARM> ;
: <UP>    ( n -- ) \PARM ." A" ;
: <DOWN>  ( n -- ) \PARM ." B" ;
: <RIGHT> ( n -- ) \PARM ." C" ;
: <BACK>  ( n -- ) \PARM ." D" ;
: <HOME>  (  -- )  <ESC>[ ." 0;0H" ;
: <CLS>   ( n -- ) <ESC>[ ." 2J" ;
: <CLRLN> ( -- )   <ESC>[ ." K" ;

\ redefine Forth words using markup words
: AT-XY   ( col row --) SWAP <ESC>[ <PARM> ." ;" <PARM> ." f" ;
: VT100PAGE ( -- ) <CLS>  <HOME> ;

CR .( Set PAGE vector for VT100)
' VT100PAGE  'PAGE !
