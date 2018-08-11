\ ANSI Terminal control lexicon for VT100 etc..

DECIMAL

: .PARM ( n -- )
        BASE @ SWAP DECIMAL U. BASE ! ;  \ send n as DECIMAL text

: \ESC  ( -- )   27 EMIT ." [" ;   \ start control sequence
: \P    ( n -- ) \ESC .PARM ;      \ escape, send parm as text

: <XY> ( row col -- )              \ cursor position
        SWAP \ESC .PARM ." ;" .PARM ." H" ;

: <UP>    ( row --) \P   ." A" ;  \ cursor up
: <DOWN>  ( row --) \P   ." B" ;  \ cursor down
: <RIGHT> ( col --) \P   ." C" ;  \ cursor forward
: <BACK>  ( col --) \P   ." D" ;  \ cursor backward
: <HOME>  ( -- )    \ESC ." F" ;  \ cursor home
: <CLS>   ( -- )    \ESC ." 2J" ; \ erase display
: <CLRLN> ( -- )    \ESC ." K" ;  \ erase line
