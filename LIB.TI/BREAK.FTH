\ BREAK    simple word to exit a program to Forth

\ you can put this word in any loop and stop it 
\ by pressing FNCT 4 (BREAK)
\ ?TERMINAL is in TI ROM and smaller code so it's faster than KEY?
\ so Program runs quicker while scanning for the break key.

\ ABORT if function 4 is pressed
: ?BREAK    ( -- )
	    ?TERMINAL
            IF 
              BEGIN PAUSE ?TERMINAL 0= UNTIL
              CR ." *BREAK*" ABORT
            THEN ;
