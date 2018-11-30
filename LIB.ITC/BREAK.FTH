\ BREAK    simple word to exit a program to Forth

\ Changed to work with V2.1.E

\ you can put this word in any loop and stop it 
\ by pressing FNCT 4 (BREAK)
\ ?TERMINAL is in TI ROM and smaller code so it's faster than KEY?
\ so Program runs quicker while scanning for the break key.

: ?BREAK    ( -- )  ?TERMINAL ABORT" *BREAK*" ;
