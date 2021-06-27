\ part of Core ANS Forth

: 2OVER  ( d d2 - d d2 d)  2>R 2DUP  2R> 2SWAP ; \ slow
\ : 2OVER  ( d d2 -- d d2 d) 3 PICK 3 PICK ; \ 20% faster
\ INCLUDE DSK1.3RD4TH
\ : 2OVER  ( d d2 -- d d2 d)  4TH 4TH ;      \ 60% faster!

\ DSK1.DOUBLE has a machine code version
