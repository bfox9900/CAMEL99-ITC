\ vectored I/O Version 2.1.F or higher
HEX
NEEDS TTYEMIT FROM DSK1.9902GOOD
NEEDS 'EMIT   FROM DSK1.VECTORIO

\ VT100 CONTROL
DECIMAL
: .PARM   ( n -- ) BASE @ SWAP DECIMAL U. BASE ! ;
: \ESC    ( -- )   27 EMIT ." [" ;
: \PARM   ( c -- ) \ESC .PARM ;
: <UP>    ( -- )   \PARM ." A" ;
: <DOWN>  ( -- )   \PARM ." B" ;
: <RIGHT> ( -- )   \PARM ." C" ;
: <BACK>  ( -- )   \PARM ." D" ;
: <HOME>  ( -- )   \ESC  ." F" ;
: <CLS>   ( -- )   \ESC  ." 2J" ;
: <CLRLN> ( -- )   \ESC  ." K" ;

: AT-XY  ( col row --) 2DUP AT-XY  \ESC .PARM ." ;" .PARM ." H" ;
: TTYCLS ( -- ) <CLS>  <HOME> ;

\ re-vector I/O operations to use TTY
: TTY/1 ( -- )
        ['] TTYEMIT  'EMIT !   \ output a char
        ['] TTYCR    'CR   !
        ['] TTYKEY   'KEY  !   \ wait for a char
        ['] TTY?     'KEY? !   \ test for a char and return a flag
        ['] TTYCLS   'PAGE !
        RS232 SOURCE-ID !       \ indicate we are on RS232 RS232
        CR ." Camel99 Forth"  CR ;

: >TTY  ['] TTYEMIT  'EMIT ! ;  
