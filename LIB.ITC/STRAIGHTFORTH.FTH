\ STRAIGHT in Forth. Rcv bytes into buffer, no echo. bjf Feb 2020
\ re-write with ISO WHILE loops Jul 2022
HERE

DECIMAL
: TIMEKEY ( wait-time -- c ?)  \ 1000 ~= 1000mS on TI-99
\ waits for a key until counter hits zero
      BEGIN 1-    \ decrement wait-time
        DUP WHILE ( wait-time > 0 )
        KEY?
        ?DUP
      UNTIL
      ( -- cntr key)
      NIP        \ key was detected, remove the counter

      THEN       \ timer elaped before key pressed.
      DUP 0>     \ add the true/false flag
;

: STRAIGHT ( addr len -- addr len)
       BOUNDS TUCK  ( -- start end start )
       KEY OVER C! 1+  \ wait & store 1st key, bump address
       BEGIN 2DUP >    WHILE ( end>start) \ continue else jump to THEN
          1000 TIMEKEY WHILE ( key<>0)
          OVER C! 1+   \ store & bump address
       REPEAT          \ and keep going
       THEN            \ jump out point. resolves 1st WHILE
       DROP OVER -     \ compute the length
;

HERE SWAP - SPACE DECIMAL . .( bytes)
