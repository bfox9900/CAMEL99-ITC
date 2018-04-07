\ BREAK    simple word to exit a program to Forth

\ you can put this word in any loop and stop it 
\ by pressing FNCT 4 (BREAK)
\ ?TERMINAL is in TI ROM so it's 6 times faster than KEY? 
\ so Program runs quicker while scanning for the break key.

: ?BREAK   ?TERMINAL ABORT" *BREAK*"  ;