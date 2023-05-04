CR .( VT100+.FTH  extended terminal control)

NEEDS <##> FROM DSK1.VT100

DECIMAL
: <RESETVT100> ( -- ) <ESC> [CHAR] c EMIT ; \ reset the terminal

\ More VT100 terminal controls
: <SCROLLALL>  ( -- ) <ESC>[ ." r" ; \ Enable scrolling for entire display.

\ Enable scrolling from row {start} to row {end}.
: <SCROLLROWS> ( rstart rend-- ) SWAP <ESC>[ <##> ." ;" <##> ." r" ;
: <SCROLLDOWN> ( -- ) <ESC> ." D" ; \ Scroll display down one line.
: <SCROLLUP>   ( -- ) <ESC> ." M" ; \ Scroll display up one line.

\ Erasing Text
: <ERASERIGHT>     <ESC>[ ." K"  ;  \ Erase from cursor to end of line
: <ERASELEFT>      <ESC>[ ." 1K" ;  \ Erase from Cursor to start of line
: <ERASELINE>      <ESC>[ ." 2K" ;  \ Erases the entire current line
: <ERASEDOWN>      <ESC>[ ." J"  ;  \ Erases screen from current line down
: <ERASEUP>        <ESC>[ ." 1J" ;  \ Erases screen from current line up
