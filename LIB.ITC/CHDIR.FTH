\ path control ...

: CHDIR  ( <path> )  PARSE-NAME 2DUP ?DOT TOUPPER $HOME PLACE ;
\ USAGE: CHDIR DSK3.

: +PATH  ( $ u -- $' u' )
    $HOME COUNT DUP 0= ABORT" Path not set"
    PAD PLACE   PAD +PLACE  PAD COUNT ;

: -PATH  ( $ u -- $ u ?)  2DUP [CHAR] . SCAN NIP 0= ;

: MAKE-PATH ( $ u -- $' u') -PATH IF +PATH THEN ;

\ SMART include
: INCLUDED  MAKE-PATH  INCLUDED ;
: INCLUDE   PARSE-NAME INCLUDED ;
