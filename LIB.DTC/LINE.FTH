\ Recursive line drawing in Forth by Dr. C.H. Ting
\ Not real fast but clever and small

INCLUDE DSK1.TOOLS

: PLOT   ( y x -- ) >VPOS [CHAR] * SWAP VC! ;

: 2ROT   ( d1 d2 d3 -- d2 d3 d1) 2>R 2SWAP 2R> 2SWAP ;

: 2OVER  ( d1 d2 -- d1 d2 d1) 2>R 2DUP  2R> 2SWAP ;

: LDRAW ( x1 y1 x1 x2 -- )
        2OVER 2OVER      \ perform a '4DUP'
        ROT - ABS        \ calc ABS(y2-y1)
       -ROT ABS          \ calc ABS(x2-x1)
        MAX 2 <          \ within 1 pixel?
        IF
           ( y x ) PLOT
        ELSE
           2OVER 2OVER
           ROT + 1+ 2/ >R
           + 1+ 2/ R>
           2DUP 2ROT
           RECURSE RECURSE \ draw each of the two segments
        THEN
;

DECIMAL


