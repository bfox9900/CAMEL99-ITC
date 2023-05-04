CR .( VT100 terminal control, [0,0] Home coordinates  May 2020 )
DECIMAL
\ type 'n' as a two digit number in base 10, with no space
: <##>   ( n -- )
         BASE @ >R                   \ save radix
         0 <#  DECIMAL # #  #> TYPE  \ convert to 2 digits & print
         R> BASE ! ;                 \ restore radix

\ markup language for terminal control codes
\ : <ESC>   ( -- )   27 EMIT ;
: <ESC>[  ( -- )   27 EMIT  91 EMIT  ;
: <UP>    ( n -- ) <ESC>[ <##> ." A" ;
: <DOWN>  ( n -- ) <ESC>[ <##> ." B" ;
: <RIGHT> ( n -- ) <ESC>[ <##> ." C" ;
: <BACK>  ( n -- ) <ESC>[ <##> ." D" ;
: <HOME>  ( -- )   <ESC>[ ." H"   0 0 VROW 2! ;

\ define Forth words using markup words
: PAGE    ( n -- ) <ESC>[ ." 2J"  <HOME> ;
: AT-XY   ( col row --)
          2DUP VROW 2!  \ store col,row
          <ESC>[ 1+ <##> ." ;" 1+ <##> ." f" ;
