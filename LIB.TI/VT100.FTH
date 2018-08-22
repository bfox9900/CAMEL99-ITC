


DECIMAL
: .PARM
        BASE @ SWAP DECIMAL U. BASE ! ;

: \ESC     27 EMIT ." [" ;

: \PARM  \ESC .PARM ;

: <UP>     \PARM ." A" ;

: <DOWN>   \PARM ." B" ;

: <RIGHT>  \PARM ." C" ;

: <BACK>   \PARM ." D" ;

: <HOME>      \ESC  ." F" ;

: <CLS>       \ESC  ." 2J" ;

: <CLRLN>     \ESC  ." K" ;

: AT-XY   SWAP \ESC .PARM ." ;" .PARM ." H" ;

: PAGE   <CLS>  <HOME> ;

