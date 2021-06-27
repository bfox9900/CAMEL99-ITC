\ ?BREAK   word to exit a program to Forth        2018 Brian Fox
\ ?TERMINAL is in TI ROM and smaller code so it's faster than KEY?
\ Put this word anywhere you want to test for the break key FNCT 4 (BREAK)

: ?BREAK    ( -- )  ?TERMINAL ABORT" *BREAK*" ;
