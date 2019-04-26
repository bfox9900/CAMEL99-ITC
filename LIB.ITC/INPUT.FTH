\ INPUT.FTH   creates input like BASIC
\ *Difference* there is a separate input for numbers and strings

DECIMAL
: $ACCEPT ( $addr -- ) CR ." ?  "  DUP  1+ 80 ACCEPT  SWAP C!  ;

: $INPUT  ( $addr -- ) BEEP $ACCEPT ;  \ BEEP like TI-BASIC

: #INPUT  ( variable -- )   \ made to look/work like TI-BASIC
          BEEP
          BEGIN
            PAD DUP $ACCEPT ?NUMBER 0=  \ convert the number in PAD
          WHILE              \ while the conversion is bad we do this
             CR HONK ." input error "
             CR DROP
          REPEAT
          SWAP ! ;     \ store the number in the variable on the stack)


\ Usage:

\ VARIABLE A$ 100 ALLOT      \ string variables need more space
\ VARIABLE X
\
\ A$ $INPUT

\ X  #INPUT