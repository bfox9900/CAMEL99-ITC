\ part of Core ANS Forth

\ : 2OVER  ( d d2 - d d2 d)  2>R 2DUP  2R> 2SWAP ; ( normal implementation)

: 2OVER  ( d d2 -- d d2 d)  3 PICK 3 PICK ; \ 20% faster on 9900 by using indexed addressing
\ see: PICK in SRC/9900FAST.HSF
