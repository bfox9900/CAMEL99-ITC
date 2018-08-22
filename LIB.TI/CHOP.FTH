\ CHOP.FTH  chop a string in two, leaving both parts on the stack

\ S" AAAABBBBCCCCDDDD" 4 CHOP  ( -- addr len addr' len')

\ results:
\ TYPE BBBBCCCCDDDD
\ TYPE AAAA
\                         left$    right$
\                        -------- --------
: /CHOP  ( addr len n -- addr len addr len )
        >R
        2DUP DROP R@        \ LEFT$
        2SWAP R> /STRING ;  \ remainder

