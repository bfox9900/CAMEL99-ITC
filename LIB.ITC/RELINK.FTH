\ relink.fth  removes words from dictionary    Mar 22, 2022

: RELINK  ( <word1> <word2> ) \ relink any two words
         '     '
        2DUP < ABORT" Backwards RELINK"
        CFA>NFA ( CFA1 nfa2 )
        SWAP CFA>LFA ( nfa2 lfa1 ) ! ;
