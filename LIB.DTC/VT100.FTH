CR .( VT100 terminal control)
DECIMAL
\ type a number in base 10, with no space
: <ARG>   ( n -- )
           BASE @ >R  
           0 <#  DECIMAL #S  #> TYPE 
           R> BASE ! ;

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
: AT-XY   ( col row --) 
          2DUP VROW 2!
          SWAP <ESC>[ <ARG> ." ;" <ARG> ." f" ;

: TTYPAGE ( -- ) <CLS>  <HOME> ;

CR .( Set PAGE vector for VT100)
' TTYPAGE  'PAGE !
