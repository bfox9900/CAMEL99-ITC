\ TIMES  re-execute a line of text in TIB (terminal input buffer) A. Nijhof
\ Ported to Camel Forth with minor changes (OFF)  brianfox
\ source: http://home.iae.nl/users/mhx/sf13/ec210c.html

VARIABLE #TIMES        \ Counter
: TIMES ( n -- )
  #TIMES @ 1+ TUCK    ( #times+1 n #times+1 )
  #TIMES OFF          \ Let's be careful. set to 0
  = ?TERMINAL OR      \ n-th time or BREAK key
  IF DROP EXIT THEN   \ We're through.
  #TIMES !            \ Increment counter..
  >IN OFF ;           \ reset interpreter pointer, re-interprets the line again

\ Example
\ BL <enter>  DUP EMIT 1+  96 TIMES DROP <enter>
