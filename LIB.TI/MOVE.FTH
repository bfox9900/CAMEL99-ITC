\ MOVE ANS Forth word

: MOVE    ( src dst n -- )
          >R  2DUP SWAP DUP R@ +  \ -- src dst dst src src+n
          WITHIN
          IF    R> CMOVE>         \ src <= dst < src+n
          ELSE  R> CMOVE  
          THEN ;  
