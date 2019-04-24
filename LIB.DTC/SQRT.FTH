\ integer square root in Forth.  Not too fast but small

\ *WARNING* The 16 bit limit is:  65000 SQRT . 254

: SQRT ( n -- n ) -1 TUCK DO   2+ DUP  +LOOP   2/ ;


