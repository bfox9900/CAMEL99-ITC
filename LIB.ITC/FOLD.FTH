\ FOLD.FTH     for ANS Forth   Brian Fox 

\ Smart compilers do constant folding to pre-compute things
\ that will never change in a program. 

\ Simple Forth's are not very smart but the programmer can easily
\ do this manually with [  ]FOLD 

: ]FOLD    ]  POSTPONE LITERAL ; IMMEDIATE 

\ : NOFOLDTEST  10000 0 DO   99 1 + DROP   LOOP ; \ 2.16 secs

\ : FOLDTEST    10000 0 DO  [ 99 1 + ]FOLD  DROP  LOOP ; \ 1.31 secs