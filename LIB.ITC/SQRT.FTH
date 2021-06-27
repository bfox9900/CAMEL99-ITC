\ integer square root in Forth.  Not too fast but small

\ *WARNING* The 16 bit limit is:  65000 SQRT . 254

: SQRT ( n -- n ) -1 TUCK DO   2+  DUP +LOOP   2/ ;

\ Demo version To see the operation
\ NEEDS .S FROM DSK1.TOOLS
\ : SQRT ( n -- n )
\      -1 TUCK   ( -- -1  n -1)
\      DO        \ count from n downto -1
\                ( n --) \ initial value = -1
\        2+      ( inc n by 2)
\        CR  .S  ( show the stack)
\      250 MS    ( wait 1/4 sec.)
\      DUP +LOOP ( step the loop by n on stack )
\      2/ ;      ( divide result by 2)
