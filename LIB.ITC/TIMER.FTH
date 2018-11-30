\ simple down counting timer

HEX
CODE 1-!@  ( variable -- n) 
           0614 ,  \ *TOS DEC,
           C114 ,  \ *TOS TOS MOV,  ( fetch)
           NEXT,
           ENDCODE

: TIMER:
\                -iadr-  -tadr-
          CREATE ( n) ,    0 ,

          DOES>  DUP CELL+  ( -- iadr tadr)
                 DUP @      ( -- iadr tadr t)
                 IF   1-!@ NIP          \ decr. timer
                 ELSE SWAP @ OVER ! @   \ re-load the timer
                 THEN ;

