\ inline directive and tester

20 CONSTANT InBit

: INLINED    ( -- )
                LATEST @ 1- DUP C@        \ read the precedence field
                InBit OR                  \ set the INLINE bit ( 20 )
                OVER C! ;                 \ store back in the precedence field

: INLINE?   ( nfa -- ?)
             C@ InBit and 0> ;            \ test if a TARGET word is immediate
